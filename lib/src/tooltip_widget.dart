/*
 * Copyright (c) 2021 Simform Solutions
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';
import 'get_position.dart';

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final EdgeInsets? contentPadding;
  final bool disableAnimation;
  final Widget actionButton;
  final Widget content;

  ToolTipWidget({
    required this.position,
    required this.offset,
    required this.screenSize,
    required this.actionButton,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    required this.disableAnimation,
    required this.content,
  });

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with SingleTickerProviderStateMixin {
  Offset? position;

  bool isArrowUp = false;

  bool isCloseToTopOrBottom(Offset position) {
    /// TODO need to use screen utils?
    var height = 175.0;
    final bottomPosition =
        position.dy + ((widget.position?.getHeight() ?? 0) / 2);
    final topPosition = position.dy - ((widget.position?.getHeight() ?? 0) / 2);
    return ((widget.screenSize?.height ?? MediaQuery.of(context).size.height) -
                bottomPosition) <=
            height &&
        topPosition >= height;
  }

  String findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return 'ABOVE';
    } else {
      return 'BELOW';
    }
  }

  /// TODO set toolTips width
  double _getTooltipWidth() {
    return 328.w;
  }

  @override
  Widget build(BuildContext context) {
    position = widget.offset;
    final contentOrientation = findPositionForContent(position!);
    final contentOffsetMultiplier = contentOrientation == "BELOW" ? 1.0 : -1.0;
    isArrowUp = contentOffsetMultiplier == 1.0;

    final contentY = isArrowUp
        ? widget.position!.getBottom() + (contentOffsetMultiplier * 3)
        : widget.position!.getTop() + (contentOffsetMultiplier * 3);

    final num contentFractionalOffset =
        contentOffsetMultiplier.clamp(-1.0, 0.0);

    var paddingTop = isArrowUp ? 22.0 : 0.0;
    var paddingBottom = isArrowUp ? 0.0 : 27.0;

    /// TODO need to use screen utils?
    final arrowWidth = 18.0;
    final arrowHeight = 9.0;

    return Positioned(
      top: contentY,
      left: 0,
      right: 0,
      child: FractionalTranslation(
        translation: Offset(0.0, contentFractionalOffset as double),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(
              top: paddingTop - (isArrowUp ? arrowHeight : 0),
              bottom: paddingBottom - (isArrowUp ? 0 : arrowHeight),
            ),
            child: Stack(
              alignment: isArrowUp ? Alignment.topLeft : Alignment.bottomLeft,
              children: [
                Positioned(
                  left: (widget.position!.getCenter() - (arrowWidth / 2)),
                  child: CustomPaint(
                    painter: _Arrow(
                      /// TODO need to use screen utils?
                      strokeWidth: 10,
                      paintingStyle: PaintingStyle.fill,
                      isUpArrow: isArrowUp,
                    ),
                    child: SizedBox(
                      height: arrowHeight,
                      width: arrowWidth,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: isArrowUp ? arrowHeight - 1 : 0,
                    bottom: isArrowUp ? 0 : arrowHeight - 1,
                  ),
                  child: Center(
                    child: Container(
                      width: _getTooltipWidth(),
                      padding: widget.contentPadding,
                      decoration: BoxDecoration(
                        color: kShowCaseNeutral800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          widget.content,
                          SizedBox(height: 24),
                          widget.actionButton,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Arrow extends CustomPainter {
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final bool isUpArrow;

  _Arrow(
      {this.strokeWidth = 3,
      this.paintingStyle = PaintingStyle.stroke,
      this.isUpArrow = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kShowCaseNeutral800
      ..strokeWidth = strokeWidth
      ..style = paintingStyle;

    canvas.drawPath(getTrianglePath(size.width, size.height), paint);
  }

  Path getTrianglePath(double x, double y) {
    if (isUpArrow) {
      return Path()
        ..moveTo(0, y)
        ..lineTo(x / 2, 0)
        ..lineTo(x, y)
        ..lineTo(0, y);
    } else {
      return Path()
        ..moveTo(0, 0)
        ..lineTo(x, 0)
        ..lineTo(x / 2, y)
        ..lineTo(0, 0);
    }
  }

  @override
  bool shouldRepaint(_Arrow oldDelegate) {
    return oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
