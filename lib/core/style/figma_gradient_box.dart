import 'package:flutter/material.dart';

class FigmaGradientBox extends StatefulWidget {
  final double figmaWidth;
  final double figmaHeight;
  final Offset gradientStart;
  final Offset gradientEnd;
  final List<Color> colors;
  final List<double> stops;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const FigmaGradientBox({
    super.key,
    required this.figmaWidth,
    required this.figmaHeight,
    required this.gradientStart,
    required this.gradientEnd,
    required this.colors,
    required this.stops,
    required this.borderRadius,
    required this.padding,
    required this.child,
  });

  @override
  State<FigmaGradientBox> createState() => _FigmaGradientBoxState();
}

class _FigmaGradientBoxState extends State<FigmaGradientBox> {
  final GlobalKey _boxKey = GlobalKey();
  Size? _measuredSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    final renderBox = _boxKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;
    final newSize = renderBox.size;
    if (_measuredSize == newSize) return;
    setState(() => _measuredSize = newSize);
  }

  @override
  void didUpdateWidget(covariant FigmaGradientBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  Alignment _toAlignment(Offset point, double width, double height) {
    final relX = point.dx / width;
    final relY = point.dy / height;
    return Alignment(relX * 2 - 1, relY * 2 - 1);
  }

  @override
  Widget build(BuildContext context) {
    final width = _measuredSize?.width ?? widget.figmaWidth;
    final height = _measuredSize?.height ?? widget.figmaHeight;

    return Container(
      key: _boxKey,
      width: double.infinity,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        gradient: LinearGradient(
          begin: _toAlignment(widget.gradientStart, width, height),
          end: _toAlignment(widget.gradientEnd, width, height),
          colors: widget.colors,
          stops: widget.stops,
        ),
      ),
      child: widget.child,
    );
  }
}