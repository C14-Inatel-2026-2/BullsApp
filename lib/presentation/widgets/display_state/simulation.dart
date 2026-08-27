/// Porte de simulation.dart a partir de DisplayState.jsx
/// Contém toda a lógica pura (sem UI): parsing de ações, física do robô,
/// geometria de tela. Espera receber `physics` e `state` já decodificados
/// de JSON (Map<String, dynamic>), exatamente como PHYSICS.json e uma
/// entrada de JOGADAS.json.
library simulation;

import 'dart:math' as math;

// ---------------------------------------------------------------------
// Helpers numéricos
// ---------------------------------------------------------------------

double degToRad(double deg) => deg * math.pi / 180;

double radToDeg(double rad) => rad * 180 / math.pi;

double normalizeAngleDeg(double angle) {
  var a = angle % 360;
  if (a > 180) a -= 360;
  if (a < -180) a += 360;
  return a;
}

double safeNumber(dynamic value, [double fallback = 0]) {
  if (value == null) return fallback;
  if (value is num) return value.toDouble();
  final n = num.tryParse(value.toString());
  return n?.toDouble() ?? fallback;
}

bool hasStartPosition(dynamic value) => value is Map;

/// Retorna `startPosition` resolvida a partir de:
/// prop explícita > lado (ladoEsc/ladoDir) > state.startPosition > null
Map<String, dynamic>? resolveStartPosition(
  Map<String, dynamic>? state,
  String side,
  Map<String, dynamic>? propStartPosition,
) {
  if (hasStartPosition(propStartPosition)) return propStartPosition;

  final sideMap = state?[side] as Map<String, dynamic>?;
  final sideStartPosition = sideMap?['startPosition'];
  if (hasStartPosition(sideStartPosition)) {
    return sideStartPosition as Map<String, dynamic>;
  }

  final stateStartPosition = state?['startPosition'];
  if (hasStartPosition(stateStartPosition)) {
    return stateStartPosition as Map<String, dynamic>;
  }

  return null;
}

bool isDesempateState(Map<String, dynamic>? state) {
  final category =
      (state?['category'] ?? state?['categoria'] ?? '').toString().trim().toUpperCase();
  return category == 'DESEMPATE';
}

class Pose {
  final double x;
  final double y;
  final double angle;

  const Pose({required this.x, required this.y, required this.angle});

  Pose copyWith({double? x, double? y, double? angle}) =>
      Pose(x: x ?? this.x, y: y ?? this.y, angle: angle ?? this.angle);
}

Pose getDefaultStartPosition(
  Map<String, dynamic> physics,
  Map<String, dynamic>? state,
) {
  final gap = safeNumber(physics['shikiriSenGapCm']);
  final width = safeNumber(physics['shikiriSenWidthCm']);

  return Pose(
    x: 0,
    y: -(gap / 2 + width + 15),
    angle: isDesempateState(state) ? -90 : 90,
  );
}

// ---------------------------------------------------------------------
// Parser de expressão aritmética simples (substitui o Function() do JS)
// Suporta: + - * / ( ) números e ponto decimal, unário -
// ---------------------------------------------------------------------

double _evalExpression(String expr) {
  final s = expr.replaceAll(' ', '');
  var pos = 0;

  late double Function() parseExpr;
  late double Function() parseTerm;
  late double Function() parseFactor;

  parseExpr = () {
    var value = parseTerm();
    while (pos < s.length && (s[pos] == '+' || s[pos] == '-')) {
      final op = s[pos];
      pos++;
      final rhs = parseTerm();
      value = op == '+' ? value + rhs : value - rhs;
    }
    return value;
  };

  parseTerm = () {
    var value = parseFactor();
    while (pos < s.length && (s[pos] == '*' || s[pos] == '/')) {
      final op = s[pos];
      pos++;
      final rhs = parseFactor();
      value = op == '*' ? value * rhs : value / rhs;
    }
    return value;
  };

  parseFactor = () {
    if (pos < s.length && s[pos] == '-') {
      pos++;
      return -parseFactor();
    }
    if (pos < s.length && s[pos] == '+') {
      pos++;
      return parseFactor();
    }
    if (pos < s.length && s[pos] == '(') {
      pos++;
      final value = parseExpr();
      if (pos < s.length && s[pos] == ')') pos++;
      return value;
    }
    final start = pos;
    while (pos < s.length && (_isDigit(s[pos]) || s[pos] == '.')) {
      pos++;
    }
    if (start == pos) return 0;
    return double.tryParse(s.substring(start, pos)) ?? 0;
  };

  try {
    if (s.isEmpty) return 0;
    return parseExpr();
  } catch (_) {
    return 0;
  }
}

