import 'dart:async';
import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

enum TutorialSection { home, chatbot, profile, editProfile, settings, information }

enum TutorialResult { completed, skipped, dismissed }

// STEP MODEL
class TutorialStep {
  /// Id of a [TutorialTarget]. `null` = centered modal with no spotlight.
  final String? targetId;
  final String title;
  final String description;
  final IconData icon;
  final bool circle;
  final double padding;
  final double radius;
  final Future<void> Function()? onEnter;

  const TutorialStep({
    this.targetId,
    required this.title,
    required this.description,
    this.icon = Icons.lightbulb_outline_rounded,
    this.circle = false,
    this.padding = 8,
    this.radius = 8,
    this.onEnter,
  });
}

class _Plan {
  final List<TutorialStep> steps;
  final void Function()? onClose;
  const _Plan(this.steps, {this.onClose});
}

// TARGET REGISTRY
class TutorialTarget extends StatefulWidget {
  final String id;
  final bool enabled;
  final Widget child;

  const TutorialTarget({
    super.key,
    required this.id,
    required this.child,
    this.enabled = true,
  });

  @override
  State<TutorialTarget> createState() => _TutorialTargetState();
}

class _TutorialTargetState extends State<TutorialTarget> {
  @override
  void initState() {
    super.initState();
    if (widget.enabled) TutorialTargets._add(widget.id, this);
  }

