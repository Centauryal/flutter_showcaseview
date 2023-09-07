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
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/colors.dart';
import 'enum.dart';
import 'get_position.dart';
import 'layout_overlays.dart';
import 'shape_clipper.dart';
import 'showcase_widget.dart';
import 'tooltip_widget.dart';

class Showcase extends StatefulWidget {
  /// A key that is unique across the entire app.
  ///
  /// This Key will be used to control state of individual showcase and also
  /// used in [ShowCaseWidgetState.startShowCase] to define position of current
  /// target widget while showcasing.
  @override
  final GlobalKey key;

  /// Target widget that will be showcased or highlighted
  final Widget child;
  final bool withStep;
  final ShapeBorder? shapeBorder;
  final EdgeInsets contentPadding;
  final VoidCallback? onFinishClick;
  final EdgeInsets overlayPadding;
  final Widget infoContent;

  /// Represents subject line of target widget
  final String? title;

  /// Title alignment with in tooltip widget
  ///
  /// Defaults to [TextAlign.start]
  final TextAlign titleAlignment;

  /// Represents summary description of target widget
  final String? description;

  /// ShapeBorder of the highlighted box when target widget will be showcased.
  ///
  /// Note: If [targetBorderRadius] is specified, this parameter will be ignored.
  ///
  /// Default value is:
  /// ```dart
  /// RoundedRectangleBorder(
  ///   borderRadius: BorderRadius.all(Radius.circular(8)),
  /// ),
  /// ```
  final ShapeBorder targetShapeBorder;

  /// Radius of rectangle box while target widget is being showcased.
  final BorderRadius? targetBorderRadius;

  /// TextStyle for default tooltip title
  final TextStyle? titleTextStyle;

  /// TextStyle for default tooltip description
  final TextStyle? descTextStyle;

  /// Empty space around tooltip content.
  ///
  /// Default Value for [Showcase] widget is:
  /// ```dart
  /// EdgeInsets.symmetric(vertical: 8, horizontal: 8)
  /// ```
  final EdgeInsets tooltipPadding;

  /// Background color of overlay during showcase.
  ///
  /// Default value is [Colors.black45]
  final Color overlayColor;

  /// Opacity apply on [overlayColor] (which ranges from 0.0 to 1.0)
  ///
  /// Default to 0.75
  final double overlayOpacity;

  /// Custom tooltip widget when [Showcase.withWidget] is used.
  final Widget? container;

  /// Defines background color for tooltip widget.
  ///
  /// Default to [Colors.white]
  final Color tooltipBackgroundColor;

  /// Defines text color of default tooltip when [titleTextStyle] and
  /// [descTextStyle] is not provided.
  ///
  /// Default to [Colors.black]
  final Color textColor;

  /// If [enableAutoScroll] is sets to `true`, this widget will be shown above
  /// the overlay until the target widget is visible in the viewport.
  final Widget scrollLoadingWidget;

  /// Whether the default tooltip will have arrow to point out the target widget.
  ///
  /// Default to `true`
  final bool showArrow;

  /// Height of [container]
  final double? height;

  /// Width of [container]
  final double? width;

  /// The duration of time the bouncing animation of tooltip should last.
  ///
  /// Default to [Duration(milliseconds: 2000)]
  final Duration movingAnimationDuration;

  /// Triggered when default tooltip is tapped
  final VoidCallback? onToolTipClick;

  /// Triggered when showcased target widget is tapped
  ///
  /// Note: [disposeOnTap] is required if you're using [onTargetClick]
  /// otherwise throws error
  final VoidCallback? onTargetClick;

  /// Will dispose all showcases if tapped on target widget or tooltip
  ///
  /// Note: [onTargetClick] is required if you're using [disposeOnTap]
  /// otherwise throws error
  final bool? disposeOnTap;

