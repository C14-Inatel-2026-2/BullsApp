/// Constantes não-cromáticas extraídas de DisplayState.module.css
/// (raios, espaçamentos, tamanhos de fonte, sombras).
library display_state_style;

import 'package:flutter/material.dart';
import 'display_state_colors.dart';

class DisplayStateStyle {
  DisplayStateStyle._();

  static const wrapperMaxWidth = 520.0;
  static const fontFamily = 'Arial'; // fallback do sistema; sem custom font

  static const stageBorderRadius = 18.0;
  static const stageBorderWidth = 2.0;
  static const stageShadow = [
    BoxShadow(
      color: DisplayStateColors.stageShadow,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const compactBorderRadius = 18.0;

  static const dojoOuterFactor = 0.82; // dojoOuter é 82% do stage/compactWrapper

  static const robotBorderRadius = 12.0;
  static const robotImgBorderWidth = 2.0;
  static const robotImgShadow = [
    BoxShadow(
      color: DisplayStateColors.robotImgShadow,
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const infoBarPaddingH = 14.0;
  static const infoBarPaddingTop = 12.0;
  static const infoFontSize = 13.0;

  static const progressTrackHeight = 8.0;
  static const progressTrackBottom = 38.0;
  static const progressSideMargin = 14.0;

  static const actionTextFontSize = 12.0;
  static const actionTextBottom = 12.0;

  static const nextTextFontSize = 15.0;
  static const nextTextBorderRadius = 12.0;
  static const nextTextPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 12);

  static const controlsBorderRadius = 14.0;
  static const controlsPadding = EdgeInsets.all(14);

  static const sideTitleFontSize = 13.0;
  static const sideButtonMinHeight = 42.0;
  static const sideButtonBorderRadius = 10.0;

  static const timelineHeaderFontSize = 13.0;

  static const controlButtonMinHeight = 38.0;
  static const controlButtonBorderRadius = 10.0;

  static const arrowHeadLength = 7.0;
  static const arrowHeadWidth = 6.0;
  static const pathStrokeWidth = 3.0;
  static const pathDashLength = 7.0;
  static const pathDashGap = 7.0;
  static const startPointRadius = 6.0;
}