  @override
  void didUpdateWidget(covariant TutorialTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id || oldWidget.enabled != widget.enabled) {
      TutorialTargets._remove(oldWidget.id, this);
      if (widget.enabled) TutorialTargets._add(widget.id, this);
    }
  }

  @override
  void dispose() {
    TutorialTargets._remove(widget.id, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class TutorialTargets {
  TutorialTargets._();

  static final Map<String, List<_TutorialTargetState>> _targets = {};

  static void _add(String id, _TutorialTargetState s) =>
      (_targets[id] ??= []).add(s);

  static void _remove(String id, _TutorialTargetState s) {
    final list = _targets[id];
    if (list == null) return;
    list.remove(s);
    if (list.isEmpty) _targets.remove(id);
  }

  static _TutorialTargetState? _find(String id) {
    final list = _targets[id];
    if (list == null) return null;
    for (final s in list.reversed) {
      if (!s.mounted) continue;
      final ro = s.context.findRenderObject();
      if (ro is! RenderBox || !ro.attached || !ro.hasSize) continue;
      final r = ro.localToGlobal(Offset.zero) & ro.size;
      final screen = MediaQuery.sizeOf(s.context);
      if (r.center.dx < 0 || r.center.dx > screen.width) continue;
      return s;
    }
    return null;
  }

  static BuildContext? contextOf(String id) => _find(id)?.context;

  static Rect? rectOf(String id) {
    final s = _find(id);
    if (s == null) return null;
    final ro = s.context.findRenderObject();
    if (ro is! RenderBox || !ro.attached || !ro.hasSize) return null;
    return ro.localToGlobal(Offset.zero) & ro.size;
  }

  static Future<void> ensureVisible(String id) async {
    final s = _find(id);
    if (s == null) return;
    try {
      final ctx = s.context;
      if (Scrollable.maybeOf(ctx) == null) return;
      final rect = rectOf(id);
      if (rect == null) return;
      final size = MediaQuery.sizeOf(ctx);
      final top = MediaQuery.paddingOf(ctx).top + 90;
      if (rect.top < top || rect.bottom > size.height - 120) {
        await Scrollable.ensureVisible(
          ctx,
          alignment: 0.3,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
        await Future.delayed(const Duration(milliseconds: 60));
      }
    } catch (_) {
    }
  }
}

// PUBLIC API
class AppTutorial {
  AppTutorial._();

  static const _kUid = 'tutorial_uid';
  static const _kDone = 'tutorial_done';
  static const _kPending = 'tutorial_pending_at';

  static Box get _box => Hive.box('auth_box');

  static Future<void> markSignupPending() =>
      _box.put(_kPending, DateTime.now().millisecondsSinceEpoch);

  static Future<void> cancelSignupPending() => _box.delete(_kPending);

  static Future<void> begin() async {
    await _box.delete(_kPending);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _box.put(_kUid, uid);
    await _box.put(_kDone, <String>[]);
  }

  static Future<void> restart() => begin();

  static bool get _pendingRecent {
    final at = _box.get(_kPending);
    return at is int &&
        DateTime.now().millisecondsSinceEpoch - at < const Duration(minutes: 2).inMilliseconds;
  }

  static bool get isActive {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && _box.get(_kUid) == uid;
  }

  static bool _isDone(TutorialSection s) =>
      List<String>.from(_box.get(_kDone, defaultValue: <String>[]) as List)
          .contains(s.name);

  static bool shouldRun(TutorialSection s) => isActive && !_isDone(s);

  static Future<void> _markDone(TutorialSection s) async {
    final done =
        List<String>.from(_box.get(_kDone, defaultValue: <String>[]) as List);
    if (!done.contains(s.name)) done.add(s.name);
    await _box.put(_kDone, done);
  }

  static Future<void> skipAll() => _box.delete(_kUid);

  static _Session? _session;
  static final Set<TutorialSection> _waiting = {};

  static bool get isShowing => _session != null;

  static void dismiss() => _session?.close(TutorialResult.dismissed);

  /// Starts the tutorial for [section] if it is enabled and not yet seen.
  static Future<TutorialResult?> run(
      BuildContext context, TutorialSection section) async {
    if (_session != null) return null;
    final allowed = shouldRun(section) ||
        (section == TutorialSection.home && _pendingRecent);
    if (!allowed) return null;
    if (!_waiting.add(section)) return null;

    try {
      if (!await _waitUntilClear(context)) return null;
      if (!shouldRun(section) || _session != null) return null;

      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) return null;

      final session = _Session(owner: context, plan: _planFor(section));
      _session = session;
      session.entry = OverlayEntry(
        builder: (_) => _TutorialOverlay(session: session),
      );
      overlay.insert(session.entry!);

      final result = await session.completer.future;
      if (result == TutorialResult.completed ||
          result == TutorialResult.skipped) {
        await _markDone(section);
      }
      return result;
    } finally {
      _waiting.remove(section);
    }
  }

  static Future<bool> _waitUntilClear(BuildContext ctx) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final deadline = DateTime.now().add(const Duration(seconds: 25));
    while (DateTime.now().isBefore(deadline)) {
      if (!ctx.mounted) return false;
      if (_isClear(ctx)) {
        await Future.delayed(const Duration(milliseconds: 350));
        if (!ctx.mounted) return false;
        if (_isClear(ctx)) return true;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  static bool _isClear(BuildContext ctx) {
    if (!ctx.mounted) return false;

    final route = ModalRoute.of(ctx);
    if (route != null) {
      if (!route.isCurrent) return false;
      final a = route.animation;
      if (a != null && a.status != AnimationStatus.completed) return false;
    }

    final rootCtx = TutorialTargets.contextOf('sidebar.root');
    if (rootCtx != null && rootCtx.mounted) {
      final rootRoute = ModalRoute.of(rootCtx);
      if (rootRoute != null && !rootRoute.isCurrent) return false;
    }
    return true;
  }

  static Future<void> _openDrawer() async {
    final ctx = TutorialTargets.contextOf('home.menu');
    final scaffold = ctx == null ? null : Scaffold.maybeOf(ctx);
    if (scaffold == null || scaffold.isEndDrawerOpen) return;
    scaffold.openEndDrawer();
    await Future.delayed(const Duration(milliseconds: 450));
  }

  static Future<void> _closeDrawer() async {
    final ctx = TutorialTargets.contextOf('home.menu');
    final scaffold = ctx == null ? null : Scaffold.maybeOf(ctx);
    if (scaffold == null || !scaffold.isEndDrawerOpen) return;
    scaffold.closeEndDrawer();
    await Future.delayed(const Duration(milliseconds: 350));
  }

  // All tutorial text
  static _Plan _planFor(TutorialSection section) {
    switch (section) {
      case TutorialSection.home:
        return _Plan(
          [
            const TutorialStep(
              targetId: 'home.services',
              icon: Icons.list_alt_rounded,
              title: 'Service Information',
              description:
                  'Here you can find all government services. Tap a service to see the documents you need, the fees, and how long it takes. Tap "See All" to see more.',
            ),
            const TutorialStep(
              targetId: 'home.chatbot',
              circle: true,
              padding: 6,
              icon: Icons.smart_toy_outlined,
              title: 'GaBayan AI Chatbot',
              description:
                  'Need help? Tap the robot and ask your question. It can tell you which office to go to and what documents to bring.',
            ),
            const TutorialStep(
              targetId: 'home.menu',
              circle: true,
              padding: 4,
              icon: Icons.menu_rounded,
              title: 'Sidebar Menu',
              description:
                  'Tap here to open the menu. You can go to your Profile, Navigate, About and Settings. Let\'s take a look inside.',
            ),
            TutorialStep(
              targetId: 'drawer.profile',
              icon: Icons.person_outline_rounded,
              title: 'Profile',
              description:
                  'See the services you started and finished. You can also change your name, photo and password.',
              onEnter: _openDrawer,
            ),
            TutorialStep(
              targetId: 'drawer.navigate',
              icon: Icons.navigation_outlined,
              title: 'Navigate',
              description:
                  'Find the way to the office you need to visit. You can also start it from the steps of a service.',
              onEnter: _openDrawer,
            ),
            TutorialStep(
              targetId: 'drawer.settings',
              icon: Icons.settings_outlined,
              title: 'Settings',
              description:
                  'Turn on dark mode, change the language, or make the text bigger or smaller.',
              onEnter: _openDrawer,
            ),
            TutorialStep(
              icon: Icons.check_circle_outline_rounded,
              title: 'You\'re all set!',
              description:
                  'Great! When you open the chatbot, a service, your profile or settings for the first time, we will show a quick tip. You can skip anytime.',
              onEnter: _closeDrawer,
            ),
          ],
          onClose: () {
            final ctx = TutorialTargets.contextOf('home.menu');
            final scaffold = ctx == null ? null : Scaffold.maybeOf(ctx);
            if (scaffold != null && scaffold.isEndDrawerOpen) {
              scaffold.closeEndDrawer();
            }
          },
        );

      case TutorialSection.chatbot:
        return const _Plan([
          TutorialStep(
            targetId: 'chat.cards',
            icon: Icons.apps_rounded,
            title: 'Suggested Services',
            description:
                'These are common services. Tap one to see its details.',
          ),
          TutorialStep(
            targetId: 'chat.chips',
            icon: Icons.touch_app_outlined,
            title: 'Quick Replies',
            description:
                'Tap a button to go somewhere fast or see an office\'s services. No typing needed. Swipe left or right to see more.',
          ),
          TutorialStep(
            targetId: 'chat.input',
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Ask Anything',
            description:
                'Type your question here. For example: "What do I need for a business permit?"',
          ),
          TutorialStep(
            targetId: 'chat.send',
            circle: true,
            padding: 6,
            icon: Icons.send_outlined,
            title: 'Send',
            description: 'Tap to send your question. The assistant will reply in a few seconds.',
          ),
          TutorialStep(
            targetId: 'chat.search',
            circle: true,
            padding: 4,
            icon: Icons.search_rounded,
            title: 'Search Conversation',
            description: 'Tap to look for a word or message in this chat.',
          ),
          TutorialStep(
            targetId: 'chat.history',
            circle: true,
            padding: 4,
            icon: Icons.history_rounded,
            title: 'New Chat & History',
            description: 'Start a new chat, or open your old chats.',
          ),
        ]);

      case TutorialSection.profile:
        return const _Plan([
          TutorialStep(
            targetId: 'profile.edit',
            circle: true,
            padding: 6,
            icon: Icons.edit_outlined,
            title: 'Edit Profile',
            description:
                'Tap the pencil to change your photo, name or password.',
          ),
          TutorialStep(
            targetId: 'profile.history',
            icon: Icons.history_rounded,
            title: 'Service History',
            description:
                'These are the services you have tried. Tap one to continue where you stopped.',
          ),
        ]);

      case TutorialSection.editProfile:
        return const _Plan([
          TutorialStep(
            targetId: 'edit.photo',
            circle: true,
            padding: 6,
            icon: Icons.photo_camera_outlined,
            title: 'Profile Photo',
            description: 'Tap the camera to take a new photo or choose one from your phone.',
          ),
          TutorialStep(
            targetId: 'edit.username',
            icon: Icons.badge_outlined,
            title: 'Username',
            description: 'Type the name you want to use. It must have at least 8 characters.',
          ),
          TutorialStep(
            targetId: 'edit.verify',
            icon: Icons.mark_email_read_outlined,
            title: 'Verification Code',
            description:
                'Want a new password? Tap "Send Code". We will email you a code. Type it here, then tap "Verify Code".',
          ),
          TutorialStep(
            targetId: 'edit.password',
            icon: Icons.lock_outline_rounded,
            title: 'New Password',
            description:
                'This opens after your code is verified. Use at least 8 characters with a capital letter, a number and a symbol.',
          ),
        ]);

      case TutorialSection.settings:
        return const _Plan([
          TutorialStep(
            targetId: 'settings.appearance',
            icon: Icons.dark_mode_outlined,
            title: 'Appearance',
            description: 'Turn on Dark Mode for a darker screen, or change the language.',
          ),
          TutorialStep(
            targetId: 'settings.fontsize',
            icon: Icons.format_size_rounded,
            title: 'Font Size',
            description: 'Move the slider to make the text smaller or bigger.',
          ),
          TutorialStep(
            targetId: 'settings.save',
            icon: Icons.save_outlined,
            title: 'Save Changes',
            description: 'Tap Save Changes when you are done so your choices are kept.',
          ),
        ]);

      case TutorialSection.information:
        return const _Plan([
          TutorialStep(
            targetId: 'info.reminders',
            circle: true,
            padding: 4,
            icon: Icons.info_outline_rounded,
            title: 'Reminders',
            description: 'Tap here to read important reminders before you start.',
          ),
          TutorialStep(
            targetId: 'info.summary',
            icon: Icons.receipt_long_outlined,
            title: 'Transaction Summary',
            description:
                'Tap to see the fees and how long this service takes.',
          ),
          TutorialStep(
            targetId: 'info.requirements',
            icon: Icons.assignment_outlined,
            title: 'Requirements Checklist',
            description:
                'These are the documents you need to bring. Tap the box when you have each one.',
          ),
          TutorialStep(
            targetId: 'info.steps',
            icon: Icons.assignment_turned_in_outlined,
            title: 'Step-by-Step Guide',
            description:
                'Follow these steps one by one. Each step tells you where to go, the fee, and the time needed.',
          ),
          TutorialStep(
            targetId: 'info.navigate',
            icon: Icons.navigation_outlined,
            title: 'Start Navigation',
            description: 'Tap Navigate to get directions to the office for this step.',
          ),
          TutorialStep(
            targetId: 'info.complete',
            icon: Icons.check_circle_outline_rounded,
            title: 'Mark as Completed',
            description:
                'Tap this when you finish a step. It opens the next step and saves your progress.',
          ),
        ]);
    }
  }
}

// SESSION
class _Session {
  _Session({required this.owner, required this.plan});

  final BuildContext owner;
  final _Plan plan;
  final Completer<TutorialResult> completer = Completer<TutorialResult>();
  OverlayEntry? entry;

  void close(TutorialResult result) {
    if (completer.isCompleted) return;
    try {
      plan.onClose?.call();
    } catch (_) {}
    entry?.remove();
    entry = null;
    if (AppTutorial._session == this) AppTutorial._session = null;
    completer.complete(result);
  }
}

// OVERLAY UI
class _TutorialOverlay extends StatefulWidget {
  final _Session session;
  const _TutorialOverlay({required this.session});

  @override
  State<_TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<_TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  Rect _from = Rect.zero;
  Rect _to = Rect.zero;
  int _index = -1;
  bool _busy = false;
  bool _shownAny = false;
  Timer? _watchdog;

  List<TutorialStep> get _steps => widget.session.plan.steps;

  @override
  void initState() {
    super.initState();
    _watchdog = Timer.periodic(const Duration(milliseconds: 400), (_) {
      if (!widget.session.owner.mounted) {
        widget.session.close(TutorialResult.dismissed);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final c = _screenCenter();
      _from = _to = Rect.fromCenter(center: c, width: 0, height: 0);
      _go(0);
    });
  }

  @override
  void dispose() {
    _watchdog?.cancel();
    _anim.dispose();
    super.dispose();
  }

  Offset _screenCenter() => MediaQuery.sizeOf(context).center(Offset.zero);

  Rect _currentRect() {
    final t = Curves.easeInOutCubic.transform(_anim.value);
    return Rect.lerp(_from, _to, t) ?? _to;
  }

  Future<void> _go(int target) async {
    if (_busy) return;
    _busy = true;
    try {
      var i = target;
      while (i < _steps.length) {
        final step = _steps[i];
        await step.onEnter?.call();
        if (!mounted) return;

        Rect? rect;
        if (step.targetId != null) {
          await TutorialTargets.ensureVisible(step.targetId!);
          rect = await _resolve(step.targetId!);
          if (!mounted) return;
          if (rect == null) {
            i++;
            continue;
          }
        }
        _show(i, rect, step);
        return;
      }
      widget.session.close(
        _shownAny ? TutorialResult.completed : TutorialResult.dismissed,
      );
    } finally {
      _busy = false;
    }
  }

  Future<Rect?> _resolve(String id) async {
    final deadline = DateTime.now().add(const Duration(milliseconds: 2500));
    Rect? last;
    while (DateTime.now().isBefore(deadline)) {
      if (!mounted) return null;
      final r = TutorialTargets.rectOf(id);
      if (r != null &&
          last != null &&
          (r.center - last.center).distance < 1.5 &&
          (r.width - last.width).abs() < 1.5 &&
          (r.height - last.height).abs() < 1.5) {
        return r;
      }
      last = r;
      await Future.delayed(const Duration(milliseconds: 90));
    }
    return last;
  }

  Rect _inflate(Rect r, TutorialStep s) {
    if (s.circle) {
      return Rect.fromCircle(
        center: r.center,
        radius: math.max(r.width, r.height) / 2 + s.padding,
      );
    }
    return r.inflate(s.padding);
  }

  void _show(int index, Rect? rect, TutorialStep step) {
    _shownAny = true;
    final prev = _currentRect();
    final Rect next = rect == null
        ? Rect.fromCenter(center: _screenCenter(), width: 0, height: 0)
        : _inflate(rect, step);
    setState(() {
      _from = (prev.isEmpty && !next.isEmpty)
          ? Rect.fromCenter(center: next.center, width: 0, height: 0)
          : prev;
      _to = next;
      _index = index;
    });
    _anim
      ..reset()
      ..forward();
  }

  void _next() {
    if (_busy || _index < 0) return;
    if (_index >= _steps.length - 1) {
      widget.session.close(TutorialResult.completed);
    } else {
      _go(_index + 1);
    }
  }

  void _skip() => widget.session.close(TutorialResult.skipped);

  @override
  Widget build(BuildContext context) {
    final step = _index >= 0 ? _steps[_index] : null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 250),
      builder: (context, opacity, child) =>
          Opacity(opacity: opacity, child: child),
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
                child: AnimatedBuilder(
                  animation: _anim,
                  builder: (_, __) => _index < 0
                      ? const SizedBox.expand()
                      : CustomPaint(
                    painter: _SpotlightPainter(
                      rect: _currentRect(),
                      radius: step?.radius ?? 8,
                      circle: step?.circle ?? false,
                    ),
                  ),
                ),
              ),
            ),
            if (step != null)
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  child: KeyedSubtree(
                    key: ValueKey(_index),
                    child: _buildCardLayer(context, step),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardLayer(BuildContext context, TutorialStep step) {
    final mq = MediaQuery.of(context);
    final screen = mq.size;
    final rect = _to;
    const margin = 20.0;
    const gap = 16.0;
    const cardMax = 260.0;

    final card = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: _TutorialCard(
          step: step,
          index: _index,
          total: _steps.length,
          onNext: _next,
          onSkip: _skip,
        ),
      ),
    );

    if (rect.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: margin),
        child: card,
      );
    }

    final spaceBelow = screen.height - rect.bottom - mq.padding.bottom;
    final spaceAbove = rect.top - mq.padding.top;
    final preferBelow = rect.center.dy < screen.height * 0.5;

    Positioned place;
    if (preferBelow && spaceBelow >= cardMax) {
      place = Positioned(left: margin, right: margin, top: rect.bottom + gap, child: card);
    } else if (!preferBelow && spaceAbove >= cardMax) {
      place = Positioned(
          left: margin, right: margin, bottom: screen.height - rect.top + gap, child: card);
    } else if (spaceBelow >= cardMax) {
      place = Positioned(left: margin, right: margin, top: rect.bottom + gap, child: card);
    } else if (spaceAbove >= cardMax) {
      place = Positioned(
          left: margin, right: margin, bottom: screen.height - rect.top + gap, child: card);
    } else {
      place = Positioned(
          left: margin, right: margin, bottom: mq.padding.bottom + margin, child: card);
    }
    return Stack(children: [place]);
  }
}

