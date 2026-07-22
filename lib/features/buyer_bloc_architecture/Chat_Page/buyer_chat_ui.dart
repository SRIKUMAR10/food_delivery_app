import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/buyer_bloc_architecture/Chat_Page/custom_camera_page.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'buyer_chat_bloc.dart';
import 'buyer_chat_event.dart';
import 'buyer_chat_state.dart';
import '../../../core/repositories/i_chat_repository.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/chat_message_model.dart';
import '../../../core/models/order_model.dart';
import '../../../core/models/order_status.dart';
import '../../../core/repositories/i_order_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'audio_widgets.dart';
import 'invoice_generator.dart';
import 'video_call_page.dart';
import 'voice_call_page.dart';
import '../Rating_page/Rating_page_ui.dart';
import '../Track_Order_page/Track_Order_page_ui.dart';
import '../Cart Page/cart_page_Bloc.dart';
import '../Order Page/order_view_model.dart';
import '../Cart Page/cart_models.dart';
import '../Cart Page/cart_page_UI.dart';
import '../FoodGoLoginScreen/FoodGoLoginScreen_UI.dart';

class _AppTheme {
  _AppTheme._();

  // Premium Colors
  static const Color primary = Color(0xFFEF4444);
  static const Color primaryLight = Color(0xFFFF6B6B);
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutrals
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color surfaceHover = Color(0xFFF1F3F5);
  static const Color surfaceActive = Color(0xFFF8FAFC);

  // Glassmorphism
  static const Color glassBg = Color(0xBBFFFFFF);
  static const Color glassBorder = Color(0x80FFFFFF);

  // Chat specific
  static const Color bubbleMine = Color(0xFFEF4444);
  static const Color bubbleOther = Color(0xFFFFFFFF);
  static const Color chatBgStart = Color(0xFFFAFAFA);
  static const Color chatBgEnd = Color(0xFFF4F6F8);

  // Spacing
  static const double pagePadding = 24.0;
  static const double cardPadding = 20.0;
  static const double messageSpacing = 16.0;
  static const double sectionGap = 20.0;
  static const double headerHeight = 80.0;
  static const double inputHeight = 64.0;

  // Radius
  static const double cardRadius = 22.0;
  static const double bubbleRadius = 18.0;
  static const double searchRadius = 18.0;
  static const double inputRadius = 30.0;
  static const double avatarRadius = 30.0;
  static const double badgeRadius = 20.0;
  static const double buttonRadius = 14.0;

  // Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get bubbleShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );
  static const LinearGradient chatBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAFAFA), Color(0xFFF4F6F8)],
  );

  // Duration
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration normalDuration = Duration(milliseconds: 250);
  static const Duration slowDuration = Duration(milliseconds: 350);
}

class ChatBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    final dotPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    const double spacing = 60.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw a mix of tiny dots, crosses, and small circles
        final mod = ((x + y) / spacing).round() % 3;
        
        if (mod == 0) {
          canvas.drawCircle(Offset(x + spacing/2, y + spacing/2), 1.5, dotPaint);
        } else if (mod == 1) {
          // Draw small plus
          final cx = x + spacing/2;
          final cy = y + spacing/2;
          canvas.drawLine(Offset(cx - 3, cy), Offset(cx + 3, cy), paint);
          canvas.drawLine(Offset(cx, cy - 3), Offset(cx, cy + 3), paint);
        } else {
          // Draw a small outline circle
          canvas.drawCircle(Offset(x + spacing/2, y + spacing/2), 3.0, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SupportNavigationData {
  final String orderId;
  final String sellerId;
  final String sellerName;
  final String buyerName;
  final String shopName;
  final String sellerImageUrl;
  final String? orderImageUrl;
  final String? orderTitle;
  final double? orderTotal;

  const SupportNavigationData({
    required this.orderId,
    required this.sellerId,
    required this.sellerName,
    required this.buyerName,
    this.shopName = '',
    this.sellerImageUrl = '',
    this.orderImageUrl,
    this.orderTitle,
    this.orderTotal,
  });
}

class BuyerChatPage extends StatelessWidget {
  final String? orderId;
  final String? sellerId;
  final String? sellerName;
  final String? shopName;
  final String? sellerImageUrl;
  final String? buyerName;
  final SupportNavigationData? pendingOrderData;

  const BuyerChatPage({
    Key? key,
    this.orderId,
    this.sellerId,
    this.sellerName,
    this.shopName,
    this.sellerImageUrl,
    this.buyerName,
    this.pendingOrderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPushedRoute =
        pendingOrderData != null || (orderId != null && sellerId != null);
    return BlocProvider(
      create: (context) {
        final bloc = BuyerChatBloc(
          repository: context.read<IChatRepository>(),
          authService: context.read<IAuthService>(),
        );
        final data = pendingOrderData;
        if (data != null) {
          bloc.openOrderConversation(
            orderId: data.orderId,
            sellerId: data.sellerId,
            sellerName: data.sellerName,
            shopName: data.shopName,
            sellerImageUrl: data.sellerImageUrl,
            buyerName: data.buyerName,
            orderImageUrl: data.orderImageUrl,
            orderTitle: data.orderTitle,
            orderTotal: data.orderTotal,
          );
        } else if (orderId != null &&
            sellerId != null &&
            sellerName != null &&
            buyerName != null) {
          bloc.openOrderConversation(
            orderId: orderId!,
            sellerId: sellerId!,
            sellerName: sellerName!,
            shopName: shopName,
            sellerImageUrl: sellerImageUrl,
            buyerName: buyerName!,
          );
        } else {
          bloc.add(LoadBuyerConversations());
        }
        return bloc;
      },
      child: BuyerChatView(isPushedRoute: isPushedRoute),
    );
  }
}

class BuyerChatView extends StatelessWidget {
  final bool isPushedRoute;
  const BuyerChatView({Key? key, this.isPushedRoute = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BuyerChatBloc, BuyerChatState>(
      listener: (context, state) {
        if (state is BuyerChatLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: _AppTheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BuyerChatLoading || state is BuyerChatInitial) {
          return Scaffold(
            backgroundColor: _AppTheme.background,
            body: Center(
              child: CircularProgressIndicator(color: _AppTheme.primary),
            ),
          );
        } else if (state is BuyerChatError) {
          return Scaffold(
            backgroundColor: _AppTheme.background,
            body: Center(
              child: state.message == 'User not logged in'
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: _AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.support_agent_rounded,
                              size: 40,
                              color: _AppTheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Support Chat',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Please log in to access support',
                            style: TextStyle(
                              fontSize: 15,
                              color: _AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FoodGoLoginScreenUI(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('Log In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AppTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  _AppTheme.buttonRadius,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: _AppTheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(
                            color: _AppTheme.primary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          );
        } else if (state is BuyerChatLoaded) {
          final screenType = _screenType(context);
          final isDesktop = screenType == _ScreenType.desktop;

          if (isDesktop) {
            return Scaffold(
              backgroundColor: _AppTheme.background,
              body: Padding(
                padding: const EdgeInsets.all(_AppTheme.pagePadding),
                child: Row(
                  children: [
                    Container(
                      width: 380,
                      decoration: BoxDecoration(
                        color: _AppTheme.card,
                        borderRadius: BorderRadius.circular(
                          _AppTheme.cardRadius,
                        ),
                        boxShadow: _AppTheme.cardShadow,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          _AppTheme.cardRadius,
                        ),
                        child: _BuyerChatListView(
                          conversations: state.filteredConversations,
                          currentUserId: state.currentUserId,
                          searchQuery: state.searchQuery,
                          embedded: true,
                          selectedConversationId: state.selectedConversationId,
                        ),
                      ),
                    ),
                    const SizedBox(width: _AppTheme.pagePadding),
                    Expanded(
                      child:
                          state.selectedConversationId != null &&
                              state.selectedConversation != null
                          ? Container(
                              decoration: BoxDecoration(
                                color: _AppTheme.card,
                                borderRadius: BorderRadius.circular(
                                  _AppTheme.cardRadius,
                                ),
                                boxShadow: _AppTheme.cardShadow,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  _AppTheme.cardRadius,
                                ),
                                child: _ChatPanel(
                                  conversation: state.selectedConversation!,
                                  messages: state.messages,
                                  isSending: state.isSendingMessage,
                                  isPushedRoute: isPushedRoute,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: _AppTheme.card,
                                borderRadius: BorderRadius.circular(
                                  _AppTheme.cardRadius,
                                ),
                                boxShadow: _AppTheme.cardShadow,
                              ),
                              child: _EmptyChatPlaceholder(),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.selectedConversationId != null &&
              state.selectedConversation != null) {
            return Scaffold(
              backgroundColor: _AppTheme.background,
              body: _ChatPanel(
                conversation: state.selectedConversation!,
                messages: state.messages,
                isSending: state.isSendingMessage,
                isPushedRoute: isPushedRoute,
              ),
            );
          }

          return _BuyerChatListView(
            conversations: state.filteredConversations,
            currentUserId: state.currentUserId,
            searchQuery: state.searchQuery,
            selectedConversationId: state.selectedConversationId,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyChatPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _AppTheme.background,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ChatBackgroundPainter(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: _AppTheme.primary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _AppTheme.primary.withValues(alpha: 0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _AppTheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.forum_outlined,
                        size: 40,
                        color: _AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'FoodGo Support',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select a conversation to start messaging.\nWe are here to help you 24/7.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: _AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _AppTheme.surfaceHover,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _AppTheme.borderLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.lock_outline, size: 12, color: _AppTheme.textTertiary),
                      SizedBox(width: 6),
                      Text(
                        'End-to-end encrypted',
                        style: TextStyle(
                          fontSize: 11,
                          color: _AppTheme.textTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _ScreenType { mobile, tablet, desktop }

_ScreenType _screenType(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 600) return _ScreenType.mobile;
  if (w < 1024) return _ScreenType.tablet;
  return _ScreenType.desktop;
}

class _BuyerChatListView extends StatefulWidget {
  final List<ConversationModel> conversations;
  final String currentUserId;
  final String searchQuery;
  final bool embedded;
  final String? selectedConversationId;

  const _BuyerChatListView({
    required this.conversations,
    required this.currentUserId,
    required this.searchQuery,
    this.embedded = false,
    this.selectedConversationId,
  });

  @override
  State<_BuyerChatListView> createState() => _BuyerChatListViewState();
}

class _BuyerChatListViewState extends State<_BuyerChatListView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void didUpdateWidget(covariant _BuyerChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent = Column(
      children: [
        _PremiumSearchBar(controller: _searchController),
        Expanded(
          child: widget.conversations.isEmpty
              ? _EmptyConversationsState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: widget.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = widget.conversations[index];
                    final isSelected =
                        conversation.id == widget.selectedConversationId;
                    return _ConversationTile(
                      conversation: conversation,
                      currentUserId: widget.currentUserId,
                      isSelected: isSelected,
                      onTap: () {
                        context.read<BuyerChatBloc>().add(
                          SelectBuyerConversation(conversation.id),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );

    if (widget.embedded) {
      return Container(
        color: _AppTheme.card,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 14),
              decoration: BoxDecoration(
                color: _AppTheme.card,
                border: Border(
                  bottom: BorderSide(color: _AppTheme.borderLight),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: _AppTheme.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Support Chat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.conversations.length} conversations',
                        style: const TextStyle(
                          fontSize: 13,
                          color: _AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: bodyContent),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: _AppTheme.background,
      appBar: AppBar(
        title: const Text('Support Chat'),
        centerTitle: true,
        backgroundColor: _AppTheme.card,
      ),
      body: bodyContent,
    );
  }
}

class _PremiumSearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _PremiumSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_AppTheme.searchRadius),
          boxShadow: _AppTheme.glassShadow,
        ),
        child: TextField(
          controller: controller,
          onChanged: (query) {
            context.read<BuyerChatBloc>().add(FilterBuyerConversations(query));
          },
          decoration: InputDecoration(
            hintText: 'Search customer or order...',
            hintStyle: const TextStyle(
              color: _AppTheme.textTertiary,
              fontSize: 14,
            ),
            prefixIcon: Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.search_rounded,
                color: _AppTheme.textTertiary,
                size: 22,
              ),
            ),
            suffixIcon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: const Text(
                      '⌘K',
                      style: TextStyle(
                        fontSize: 11,
                        color: _AppTheme.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            filled: true,
            fillColor: _AppTheme.glassBg,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_AppTheme.searchRadius),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_AppTheme.searchRadius),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_AppTheme.searchRadius),
              borderSide: const BorderSide(
                color: _AppTheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyConversationsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 32,
              color: _AppTheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No conversations yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Start chatting with a restaurant',
            style: TextStyle(fontSize: 13, color: _AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<_ConversationTile> {
  bool _isHovered = false;

  String _formatTime(DateTime? lastMessageTimestamp) {
    if (lastMessageTimestamp == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDate = DateTime(
      lastMessageTimestamp.year,
      lastMessageTimestamp.month,
      lastMessageTimestamp.day,
    );
    final diff = today.difference(msgDate).inDays;
    if (diff == 0) return DateFormat('hh:mm a').format(lastMessageTimestamp);
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(lastMessageTimestamp);
    return DateFormat('MMM dd').format(lastMessageTimestamp);
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final unread = conversation.unreadCountForUser(widget.currentUserId);
    final displayName =
        conversation.shopName ??
        conversation.otherParticipantName(widget.currentUserId);
    final hasImage =
        conversation.sellerImageUrl != null &&
        conversation.sellerImageUrl!.isNotEmpty;

    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: _AppTheme.normalDuration,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? _AppTheme.primary.withValues(alpha: 0.06)
                : (_isHovered ? _AppTheme.background : Colors.transparent),
            border: Border(
              left: BorderSide(
                color: widget.isSelected
                    ? _AppTheme.primary
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasImage
                          ? Colors.transparent
                          : _AppTheme.surfaceHover,
                      border: Border.all(
                        color: widget.isSelected
                            ? _AppTheme.primary.withValues(alpha: 0.3)
                            : _AppTheme.border,
                        width: 2,
                      ),
                    ),
                    child: hasImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child: Image.network(
                              conversation.sellerImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _AvatarFallback(name: displayName),
                            ),
                          )
                        : _AvatarFallback(name: displayName),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: _OnlineDot(size: 14, borderWidth: 2.5, pulse: true),
                  ),
                  if (unread > 0)
                    Positioned(
                      left: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _AppTheme.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontWeight: unread > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              fontSize: 15,
                              color: _AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (conversation.lastMessageTimestamp != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              _formatTime(conversation.lastMessageTimestamp),
                              style: TextStyle(
                                fontSize: 11,
                                color: unread > 0
                                    ? _AppTheme.primary
                                    : _AppTheme.textTertiary,
                                fontWeight: unread > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: unread > 0
                                  ? _AppTheme.textPrimary
                                  : _AppTheme.textTertiary,
                              fontWeight: unread > 0
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (conversation.orderId != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _AppTheme.surfaceHover,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: _AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String name;
  const _AvatarFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _AppTheme.surfaceHover,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: _AppTheme.textSecondary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

class _ChatPanel extends StatefulWidget {
  final ConversationModel conversation;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final bool isPushedRoute;

  const _ChatPanel({
    required this.conversation,
    required this.messages,
    required this.isSending,
    this.isPushedRoute = false,
  });

  @override
  State<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<_ChatPanel> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Show button if we are scrolled up by more than 200 pixels
      final isNotAtBottom = _scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200;
      if (isNotAtBottom != _showScrollToBottom) {
        setState(() => _showScrollToBottom = isNotAtBottom);
      }
    }
  }

  @override
  void didUpdateWidget(covariant _ChatPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length > oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      context.read<BuyerChatBloc>().add(
        SendBuyerMessage(widget.conversation.id, _textController.text),
      );
      _textController.clear();
    }
  }

  List<Widget> _buildChatItems(_ScreenType screenType) {
    final items = <Widget>[];
    String? lastDateKey;

    items.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _PremiumOrderContextCard(conversation: widget.conversation),
      ),
    );

    for (final msg in widget.messages) {
      final dateKey = DateFormat('yyyy-MM-dd').format(msg.timestamp);
      if (dateKey != lastDateKey) {
        items.add(_DateSeparatorChip(dateTime: msg.timestamp));
        lastDateKey = dateKey;
      }
      items.add(
        _AnimatedMessage(
          index: items.length,
          child: _BuyerChatBubble(
            message: msg,
            isMe: msg.senderRole == 'buyer',
          ),
        ),
      );
    }

    return items;
  }

  void _handleAttachment() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<BuyerChatBloc>().add(
        SendBuyerMediaMessage(
          conversationId: widget.conversation.id,
          file: kIsWeb ? await pickedFile.readAsBytes() : File(pickedFile.path),
          messageType: 'image',
          fileName: pickedFile.name,
        ),
      );
    }
  }

  void _handleEmojiToggle(bool show) {
    context.read<BuyerChatBloc>().add(ToggleEmojiPicker(show));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _screenType(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _PremiumChatHeader(
            conversation: widget.conversation,
            screenType: screenType,
            isPushedRoute: widget.isPushedRoute,
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: _AppTheme.chatBackground,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ChatBackgroundPainter(),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final items = _buildChatItems(screenType);
                      return ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(
                          screenType == _ScreenType.mobile ? 12 : 20,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => items[index],
                      );
                    },
                  ),
                  if (_showScrollToBottom)
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: _scrollToBottom,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _AppTheme.card,
                            shape: BoxShape.circle,
                            boxShadow: _AppTheme.cardShadow,
                          ),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _AppTheme.textSecondary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _PremiumComposer(
            controller: _textController,
            isSending: widget.isSending,
            screenType: screenType,
            onSend: _sendMessage,
            onAttach: _handleAttachment,
            onEmoji: () {
              final showEmoji =
                  context.read<BuyerChatBloc>().state is BuyerChatLoaded
                  ? (context.read<BuyerChatBloc>().state as BuyerChatLoaded)
                        .showEmojiPicker
                  : false;
              _handleEmojiToggle(!showEmoji);
            },
          ),
          BlocBuilder<BuyerChatBloc, BuyerChatState>(
            builder: (context, state) {
              if (state is BuyerChatLoaded && state.showEmojiPicker) {
                return SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      _textController.text = _textController.text + emoji.emoji;
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class _PremiumChatHeader extends StatelessWidget {
  final ConversationModel conversation;
  final _ScreenType screenType;
  final bool isPushedRoute;

  const _PremiumChatHeader({
    required this.conversation,
    required this.screenType,
    required this.isPushedRoute,
  });

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        context.read<BuyerChatBloc>().authService.currentUserId ?? '';
    final otherName = conversation.otherParticipantName(currentUserId);
    final displayName = conversation.shopName ?? otherName;
    final hasImage =
        conversation.sellerImageUrl != null &&
        conversation.sellerImageUrl!.isNotEmpty;
    final orderText = conversation.orderId != null
        ? 'Order #${conversation.orderId!.length > 8 ? conversation.orderId!.substring(0, 8) : conversation.orderId}'
        : null;

    return Container(
      decoration: BoxDecoration(
        color: _AppTheme.glassBg,
        border: Border(bottom: BorderSide(color: _AppTheme.borderLight)),
        boxShadow: _AppTheme.glassShadow,
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            bottom: false,
            top: screenType != _ScreenType.desktop,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenType == _ScreenType.desktop ? 16 : 4,
                10,
                16,
                10,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final showActions = constraints.maxWidth > 220;
                  return Row(
                    children: [
                      if (screenType != _ScreenType.desktop)
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            if (isPushedRoute && Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.read<BuyerChatBloc>().add(
                                SelectBuyerConversation(''),
                              );
                            }
                          },
                        ),
                      if (screenType == _ScreenType.desktop)
                        const SizedBox(width: 4),
                      Stack(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: hasImage
                                  ? Colors.transparent
                                  : _AppTheme.surfaceHover,
                              border: Border.all(
                                color: _AppTheme.border,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1A000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: hasImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.network(
                                      conversation.sellerImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          _AvatarFallback(name: displayName),
                                    ),
                                  )
                                : _AvatarFallback(name: displayName),
                          ),
                          Positioned(
                            right: 1,
                            bottom: 1,
                            child: _OnlineDot(
                              size: 14,
                              borderWidth: 2.5,
                              pulse: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    displayName,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: _AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 18,
                                  color: _AppTheme.info,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 11,
                                  color: _AppTheme.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Customer since 2025',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _AppTheme.textTertiary,
                                  ),
                                ),
                                if (orderText != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _AppTheme.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        _AppTheme.badgeRadius,
                                      ),
                                    ),
                                    child: Text(
                                      orderText,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _AppTheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _AppTheme.success.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Online',
                                    style: TextStyle(
                                      color: _AppTheme.success,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (showActions) ...[
                        _CircularIconButton(
                          icon: Icons.phone_outlined,
                          onPressed: () async {
                            final bloc = context.read<BuyerChatBloc>();
                            final userId = bloc.authService.currentUserId;
                            if (userId == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please log in to make a voice call.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VoiceCallPage(
                                    callID: conversation.id,
                                    userID: userId,
                                    userName: conversation.buyerName,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        _CircularIconButton(
                          icon: Icons.videocam_outlined,
                          onPressed: () async {
                            final bloc = context.read<BuyerChatBloc>();
                            final userId = bloc.authService.currentUserId;
                            if (userId == null) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please log in to make a video call.',
                                    ),
                                  ),
                                );
                              }
                              return;
                            }
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VideoCallPage(
                                    callID: conversation.id,
                                    userID: userId,
                                    userName: conversation.buyerName,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                      if (screenType != _ScreenType.mobile) ...[
                        const SizedBox(width: 4),
                        _CircularIconButton(
                          icon: Icons.more_vert_rounded,
                          onPressed: () {},
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircularIconButton({required this.icon, required this.onPressed});

  @override
  State<_CircularIconButton> createState() => _CircularIconButtonState();
}

class _CircularIconButtonState extends State<_CircularIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: AnimatedContainer(
        duration: _AppTheme.fastDuration,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered ? _AppTheme.surfaceHover : Colors.transparent,
        ),
        child: IconButton(
          icon: Icon(widget.icon, size: 22),
          color: _AppTheme.textSecondary,
          onPressed: widget.onPressed,
          splashRadius: 20,
        ),
      ),
    );
  }
}

class _PremiumComposer extends StatefulWidget {
  final TextEditingController controller;
  final bool isSending;
  final _ScreenType screenType;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onEmoji;

  const _PremiumComposer({
    required this.controller,
    required this.isSending,
    required this.screenType,
    required this.onSend,
    required this.onAttach,
    required this.onEmoji,
  });

  @override
  State<_PremiumComposer> createState() => _PremiumComposerState();
}

class _PremiumComposerState extends State<_PremiumComposer> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  dynamic _recordedAudioData;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _audioRecorder.dispose();
    super.dispose();
  }

  void _handleCamera() async {
    try {
      // Use the custom camera page for all platforms as requested.
      final XFile? pickedFile = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CustomCameraPage()),
      );

      if (pickedFile != null && mounted) {
        context.read<BuyerChatBloc>().add(
          SendBuyerMediaMessage(
            conversationId:
                context.read<BuyerChatBloc>().state is BuyerChatLoaded
                ? (context.read<BuyerChatBloc>().state as BuyerChatLoaded)
                      .selectedConversationId!
                : '',
            file: kIsWeb
                ? await pickedFile.readAsBytes()
                : File(pickedFile.path),
            messageType: 'image',
            fileName: pickedFile.name,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to open camera.')));
      }
      print('Camera Error: $e');
    }
  }

  void _toggleRecording() async {
    if (_isRecording) {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null && mounted) {
        dynamic fileData;
        if (kIsWeb) {
          try {
            print('--- AUDIO RECORDING AUDIT ---');
            print('1. Recorded File Path: $path');

            // Using XFile is the safest way to read blob URLs in Flutter Web
            // to avoid 0-byte/corrupted file uploads.
            final xFile = XFile(path);
            fileData = await xFile.readAsBytes();

            print('1. FileData bytes length: ${fileData.length}');
            if (fileData.isEmpty) {
              print('🚨 ERROR: Recorded audio is 0 bytes!');
            }
          } catch (e) {
            print('🚨 ERROR fetching web audio blob using XFile: $e');
            return;
          }
        } else {
          fileData = File(path);
        }
        setState(() {
          _recordedAudioData = fileData;
        });
      }
    } else {
      if (await _audioRecorder.hasPermission()) {
        if (kIsWeb) {
          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.opus),
            path: '',
          );
        } else {
          final dir = await getApplicationDocumentsDirectory();
          final path =
              '${dir.path}/audio_message_${DateTime.now().millisecondsSinceEpoch}.m4a';
          await _audioRecorder.start(const RecordConfig(), path: path);
        }
        setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone permission denied. Please allow microphone access in your browser/device.',
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasText = widget.controller.text.trim().isNotEmpty;
    final hasAudio = _recordedAudioData != null;
    final canSend = hasText || hasAudio;

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: _AppTheme.borderLight)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _AppTheme.glassBg,
          boxShadow: _AppTheme.glassShadow,
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _ComposerIconButton(
                      icon: Icons.emoji_emotions_outlined,
                      onPressed: widget.onEmoji,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            _AppTheme.inputRadius,
                          ),
                          border: Border.all(
                            color: _AppTheme.border.withValues(alpha: 0.5),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: widget.controller,
                          readOnly: hasAudio,
                          decoration: InputDecoration(
                            hintText: hasAudio ? 'Audio recorded (Press send to send)' : 'Type a message...',
                            hintStyle: TextStyle(
                              color: hasAudio ? _AppTheme.primary : _AppTheme.textTertiary,
                              fontWeight: hasAudio ? FontWeight.w500 : FontWeight.normal,
                              fontSize: 15,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 20,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _handleSend(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ComposerIconButton(
                      icon: hasAudio ? Icons.delete_outline : Icons.attach_file_outlined,
                      onPressed: hasAudio ? () => setState(() => _recordedAudioData = null) : widget.onAttach,
                    ),
                    if (!hasAudio)
                      _ComposerIconButton(
                        icon: Icons.camera_alt_outlined,
                        onPressed: _handleCamera,
                      ),
                    const SizedBox(width: 4),
                    AnimatedContainer(
                      duration: _AppTheme.fastDuration,
                      decoration: BoxDecoration(
                        color: canSend
                            ? _AppTheme.primary
                            : Colors.transparent, // No round background for recording
                        shape: BoxShape.circle,
                        boxShadow: canSend
                            ? [
                                BoxShadow(
                                  color: _AppTheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          canSend
                              ? Icons.send_rounded
                              : (_isRecording
                                    ? Icons.mic_rounded // Selected state
                                    : Icons.mic_none_outlined), // Unselected state
                          color: canSend
                              ? Colors.white
                              : (_isRecording ? Colors.red : _AppTheme.textTertiary),
                          size: 24,
                        ),
                        onPressed: widget.isSending
                            ? null
                            : (canSend ? _handleSend : _toggleRecording),
                        splashRadius: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSend() {
    if (_recordedAudioData != null) {
      context.read<BuyerChatBloc>().add(
        SendBuyerMediaMessage(
          conversationId:
              context.read<BuyerChatBloc>().state is BuyerChatLoaded
              ? (context.read<BuyerChatBloc>().state as BuyerChatLoaded)
                    .selectedConversationId!
              : '',
          file: _recordedAudioData,
          messageType: 'audio',
          fileName: kIsWeb ? 'audio_message.webm' : 'audio_message.m4a',
        ),
      );
      setState(() {
        _recordedAudioData = null;
      });
      widget.controller.clear();
    } else {
      widget.onSend();
    }
  }
}

class _ComposerIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ComposerIconButton({required this.icon, required this.onPressed});

  @override
  State<_ComposerIconButton> createState() => _ComposerIconButtonState();
}

class _ComposerIconButtonState extends State<_ComposerIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: AnimatedContainer(
        duration: _AppTheme.fastDuration,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _isHovered ? _AppTheme.surfaceHover : Colors.transparent,
        ),
        child: IconButton(
          icon: Icon(widget.icon, size: 22),
          color: _AppTheme.textTertiary,
          onPressed: widget.onPressed,
          splashRadius: 20,
        ),
      ),
    );
  }
}

class _AnimatedMessage extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedMessage({required this.index, required this.child});

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _opacityAnimation, child: widget.child),
    );
  }
}

class _BuyerChatBubble extends StatefulWidget {
  final ChatMessageModel message;
  final bool isMe;

  const _BuyerChatBubble({required this.message, required this.isMe});

  @override
  State<_BuyerChatBubble> createState() => _BuyerChatBubbleState();
}

class _BuyerChatBubbleState extends State<_BuyerChatBubble> {
  bool _isHovered = false;

  void _showMessageOptions(BuildContext context, Offset position) {
    if (widget.message.isDeletedForEveryone) return;
    
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    showMenu<String>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      items: [
        PopupMenuItem(
          value: 'delete_me',
          child: Row(
            children: const [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete for me', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        if (widget.isMe)
          PopupMenuItem(
            value: 'delete_everyone',
            child: Row(
              children: const [
                Icon(Icons.delete_forever, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Delete for everyone', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    ).then((value) {
      if (!context.mounted) return;
      if (value == 'delete_me') {
        context.read<BuyerChatBloc>().add(
          DeleteBuyerMessage(widget.message, forEveryone: false),
        );
      } else if (value == 'delete_everyone') {
        context.read<BuyerChatBloc>().add(
          DeleteBuyerMessage(widget.message, forEveryone: true),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenType = _screenType(context);
    final maxWidth = switch (screenType) {
      _ScreenType.mobile => MediaQuery.of(context).size.width * 0.8,
      _ScreenType.tablet => 380.0,
      _ScreenType.desktop => 420.0,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Align(
        alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              gradient: widget.isMe
                  ? const LinearGradient(
                      colors: [Color(0xFFFF4B4B), Color(0xFFFF6B6B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.isMe ? null : _AppTheme.bubbleOther,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(widget.isMe ? 22 : 4),
                bottomRight: Radius.circular(widget.isMe ? 4 : 22),
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isMe
                      ? const Color(0xFFFF4B4B).withValues(alpha: 0.25)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
          child: GestureDetector(
            onLongPressStart: (details) => _showMessageOptions(context, details.globalPosition),
            onSecondaryTapDown: (details) => _showMessageOptions(context, details.globalPosition),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(
                      widget.message.messageType == 'image' && !widget.message.isDeletedForEveryone ? 4.0 : 16.0),
                  child: widget.message.isDeletedForEveryone 
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.block, size: 16, color: widget.isMe ? Colors.white70 : Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'This message was deleted', 
                                  style: TextStyle(color: widget.isMe ? Colors.white : Colors.grey, fontStyle: FontStyle.italic, fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.message.messageType == 'image' && widget.message.mediaUrl != null)
                              _PremiumImageMessage(
                                imageUrl: widget.message.mediaUrl!,
                                timestamp: widget.message.timestamp,
                                isRead: widget.message.isRead,
                                isMe: widget.isMe,
                                maxWidth: maxWidth,
                              )
                            else if (widget.message.messageType == 'audio' &&
                                widget.message.mediaUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6.0),
                                child: AudioPlayerWidget(
                                  key: ValueKey(widget.message.mediaUrl),
                                  audioUrl: widget.message.mediaUrl!,
                                  isMe: widget.isMe,
                                ),
                              )
                            else if (widget.message.messageType == 'document' &&
                                widget.message.mediaUrl != null)
                              _PremiumDocumentMessage(
                                fileUrl: widget.message.mediaUrl!,
                                fileName: 'Invoice.pdf', // Or fetch from message if available
                                isMe: widget.isMe,
                              )
                            else if (widget.message.text.isNotEmpty)
                              Text(
                                widget.message.text,
                                style: TextStyle(
                                  color: widget.isMe ? Colors.white : const Color(0xFF111B21),
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                            if (widget.message.messageType != 'image')
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: _MessageFooter(
                                  timestamp: widget.message.timestamp,
                                  isRead: widget.message.isRead,
                                  isMe: widget.isMe,
                                  isDarkBg: widget.isMe,
                                ),
                              ),
                          ],
                        ),
                ),
                if (!widget.message.isDeletedForEveryone && _isHovered)
                  Positioned(
                    bottom: widget.message.messageType == 'image' ? 38 : 4,
                    right: widget.message.messageType == 'image' ? 12 : 4,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTapDown: (details) => _showMessageOptions(context, details.globalPosition),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 24,
                            color: widget.message.messageType == 'image' ? Colors.white : (widget.isMe ? Colors.white : Colors.black54),
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 4, offset: Offset(0, 1))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

class _MessageFooter extends StatelessWidget {
  final DateTime timestamp;
  final bool isRead;
  final bool isMe;
  final bool isDarkBg;

  const _MessageFooter({
    required this.timestamp,
    required this.isRead,
    required this.isMe,
    this.isDarkBg = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('hh:mm a').format(timestamp),
          style: TextStyle(
            color: isDarkBg ? Colors.white : const Color(0xFF667781),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            shadows: isDarkBg
                ? [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ]
                : null,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 3),
          Icon(
            isRead ? Icons.done_all : Icons.done,
            size: 12,
            color: isRead
                ? const Color(0xFF53BDEB)
                : (isDarkBg ? Colors.white : const Color(0xFF667781)),
            shadows: isDarkBg
                ? [
                    Shadow(
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ]
                : null,
          ),
        ],
      ],
    );
  }
}

class _PremiumImageMessage extends StatefulWidget {
  final String imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final bool isMe;
  final double maxWidth;

  const _PremiumImageMessage({
    required this.imageUrl,
    required this.timestamp,
    required this.isRead,
    required this.isMe,
    required this.maxWidth,
  });

  @override
  State<_PremiumImageMessage> createState() => _PremiumImageMessageState();
}

class _PremiumImageMessageState extends State<_PremiumImageMessage> {
  bool _isHovered = false;
  bool _isLoaded = false;
  bool _isPressed = false;

  void _openFullScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            _FullScreenImage(imageUrl: widget.imageUrl),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
        opaque: false,
        barrierColor: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidth = (widget.maxWidth - 32) > 0 ? (widget.maxWidth - 32) : 0.0;

    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _openFullScreen();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          transform: _isPressed
              ? Matrix4.diagonal3Values(0.97, 0.97, 1)
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: imageWidth,
                    minHeight: 120,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _ShimmerPlaceholder(),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      height: 120,
                      width: imageWidth,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey,
                          size: 36,
                        ),
                      ),
                    ),
                    imageBuilder: (_, imageProvider) {
                      return Container(
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 0.5,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.0),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                        child: Image(image: imageProvider, fit: BoxFit.cover),
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _MessageFooter(
                    timestamp: widget.timestamp,
                    isRead: widget.isRead,
                    isMe: widget.isMe,
                    isDarkBg: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatefulWidget {
  @override
  State<_ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<_ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                    Colors.grey.shade200,
                  ],
                  stops: [
                    _animation.value.clamp(0.0, 1.0),
                    (_animation.value + 0.3).clamp(0.0, 1.0),
                    (_animation.value + 0.6).clamp(0.0, 1.0),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcOver,
              child: Container(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Hero(
            tag: imageUrl,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) => const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSeparatorChip extends StatelessWidget {
  final DateTime dateTime;

  const _DateSeparatorChip({required this.dateTime});

  String _formatDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final diff = today.difference(date).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(dateTime);
    return DateFormat('d MMMM yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Text(
            _formatDate(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverCard extends StatefulWidget {
  final Widget child;
  const _HoverCard({required this.child});
  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: AnimatedContainer(
        duration: _AppTheme.normalDuration,
        curve: Curves.easeOut,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _AppTheme.card,
          borderRadius: BorderRadius.circular(_AppTheme.cardRadius),
          border: Border.all(color: _AppTheme.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.10 : 0.05),
              blurRadius: _isHovered ? 28 : 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class _PremiumOrderContextCard extends StatefulWidget {
  final ConversationModel conversation;
  const _PremiumOrderContextCard({required this.conversation});

  @override
  State<_PremiumOrderContextCard> createState() =>
      _PremiumOrderContextCardState();
}

class _PremiumOrderContextCardState extends State<_PremiumOrderContextCard> {
  bool _isHovered = false;
  Future<OrderModel?>? _orderFuture;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void didUpdateWidget(covariant _PremiumOrderContextCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation.orderId != widget.conversation.orderId) {
      _loadOrder();
    }
  }

  void _loadOrder() {
    if (widget.conversation.orderId != null) {
      final orderRepo = context.read<IOrderRepository>();
      _orderFuture = orderRepo.getOrderById(widget.conversation.orderId!);
    } else {
      _orderFuture = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.conversation.orderId == null) return const SizedBox.shrink();

    return FutureBuilder<OrderModel?>(
      future: _orderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSkeleton();
        }
        final order = snapshot.data;
        if (order == null) return const SizedBox.shrink();

        final item = order.items?.isNotEmpty == true
            ? order.items!.first
            : null;

        return MouseRegion(
          hitTestBehavior: HitTestBehavior.opaque,
          onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
          onExit: (_) { if (mounted) setState(() => _isHovered = false); },
          child: AnimatedContainer(
            duration: _AppTheme.normalDuration,
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _AppTheme.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _AppTheme.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProductHeader(item, order, context),
                const SizedBox(height: 24),
                _buildInfoGrid(order, context),
                const SizedBox(height: 24),
                _buildOrderStatusChip(order.status.name),
                const SizedBox(height: 24),
                _OrderTimelineWithAnimation(currentStatus: order.status),
                const SizedBox(height: 24),
                _buildOrderSummaryCard(order),
                const SizedBox(height: 24),
                _buildActionButtons(item, order, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _AppTheme.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: _AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(
    dynamic item,
    OrderModel order,
    BuildContext context,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProductImageWidget(imageUrl: item?.imageUrl, itemName: item?.name),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item?.name ?? 'Multiple Items',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RatingChip(),
                  const SizedBox(width: 10),
                  _VegBadge(),
                  const SizedBox(width: 10),
                  _QuantityChip(qty: item?.quantity ?? 1),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                '₹${order.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: _AppTheme.primary,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(OrderModel order, BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 2,
            mainAxisExtent: 72,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          children: [
            _PremiumInfoCard(
              icon: Icons.receipt_long_rounded,
              label: 'Order ID',
              value: '#${order.id.toUpperCase().substring(0, 8)}',
            ),
            _PremiumInfoCard(
              icon: Icons.storefront_rounded,
              label: 'Seller',
              value: widget.conversation.shopName ?? 'Store',
            ),
            _PremiumInfoCard(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Payment',
              value: order.paymentMethod ?? 'Wallet',
            ),
            _PremiumInfoCard(
              icon: Icons.inventory_2_rounded,
              label: 'Items',
              value: '${order.items?.length ?? 1} Item',
            ),
            _PremiumInfoCard(
              icon: Icons.local_shipping_rounded,
              label: 'Delivery',
              value: 'Standard',
            ),
            _PremiumInfoCard(
              icon: Icons.calendar_month_rounded,
              label: 'Date',
              value: DateFormat('MMM dd, yyyy').format(order.timestamp),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOrderStatusChip(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String label;
    switch (status.toLowerCase()) {
      case 'neworder':
      case 'new_order':
      case 'new':
        bgColor = const Color(0xFF3B82F6);
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.fiber_new_rounded;
        label = 'New Order';
        break;
      case 'delivered':
        bgColor = const Color(0xFF22C55E);
        textColor = const Color(0xFF16A34A);
        icon = Icons.check_circle_rounded;
        label = 'Delivered';
        break;
      case 'preparing':
        bgColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFFD97706);
        icon = Icons.restaurant_rounded;
        label = 'Preparing';
        break;
      case 'outfordelivery':
        bgColor = const Color(0xFF2563EB);
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.delivery_dining_rounded;
        label = 'Out for Delivery';
        break;
      case 'accepted':
        bgColor = const Color(0xFF22C55E);
        textColor = const Color(0xFF16A34A);
        icon = Icons.thumb_up_rounded;
        label = 'Accepted';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFDC2626);
        icon = Icons.cancel_rounded;
        label = 'Cancelled';
        break;
      default:
        bgColor = const Color(0xFF6B7280);
        textColor = const Color(0xFF4B5563);
        icon = Icons.info_outline_rounded;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            bgColor.withValues(alpha: 0.12),
            bgColor.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bgColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(OrderModel order) {
    final subtotal =
        order.items?.fold(
          0.0,
          (sum, item) => sum + item.price * item.quantity,
        ) ??
        order.amount;
    final total = order.amount;
    final delivery = total >= subtotal
        ? 0.0
        : (total - subtotal).abs().clamp(0, 50);
    final taxes = (total - subtotal - delivery).abs();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AppTheme.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AppTheme.border),
      ),
      child: Column(
        children: [
          _summaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}', false),
          const SizedBox(height: 10),
          _summaryRow(
            'Delivery',
            delivery == 0 ? 'FREE' : '₹${delivery.toStringAsFixed(2)}',
            delivery == 0,
          ),
          const SizedBox(height: 10),
          _summaryRow('Taxes & Fees', '₹${taxes.toStringAsFixed(2)}', false),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: _AppTheme.border, height: 1),
          ),
          _summaryRow(
            'Total',
            '₹${total.toStringAsFixed(2)}',
            false,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value,
    bool isFree, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
            color: isTotal ? const Color(0xFF111827) : const Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isFree
                ? _AppTheme.success
                : (isTotal ? const Color(0xFF111827) : const Color(0xFF111827)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    dynamic item,
    OrderModel order,
    BuildContext context,
  ) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _PremiumActionButton(
          icon: Icons.star_rounded,
          label: 'Rate',
          color: const Color(0xFFF59E0B),
          isOutlined: true,
          onTap: () {
            if (item != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RatingPageUI(foodId: item.productId, foodName: item.name),
                ),
              );
            }
          },
        ),
        _PremiumActionButton(
          icon: Icons.receipt_long_outlined,
          label: 'Invoice',
          color: const Color(0xFF2563EB),
          isOutlined: true,
          onTap: () async {
            try {
              final pdfBytes = await InvoiceGenerator.generateInvoice(
                orderId: order.id,
                buyerName: 'Buyer', // Name can be fetched from conversation if passed down, or default to Buyer
                sellerName: 'Seller',
                shopName: 'FoodGo Shop',
                totalAmount: order.amount,
                date: order.timestamp,
                items: order.items?.map((i) => {
                  'name': i.name,
                  'qty': i.quantity ?? 1,
                  'price': i.price,
                }).toList() ?? [],
              );
              
              if (context.mounted) {
                final state = context.read<BuyerChatBloc>().state;
                if (state is BuyerChatLoaded && state.selectedConversationId != null) {
                  context.read<BuyerChatBloc>().add(
                    SendBuyerMediaMessage(
                      conversationId: state.selectedConversationId!,
                      file: pdfBytes,
                      messageType: 'document',
                      fileName: 'invoice_${order.id.substring(0, 8)}.pdf',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invoice generated and sent to chat!'),
                      backgroundColor: _AppTheme.success,
                    )
                  );
                }
              }
            } catch(e) {
              if (context.mounted) {
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Failed to generate invoice: $e'), backgroundColor: Colors.red,)
                 );
              }
            }
          },
        ),
        _PremiumActionButton(
          icon: Icons.local_shipping_rounded,
          label: 'Track',
          color: const Color(0xFF2563EB),
          isOutlined: true,
          onTap: () {
            final orderViewModel = OrderViewModel(
              id: order.id,
              status: order.status.name,
              totalAmount: order.amount,
              date: order.timestamp,
              items:
                  order.items
                      ?.map(
                        (i) => CartItem(
                          id: i.productId,
                          name: i.name,
                          price: i.price,
                          sellerId: order.sellerId,
                          image: i.imageUrl,
                          quantity: i.quantity,
                        ),
                      )
                      .toList() ??
                  [],
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TrackOrderPageUI(
                  orderId: order.id,
                  order: orderViewModel,
                  isEmbedded: false,
                  allowPopOnDesktop: false,
                ),
              ),
            );
          },
        ),
        _PremiumActionButton(
          icon: Icons.shopping_cart_rounded,
          label: 'Buy Again',
          color: _AppTheme.primary,
          isGradient: true,
          onTap: () {
            if (item != null) {
              context.read<CartBloc>().add(
                CartItemAdded(
                  CartItem(
                    id: item.productId,
                    name: item.name,
                    price: item.price,
                    sellerId: widget.conversation.sellerId,
                    image: item.imageUrl,
                  ),
                ),
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Added to cart')));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPageUI()),
              );
            }
          },
        ),
      ],
    );
  }
}

class _ProductImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String? itemName;

  const _ProductImageWidget({this.imageUrl, this.itemName});

  @override
  State<_ProductImageWidget> createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<_ProductImageWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: AnimatedContainer(
        duration: _AppTheme.normalDuration,
        curve: Curves.easeOut,
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _AppTheme.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: widget.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: _AppTheme.surfaceHover,
                    child: const Center(
                      child: Icon(
                        Icons.fastfood_rounded,
                        size: 36,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: _AppTheme.surfaceHover,
                    child: const Center(
                      child: Icon(
                        Icons.fastfood_rounded,
                        size: 36,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                )
              : Container(
                  color: _AppTheme.surfaceHover,
                  child: const Center(
                    child: Icon(
                      Icons.fastfood_rounded,
                      size: 36,
                      color: Color(0xFFCBD5E1),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
          const SizedBox(width: 3),
          const Text(
            '4.8',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityChip extends StatelessWidget {
  final int qty;
  const _QuantityChip({required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _AppTheme.surfaceHover,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Qty $qty',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }
}

class _VegBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _AppTheme.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _AppTheme.success.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Veg',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumInfoCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PremiumInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  State<_PremiumInfoCard> createState() => _PremiumInfoCardState();
}

class _PremiumInfoCardState extends State<_PremiumInfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: AnimatedContainer(
        duration: _AppTheme.fastDuration,
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? _AppTheme.primary.withValues(alpha: 0.2)
                : _AppTheme.border,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 18, color: _AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;
  final bool isGradient;
  final VoidCallback? onTap;

  const _PremiumActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.isOutlined = false,
    this.isGradient = false,
    this.onTap,
  });

  @override
  State<_PremiumActionButton> createState() => _PremiumActionButtonState();
}

class _PremiumActionButtonState extends State<_PremiumActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) { if (mounted) setState(() => _isHovered = true); },
      onExit: (_) { if (mounted) setState(() => _isHovered = false); },
      child: AnimatedContainer(
        duration: _AppTheme.fastDuration,
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: _AppTheme.fastDuration,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: widget.isGradient
                    ? null
                    : (widget.isOutlined
                          ? (_isHovered
                                ? widget.color.withValues(alpha: 0.06)
                                : Colors.transparent)
                          : widget.color.withValues(alpha: 0.1)),
                gradient: widget.isGradient
                    ? const LinearGradient(
                        colors: [_AppTheme.primary, Color(0xFFDC2626)],
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: widget.isOutlined
                    ? Border.all(
                        color: _isHovered
                            ? widget.color.withValues(alpha: 0.4)
                            : _AppTheme.border,
                      )
                    : null,
                boxShadow: widget.isGradient
                    ? [
                        BoxShadow(
                          color: _AppTheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 16,
                    color: widget.isGradient ? Colors.white : widget.color,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isGradient
                          ? Colors.white
                          : (widget.isOutlined
                                ? const Color(0xFF475569)
                                : widget.color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTimelineWithAnimation extends StatefulWidget {
  final OrderStatus currentStatus;
  const _OrderTimelineWithAnimation({required this.currentStatus});

  @override
  State<_OrderTimelineWithAnimation> createState() =>
      _OrderTimelineWithAnimationState();
}

class _OrderTimelineWithAnimationState
    extends State<_OrderTimelineWithAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimeline(widget.currentStatus);
  }

  Widget _buildTimeline(OrderStatus currentStatus) {
    final statusOrder = {
      OrderStatus.newOrder: 0,
      OrderStatus.accepted: 1,
      OrderStatus.rejected: -1,
      OrderStatus.preparing: 2,
      OrderStatus.ready: 2,
      OrderStatus.outForDelivery: 3,
      OrderStatus.delivered: 4,
      OrderStatus.cancelled: -1,
    };
    final currentIdx = statusOrder[currentStatus] ?? 0;
    final isCancelled = currentStatus == OrderStatus.cancelled;

    final stepsData = [
      {'title': 'Order Confirmed', 'index': 0, 'time': '12:30 PM'},
      {'title': 'Preparing Your Food', 'index': 2, 'time': '12:45 PM'},
      {'title': 'Out for Delivery', 'index': 3, 'time': '01:15 PM'},
      {'title': 'Delivered', 'index': 4, 'time': '01:45 PM'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AppTheme.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _AppTheme.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tracking Status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1C),
                ),
              ),
              const Spacer(),
              if (currentIdx >= 0 && !isCancelled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. ${stepsData.last['time']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              return Column(
                children: stepsData.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var step = entry.value;
                  int stepLevel = step['index'] as int;
                  String stepTime = step['time'] as String;
                  bool isLast = idx == stepsData.length - 1;

                  bool isCompleted = !isCancelled && currentIdx > stepLevel;
                  bool isCurrent = !isCancelled && currentIdx == stepLevel;

                  if (currentIdx == 1 && stepLevel == 2) {
                    isCurrent = true;
                  }

                  bool isFuture =
                      !isCancelled &&
                      currentIdx < stepLevel &&
                      !(currentIdx == 1 && stepLevel == 2);
                  if (isCancelled) isFuture = true;

                  final animatedOpacity = isCompleted
                      ? 1.0
                      : (isCurrent
                            ? _progressController.value * 0.8 + 0.2
                            : 0.3);

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Column(
                            children: [
                              _TimelineNode(
                                isCompleted: isCompleted,
                                isCurrent: isCurrent,
                                isFuture: isFuture,
                                pulseAnimation: _pulseAnimation,
                              ),
                              if (!isLast)
                                Expanded(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 600),
                                    width: 2.5,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isCompleted
                                            ? [
                                                const Color(0xFF22C55E),
                                                const Color(0xFF22C55E),
                                              ]
                                            : isCurrent
                                            ? [
                                                const Color(0xFF22C55E),
                                                const Color(0xFFD1D5DB),
                                              ]
                                            : [
                                                const Color(0xFFD1D5DB),
                                                const Color(0xFFD1D5DB),
                                              ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 28.0),
                            child: Opacity(
                              opacity: animatedOpacity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step['title'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: isFuture
                                              ? Colors.grey.shade400
                                              : const Color(0xFF1C1C1C),
                                        ),
                                      ),
                                      if (!isFuture)
                                        Text(
                                          stepTime,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isCompleted
                                                ? const Color(0xFF22C55E)
                                                : const Color(0xFF94A3B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (isCurrent)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          const Text(
                                            'In progress',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF22C55E),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          _PulsatingDot(
                                            size: 5,
                                            color: const Color(0xFF22C55E),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final bool isFuture;
  final Animation<double> pulseAnimation;

  const _TimelineNode({
    required this.isCompleted,
    required this.isCurrent,
    required this.isFuture,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
      );
    } else if (isCurrent) {
      return AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: pulseAnimation.value,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 8,
                  height: 8,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFF22C55E),
                  ),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD1D5DB), width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFD1D5DB),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
  }
}

class _OnlineDot extends StatefulWidget {
  final double size;
  final double borderWidth;
  final bool pulse;

  const _OnlineDot({this.size = 12, this.borderWidth = 2, this.pulse = false});

  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<_OnlineDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..repeat(reverse: true);
      _animation = Tween<double>(
        begin: 0.6,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      _controller = AnimationController(vsync: this, value: 1);
      _animation = Tween<double>(
        begin: 1,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: _AppTheme.success,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: widget.borderWidth),
            boxShadow: [
              BoxShadow(
                color: _AppTheme.success.withValues(
                  alpha: _animation.value * 0.5,
                ),
                blurRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PulsatingDot extends StatefulWidget {
  final double size;
  final Color color;

  const _PulsatingDot({required this.size, required this.color});

  @override
  State<_PulsatingDot> createState() => _PulsatingDotState();
}

class _PulsatingDotState extends State<_PulsatingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _PremiumDocumentMessage extends StatelessWidget {
  final String fileUrl;
  final String fileName;
  final bool isMe;

  const _PremiumDocumentMessage({
    required this.fileUrl,
    required this.fileName,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open document')),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isMe ? Colors.black.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMe ? null : Border.all(color: _AppTheme.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withValues(alpha: 0.2) : _AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.picture_as_pdf_rounded,
                color: isMe ? Colors.white : _AppTheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      color: isMe ? Colors.white : _AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'PDF Document • Tap to view',
                    style: TextStyle(
                      color: isMe ? Colors.white70 : _AppTheme.textTertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.download_rounded,
              color: isMe ? Colors.white : _AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
