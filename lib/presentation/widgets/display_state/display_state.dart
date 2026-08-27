/// Porte de DisplayState.jsx + DisplayState.module.css para Flutter.
///
/// Uso:
///   DisplayState(
///     physics: physicsMap,      // decodificado de PHYSICS.json
///     state: jogadaMap,         // uma entrada de JOGADAS.json, ex: jogadas['JOGADA_1']
///   )
///
/// Carregando os JSONs (assets):
///   final physicsMap = jsonDecode(await rootBundle.loadString('assets/PHYSICS.json'));
///   final jogadas = jsonDecode(await rootBundle.loadString('assets/JOGADAS.json'));
library display_state;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'simulation.dart';
import 'display_state_colors.dart';
import 'display_state_style.dart';

enum DisplayVisual { defaultVisual, compact }

class DisplayState extends StatefulWidget {
  final Map<String, dynamic> physics;
  final Map<String, dynamic>? state;
  final Map<String, dynamic>? startPosition;

  final DisplayVisual visual;
  final double animationSpeed;
  final String arrow; // 'NEVER' | 'ALWAYS' | 'DRAW'
  final int loopMs; // 0 = não repete
  final bool autoplay;
  final bool hiddenRobot;
  final bool showStartPoint;
  final String robotAssetPath;

  const DisplayState({
    super.key,
    required this.physics,
    required this.state,
    this.startPosition,
    this.visual = DisplayVisual.defaultVisual,
    this.animationSpeed = 1,
    this.arrow = 'NEVER',
    this.loopMs = 0,
    this.autoplay = true,
    this.hiddenRobot = false,
    this.showStartPoint = false,
    this.robotAssetPath = 'assets/images/robot_view.png',
  });

  @override
  State<DisplayState> createState() => _DisplayStateState();
}

