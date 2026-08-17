import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:food_delivery_app/core/utils/app_exception_formatter.dart';
import '../../../api_service/RazorpayApiService.dart';
import '../../../core/services/i_auth_service.dart';
import '../../../core/services/seller_status_service.dart';
import '../../../core/repositories/i_cart_repository.dart';
import '../../../core/repositories/i_coupon_repository.dart';
import '../../../core/repositories/i_product_repository.dart';
import '../../../core/repositories/i_user_profile_repository.dart';
import '../../../features/buyer_bloc_architecture/user_profile_image/user_profile_models.dart';
import '../../../repositories/firebase_user_profile_repository.dart';
import 'cart_models.dart';

part 'cart_page_Event.dart';
part 'cart_page_State.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final ICartRepository _cartRepository;
  final ICouponRepository _couponRepository;
  final IProductRepository _productRepository;
  final IAuthService _authService;
  final SellerStatusService _sellerStatusService;
  final IUserProfileRepository _userProfileRepository;
  final RazorpayApiService _razorpayApiService;

  final FirebaseFirestore? _firestore;

  StreamSubscription<String?>? _authSubscription;
  StreamSubscription<List<AppliedCoupon>>? _couponSubscription;
  StreamSubscription<UserProfile?>? _profileSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _walletSubscription;

  CartBloc({
    required ICartRepository cartRepository,
    required ICouponRepository couponRepository,
    required IProductRepository productRepository,
    required IAuthService authService,
    SellerStatusService? sellerStatusService,
    IUserProfileRepository? userProfileRepository,
    RazorpayApiService? razorpayApiService,
    FirebaseFirestore? firestore,
  })  : _cartRepository = cartRepository,
        _couponRepository = couponRepository,
        _productRepository = productRepository,
        _authService = authService,
        _sellerStatusService = sellerStatusService ?? SellerStatusService(),
        _userProfileRepository = userProfileRepository ?? _DefaultUserProfileRepository(),
        _razorpayApiService = razorpayApiService ?? RazorpayApiService(),
        _firestore = firestore,
        super(const CartLoading()) {
    
    _authSubscription = _authService.authStateChanges.listen((userId) {
      if (userId != null) {
        add(const LoadCartStarted());
      } else {
        add(const CartCleared());
      }
    });

    on<LoadCartStarted>(_onLoadCartStarted);
    on<CartItemAdded>(_onCartItemAdded);
    on<CartItemRemoved>(_onCartItemRemoved);
    on<CartItemQuantityUpdated>(_onCartItemQuantityUpdated);
    on<CartItemSelectionToggled>(_onCartItemSelectionToggled);
    on<CartCleared>(_onCartCleared);
    on<CartPaymentMethodSelected>(_onCartPaymentMethodSelected);
    on<CartCheckoutRequested>(_onCartCheckoutRequested);
    on<CartRazorpaySuccessReceived>(_onCartRazorpaySuccessReceived);
    on<CartRazorpayFailedReceived>(_onCartRazorpayFailedReceived);
    on<_WalletBalanceUpdated>(_onWalletBalanceUpdated);
    on<LoadAvailableCoupons>(_onLoadAvailableCoupons);
    on<_CouponsLoaded>(_onCouponsLoaded);
    on<CouponApplied>(_onCouponApplied);
    on<ApplyCouponCodeRequested>(_onApplyCouponCodeRequested);
    on<CouponRemoved>(_onCouponRemoved);
    on<CouponError>(_onCouponError);
    on<DeliveryAddressTypeChanged>(_onDeliveryAddressTypeChanged);
    on<_ProfileUpdated>(_onProfileUpdated);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _couponSubscription?.cancel();
    _profileSubscription?.cancel();
    _walletSubscription?.cancel();
    return super.close();
  }

  String? get _currentUserId => _authService.currentUserId;

  void _subscribeToCoupons(List<String> sellerIds) {
    _couponSubscription?.cancel();
    _couponSubscription = _couponRepository
        .getActiveCouponsBySellers(sellerIds)
        .map(
          (coupons) => coupons.map((c) => AppliedCoupon(
            code: c.code,
            sellerId: c.sellerId,
            discountAmount: c.discountAmount,
            isPercentage: c.isPercentage,
            couponId: c.id,
            minimumOrderValue: c.minimumOrderValue,
            description: c.description,
          )).toList(),
        )
        .listen((availableCoupons) {
      if (!isClosed) {
        add(_CouponsLoaded(availableCoupons));
      }
    });
  }

  void _subscribeToProfile(String userId) {
    _profileSubscription?.cancel();
    _profileSubscription = _userProfileRepository
        .watchProfile(userId)
        .listen((profile) {
      if (!isClosed) {
        add(_ProfileUpdated(profile));
      }
    });
  }

  void _subscribeToWallet(String userId) {
    _walletSubscription?.cancel();
    try {
      final db = _firestore ?? FirebaseFirestore.instance;
      _walletSubscription = db
          .collection('buyer_user')
          .doc(userId)
          .snapshots()
          .listen((snap) {
        if (snap.exists && !isClosed) {
          final balance = (snap.data()?['wallet'] as num?)?.toDouble() ?? 0.0;
          add(_WalletBalanceUpdated(balance));
        }
      }, onError: (_) {});
    } catch (_) {
      // Safely ignore in test environments without Firebase instance
    }
  }

  String _resolveAddress(UserProfile? profile, String selectedType) {
    if (profile == null) return 'Primary Address';
    final type = selectedType.toLowerCase().trim();
    if (type == 'home' && profile.homeAddress.trim().isNotEmpty) {
      return profile.homeAddress.trim();
    } else if (type == 'work' && profile.workAddress.trim().isNotEmpty) {
      return profile.workAddress.trim();
    } else if (type == 'other' && profile.otherAddress.trim().isNotEmpty) {
      return profile.otherAddress.trim();
    } else if (profile.address.trim().isNotEmpty) {
      return profile.address.trim();
    }
    return 'Primary Address';
  }

  CartLoaded _computePricing({
    required List<CartItem> items,
    AppliedCoupon? appliedCoupon,
    List<AppliedCoupon> availableCoupons = const [],
    String? couponMessage,
    bool isCouponLoading = false,
    String selectedAddressType = 'Home',
    String deliveryAddress = '',
    String homeAddress = '',
    String workAddress = '',
    String otherAddress = '',
    String customerName = '',
    String customerPhone = '',
    CartPaymentMethod selectedPaymentMethod = CartPaymentMethod.razorpay,
    bool isCheckingOut = false,
    double walletBalance = 0.0,
    String? paymentError,
  }) {
    double subtotal = 0.0;
    int totalCount = 0;
    for (final item in items) {
      if (item.isSelected) {
        subtotal += (item.price * item.quantity);
        totalCount += item.quantity;
      }
    }

    double discountAmount = 0.0;
    if (appliedCoupon != null && subtotal > 0) {
      if (appliedCoupon.isPercentage) {
        discountAmount = (subtotal * appliedCoupon.discountAmount / 100).clamp(0, subtotal).toDouble();
      } else {
        discountAmount = appliedCoupon.discountAmount.clamp(0, subtotal).toDouble();
      }
    }

    // Free delivery for orders >= ₹500, otherwise ₹35 base fee (₹0 if cart is empty)
    final double deliveryFee = (subtotal >= 500.0 || subtotal == 0.0) ? 0.0 : 35.0;
    final double taxableSubtotal = (subtotal - discountAmount).clamp(0.0, double.infinity).toDouble();
    // 5% GST on taxable amount
    final double taxAmount = subtotal > 0 ? (taxableSubtotal * 0.05) : 0.0;
    // Platform fee ₹5 if items are present
    final double platformFee = subtotal > 0 ? 5.0 : 0.0;

    final double grandTotal = taxableSubtotal + deliveryFee + taxAmount + platformFee;

    return CartLoaded(
      items: items,
      totalAmount: subtotal,
      totalCount: totalCount,
      appliedCoupon: appliedCoupon,
      discountAmount: discountAmount,
      deliveryFee: deliveryFee,
      taxAmount: taxAmount,
      platformFee: platformFee,
      finalAmount: grandTotal,
      availableCoupons: availableCoupons,
      couponMessage: couponMessage,
      isCouponLoading: isCouponLoading,
      selectedAddressType: selectedAddressType,
      deliveryAddress: deliveryAddress,
      homeAddress: homeAddress,
      workAddress: workAddress,
      otherAddress: otherAddress,
      customerName: customerName,
      customerPhone: customerPhone,
      selectedPaymentMethod: selectedPaymentMethod,
      isCheckingOut: isCheckingOut,
      walletBalance: walletBalance,
      paymentError: paymentError,
    );
  }

  Future<void> _onLoadCartStarted(
    LoadCartStarted event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
      return;
    }

    emit(const CartLoading());

    await _authService.ensureTokenReady();
    _subscribeToProfile(uid);
    _subscribeToWallet(uid);

    try {
      await emit.forEach<List<CartItem>>(
        _cartRepository.getCartItemsStream(uid),
        onData: (items) {
          final sellerIds = items.map((i) => i.sellerId).toSet().toList();
          if (sellerIds.isNotEmpty) {
            _subscribeToCoupons(sellerIds);
          }

          final currentState = state;
          if (currentState is CartLoaded) {
            return _computePricing(
              items: items,
              appliedCoupon: currentState.appliedCoupon,
              availableCoupons: currentState.availableCoupons,
              couponMessage: currentState.couponMessage,
              isCouponLoading: currentState.isCouponLoading,
              selectedAddressType: currentState.selectedAddressType,
              deliveryAddress: currentState.deliveryAddress,
              homeAddress: currentState.homeAddress,
              workAddress: currentState.workAddress,
              otherAddress: currentState.otherAddress,
              customerName: currentState.customerName,
              customerPhone: currentState.customerPhone,
              selectedPaymentMethod: currentState.selectedPaymentMethod,
              isCheckingOut: currentState.isCheckingOut,
              walletBalance: currentState.walletBalance,
              paymentError: currentState.paymentError,
            );
          }

          return _computePricing(items: items);
        },
        onError: (error, stackTrace) =>
            const CartLoaded(items: [], totalAmount: 0, totalCount: 0),
      );
    } catch (_) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
    }
  }

  void _onProfileUpdated(
    _ProfileUpdated event,
    Emitter<CartState> emit,
  ) {
    final profile = event.profile as UserProfile?;
    final currentState = state;
    if (currentState is CartLoaded) {
      final selectedType = profile?.selectedAddressType ?? currentState.selectedAddressType;
      final deliveryAddress = _resolveAddress(profile, selectedType);

      emit(currentState.copyWith(
        selectedAddressType: selectedType,
        deliveryAddress: deliveryAddress,
        homeAddress: profile?.homeAddress ?? currentState.homeAddress,
        workAddress: profile?.workAddress ?? currentState.workAddress,
        otherAddress: profile?.otherAddress ?? currentState.otherAddress,
        customerName: profile?.name ?? currentState.customerName,
        customerPhone: profile?.phone ?? currentState.customerPhone,
      ));
    }
  }

  Future<void> _onDeliveryAddressTypeChanged(
    DeliveryAddressTypeChanged event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    final currentState = state;
    if (currentState is CartLoaded) {
      final resolvedAddress = _resolveAddress(
        UserProfile(
          name: currentState.customerName,
          email: '',
          phone: currentState.customerPhone,
          address: currentState.deliveryAddress,
          homeAddress: currentState.homeAddress,
          workAddress: currentState.workAddress,
          otherAddress: currentState.otherAddress,
          selectedAddressType: event.addressType,
        ),
        event.addressType,
      );

      emit(currentState.copyWith(
        selectedAddressType: event.addressType,
        deliveryAddress: resolvedAddress,
      ));

      if (uid != null) {
        try {
          final profile = await _userProfileRepository.loadProfile(uid);
          if (profile != null) {
            await _userProfileRepository.saveProfile(
              uid,
              profile.copyWith(selectedAddressType: event.addressType),
            );
          }
        } catch (e) {
          debugPrint('Failed to save selected address type: $e');
        }
      }
    }
  }

  Future<void> _onCartItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      final currentState = state;
      if (currentState is CartLoaded && event.item.quantity > 0) {
        final product = await _productRepository.getProduct(event.item.id, event.item.sellerId);
        if (product != null) {
          if (!product.isActive || product.isArchived) {
            emit(_cartErrorWithPrevious(currentState, '${event.item.name} is currently unavailable.'));
            return;
          }
          if (product.availableStock < event.item.quantity) {
            emit(_cartErrorWithPrevious(currentState, '${event.item.name} only has ${product.availableStock} in stock.'));
            return;
          }
        }
      }
      await _cartRepository.addItem(uid, event.item);
    } catch (e) {
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to add item to cart.'));
      }
    }
  }

  Future<void> _onCartItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _cartRepository.removeItem(uid, event.id);
    } catch (e) {
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to remove item.'));
      }
    }
  }

  Future<void> _onCartItemQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      final currentState = state;
      if (currentState is CartLoaded && event.delta > 0) {
        final item = currentState.items.firstWhere(
          (i) => i.id == event.id,
          orElse: () => const CartItem(id: '', name: '', price: 0, sellerId: ''),
        );
        if (item.id.isNotEmpty) {
          final product = await _productRepository.getProduct(item.id, item.sellerId);
          if (product != null && product.availableStock < (item.quantity + event.delta)) {
            emit(_cartErrorWithPrevious(currentState, '${item.name} only has ${product.availableStock} in stock.'));
            return;
          }
        }
      }
      await _cartRepository.updateQuantity(uid, event.id, event.delta);
    } catch (e) {
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to update quantity.'));
      }
    }
  }

  Future<void> _onCartItemSelectionToggled(
    CartItemSelectionToggled event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    try {
      await _cartRepository.toggleSelection(uid, event.id, event.isSelected);
    } catch (e) {
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to update selection.'));
      }
    }
  }

  CartError _cartErrorWithPrevious(CartLoaded previous, String message) {
    return CartError(message, previousState: previous);
  }

  Future<void> _onCartCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    _couponSubscription?.cancel();
    _couponSubscription = null;
    _profileSubscription?.cancel();
    _profileSubscription = null;

    final uid = _currentUserId;
    if (uid == null) {
      emit(const CartLoaded(items: [], totalAmount: 0, totalCount: 0));
      return;
    }
    try {
      await _cartRepository.clearCart(uid);
    } catch (e) {
      if (state is CartLoaded) {
        emit(_cartErrorWithPrevious(state as CartLoaded, 'Failed to clear cart.'));
      }
    }
  }

  void _onCartPaymentMethodSelected(
    CartPaymentMethodSelected event,
    Emitter<CartState> emit,
  ) {
    final s = state;
    if (s is CartLoaded) {
      emit(s.copyWith(
        selectedPaymentMethod: event.method,
        clearPaymentError: true,
      ));
    }
  }

  void _onWalletBalanceUpdated(
    _WalletBalanceUpdated event,
    Emitter<CartState> emit,
  ) {
    final s = state;
    if (s is CartLoaded) {
      emit(s.copyWith(walletBalance: event.balance));
    }
  }

  Future<void> _onCartCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;

    try {
      final currentState = state;
      if (currentState is! CartLoaded) return;

      final selectedItems = currentState.items.where((i) => i.isSelected).toList();
      if (selectedItems.isEmpty) return;

      emit(currentState.copyWith(isCheckingOut: true, clearPaymentError: true));

      final sellerIds = selectedItems.map((i) => i.sellerId).toSet().toList();
      for (final sellerId in sellerIds) {
        final availability = await _sellerStatusService.checkAvailability(sellerId);
        if (!availability.isAvailable) {
          final msg = !availability.isOnline
              ? 'Store is currently offline.'
              : (availability.message ?? 'Store is currently closed.');
          emit(currentState.copyWith(
            isCheckingOut: false,
            paymentError: msg,
            couponMessage: msg,
            clearCouponMessage: false,
          ));
          if (event.onFailure != null) {
            event.onFailure!(msg);
          } else if (event.onInsufficientBalance != null) {
            event.onInsufficientBalance!(msg);
          }
          return;
        }
      }

      List<String> validationErrors = [];
      for (final item in selectedItems) {
        final product = await _productRepository.getProduct(item.id, item.sellerId);
        if (product == null) {
          validationErrors.add('${item.name} is no longer available.');
          continue;
        }
        if (!product.isActive || product.isArchived) {
          validationErrors.add('${item.name} is currently disabled.');
          continue;
        }
        if (product.availableStock < item.quantity) {
          validationErrors.add('${item.name} only has ${product.availableStock} in stock (you requested ${item.quantity}).');
          continue;
        }
        if (product.effectivePrice != item.price) {
          await _cartRepository.updateItemPrice(uid, item.id, product.effectivePrice);
          validationErrors.add('${item.name} price has been automatically updated from ₹${item.price.toStringAsFixed(0)} to ₹${product.effectivePrice.toStringAsFixed(0)}.');
          continue;
        }
      }

      if (validationErrors.isNotEmpty) {
        final msg = validationErrors.join('\n');
        emit(currentState.copyWith(
          isCheckingOut: false,
          paymentError: msg,
          couponMessage: msg,
          clearCouponMessage: false,
        ));
        if (event.onFailure != null) {
          event.onFailure!(msg);
        } else if (event.onInsufficientBalance != null) {
          event.onInsufficientBalance!(msg);
        }
        return;
      }

      String displayName = currentState.customerName.trim();
      if (displayName.isEmpty || displayName == 'Customer') {
        displayName = _authService.currentUserDisplayName ?? 'Customer';
      }

      final customerPhone = currentState.customerPhone.trim();
      String deliveryAddress = currentState.deliveryAddress.trim();
      if (deliveryAddress.isEmpty || deliveryAddress == 'Primary Address') {
        final profile = await _userProfileRepository.loadProfile(uid);
        deliveryAddress = _resolveAddress(profile, profile?.selectedAddressType ?? 'Home');
      }

      final customerEmail = _authService.currentUserEmail ?? 'customer@example.com';

      // 1. Razorpay Online Payment Flow
      if (currentState.selectedPaymentMethod == CartPaymentMethod.razorpay) {
        try {
          final orderResponse = await _razorpayApiService.createOrder(
            amount: (currentState.finalAmount * 100).toInt(),
            receipt: 'rcpt_${DateTime.now().millisecondsSinceEpoch}',
          );
          final orderId = orderResponse['orderId'] as String? ?? orderResponse['id'] as String?;

          emit(currentState.copyWith(isCheckingOut: false));

          if (event.onOpenRazorpay != null) {
            event.onOpenRazorpay!(orderId, currentState.finalAmount, customerEmail, customerPhone);
          } else {
            _razorpayApiService.startPayment(
              amount: currentState.finalAmount,
              email: customerEmail,
              phone: customerPhone,
              orderId: orderId,
              description: 'Food Order Payment',
            );
          }
        } catch (e) {
          final err = AppExceptionFormatter.toUserFriendlyMessage(e);
          emit(currentState.copyWith(
            isCheckingOut: false,
            paymentError: err,
          ));
          if (event.onFailure != null) {
            event.onFailure!(err);
          }
        }
        return;
      }

      // 2. FoodGo Wallet Payment Flow
      if (currentState.selectedPaymentMethod == CartPaymentMethod.wallet) {
        if (currentState.walletBalance < currentState.finalAmount) {
          final msg = 'Insufficient wallet balance (₹${currentState.walletBalance.toStringAsFixed(0)}). Required: ₹${currentState.finalAmount.toStringAsFixed(0)}.';
          emit(currentState.copyWith(
            isCheckingOut: false,
            paymentError: msg,
          ));
          if (event.onInsufficientBalance != null) {
            event.onInsufficientBalance!(msg);
          }
          return;
        }

        await _cartRepository.checkoutCart(
          uid,
          selectedItems,
          displayName,
          deliveryAddress,
          customerPhone: customerPhone,
          appliedCoupon: currentState.appliedCoupon,
          paymentMethod: 'Wallet',
        );

        emit(currentState.copyWith(isCheckingOut: false));
        if (event.onSuccess != null) {
          event.onSuccess!(null);
        }
        return;
      }

      // 3. Cash on Delivery (COD) Flow
      await _cartRepository.checkoutCart(
        uid,
        selectedItems,
        displayName,
        deliveryAddress,
        customerPhone: customerPhone,
        appliedCoupon: currentState.appliedCoupon,
        paymentMethod: 'COD',
      );

      emit(currentState.copyWith(isCheckingOut: false));
      if (event.onSuccess != null) {
        event.onSuccess!(null);
      }
    } catch (e) {
      debugPrint("Checkout Error: $e");
      final errMsg = AppExceptionFormatter.toUserFriendlyMessage(e);
      if (state is CartLoaded) {
        emit((state as CartLoaded).copyWith(
          isCheckingOut: false,
          paymentError: errMsg,
        ));
      }
      if (event.onFailure != null) {
        event.onFailure!(errMsg);
      }
    }
  }

  Future<void> _onCartRazorpaySuccessReceived(
    CartRazorpaySuccessReceived event,
    Emitter<CartState> emit,
  ) async {
    final uid = _currentUserId;
    if (uid == null) return;
    final currentState = state;
    if (currentState is! CartLoaded) return;

    final selectedItems = currentState.items.where((i) => i.isSelected).toList();
    if (selectedItems.isEmpty) return;

    emit(currentState.copyWith(isCheckingOut: true, clearPaymentError: true));

    try {
      String displayName = currentState.customerName.trim();
      if (displayName.isEmpty || displayName == 'Customer') {
        displayName = _authService.currentUserDisplayName ?? 'Customer';
      }

      final customerPhone = currentState.customerPhone.trim();
      String deliveryAddress = currentState.deliveryAddress.trim();
      if (deliveryAddress.isEmpty || deliveryAddress == 'Primary Address') {
        final profile = await _userProfileRepository.loadProfile(uid);
        deliveryAddress = _resolveAddress(profile, profile?.selectedAddressType ?? 'Home');
      }

      await _cartRepository.verifyAndCheckoutRazorpay(
        buyerId: uid,
        razorpayOrderId: event.response.orderId ?? '',
        razorpayPaymentId: event.response.paymentId ?? '',
        razorpaySignature: event.response.signature ?? '',
        selectedItems: selectedItems,
        customerName: displayName,
        deliveryAddress: deliveryAddress,
        customerPhone: customerPhone,
        appliedCoupon: currentState.appliedCoupon,
      );

      emit(currentState.copyWith(isCheckingOut: false));
      if (event.onSuccess != null) {
        event.onSuccess!(null);
      }
    } catch (e) {
      debugPrint("Razorpay Verification Error: $e");
      final errMsg = AppExceptionFormatter.toUserFriendlyMessage(e);
      emit(currentState.copyWith(
        isCheckingOut: false,
        paymentError: errMsg,
      ));
      if (event.onFailure != null) {
        event.onFailure!(errMsg);
      }
    }
  }

  void _onCartRazorpayFailedReceived(
    CartRazorpayFailedReceived event,
    Emitter<CartState> emit,
  ) {
    final currentState = state;
    if (currentState is CartLoaded) {
      final isCancelled = event.response.code == Razorpay.PAYMENT_CANCELLED;
      final msg = isCancelled
          ? 'Payment cancelled by user.'
          : (event.response.message ?? 'Payment failed. Please try again.');
      emit(currentState.copyWith(
        isCheckingOut: false,
        paymentError: msg,
      ));
      if (event.onFailure != null) {
        event.onFailure!(msg);
      }
    }
  }

  void _onLoadAvailableCoupons(
    LoadAvailableCoupons event,
    Emitter<CartState> emit,
  ) {
    _subscribeToCoupons(event.sellerIds);
  }

  void _onCouponsLoaded(
    _CouponsLoaded event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      emit((state as CartLoaded).copyWith(
        availableCoupons: event.coupons,
      ));
    }
  }

  void _onCouponApplied(
    CouponApplied event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      if (event.coupon.minimumOrderValue > 0 && current.totalAmount < event.coupon.minimumOrderValue) {
        emit(current.copyWith(
          couponMessage: 'Minimum order value of ₹${event.coupon.minimumOrderValue.toStringAsFixed(0)} required.',
          clearCouponMessage: false,
        ));
        return;
      }

      final updated = _computePricing(
        items: current.items,
        appliedCoupon: event.coupon,
        availableCoupons: current.availableCoupons,
        couponMessage: 'Coupon applied! You save ₹${(event.coupon.isPercentage ? (current.totalAmount * event.coupon.discountAmount / 100) : event.coupon.discountAmount).toStringAsFixed(0)}',
        selectedAddressType: current.selectedAddressType,
        deliveryAddress: current.deliveryAddress,
        homeAddress: current.homeAddress,
        workAddress: current.workAddress,
        otherAddress: current.otherAddress,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
      );

      emit(updated);
    }
  }

  Future<void> _onApplyCouponCodeRequested(
    ApplyCouponCodeRequested event,
    Emitter<CartState> emit,
  ) async {
    if (state is! CartLoaded) return;
    final current = state as CartLoaded;
    final inputCode = event.code.trim().toUpperCase();

    if (inputCode.isEmpty) {
      emit(current.copyWith(
        couponMessage: 'Please enter a coupon code.',
        clearCouponMessage: false,
      ));
      return;
    }

    emit(current.copyWith(isCouponLoading: true));

    // Look for matching coupon in currently loaded availableCoupons
    AppliedCoupon? match;
    for (final c in current.availableCoupons) {
      if (c.code.trim().toUpperCase() == inputCode) {
        match = c;
        break;
      }
    }

    if (match != null) {
      if (match.minimumOrderValue > 0 && current.totalAmount < match.minimumOrderValue) {
        emit(current.copyWith(
          isCouponLoading: false,
          couponMessage: 'Minimum order value of ₹${match.minimumOrderValue.toStringAsFixed(0)} required.',
          clearCouponMessage: false,
        ));
        return;
      }

      final updated = _computePricing(
        items: current.items,
        appliedCoupon: match,
        availableCoupons: current.availableCoupons,
        couponMessage: 'Coupon ${match.code} applied successfully!',
        isCouponLoading: false,
        selectedAddressType: current.selectedAddressType,
        deliveryAddress: current.deliveryAddress,
        homeAddress: current.homeAddress,
        workAddress: current.workAddress,
        otherAddress: current.otherAddress,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
      );
      emit(updated);
      return;
    }

    // Try finding coupon for any seller in the cart
    final sellerIds = current.items.map((i) => i.sellerId).toSet().toList();
    for (final sellerId in sellerIds) {
      final couponModel = await _couponRepository.validateAndApplyCoupon(inputCode, sellerId, current.totalAmount);
      if (couponModel != null) {
        final applied = AppliedCoupon(
          code: couponModel.code,
          sellerId: couponModel.sellerId,
          discountAmount: couponModel.discountAmount,
          isPercentage: couponModel.isPercentage,
          couponId: couponModel.id,
          minimumOrderValue: couponModel.minimumOrderValue,
          description: couponModel.description,
        );

        final updated = _computePricing(
          items: current.items,
          appliedCoupon: applied,
          availableCoupons: current.availableCoupons,
          couponMessage: 'Coupon ${applied.code} applied successfully!',
          isCouponLoading: false,
          selectedAddressType: current.selectedAddressType,
          deliveryAddress: current.deliveryAddress,
          homeAddress: current.homeAddress,
          workAddress: current.workAddress,
          otherAddress: current.otherAddress,
          customerName: current.customerName,
          customerPhone: current.customerPhone,
        );
        emit(updated);
        return;
      }
    }

    emit(current.copyWith(
      isCouponLoading: false,
      couponMessage: 'Invalid or expired coupon code.',
      clearCouponMessage: false,
    ));
  }

  void _onCouponRemoved(
    CouponRemoved event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final current = state as CartLoaded;
      final updated = _computePricing(
        items: current.items,
        appliedCoupon: null,
        availableCoupons: current.availableCoupons,
        couponMessage: 'Coupon removed',
        selectedAddressType: current.selectedAddressType,
        deliveryAddress: current.deliveryAddress,
        homeAddress: current.homeAddress,
        workAddress: current.workAddress,
        otherAddress: current.otherAddress,
        customerName: current.customerName,
        customerPhone: current.customerPhone,
      );
      emit(updated);
    }
  }

  void _onCouponError(
    CouponError event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      emit((state as CartLoaded).copyWith(
        couponMessage: event.message,
        clearCouponMessage: false,
      ));
    }
  }
}

