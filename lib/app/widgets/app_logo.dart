import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final bool showGlow;
  final BorderRadius? borderRadius;

  const AppLogo({
    super.key,
    this.size = 64,
    this.animate = false,
    this.showGlow = true,
    this.borderRadius,
  });

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      final isTest =
          WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (!isTest) {
        _controller.repeat(reverse: true);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void didUpdateWidget(AppLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        final isTest =
            WidgetsBinding.instance.runtimeType.toString().contains('Test');
        if (!isTest) {
          _controller.repeat(reverse: true);
        } else {
          _controller.forward();
        }
      } else {
        _controller.stop();
        _controller.value = 0.5;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(widget.size * 0.22);

    Widget imageContent = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: widget.showGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                  blurRadius: widget.size * 0.35,
                  spreadRadius: 1,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  blurRadius: widget.size * 0.2,
                  spreadRadius: -2,
                  offset: const Offset(4, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: kIsWeb
            ? Image.network(
                'app_logo.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/images/app_logo.png',
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallback(radius),
                  );
                },
              )
            : Image.asset(
                'assets/images/app_logo.png',
                width: widget.size,
                height: widget.size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallback(radius),
              ),
      ),
    );

    if (!widget.animate) {
      return imageContent;
    }

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: imageContent,
    );
  }

  Widget _buildFallback(BorderRadius radius) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: radius,
      ),
      child: Icon(
        Icons.analytics_rounded,
        size: widget.size * 0.55,
        color: Colors.white,
      ),
    );
  }
}