bool _isDigit(String c) => c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57;

double parseMotorValue(String? raw, Map<String, dynamic> physics) {
  if (raw == null || raw.isEmpty) return 0;

  final maxTicks = safeNumber(physics['maxTicks']).toString();

  var value = raw
      .trim()
      .replaceAll('MAX_TICKS', maxTicks)
      .replaceAll('MAX', maxTicks);

  value = value.replaceAll(RegExp(r'[^0-9+\-*/(). ]'), '');

  final result = _evalExpression(value);
  return result.isFinite ? result : 0;
}

// ---------------------------------------------------------------------
// Ações
// ---------------------------------------------------------------------

enum ActionType { stub, motorL, motorR, delay, pid, next, unknown }

class ParsedAction {
  final ActionType type;
  final String raw;
  final String? value; // motorL / motorR
  final double ms; // delay
  final double deg; // pid
  final String? next; // next

  ParsedAction({
    required this.type,
    required this.raw,
    this.value,
    this.ms = 0,
    this.deg = 0,
    this.next,
  });
}

ParsedAction parseAction(String action) {
  final text = action.trim();

  if (text.isEmpty || text.startsWith('(')) {
    return ParsedAction(type: ActionType.stub, raw: text);
  }

  final parts = text.split(':');
  final key = parts.first;
  final value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

  if (key == 'motorL') {
    return ParsedAction(type: ActionType.motorL, raw: text, value: value);
  }
  if (key == 'motorR') {
    return ParsedAction(type: ActionType.motorR, raw: text, value: value);
  }
  if (key == 'delay') {
    return ParsedAction(type: ActionType.delay, raw: text, ms: safeNumber(value));
  }
  if (key == 'PID') {
    final clean = value.replaceAll(RegExp(r'[^\-0-9.]'), '');
    return ParsedAction(type: ActionType.pid, raw: text, deg: safeNumber(clean));
  }
  if (key == 'NEXT') {
    return ParsedAction(type: ActionType.next, raw: text, next: value);
  }

  return ParsedAction(type: ActionType.unknown, raw: text);
}

List<String> getActionsFromState(Map<String, dynamic>? state, String side) {
  if (state == null) return [];

  final sideMap = state[side] as Map<String, dynamic>?;
  if (sideMap != null && sideMap['actions'] != null) {
    return List<String>.from(sideMap['actions']);
  }

  if (state['actions'] != null) {
    return List<String>.from(state['actions']);
  }

  final ladoDir = state['ladoDir'] as Map<String, dynamic>?;
  if (ladoDir != null && ladoDir['actions'] != null) {
    return List<String>.from(ladoDir['actions']);
  }

  final ladoEsc = state['ladoEsc'] as Map<String, dynamic>?;
  if (ladoEsc != null && ladoEsc['actions'] != null) {
    return List<String>.from(ladoEsc['actions']);
  }

  return [];
}

String getNextFromActions(List<String> actions) {
  for (final a in actions) {
    final parsed = parseAction(a);
    if (parsed.type == ActionType.next) return parsed.next ?? 'sem NEXT';
  }
  return 'sem NEXT';
}

// ---------------------------------------------------------------------
// Física
// ---------------------------------------------------------------------

class _Smoothed {
  double vL = 0;
  double vR = 0;
}

Pose simulateLinearStep(
  Pose pose,
  double motorL,
  double motorR,
  double dtSec,
  Map<String, dynamic> physics,
  _Smoothed smoothed,
) {
  final maxTicks = safeNumber(physics['maxTicks']);
  final maxSpeed = safeNumber(physics['maxSpeedCmPerSec']);
  final wheelBase = safeNumber(physics['wheelBaseCm']);

  final targetVL = (motorL / maxTicks) * maxSpeed;
  final targetVR = (motorR / maxTicks) * maxSpeed;

  final smooth = safeNumber(physics['motorInertia']).clamp(0, 1);

  final vL = smoothed.vL + (targetVL - smoothed.vL) * (1 - smooth);
  final vR = smoothed.vR + (targetVR - smoothed.vR) * (1 - smooth);

  smoothed.vL = vL;
  smoothed.vR = vR;

  final v = (vL + vR) / 2;
  final omegaRad = (vR - vL) / wheelBase;

  final thetaRad = degToRad(pose.angle);

  var next = Pose(
    x: pose.x + math.cos(thetaRad) * v * dtSec,
    y: pose.y + math.sin(thetaRad) * v * dtSec,
    angle: normalizeAngleDeg(pose.angle + radToDeg(omegaRad * dtSec)),
  );

  if (physics['clampInsideDojo'] == true) {
    final innerDiam = safeNumber(physics['dojoInnerDiameterCm']);
    final robotW = safeNumber(physics['robotWidthCm']);
    final robotH = safeNumber(physics['robotHeightCm']);
    final radius = innerDiam / 2 - math.max(robotW, robotH) / 2;

    final dist = math.sqrt(next.x * next.x + next.y * next.y);
    if (dist > radius && dist > 0) {
      final k = radius / dist;
      next = next.copyWith(x: next.x * k, y: next.y * k);
    }
  }

  return next;
}

