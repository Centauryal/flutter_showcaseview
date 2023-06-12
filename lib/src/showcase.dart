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
import 'layout_overlays.dart';
import 'shape_clipper.dart';
import 'showcase_widget.dart';
import 'tooltip_widget.dart';

class Showcase extends StatefulWidget {
  @override
  final GlobalKey key;

  final Widget child;
  final bool withStep;
  final ShapeBorder? shapeBorder;
  final EdgeInsets contentPadding;
  final VoidCallback? onFinishClick;
  final EdgeInsets overlayPadding;
  final Widget infoContent;

  Showcase({
    required this.key,
    required this.child,
    required this.infoContent,
    this.withStep = false,
    this.shapeBorder,
    this.onFinishClick,
    EdgeInsets? contentPadding,
    this.overlayPadding = EdgeInsets.zero,
  }) : contentPadding = contentPadding ?? EdgeInsets.all(16.w);

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  bool _showShowCase = false;
  GetPosition? position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    position ??= GetPosition(
      key: widget.key,
      padding: widget.overlayPadding,
      screenWidth: MediaQuery.of(context).size.width,
      screenHeight: MediaQuery.of(context).size.height,
    );
    showOverlay();
  }

  /// show overlay if there is any target widget
  ///
  void showOverlay() {
    final activeStep = ShowCaseWidget.activeTargetWidget(context);
    setState(() {
      _showShowCase = activeStep == widget.key;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      overlayBuilder: (context, rectBound, offset) {
        final size = MediaQuery.of(context).size;
        position = GetPosition(
          key: widget.key,
          padding: widget.overlayPadding,
          screenWidth: size.width,
          screenHeight: size.height,
        );
        return buildOverlayOnTarget(offset, rectBound.size, rectBound, size);
      },
      showOverlay: true,
      child: widget.child,
    );
  }

  void _nextIfAny() {
    ShowCaseWidget.of(context)!.completed(widget.key);
  }

  void _dismissTap() {
    widget.onFinishClick?.call();
    ShowCaseWidget.of(context)!.dismiss();
  }

  void _previousTap() {
    ShowCaseWidget.of(context)!.previous();
  }

  int? _lengthShowcase() {
    return ShowCaseWidget.of(context)?.ids?.length ?? 0;
  }

  int? _currentPageShowcase() {
    return ShowCaseWidget.of(context)?.activeWidgetId;
  }

  Widget buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) {
    return _showShowCase
        ? Stack(
            children: [
              ClipPath(
                clipper: RRectClipper(
                  area: rectBound,
                  isCircle: widget.shapeBorder == CircleBorder(),
                  overlayPadding: widget.overlayPadding,
                ),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.black45.withOpacity(0.75),
                  ),
                ),
              ),
              _TargetWidget(
                offset: offset,
                size: size,
                shapeBorder: widget.shapeBorder,
              ),
              ToolTipWidget(
                position: position,
                offset: offset,
                screenSize: screenSize,
                contentPadding: widget.contentPadding,
                actionButton: widget.withStep
                    ? ActionWithStep(
                        length: _lengthShowcase(),
                        currentPage: _currentPageShowcase(),
                        skipButton: _dismissTap,
                        nextButton: _nextIfAny,
                        previousButton: _previousTap,
                        finishButton: _dismissTap,
                        textButtonStyle: TextStyle(),
                      )
                    : ActionWithOkButton(
                        okButton: _dismissTap,
                      ),
                content: widget.infoContent,
              ),
            ],
          )
        : SizedBox.shrink();
  }
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size? size;
  final Animation<double>? widthAnimation;
  final ShapeBorder? shapeBorder;
  final BorderRadius? radius;

  _TargetWidget(
      {Key? key,
      required this.offset,
      this.size,
      this.widthAnimation,
      this.shapeBorder,
      this.radius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Container(
          height: size!.height,
          width: size!.width,
          decoration: ShapeDecoration(
            shape: radius != null
                ? RoundedRectangleBorder(borderRadius: radius!)
                : shapeBorder ??
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8.w),
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}

class ActionWithOkButton extends StatelessWidget {
  final VoidCallback okButton;

  const ActionWithOkButton({
    Key? key,
    required this.okButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 38.w,
      child: ElevatedButton(
        onPressed: okButton,
        child: Text(
          'oke'.toUpperCase(),
          style: TextStyle(color: kShowCaseNeutral1000),
        ),
      ),
    );
  }
}

class ActionWithStep extends StatelessWidget {
  final int? length;
  final int? currentPage;
  final VoidCallback skipButton;
  final VoidCallback nextButton;
  final VoidCallback previousButton;
  final VoidCallback finishButton;
  final TextStyle? textButtonStyle;

  const ActionWithStep({
    Key? key,
    required this.length,
    required this.currentPage,
    required this.skipButton,
    required this.nextButton,
    required this.previousButton,
    required this.finishButton,
    required this.textButtonStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(
              length ?? 0,
              (index) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Container(
                      height: 8.w,
                      width: 8.w,
                      decoration: BoxDecoration(
                          color: index == currentPage
                              ? kShowCaseLightAccent
                              : kShowCaseGrey,
                          shape: BoxShape.circle),
                    ),
                  )),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: skipButton,
              child: Text(
                'lewati'.toUpperCase(),
                style: textButtonStyle?.copyWith(color: kShowCaseLightAccent) ??
                    Theme.of(context)
                        .textTheme
                        .caption
                        ?.copyWith(color: kShowCaseLightAccent),
              ),
            ),
            SizedBox(width: 14.w),
            _button(),
          ],
        )
      ],
    );
  }

  Widget _button() {
    var lengthLast = length! - 1;

    if (currentPage == lengthLast) {
      return _lastPage();
    } else if (currentPage == 0) {
      return _firstPage();
    } else {
      return _middlePage();
    }
  }

  Widget _lastPage() {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: kShowCaseNeutral0,
              width: 1.w,
            ),
          ),
          child: IconButton(
            constraints: BoxConstraints(
              maxHeight: 32.w,
              maxWidth: 32.w,
            ),
            padding: EdgeInsets.all(4.w),
            iconSize: 24.w,
            onPressed: previousButton,
            icon: Center(
              child: Icon(
                Icons.chevron_left,
                color: kShowCaseNeutral0,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kShowCaseLightAccent,
            shape: BoxShape.circle,
            border: Border.all(
              color: kShowCaseLightAccent,
              width: 1.w,
            ),
          ),
          child: IconButton(
            constraints: BoxConstraints(
              maxHeight: 32.w,
              maxWidth: 32.w,
            ),
            padding: EdgeInsets.all(4.w),
            iconSize: 24.w,
            onPressed: finishButton,
            icon: Center(
              child: Icon(
                Icons.check,
                color: kShowCaseNeutral1000,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _middlePage() {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: kShowCaseNeutral0,
              width: 1.w,
            ),
          ),
          child: IconButton(
            constraints: BoxConstraints(
              maxHeight: 32.w,
              maxWidth: 32.w,
            ),
            padding: EdgeInsets.all(4.w),
            iconSize: 24.w,
            onPressed: previousButton,
            icon: Center(
              child: Icon(
                Icons.chevron_left,
                color: kShowCaseNeutral0,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kShowCaseLightAccent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            constraints: BoxConstraints(
              maxHeight: 32.w,
              maxWidth: 32.w,
            ),
            padding: EdgeInsets.all(4.w),
            iconSize: 24.w,
            onPressed: nextButton,
            icon: Center(
              child: Icon(
                Icons.chevron_right,
                color: kShowCaseNeutral1000,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _firstPage() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: kShowCaseLightAccent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        constraints: BoxConstraints(
          maxHeight: 32.w,
          maxWidth: 32.w,
        ),
        padding: EdgeInsets.all(4.w),
        iconSize: 24.w,
        onPressed: nextButton,
        icon: Center(
          child: Icon(
            Icons.chevron_right,
            color: kShowCaseNeutral1000,
          ),
        ),
      ),
    );
  }
}