  /// Whether tooltip should have bouncing animation while showcasing
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.disableAnimation] will be considered.
  final bool? disableMovingAnimation;

  /// Whether disabling initial scale animation for default tooltip when
  /// showcase is started and completed
  ///
  /// Default to `false`
  final bool? disableScaleAnimation;

  /// Padding around target widget
  ///
  /// Default to [EdgeInsets.zero]
  final EdgeInsets targetPadding;

  /// Triggered when target has been double tapped
  final VoidCallback? onTargetDoubleTap;

  /// Triggered when target has been long pressed.
  ///
  /// Detected when a pointer has remained in contact with the screen at the same location for a long period of time.
  final VoidCallback? onTargetLongPress;

  /// Border Radius of default tooltip
  ///
  /// Default to [BorderRadius.circular(8)]
  final BorderRadius? tooltipBorderRadius;

  /// Description alignment with in tooltip widget
  ///
  /// Defaults to [TextAlign.start]
  final TextAlign descriptionAlignment;

  /// if `disableDefaultTargetGestures` parameter is true
  /// onTargetClick, onTargetDoubleTap, onTargetLongPress and
  /// disposeOnTap parameter will not work
  ///
  /// Note: If `disableDefaultTargetGestures` is true then make sure to
  /// dismiss current showcase with `ShowCaseWidget.of(context).dismiss()`
  /// if you are navigating to other screen. This will be handled by default
  /// if `disableDefaultTargetGestures` is set to false.
  final bool disableDefaultTargetGestures;

  /// Defines blur value.
  /// This will blur the background while displaying showcase.
  ///
  /// If null value is provided,
  /// [ShowCaseWidget.blurValue] will be considered.
  ///
  final double? blurValue;

  /// A duration for animation which is going to played when
  /// tooltip comes first time in the view.
  ///
  /// Defaults to 300 ms.
  final Duration scaleAnimationDuration;

  /// The curve to be used for initial animation of tooltip.
  ///
  /// Defaults to Curves.easeIn
  final Curve scaleAnimationCurve;

  /// An alignment to origin of initial tooltip animation.
  ///
  /// Alignment will be pre-calculated but if pre-calculated
  /// alignment doesn't work then this parameter can be
  /// used to customise the direction of the tooltip animation.
  ///
  /// eg.
  /// ```dart
  ///     Alignment(-0.2,0.3) or Alignment.centerLeft
  /// ```
  final Alignment? scaleAnimationAlignment;

  /// Defines vertical position of tooltip respective to Target widget
  ///
  /// Defaults to adaptive into available space.
  final TooltipPosition? tooltipPosition;

  /// Provides padding around the title. Default padding is zero.
  final EdgeInsets? titlePadding;

  /// Provides padding around the description. Default padding is zero.
  final EdgeInsets? descriptionPadding;

  /// Provides text direction of tooltip title.
  final TextDirection? titleTextDirection;

  /// Provides text direction of tooltip description.
  final TextDirection? descriptionTextDirection;

  /// Provides a callback when barrier has been clicked.
  ///
  /// Note-: Even if barrier interactions are disabled, this handler
  /// will still provide a callback.
  final VoidCallback? onBarrierClick;

  Showcase({
    required this.key,
    required this.child,
    required this.infoContent,
    this.withStep = false,
    this.shapeBorder,
    this.onFinishClick,
    EdgeInsets? contentPadding,
    this.overlayPadding = EdgeInsets.zero,
    this.title,
    this.titleAlignment = TextAlign.start,
    this.descriptionAlignment = TextAlign.start,
    this.targetShapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.tooltipBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.scrollLoadingWidget = const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.white),
    ),
    this.showArrow = true,
    this.onTargetClick,
    this.disposeOnTap,
    this.movingAnimationDuration = const Duration(milliseconds: 2000),
    this.disableMovingAnimation,
    this.disableScaleAnimation,
    this.tooltipPadding =
        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.onToolTipClick,
    this.targetPadding = EdgeInsets.zero,
    this.blurValue,
    this.targetBorderRadius,
    this.onTargetLongPress,
    this.onTargetDoubleTap,
    this.tooltipBorderRadius,
    this.disableDefaultTargetGestures = false,
    this.scaleAnimationDuration = const Duration(milliseconds: 300),
    this.scaleAnimationCurve = Curves.easeIn,
    this.scaleAnimationAlignment,
    this.tooltipPosition,
    this.titlePadding,
    this.descriptionPadding,
    this.titleTextDirection,
    this.descriptionTextDirection,
    this.onBarrierClick,
    this.description,
  })  : height = null,
        width = null,
        container = null,
        contentPadding = contentPadding ?? EdgeInsets.all(16.w),
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity must be between 0 and 1."),
        assert(onTargetClick == null || disposeOnTap != null,
            "disposeOnTap is required if you're using onTargetClick"),
        assert(disposeOnTap == null || onTargetClick != null,
            "onTargetClick is required if you're using disposeOnTap");

  const Showcase.withWidget({
    required this.key,
    required this.height,
    required this.width,
    required this.container,
    required this.child,
    this.targetShapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8),
      ),
    ),
    this.overlayColor = Colors.black45,
    this.targetBorderRadius,
    this.overlayOpacity = 0.75,
    this.scrollLoadingWidget = const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation(Colors.white)),
    this.onTargetClick,
    this.disposeOnTap,
    this.movingAnimationDuration = const Duration(milliseconds: 2000),
    this.disableMovingAnimation,
    this.targetPadding = EdgeInsets.zero,
    this.blurValue,
    this.onTargetLongPress,
    this.onTargetDoubleTap,
    this.disableDefaultTargetGestures = false,
    this.tooltipPosition,
    this.onBarrierClick,
    required this.withStep,
    this.shapeBorder,
    required this.contentPadding,
    this.onFinishClick,
    required this.overlayPadding,
    required this.infoContent,
  })  : showArrow = false,
        onToolTipClick = null,
        scaleAnimationDuration = const Duration(milliseconds: 300),
        scaleAnimationCurve = Curves.decelerate,
        scaleAnimationAlignment = null,
        disableScaleAnimation = null,
        title = null,
        description = null,
        titleAlignment = TextAlign.start,
        descriptionAlignment = TextAlign.start,
        titleTextStyle = null,
        descTextStyle = null,
        tooltipBackgroundColor = Colors.white,
        textColor = Colors.black,
        tooltipBorderRadius = null,
        tooltipPadding = const EdgeInsets.symmetric(vertical: 8),
        titlePadding = null,
        descriptionPadding = null,
        titleTextDirection = null,
        descriptionTextDirection = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity must be between 0 and 1.");

  @override
  State<Showcase> createState() => _ShowcaseState();
}

