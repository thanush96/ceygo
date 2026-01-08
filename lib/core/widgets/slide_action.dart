import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ceygo_app/core/theme/app_theme.dart'; // Corrected import path

class SlideAction extends StatefulWidget {
  final VoidCallback onSubmit;
  final String text;

  const SlideAction({super.key, required this.onSubmit, this.text = ''});

  @override
  State<SlideAction> createState() => _SlideActionState();
}

class _SlideActionState extends State<SlideAction>
    with TickerProviderStateMixin {
  double _dragPosition = 0;
  bool _isDragging = false;
  bool _isCompleting = false;
  late AnimationController _resetController;
  late AnimationController _shimmerController;
  late Animation<double> _resetAnimation;
  late Animation<double> _shimmerAnimation;

  final double _threshold = 0.85; // 85% slide to trigger action

  @override
  void initState() {
    super.initState();

    // Reset animation controller
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _resetAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        _dragPosition = _resetAnimation.value;
      });
    });

    // Shimmer animation for text
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _resetController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isCompleting) return;

    setState(() {
      _dragPosition += details.delta.dx;
      // Only allow sliding to the right, constrain to slider width minus button
      final maxDragDistance = maxWidth - 80; // 80 is button width + padding
      _dragPosition = _dragPosition.clamp(0, maxDragDistance);
    });

    // Haptic feedback at certain progress points
    final progress = _dragPosition / (maxWidth - 80);
    if (progress > 0.5 && progress < 0.52) {
      HapticFeedback.selectionClick();
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) {
    if (_isCompleting) return;

    final maxDragDistance = maxWidth - 80;
    final threshold = maxDragDistance * _threshold;

    setState(() {
      _isDragging = false;
    });

    if (_dragPosition > threshold) {
      // Completed slide - Accept
      _completeSlide(maxDragDistance);
    } else {
      // Not far enough - Reset
      HapticFeedback.lightImpact();
      _resetToStart();
    }
  }

  void _completeSlide(double maxDistance) {
    setState(() {
      _isCompleting = true;
    });

    // Animate to end
    _resetAnimation = Tween<double>(
      begin: _dragPosition,
      end: maxDistance,
    ).animate(CurvedAnimation(parent: _resetController, curve: Curves.easeOut));

    _resetController.reset();
    _resetController.forward().then((_) {
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 200), () {
        widget.onSubmit();
        // Reset after action
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isCompleting = false;
            });
            _resetToStart();
          }
        });
      });
    });
  }

  void _resetToStart() {
    _resetAnimation = Tween<double>(begin: _dragPosition, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );

    _resetController.reset();
    _resetController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxDragDistance = maxWidth - 80;
        final progress = _dragPosition / maxDragDistance;

        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: const Color(
              0xFF1A1A1A,
            ).withOpacity(0.1), // Adjusted for glassmorphism
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: const Color(0xFFFFFF).withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Progress fill
              AnimatedContainer(
                duration:
                    _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                height: 80,
                width: _dragPosition + 75,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.2),
                      AppTheme.primaryColor.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(55),
                ),
              ),

              // Sliding text with shimmer effect
              Center(
                child: AnimatedOpacity(
                  opacity:
                      _isCompleting
                          ? 0.0
                          : 1.0 - (progress * 1.5).clamp(0.0, 1.0),
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedBuilder(
                    animation: _shimmerAnimation,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment(_shimmerAnimation.value, 0),
                            end: Alignment(_shimmerAnimation.value + 1, 0),
                            colors: const [
                              Colors.white70,
                              Colors.white,
                              Colors.white70,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ).createShader(bounds);
                        },
                        child: Text(
                          widget.text,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Success check icon
              // if (_isCompleting)
              //   const Center(
              //     child: Icon(
              //       Icons.check_circle,
              //       color: AppTheme.successColor,
              //       size: 32,
              //     ),
              //   ),

              // Draggable button
              AnimatedPositioned(
                duration:
                    _isDragging
                        ? Duration.zero
                        : const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                left: 5 + _dragPosition,
                top: 5,
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _isDragging = true;
                    });
                    HapticFeedback.lightImpact();
                  },
                  onHorizontalDragUpdate: (details) {
                    _onHorizontalDragUpdate(details, maxWidth);
                  },
                  onHorizontalDragEnd: (details) {
                    _onHorizontalDragEnd(details, maxWidth);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    height: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient:
                      // _isCompleting
                      //     ? LinearGradient(
                      //       colors: [
                      //         AppTheme.successColor,
                      //         AppTheme.successColor.withOpacity(0.8),
                      //       ],
                      //     )
                      //     :
                      LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isCompleting
                                  ? AppTheme.successColor
                                  : AppTheme.primaryColor)
                              .withOpacity(0.4),
                          blurRadius: _isDragging ? 20 : 12,
                          offset: const Offset(0, 4),
                          spreadRadius: _isDragging ? 2 : 0,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isCompleting
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
