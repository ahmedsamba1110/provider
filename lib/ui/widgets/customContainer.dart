import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.padding,
    this.margin,
    this.child,
    this.decoration,
    this.constraints,
    this.clipBehavior,
    this.alignment,
  });

  final Clip? clipBehavior;
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;
  final AlignmentGeometry? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      clipBehavior: clipBehavior ?? Clip.none,
      constraints: constraints,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: decoration ??
          BoxDecoration(borderRadius: BorderRadius.circular(borderRadius ?? 0), color: color),
      child: child,
    );
  }
}
