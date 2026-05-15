import 'package:flutter/material.dart';

class SlideRoute extends PageRouteBuilder {
  final Widget page;
  SlideRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOutQuint;

            final inTween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .chain(CurveTween(curve: curve));

            final outTween = Tween(begin: Offset.zero, end: const Offset(-0.3, 0.0))
                .chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(inTween),
              child: SlideTransition(
                position: secondaryAnimation.drive(outTween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 400),
        );
}

class TabSwitcher extends StatelessWidget {
  final int currentIndex;
  final int previousIndex;
  final Widget child;

  const TabSwitcher({
    super.key,
    required this.currentIndex,
    required this.previousIndex,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOutQuint,
      switchOutCurve: Curves.easeInOutQuint,
      transitionBuilder: (child, animation) {
        final isForward = currentIndex >= previousIndex;
        final isIncoming = (child.key as ValueKey?)?.value == currentIndex;
        final inOffset = Tween<Offset>(
          begin: Offset(isForward ? 1.0 : -1.0, 0),
          end: Offset.zero,
        ).animate(animation);
        final outOffset = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(isForward ? -0.3 : 0.3, 0),
        ).animate(animation);
        return SlideTransition(
          position: isIncoming ? inOffset : outOffset,
          child: child,
        );
      },
      child: KeyedSubtree(
        key: ValueKey(currentIndex),
        child: child,
      ),
    );
  }
}