class _DisplayStateState extends State<DisplayState> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _side = 'ladoDir';
  bool _isLoopWaiting = false;
  Timer? _loopTimer;

  late List<String> _actions;
  late Map<String, dynamic>? _resolvedStartPosition;
  late SimulationResult _simulation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _rebuildSimulation();
    _controller.addStatusListener(_onStatusChanged);
    if (widget.autoplay) _play();
  }

  @override
  void didUpdateWidget(covariant DisplayState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state ||
        oldWidget.physics != widget.physics ||
        oldWidget.startPosition != widget.startPosition) {
      _rebuildSimulation();
      _resetAnimation(widget.autoplay);
    }
  }

  void _rebuildSimulation() {
    _actions = getActionsFromState(widget.state, _side);
    _resolvedStartPosition = resolveStartPosition(widget.state, _side, widget.startPosition);
    _simulation = simulateJogada(
      actions: _actions,
      startPosition: _resolvedStartPosition,
      physics: widget.physics,
      state: widget.state,
    );

    final speed = math.max(0.01, widget.animationSpeed);
    _controller.duration = Duration(
      milliseconds: (_simulation.durationMs / speed).round().clamp(1, 1 << 30),
    );
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    if (widget.loopMs > 0) {
      setState(() => _isLoopWaiting = true);
      _loopTimer?.cancel();
      _loopTimer = Timer(Duration(milliseconds: widget.loopMs), () {
        if (!mounted) return;
        setState(() => _isLoopWaiting = false);
        _controller
          ..reset()
          ..forward();
      });
    }
  }

  void _play() => _controller.forward();

  void _resetAnimation(bool shouldPlay) {
    _loopTimer?.cancel();
    _isLoopWaiting = false;
    _controller.reset();
    if (shouldPlay) _controller.forward();
    setState(() {});
  }

  void _setSide(String side) {
    if (_side == side) return;
    setState(() {
      _side = side;
      _rebuildSimulation();
    });
    _resetAnimation(widget.autoplay);
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  double get _timeMs => _controller.value * _simulation.durationMs;

  @override
  Widget build(BuildContext context) {
    final stageOrCompact = widget.visual == DisplayVisual.compact
        ? _CompactWrapper(
            physics: widget.physics,
            simulation: _simulation,
            controller: _controller,
            arrowMode: normalizeArrowMode(widget.arrow),
            hiddenRobot: widget.hiddenRobot,
            showStartPoint: widget.showStartPoint,
            robotAssetPath: widget.robotAssetPath,
          )
        : _Stage(
            physics: widget.physics,
            state: widget.state,
            simulation: _simulation,
            controller: _controller,
            arrowMode: normalizeArrowMode(widget.arrow),
            hiddenRobot: widget.hiddenRobot,
            showStartPoint: widget.showStartPoint,
            robotAssetPath: widget.robotAssetPath,
            isLoopWaiting: _isLoopWaiting,
            loopMs: widget.loopMs,
          );

    if (widget.visual == DisplayVisual.compact) {
      return stageOrCompact;
    }

    final hasSideChoice = widget.state?['ladoDir'] != null || widget.state?['ladoEsc'] != null;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DisplayStateStyle.wrapperMaxWidth),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontFamily: DisplayStateStyle.fontFamily,
          color: DisplayStateColors.wrapperText,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            stageOrCompact,

            // .nextText
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: DisplayStateStyle.nextTextPadding,
              decoration: BoxDecoration(
                color: DisplayStateColors.nextTextBackground,
                borderRadius: BorderRadius.circular(DisplayStateStyle.nextTextBorderRadius),
                border: Border.all(color: DisplayStateColors.nextTextBorder),
              ),
              child: Text.rich(
                TextSpan(
                  text: 'Ao terminar, cai na ',
                  style: TextStyle(
                    color: DisplayStateColors.nextTextForeground,
                    fontSize: DisplayStateStyle.nextTextFontSize,
                  ),
                  children: [
                    TextSpan(
                      text: _simulation.next,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // .controls
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: DisplayStateStyle.controlsPadding,
              decoration: BoxDecoration(
                color: DisplayStateColors.controlsBackground,
                borderRadius: BorderRadius.circular(DisplayStateStyle.controlsBorderRadius),
                border: Border.all(color: DisplayStateColors.controlsBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Lado da jogada',
                    style: TextStyle(
                      fontSize: DisplayStateStyle.sideTitleFontSize,
                      fontWeight: FontWeight.bold,
                      color: DisplayStateColors.controlsForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _SideButton(
                          label: 'Direito',
                          active: _side == 'ladoDir',
                          enabled: hasSideChoice || widget.state?['ladoDir'] != null,
                          onPressed: () => _setSide('ladoDir'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SideButton(
                          label: 'Esquerdo',
                          active: _side == 'ladoEsc',
                          enabled: hasSideChoice || widget.state?['ladoEsc'] != null,
                          onPressed: () => _setSide('ladoEsc'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Etapa da animação',
                        style: TextStyle(
                          fontSize: DisplayStateStyle.timelineHeaderFontSize,
                          fontWeight: FontWeight.bold,
                          color: DisplayStateColors.timelineHeaderText,
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) => Text(
                          '${_timeMs.round()}ms',
                          style: TextStyle(
                            fontSize: DisplayStateStyle.timelineHeaderFontSize,
                            fontWeight: FontWeight.bold,
                            color: DisplayStateColors.timelineHeaderText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) => SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: DisplayStateColors.controlsForeground,
                        thumbColor: DisplayStateColors.controlsForeground,
                      ),
                      child: Slider(
                        min: 0,
                        max: math.max(1, _simulation.durationMs.roundToDouble()),
                        value: _timeMs.clamp(0, _simulation.durationMs),
                        onChanged: (value) {
                          _controller.stop();
                          _loopTimer?.cancel();
                          setState(() => _isLoopWaiting = false);
                          _controller.value =
                              (value / _simulation.durationMs).clamp(0.0, 1.0);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: DisplayStateStyle.controlButtonMinHeight,
                    child: OutlinedButton(
                      onPressed: () => _resetAnimation(true),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: DisplayStateColors.controlButtonBackground,
                        foregroundColor: DisplayStateColors.controlButtonForeground,
                        side: const BorderSide(color: DisplayStateColors.controlButtonBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(DisplayStateStyle.controlButtonBorderRadius),
                        ),
                      ),
                      child: const Text('Reiniciar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onPressed;

  const _SideButton({
    required this.label,
    required this.active,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bg = active ? DisplayStateColors.sideButtonActiveBackground : DisplayStateColors.sideButtonBackground;
    final fg = active ? DisplayStateColors.sideButtonActiveForeground : DisplayStateColors.sideButtonForeground;
    final border = active ? DisplayStateColors.sideButtonActiveBackground : DisplayStateColors.sideButtonBorder;

    return Opacity(
      opacity: enabled ? 1 : DisplayStateColors.sideButtonDisabledOpacity,
      child: SizedBox(
        height: DisplayStateStyle.sideButtonMinHeight,
        child: OutlinedButton(
          onPressed: enabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            disabledForegroundColor: fg,
            side: BorderSide(color: border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DisplayStateStyle.sideButtonBorderRadius),
            ),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// .stage — quadrado cinza com dojo (82%), infoBar, progresso e actionText
// ---------------------------------------------------------------------

class _Stage extends StatelessWidget {
  final Map<String, dynamic> physics;
  final Map<String, dynamic>? state;
  final SimulationResult simulation;
  final AnimationController controller;
  final ArrowMode arrowMode;
  final bool hiddenRobot;
  final bool showStartPoint;
  final String robotAssetPath;
  final bool isLoopWaiting;
  final int loopMs;

  const _Stage({
    required this.physics,
    required this.state,
    required this.simulation,
    required this.controller,
    required this.arrowMode,
    required this.hiddenRobot,
    required this.showStartPoint,
    required this.robotAssetPath,
    required this.isLoopWaiting,
    required this.loopMs,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: DisplayStateColors.stageBackground,
          borderRadius: BorderRadius.circular(DisplayStateStyle.stageBorderRadius),
          border: Border.all(
            color: DisplayStateColors.stageBorder,
            width: DisplayStateStyle.stageBorderWidth,
          ),
          boxShadow: DisplayStateStyle.stageShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // dojo centralizado a 82%
            Center(
              child: FractionallySizedBox(
                widthFactor: DisplayStateStyle.dojoOuterFactor,
                heightFactor: DisplayStateStyle.dojoOuterFactor,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final timeMs = controller.value * simulation.durationMs;
                    final currentFrame = getFrameAtTime(
                      simulation.frames,
                      math.min(timeMs, simulation.durationMs),
                    );
                    return _DojoCircle(
                      physics: physics,
                      simulation: simulation,
                      currentFrame: currentFrame,
                      currentTimeMs: math.min(timeMs, simulation.durationMs),
                      arrowMode: arrowMode,
                      hiddenRobot: hiddenRobot,
                      showStartPoint: showStartPoint,
                      robotAssetPath: robotAssetPath,
                    );
                  },
                ),
              ),
            ),

            // .infoBar
            Positioned(
              left: DisplayStateStyle.infoBarPaddingH,
              right: DisplayStateStyle.infoBarPaddingH,
              top: DisplayStateStyle.infoBarPaddingTop,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final timeMs = controller.value * simulation.durationMs;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          (state?['category'] ?? state?['categoria'] ?? 'JOGADA').toString(),
                          overflow: TextOverflow.ellipsis,
                          style: _infoTextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${timeMs.round()}ms / ${simulation.durationMs.round()}ms',
                        style: _infoTextStyle(),
                      ),
                    ],
                  );
                },
              ),
            ),

            // .progressTrack / .progressFill
            Positioned(
              left: DisplayStateStyle.progressSideMargin,
              right: DisplayStateStyle.progressSideMargin,
              bottom: DisplayStateStyle.progressTrackBottom,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: DisplayStateStyle.progressTrackHeight,
                  color: DisplayStateColors.progressTrack,
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, _) => FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: controller.value.clamp(0.0, 1.0),
                      child: Container(color: DisplayStateColors.progressFill),
                    ),
                  ),
                ),
              ),
            ),

            // .actionText
            Positioned(
              left: DisplayStateStyle.progressSideMargin,
              right: DisplayStateStyle.progressSideMargin,
              bottom: DisplayStateStyle.actionTextBottom,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final timeMs = controller.value * simulation.durationMs;
                  final currentFrame = getFrameAtTime(
                    simulation.frames,
                    math.min(timeMs, simulation.durationMs),
                  );
                  return Text(
                    isLoopWaiting ? 'loop em ${loopMs}ms' : (currentFrame?.actionLabel ?? 'início'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: DisplayStateStyle.actionTextFontSize,
                      color: DisplayStateColors.actionText.withOpacity(0.95),
                      shadows: const [
                        Shadow(color: DisplayStateColors.actionTextShadow, blurRadius: 2, offset: Offset(0, 1)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _infoTextStyle({FontWeight fontWeight = FontWeight.normal}) => TextStyle(
        fontSize: DisplayStateStyle.infoFontSize,
        color: DisplayStateColors.infoText,
        fontWeight: fontWeight,
        shadows: const [
          Shadow(color: DisplayStateColors.infoTextShadow, blurRadius: 2, offset: Offset(0, 1)),
        ],
      );
}

// ---------------------------------------------------------------------
// .compactWrapper — igual ao stage, porém sem infoBar/progresso/controles
// ---------------------------------------------------------------------

class _CompactWrapper extends StatelessWidget {
  final Map<String, dynamic> physics;
  final SimulationResult simulation;
  final AnimationController controller;
  final ArrowMode arrowMode;
  final bool hiddenRobot;
  final bool showStartPoint;
  final String robotAssetPath;

  const _CompactWrapper({
    required this.physics,
    required this.simulation,
    required this.controller,
    required this.arrowMode,
    required this.hiddenRobot,
    required this.showStartPoint,
    required this.robotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: DisplayStateColors.compactBackground,
            borderRadius: BorderRadius.circular(DisplayStateStyle.compactBorderRadius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: FractionallySizedBox(
              widthFactor: DisplayStateStyle.dojoOuterFactor,
              heightFactor: DisplayStateStyle.dojoOuterFactor,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final timeMs = controller.value * simulation.durationMs;
                  final currentFrame = getFrameAtTime(
                    simulation.frames,
                    math.min(timeMs, simulation.durationMs),
                  );
                  return _DojoCircle(
                    physics: physics,
                    simulation: simulation,
                    currentFrame: currentFrame,
                    currentTimeMs: math.min(timeMs, simulation.durationMs),
                    arrowMode: arrowMode,
                    hiddenRobot: hiddenRobot,
                    showStartPoint: showStartPoint,
                    robotAssetPath: robotAssetPath,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// .dojoOuter + .dojoInner + .pathSvg + .robot — o círculo do dojo em si
// ---------------------------------------------------------------------

class _DojoCircle extends StatelessWidget {
  final Map<String, dynamic> physics;
  final SimulationResult simulation;
  final Frame? currentFrame;
  final double currentTimeMs;
  final ArrowMode arrowMode;
  final bool hiddenRobot;
  final bool showStartPoint;
  final String robotAssetPath;

  const _DojoCircle({
    required this.physics,
    required this.simulation,
    required this.currentFrame,
    required this.currentTimeMs,
    required this.arrowMode,
    required this.hiddenRobot,
    required this.showStartPoint,
    required this.robotAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    final viewSize = safeNumber(physics['viewSizePx']);
    final innerPercent = getInnerDojoPercent(physics) / 100;
    final robotPercent = getRobotSizePercent(physics) / 100;

    final screen = currentFrame != null
        ? poseToScreen(currentFrame!, physics)
        : ScreenPoint(viewSize / 2, viewSize / 2);

    return ClipOval(
      child: Container(
        color: DisplayStateColors.dojoOuter,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth;
            final scale = size / viewSize;

            return Stack(
              alignment: Alignment.center,
              children: [
                // .dojoInner
                FractionallySizedBox(
                  widthFactor: innerPercent,
                  heightFactor: innerPercent,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: DisplayStateColors.dojoInner,
                    ),
                  ),
                ),

                // .pathSvg (shikiri-sen, trajeto, ponto inicial)
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: _PathPainter(
                      physics: physics,
                      simulation: simulation,
                      currentTimeMs: currentTimeMs,
                      arrowMode: arrowMode,
                      showStartPoint: showStartPoint,
                      scale: scale,
                    ),
                  ),
                ),

                // .robot
                if (!hiddenRobot)
                  Positioned(
                    left: screen.left * scale - (robotPercent * size) / 2,
                    top: screen.top * scale - (robotPercent * size) / 2,
                    width: robotPercent * size,
                    height: robotPercent * size,
                    child: Transform.rotate(
                      angle: degToRad(90 - (currentFrame?.angle ?? 0)),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // .robotImg
                          ClipRRect(
                            borderRadius: BorderRadius.circular(DisplayStateStyle.robotBorderRadius),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: DisplayStateColors.robotImgBorder,
                                  width: DisplayStateStyle.robotImgBorderWidth,
                                ),
                                borderRadius:
                                    BorderRadius.circular(DisplayStateStyle.robotBorderRadius),
                                boxShadow: DisplayStateStyle.robotImgShadow,
                              ),
                              child: Image.asset(
                                robotAssetPath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ),
                          ),
                          // .robotFront (seta triangular no topo, indica frente)
                          Positioned(
                            top: -8,
                            child: CustomPaint(
                              size: const Size(14, 10),
                              painter: _TrianglePainter(
                                color: DisplayStateColors.robotFront,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawShadow(path, Colors.black.withOpacity(0.5), 1.5, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => oldDelegate.color != color;
}

class _PathPainter extends CustomPainter {
  final Map<String, dynamic> physics;
  final SimulationResult simulation;
  final double currentTimeMs;
  final ArrowMode arrowMode;
  final bool showStartPoint;
  final double scale;

  _PathPainter({
    required this.physics,
    required this.simulation,
    required this.currentTimeMs,
    required this.arrowMode,
    required this.showStartPoint,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // .shikiriSen (faixas de partida, cor inline no JSX: #8b4d00)
    final rectPaint = Paint()..color = DisplayStateColors.shikiriSen;
    for (final r in getShikiriSenRects(physics)) {
      final rect = Rect.fromLTWH(r.x * scale, r.y * scale, r.width * scale, r.height * scale);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(1.5 * scale)), rectPaint);
    }

    if (arrowMode == ArrowMode.never) return;

    final leftDojo = didPathLeaveDojo(simulation.frames, physics);
    final pathColor = leftDojo ? DisplayStateColors.pathError : DisplayStateColors.pathOk;

    final drawable = getDrawableFrames(simulation.frames, physics, currentTimeMs, arrowMode);
    if (drawable.length < 2) return;

    final path = Path();
    for (var i = 0; i < drawable.length; i++) {
      final p = poseToScreen(drawable[i], physics);
      final pt = Offset(p.left * scale, p.top * scale);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }

    final strokePaint = Paint()
      ..color = pathColor.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = DisplayStateStyle.pathStrokeWidth * scale
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      _dashPath(
        path,
        dashLength: DisplayStateStyle.pathDashLength * scale,
        gapLength: DisplayStateStyle.pathDashGap * scale,
      ),
      strokePaint,
    );

    final endAngleDeg = getPathEndAngle(simulation.frames, physics, currentTimeMs, arrowMode);
    final lastPoint = poseToScreen(drawable.last, physics);
    _drawArrowHead(
      canvas,
      Offset(lastPoint.left * scale, lastPoint.top * scale),
      degToRad(endAngleDeg),
      pathColor,
    );

    if (showStartPoint) {
      final start = getStartPoint(simulation.frames, physics);
      if (start != null) {
        final center = Offset(start.left * scale, start.top * scale);
        canvas.drawCircle(center, DisplayStateStyle.startPointRadius * scale,
            Paint()..color = DisplayStateColors.startPointFill);
        canvas.drawCircle(
          center,
          DisplayStateStyle.startPointRadius * scale,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * scale,
        );
      }
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    final path = Path();
    path.moveTo(0, -DisplayStateStyle.arrowHeadWidth / 2);
    path.lineTo(0, DisplayStateStyle.arrowHeadWidth / 2);
    path.lineTo(DisplayStateStyle.arrowHeadLength, 0);
    path.close();

    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    canvas.scale(scale, scale);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  Path _dashPath(Path source, {required double dashLength, required double gapLength}) {
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var draw = true;
      while (distance < metric.length) {
        final next = distance + (draw ? dashLength : gapLength);
        if (draw) {
          dashed.addPath(metric.extractPath(distance, math.min(next, metric.length)), Offset.zero);
        }
        distance = next;
        draw = !draw;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) {
    return oldDelegate.currentTimeMs != currentTimeMs ||
        oldDelegate.simulation != simulation ||
        oldDelegate.arrowMode != arrowMode;
  }
}
