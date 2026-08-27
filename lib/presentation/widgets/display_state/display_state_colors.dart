/// Cores extraídas de DisplayState.module.css
///
/// Mantido separado (assim como no seu projeto original) para facilitar
/// trocar o tema sem mexer em display_state.dart.
library display_state_colors;

import 'package:flutter/material.dart';

class DisplayStateColors {
  DisplayStateColors._();

  // .wrapper
  static const wrapperText = Color(0xFFFFFFFF);

  // .compactWrapper
  static const compactBackground = Color(0xFF3155B9);

  // .stage
  static const stageBackground = Color(0xFF777777);
  static const stageBorder = Color(0xFF5F5F5F);
  static const stageShadow = Color(0x38000000); // rgba(0,0,0,0.22)

  // .infoBar / .infoStrong / .infoTime
  static const infoText = Color(0xFFFFFFFF);
  static const infoTextShadow = Color(0xB3000000); // rgba(0,0,0,0.7)

  // .dojoOuter / .dojoInner
  static const dojoOuter = Color(0xFFFFFFFF);
  static const dojoInner = Color(0xFF000000);

  // .robotImg
  static const robotImgBorder = Color(0xFFFFFFFF);
  static const robotImgShadow = Color(0x73000000); // rgba(0,0,0,0.45)

  // .robotFront (seta triangular indicando frente do robô)
  static const robotFront = Color(0xFFFF3030);
  static const robotFrontShadow = Color(0x80000000); // rgba(0,0,0,0.5)

  // .progressTrack / .progressFill
  static const progressTrack = Color(0x3DFFFFFF); // rgba(255,255,255,0.24)
  static const progressFill = Color(0xFFFFFFFF);

  // .actionText
  static const actionText = Color(0xFFFFFFFF);
  static const actionTextShadow = Color(0xB3000000); // rgba(0,0,0,0.7)

  // .nextText
  static const nextTextBackground = Color(0xFF1F1F1F);
  static const nextTextForeground = Color(0xFFFFFFFF);
  static const nextTextBorder = Color(0xFF3A3A3A);

  // .controls
  static const controlsBackground = Color(0xFFEEEEEE);
  static const controlsForeground = Color(0xFF111111);
  static const controlsBorder = Color(0xFFD4D4D4);

  // .sideButton / .sideButtonActive
  static const sideButtonBackground = Color(0xFFFFFFFF);
  static const sideButtonForeground = Color(0xFF111111);
  static const sideButtonBorder = Color(0xFFBBBBBB);
  static const sideButtonDisabledOpacity = 0.45;
  static const sideButtonActiveBackground = Color(0xFF111111);
  static const sideButtonActiveForeground = Color(0xFFFFFFFF);

  // .timelineHeader
  static const timelineHeaderText = Color(0xFF111111);

  // .controlButton
  static const controlButtonBackground = Color(0xFFF9F9F9);
  static const controlButtonForeground = Color(0xFF111111);
  static const controlButtonBorder = Color(0xFFC7C7C7);

  // Cores do caminho/seta no SVG (definidas inline no JSX, não no CSS)
  static const pathOk = Color(0xFF22C55E);
  static const pathError = Color(0xFFFF3030);
  static const shikiriSen = Color(0xFF8B4D00);
  static const startPointFill = Color(0xFF3D86FF);
}
