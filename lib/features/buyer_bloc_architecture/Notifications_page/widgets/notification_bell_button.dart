import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/repositories/i_buyer_notification_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/i_auth_service.dart';
import '../../../../repositories/firebase_buyer_notification_repository.dart';

import '../buyer_notification_bloc.dart';
import '../buyer_notification_event.dart';
import '../buyer_notification_service.dart';
import '../buyer_notification_state.dart';
import '../buyer_notification_ui.dart';

/// Self-contained bell button with a real-time unread badge and micro-pulse
/// animation. Tapping it opens the [BuyerNotificationPageUI].
class NotificationBellButton extends StatefulWidget {
  final IBuyerNotificationRepository? repository;
  final BuyerNotificationService? service;
  final IAuthService? authService;

  const NotificationBellButton({
    super.key,
    this.repository,
    this.service,
    this.authService,
  });

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  BuyerNotificationBloc? _bloc;

  IAuthService _resolveAuth(BuildContext context) {
    try {
      return context.read<IAuthService>();
    } catch (_) {
      return FirebaseAuthService();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bloc == null) {
      final auth = widget.authService ?? _resolveAuth(context);
      final repo = widget.repository ?? FirebaseBuyerNotificationRepository();
      final svc = widget.service ?? BuyerNotificationService();
      _bloc = BuyerNotificationBloc(repository: repo, service: svc);
      final uid = auth.currentUserId;
      if (uid != null && uid.isNotEmpty) {
        _bloc!.add(StartListeningNotifications(uid));
      }
    }
  }

  @override
  void dispose() {
    _bloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BuyerNotificationBloc, BuyerNotificationState>(
      bloc: _bloc,
      builder: (context, state) {
        final unread =
            state is BuyerNotificationLoaded ? state.unreadCount : 0;
        return _BellBadge(
          unread: unread,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BuyerNotificationPageUI(
                  repository: widget.repository,
                  service: widget.service,
                  authService: widget.authService,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BellBadge extends StatefulWidget {
  final int unread;
  final VoidCallback onTap;

  const _BellBadge({required this.unread, required this.onTap});

  @override
  State<_BellBadge> createState() => _BellBadgeState();
}

class _BellBadgeState extends State<_BellBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _prevUnread = 0;

  @override
  void initState() {
    super.initState();
    _prevUnread = widget.unread;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
  }

  @override
  void didUpdateWidget(covariant _BellBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unread > _prevUnread) {
      _controller.forward(from: 0);
    }
    _prevUnread = widget.unread;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF1C1C1C),
              size: 22,
            ),
            if (widget.unread > 0)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = 1.0 +
                      (_controller.value < 0.5
                          ? _controller.value * 2 * 0.4
                          : (1.0 - _controller.value) * 2 * 0.4);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE52121),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.unread > 99 ? '99+' : '${widget.unread}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