class Frame {
  final double t;
  final double x;
  final double y;
  final double angle;
  final String actionLabel;

  Frame({
    required this.t,
    required this.x,
    required this.y,
    required this.angle,
    required this.actionLabel,
  });
}

void _pushFrame(List<Frame> frames, Pose pose, double elapsedMs, String label) {
  frames.add(Frame(t: elapsedMs, x: pose.x, y: pose.y, angle: pose.angle, actionLabel: label));
}

class SimulationResult {
  final List<Frame> frames;
  final double durationMs;
  final Pose finalPose;
  final String next;

  SimulationResult({
    required this.frames,
    required this.durationMs,
    required this.finalPose,
    required this.next,
  });
}

SimulationResult simulateJogada({
  required List<String> actions,
  required Map<String, dynamic>? startPosition,
  required Map<String, dynamic> physics,
  required Map<String, dynamic>? state,
}) {
  final defaultStart = getDefaultStartPosition(physics, state);

  var pose = Pose(
    x: safeNumber(startPosition?['x'], defaultStart.x),
    y: safeNumber(startPosition?['y'], defaultStart.y),
    angle: safeNumber(startPosition?['angle'], defaultStart.angle),
  );

  double motorL = 0;
  double motorR = 0;
  double elapsedMs = 0;

  final frames = <Frame>[];
  final parsedActions = actions.map(parseAction).toList();
  final smoothed = _Smoothed();
  final dtMs = safeNumber(physics['dtMs'], 4);
  final pidDegPerSec = safeNumber(physics['pidDegPerSec'], 540);
  final pidSettleMs = safeNumber(physics['pidSettleMs'], 20);

  _pushFrame(frames, pose, elapsedMs, 'início');

  for (final action in parsedActions) {
    switch (action.type) {
      case ActionType.motorL:
        motorL = parseMotorValue(action.value, physics);
        _pushFrame(frames, pose, elapsedMs, action.raw);
        break;

      case ActionType.motorR:
        motorR = parseMotorValue(action.value, physics);
        _pushFrame(frames, pose, elapsedMs, action.raw);
        break;

      case ActionType.delay:
        {
          final duration = math.max(0, action.ms);
          final steps = math.max(1, (duration / dtMs).ceil());

          for (var i = 0; i < steps; i++) {
            final stepMs = math.min(dtMs, duration - i * dtMs);
            final dtSec = stepMs / 1000;

            pose = simulateLinearStep(pose, motorL, motorR, dtSec, physics, smoothed);

            elapsedMs += stepMs;
            _pushFrame(frames, pose, elapsedMs, action.raw);
          }
        }
        break;

      case ActionType.pid:
        {
          final duration = (action.deg.abs() / pidDegPerSec) * 1000 + pidSettleMs;
          final steps = math.max(1, (duration / dtMs).ceil());
          final startAngle = pose.angle;
          final targetAngle = normalizeAngleDeg(startAngle + action.deg);

          motorL = 0;
          motorR = 0;
          smoothed.vL = 0;
          smoothed.vR = 0;

          for (var i = 1; i <= steps; i++) {
            final progress = i / steps;
            final eased = progress < 0.5
                ? 2 * progress * progress
                : 1 - math.pow(-2 * progress + 2, 2) / 2;

            pose = pose.copyWith(
              angle: normalizeAngleDeg(startAngle + action.deg * eased),
            );

            elapsedMs += duration / steps;
            _pushFrame(frames, pose, elapsedMs, action.raw);
          }

          pose = pose.copyWith(angle: targetAngle);
          _pushFrame(frames, pose, elapsedMs, action.raw);
        }
        break;

      case ActionType.next:
        _pushFrame(frames, pose, elapsedMs, action.raw);
        break;

      case ActionType.stub:
      case ActionType.unknown:
        _pushFrame(frames, pose, elapsedMs, action.raw);
        break;
    }
  }

  return SimulationResult(
    frames: frames,
    durationMs: math.max(1, elapsedMs),
    finalPose: pose,
    next: getNextFromActions(actions),
  );
}

// ---------------------------------------------------------------------
// Geometria / tela
// ---------------------------------------------------------------------

class ScreenPoint {
  final double left;
  final double top;
  const ScreenPoint(this.left, this.top);
}

