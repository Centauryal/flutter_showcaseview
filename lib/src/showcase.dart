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

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  final Duration animationDuration;
  final VoidCallback? onToolTipClick;
  final VoidCallback? onTargetClick;
  final VoidCallback? onFinishClick;
  final bool? disposeOnTap;
  final bool disableAnimation;
  final EdgeInsets overlayPadding;
  final Size sizeIndicatorStep;
  final Widget infoContent;

  /// Defines blur value.
  /// This will blur the background while displaying showcase.
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.defaultBlurValue] will be considered.
  ///
  final double? blurValue;

  const Showcase({
    required this.key,
    required this.child,
    required this.infoContent,
    this.withStep = false,
    this.shapeBorder,
    this.onTargetClick,
    this.onFinishClick,
    this.disposeOnTap,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation = true,
    this.contentPadding = const EdgeInsets.all(16),
    this.onToolTipClick,
    this.overlayPadding = EdgeInsets.zero,
    this.blurValue,
    this.sizeIndicatorStep = const Size(8, 8),
  })  : assert(
            onTargetClick == null
                ? true
                : (disposeOnTap == null ? false : true),
            "disposeOnTap is required if you're using onTargetClick"),
        assert(
            disposeOnTap == null
                ? true
                : (onTargetClick == null ? false : true),
            "onTargetClick is required if you're using disposeOnTap");

  @override
  _ShowcaseState createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  bool _showShowCase = false;
  Timer? timer;
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

    if (activeStep == widget.key) {
      if (ShowCaseWidget.of(context)!.autoPlay) {
        timer = Timer(
            Duration(
                seconds: ShowCaseWidget.of(context)!.autoPlayDelay.inSeconds),
            _nextIfAny);
      }
    }
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
    if (timer != null && timer!.isActive) {
      if (ShowCaseWidget.of(context)!.autoPlayLockEnable) {
        return;
      }
      timer!.cancel();
    } else if (timer != null && !timer!.isActive) {
      timer = null;
    }
    ShowCaseWidget.of(context)!.completed(widget.key);
  }

  void _getOnTargetTap() {
    if (widget.disposeOnTap == true) {
      ShowCaseWidget.of(context)!.dismiss();
      widget.onTargetClick!();
    } else {
      (widget.onTargetClick ?? _nextIfAny).call();
    }
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

  void _getOnTooltipTap() {
    if (widget.disposeOnTap == true) {
      ShowCaseWidget.of(context)!.dismiss();
    }
    widget.onToolTipClick?.call();
  }

  bool disableBarrierInteraction() {
    return ShowCaseWidget.of(context)!.disableBarrierInteraction;
  }

  Widget buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) {
    var blur = 0.0;
    if (_showShowCase) {
      blur = widget.blurValue ?? (ShowCaseWidget.of(context)?.blurValue) ?? 0;
    }

    // Set blur to 0 if application is running on web and
    // provided blur is less than 0.
    blur = kIsWeb && blur < 0 ? 0 : blur;

    return _showShowCase
        ? Stack(
            children: [
              GestureDetector(
                onTap: () {
                  if (disableBarrierInteraction()) {
                    _nextIfAny();
                  }
                },
                child: ClipPath(
                  clipper: RRectClipper(
                    area: rectBound,
                    isCircle: widget.shapeBorder == CircleBorder(),
                    overlayPadding: widget.overlayPadding,
                  ),
                  child: blur != 0
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.black45.withOpacity(0.75),
                            ),
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            color: Colors.black45.withOpacity(0.75),
                          ),
                        ),
                ),
              ),
              _TargetWidget(
                offset: offset,
                size: size,
                onTap: () {
                  if (disableBarrierInteraction()) {
                    _getOnTargetTap;
                  }
                },
                shapeBorder: widget.shapeBorder,
              ),
              ToolTipWidget(
                position: position,
                offset: offset,
                screenSize: screenSize,
                onTooltipTap: _getOnTooltipTap,
                contentPadding: widget.contentPadding,
                disableAnimation: widget.disableAnimation,
                animationDuration: widget.animationDuration,
                actionButton: widget.withStep
                    ? ActionWithStep(
                        length: _lengthShowcase(),
                        currentPage: _currentPageShowcase(),
                        skipButton: _dismissTap,
                        nextButton: _nextIfAny,
                        previousButton: _previousTap,
                        finishButton: _dismissTap,
                        textButtonStyle: TextStyle(),
                        sizeIndicatorStep: widget.sizeIndicatorStep,
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
  final VoidCallback? onTap;
  final ShapeBorder? shapeBorder;
  final BorderRadius? radius;

  _TargetWidget(
      {Key? key,
      required this.offset,
      this.size,
      this.widthAnimation,
      this.onTap,
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
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: size!.height + 16,
            width: size!.width + 16,
            decoration: ShapeDecoration(
              shape: radius != null
                  ? RoundedRectangleBorder(borderRadius: radius!)
                  : shapeBorder ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(8),
                        ),
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
      height: 38,
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
  final Size sizeIndicatorStep;

  const ActionWithStep(
      {Key? key,
      required this.length,
      required this.currentPage,
      required this.skipButton,
      required this.nextButton,
      required this.previousButton,
      required this.finishButton,
      required this.textButtonStyle,
      required this.sizeIndicatorStep})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lengthLast = length! - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: List.generate(
              length ?? 0,
              (index) => Padding(
                    padding: const EdgeInsets.only(right: 3),
                    child: Container(
                      height: sizeIndicatorStep.height,
                      width: sizeIndicatorStep.width,
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
            SizedBox(width: 15),
            currentPage == lengthLast
                ? Row(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kShowCaseNeutral0,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: previousButton,
                          icon: Center(
                            child: Icon(
                              Icons.chevron_left,
                              color: kShowCaseNeutral0,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: kShowCaseLightAccent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
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
                  )
                : Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: kShowCaseLightAccent,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
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
        )
      ],
    );
  }
}