class _TutorialCard extends StatelessWidget {
  final TutorialStep step;
  final int index;
  final int total;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _TutorialCard({
    required this.step,
    required this.index,
    required this.total,
    required this.onNext,
    required this.onSkip,
  });

  static const Color _blue = Color(0xFF2057CE);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = index >= total - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      decoration: BoxDecoration(
        color: isDark ? cs.tertiary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.5,
              color: cs.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              isLast
                  ? const SizedBox(width: 48, height: 40)
                  : TextButton(
                      onPressed: onSkip,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        minimumSize: const Size(48, 40),
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
              TextButton(
                onPressed: onNext,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(48, 40),
                ),
                child: Text(
                  isLast ? 'Got it' : 'Next',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _blue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect rect;
  final double radius;
  final bool circle;

  _SpotlightPainter({
    required this.rect,
    required this.radius,
    required this.circle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hasHole = rect.width > 1 && rect.height > 1;

    final scrim = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);

    Path? hole;
    if (hasHole) {
      hole = Path();
      if (circle) {
        hole.addOval(rect);
      } else {
        hole.addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
      }
      scrim.addPath(hole, Offset.zero);
    }

    canvas.drawPath(scrim, Paint()..color = Colors.black.withValues(alpha: 0.45));

    if (hole != null) {
      canvas.drawPath(
        hole,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFF2057CE),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) =>
      old.rect != rect || old.circle != circle || old.radius != radius;
}