class _CouponsLoaded extends CartEvent {
  final List<AppliedCoupon> coupons;
  const _CouponsLoaded(this.coupons);

  @override
  List<Object?> get props => [coupons];
}

class _DefaultUserProfileRepository implements IUserProfileRepository {
  IUserProfileRepository? _delegate;

  IUserProfileRepository _getDelegate() {
    if (_delegate != null) return _delegate!;
    try {
      _delegate = FirebaseUserProfileRepository();
      return _delegate!;
    } catch (_) {
      return const _NoopUserProfileRepository();
    }
  }

  @override
  Future<UserProfile?> loadProfile(String userId) => _getDelegate().loadProfile(userId);

  @override
  Future<void> saveProfile(String userId, UserProfile profile) =>
      _getDelegate().saveProfile(userId, profile);

  @override
  Stream<UserProfile?> watchProfile(String userId) =>
      _getDelegate().watchProfile(userId);

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required String fileName,
    required Uint8List imageBytes,
    required String contentType,
  }) =>
      _getDelegate().uploadProfileImage(
        userId: userId,
        fileName: fileName,
        imageBytes: imageBytes,
        contentType: contentType,
      );

  @override
  Future<void> updateProfileImageUrl(String userId, String imageUrl) =>
      _getDelegate().updateProfileImageUrl(userId, imageUrl);

  @override
  Stream<String?> watchProfileImageUrl(String userId) =>
      _getDelegate().watchProfileImageUrl(userId);

  @override
  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) =>
      _getDelegate().watchTransactions(userId);
}

class _NoopUserProfileRepository implements IUserProfileRepository {
  const _NoopUserProfileRepository();

  @override
  Future<UserProfile?> loadProfile(String userId) async => null;

  @override
  Future<void> saveProfile(String userId, UserProfile profile) async {}

  @override
  Stream<UserProfile?> watchProfile(String userId) => const Stream.empty();

  @override
  Future<String> uploadProfileImage({
    required String userId,
    required String fileName,
    required Uint8List imageBytes,
    required String contentType,
  }) async =>
      '';

  @override
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {}

  @override
  Stream<String?> watchProfileImageUrl(String userId) => const Stream.empty();

  @override
  Stream<List<Map<String, dynamic>>> watchTransactions(String userId) =>
      const Stream.empty();
}