ScreenPoint poseToScreen(Frame frame, Map<String, dynamic> physics) {
  final viewSize = safeNumber(physics['viewSizePx']);
  final outerDiam = safeNumber(physics['dojoOuterDiameterCm']);
  final scale = viewSize / outerDiam;
  final center = viewSize / 2;

  return ScreenPoint(center + frame.x * scale, center - frame.y * scale);
}

ScreenPoint poseToScreenFromPose(Pose pose, Map<String, dynamic> physics) {
  final viewSize = safeNumber(physics['viewSizePx']);
  final outerDiam = safeNumber(physics['dojoOuterDiameterCm']);
  final scale = viewSize / outerDiam;
  final center = viewSize / 2;

  return ScreenPoint(center + pose.x * scale, center - pose.y * scale);
}

Frame? getFrameAtTime(List<Frame> frames, double timeMs) {
  if (frames.isEmpty) return null;

  var lo = 0;
  var hi = frames.length - 1;

  while (lo < hi) {
    final mid = ((lo + hi) / 2).ceil();
    if (frames[mid].t <= timeMs) {
      lo = mid;
    } else {
      hi = mid - 1;
    }
  }

  return frames[lo];
}

bool didPathLeaveDojo(List<Frame> frames, Map<String, dynamic> physics) {
  if (frames.isEmpty) return false;

  final innerDiam = safeNumber(physics['dojoInnerDiameterCm']);
  final radius = innerDiam / 2;

  return frames.any((f) => math.sqrt(f.x * f.x + f.y * f.y) > radius);
}

ScreenPoint? getStartPoint(List<Frame> frames, Map<String, dynamic> physics) {
  if (frames.isEmpty) return null;
  return poseToScreen(frames.first, physics);
}

double getInnerDojoPercent(Map<String, dynamic> physics) {
  return safeNumber(physics['dojoInnerDiameterCm']) /
      safeNumber(physics['dojoOuterDiameterCm']) *
      100;
}

double getRobotSizePercent(Map<String, dynamic> physics) {
  return safeNumber(physics['robotWidthCm']) /
      safeNumber(physics['dojoOuterDiameterCm']) *
      100;
}

class Rect2D {
  final double x, y, width, height;
  const Rect2D(this.x, this.y, this.width, this.height);
}

List<Rect2D> getShikiriSenRects(Map<String, dynamic> physics) {
  final viewSize = safeNumber(physics['viewSizePx']);
  final outerDiam = safeNumber(physics['dojoOuterDiameterCm']);
  final scale = viewSize / outerDiam;
  final center = viewSize / 2;

  final width = safeNumber(physics['shikiriSenLengthCm']) * scale;
  final height = safeNumber(physics['shikiriSenWidthCm']) * scale;
  final gap = safeNumber(physics['shikiriSenGapCm']) * scale;

  final x = center - width / 2;

  return [
    Rect2D(x, center - gap / 2 - height, width, height),
    Rect2D(x, center + gap / 2, width, height),
  ];
}

enum ArrowMode { never, always, draw }

ArrowMode normalizeArrowMode(String? arrow) {
  if (arrow == 'ALWAYS') return ArrowMode.always;
  if (arrow == 'DRAW') return ArrowMode.draw;
  return ArrowMode.never;
}

List<Frame> getDrawableFrames(
  List<Frame> frames,
  Map<String, dynamic> physics,
  double currentTimeMs,
  ArrowMode arrowMode,
) {
  if (frames.isEmpty) return [];

  final limited =
      arrowMode == ArrowMode.draw ? frames.where((f) => f.t <= currentTimeMs).toList() : frames;

  final drawable = <Frame>[];

  for (final frame in limited) {
    final point = poseToScreen(frame, physics);
    if (drawable.isEmpty) {
      drawable.add(frame);
      continue;
    }
    final lastPoint = poseToScreen(drawable.last, physics);
    if (point.left.toStringAsFixed(2) != lastPoint.left.toStringAsFixed(2) ||
        point.top.toStringAsFixed(2) != lastPoint.top.toStringAsFixed(2)) {
      drawable.add(frame);
    }
  }

  return drawable;
}

double getPathEndAngle(
  List<Frame> frames,
  Map<String, dynamic> physics,
  double currentTimeMs,
  ArrowMode arrowMode,
) {
  final drawable = getDrawableFrames(frames, physics, currentTimeMs, arrowMode);
  if (drawable.length < 2) return 0;

  final last = poseToScreen(drawable.last, physics);
  final prev = poseToScreen(drawable[drawable.length - 2], physics);

  final dx = last.left - prev.left;
  final dy = last.top - prev.top;

  return radToDeg(math.atan2(dy, dx));
}
