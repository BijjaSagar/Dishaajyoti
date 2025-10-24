import 'package:flutter/material.dart';

/// Custom page transition builders for navigation
class PageTransitions {
  /// Slide transition from right to left
  /// Duration: 300ms
  static Route<T> slideTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// Slide transition from bottom to top
  /// Duration: 300ms
  static Route<T> slideUpTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return slideTransition<T>(
      page,
      duration: duration,
      begin: const Offset(0.0, 1.0),
    );
  }

  /// Slide transition from left to right
  /// Duration: 300ms
  static Route<T> slideLeftTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return slideTransition<T>(
      page,
      duration: duration,
      begin: const Offset(-1.0, 0.0),
    );
  }

  /// Fade transition
  /// Duration: 300ms
  static Route<T> fadeTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// Scale transition (zoom in/out)
  /// Duration: 300ms
  static Route<T> scaleTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.8,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final scaleTween = Tween<double>(
          begin: beginScale,
          end: 1.0,
        );

        return ScaleTransition(
          scale: scaleTween.animate(curvedAnimation),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// Combined fade and scale transition
  /// Duration: 300ms
  static Route<T> fadeScaleTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 0.9,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final scaleTween = Tween<double>(
          begin: beginScale,
          end: 1.0,
        );

        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: scaleTween.animate(curvedAnimation),
            child: child,
          ),
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// Slide and fade combined transition
  /// Duration: 300ms
  static Route<T> slideFadeTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final tween = Tween(begin: begin, end: end);
        final offsetAnimation = tween.animate(curvedAnimation);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// Rotation transition
  /// Duration: 400ms
  static Route<T> rotationTransition<T>(
    Widget page, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        final rotationTween = Tween<double>(
          begin: 0.0,
          end: 1.0,
        );

        return RotationTransition(
          turns: rotationTween.animate(curvedAnimation),
          child: child,
        );
      },
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }

  /// No transition (instant)
  static Route<T> noTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }

  /// Material page route (default Flutter transition)
  static Route<T> materialTransition<T>(Widget page) {
    return MaterialPageRoute<T>(
      builder: (context) => page,
    );
  }

  /// Custom transition with both primary and secondary animations
  /// Useful for creating complex transition effects
  static Route<T> customTransition<T>(
    Widget page, {
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) transitionsBuilder,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: transitionsBuilder,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
    );
  }
}

/// Extension on BuildContext for easy navigation with transitions
extension NavigationExtensions on BuildContext {
  /// Navigate to a new page with slide transition
  Future<T?> pushWithSlide<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.slideTransition(page),
    );
  }

  /// Navigate to a new page with fade transition
  Future<T?> pushWithFade<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.fadeTransition(page),
    );
  }

  /// Navigate to a new page with scale transition
  Future<T?> pushWithScale<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.scaleTransition(page),
    );
  }

  /// Navigate to a new page with fade and scale transition
  Future<T?> pushWithFadeScale<T>(Widget page) {
    return Navigator.of(this).push<T>(
      PageTransitions.fadeScaleTransition(page),
    );
  }

  /// Replace current page with slide transition
  Future<T?> pushReplacementWithSlide<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageTransitions.slideTransition(page),
    );
  }

  /// Replace current page with fade transition
  Future<T?> pushReplacementWithFade<T, TO>(Widget page) {
    return Navigator.of(this).pushReplacement<T, TO>(
      PageTransitions.fadeTransition(page),
    );
  }
}