class _ShowcaseState extends State<Showcase> {
  bool _showShowCase = false;
  bool _enableShowcase = true;
  Timer? timer;
  GetPosition? position;

  ShowCaseWidgetState get showCaseWidgetState => ShowCaseWidget.of(context);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enableShowcase = showCaseWidgetState.enableShowcase;

    if (_enableShowcase) {
      position ??= GetPosition(
        key: widget.key,
        padding: widget.targetPadding,
        screenWidth: MediaQuery.of(context).size.width,
        screenHeight: MediaQuery.of(context).size.height,
      );
      showOverlay();
    }
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
    if (_enableShowcase) {
      return AnchoredOverlay(
        overlayBuilder: (context, rectBound, offset) {
          final size = MediaQuery.of(context).size;
          position = GetPosition(
            key: widget.key,
            padding: widget.targetPadding,
            screenWidth: size.width,
            screenHeight: size.height,
          );
          return buildOverlayOnTarget(offset, rectBound.size, rectBound, size);
        },
        showOverlay: true,
        child: widget.child,
      );
    }
    return widget.child;
  }

  Future<void> _nextIfAny() async {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    } else if (timer != null && !timer!.isActive) {
      timer = null;
    }
    showCaseWidgetState.completed(widget.key);
  }

  void _dismissTap() {
    widget.onFinishClick?.call();
    ShowCaseWidget.of(context).dismiss();
  }

  void _previousTap() {
    ShowCaseWidget.of(context).previous();
  }

  int? _lengthShowcase() {
    return ShowCaseWidget.of(context).ids?.length ?? 0;
  }

  int? _currentPageShowcase() {
    return ShowCaseWidget.of(context).activeWidgetId;
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
  final ShapeBorder? shapeBorder;

  const _TargetWidget({
    Key? key,
    required this.offset,
    this.size,
    this.shapeBorder,
  }) : super(key: key);

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
            shape: shapeBorder ??
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
                        .bodySmall
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
