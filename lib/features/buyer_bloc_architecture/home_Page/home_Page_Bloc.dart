import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/product_model.dart';
import '../../../core/repositories/i_product_repository.dart';
import '../../../core/services/google_places_service.dart';
import '../../../core/services/seller_status_service.dart';
import '../../../repositories/category_repository.dart';
import 'home_page_models.dart';
import 'food_item_mapper.dart';

import 'seller_model.dart';

// Pull in event and state definitions via Dart's part mechanism.
part 'home_Page_Event.dart';
part 'home_Page_State.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final IProductRepository _productRepository;
  final CategoryRepository _categoryRepository;
  final SellerStatusService _sellerStatusService;
  final FirebaseFirestore? _firestore;
  final GooglePlacesService? _placesService;

  List<FoodItem> _allItems = [];
  List<FoodCategory> _categories = [];
  Map<String, SellerAvailability> _sellerAvailabilities = {};
  String _currentAddress = 'Fetching location...';
  List<PromotionBanner> _banners = const [];
  List<Seller> _featuredSellers = const [];
  List<FoodItem> _popularProducts = const [];
  List<FoodItem> _recentlyOrderedItems = const [];
  List<Seller> _searchedSellers = const [];

  RestaurantSortOption _activeSortOption = RestaurantSortOption.rating;
  String _selectedCuisine = '';
  double _userLat = 0.0;
  double _userLng = 0.0;
  Map<String, double> _distancesMap = {};

  String _selectedCategoryId = '';
  String _searchQuery = '';

  StreamSubscription<List<FoodCategory>>? _categorySubscription;
  StreamSubscription<List<Product>>? _productSubscription;
  StreamSubscription<QuerySnapshot>? _sellersSubscription;
  StreamSubscription<QuerySnapshot>? _promotionsSubscription;
  StreamSubscription<DocumentSnapshot>? _userProfileSubscription;
  final Map<String, StreamSubscription<SellerAvailability>> _sellerStatusSubscriptions = {};
  Timer? _batchTimer;
  Timer? _loadingTimeoutTimer;

  HomePageBloc({
    required IProductRepository productRepository,
    required CategoryRepository categoryRepository,
    SellerStatusService? sellerStatusService,
    FirebaseFirestore? firestore,
    GooglePlacesService? placesService,
  }) : _productRepository = productRepository,
       _categoryRepository = categoryRepository,
       _sellerStatusService = sellerStatusService ?? SellerStatusService(),
       _firestore = firestore,
       _placesService = placesService,
       super(const HomePageInitial('', [])) {
    on<HomePageStarted>(_onStarted);
    on<CategorySelected>(_onCategorySelected);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchCleared>(_onSearchCleared);
    on<CategoriesUpdated>(_onCategoriesUpdated);
    on<_ProductsReceived>(_onProductsReceived);
    on<_ProductErrorReceived>(_onProductErrorReceived);
    on<_SellerAvailabilitiesUpdated>(_onSellerAvailabilitiesUpdated);
    on<FetchUserLocation>(_onFetchUserLocation);
    on<LocationUpdated>(_onLocationUpdated);
    on<FeaturedSellersUpdated>(_onFeaturedSellersUpdated);
    on<RecentOrdersUpdated>(_onRecentOrdersUpdated);
    on<PromotionsUpdated>(_onPromotionsUpdated);
    on<RestaurantSortChanged>(_onRestaurantSortChanged);
    on<BuyerLocationUpdated>(_onBuyerLocationUpdated);
    on<CuisineFilterChanged>(_onCuisineFilterChanged);
  }


  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    _productSubscription?.cancel();
    _sellersSubscription?.cancel();
    _promotionsSubscription?.cancel();
    _userProfileSubscription?.cancel();
    _cancelSellerStatusSubscriptions();
    _batchTimer?.cancel();
    _loadingTimeoutTimer?.cancel();
    return super.close();
  }

  void _subscribeToUserProfile(String uid) {
    _userProfileSubscription?.cancel();
    try {
      final db = _firestore ?? FirebaseFirestore.instance;
      _userProfileSubscription = db
          .collection('buyer_user')
          .doc(uid)
          .snapshots()
          .listen((doc) {
        if (doc.exists && !isClosed) {
          final data = doc.data() as Map<String, dynamic>?;
          final addr = (data?['address'] ?? data?['deliveryAddress'] ?? '').toString().trim();
          final lat = (data?['latitude'] as num?)?.toDouble() ?? (data?['lat'] as num?)?.toDouble() ?? 0.0;
          final lng = (data?['longitude'] as num?)?.toDouble() ?? (data?['lng'] as num?)?.toDouble() ?? 0.0;
          if (addr.isNotEmpty && addr != 'Fetching location...' && addr != 'Fetching live location...') {
            add(BuyerLocationUpdated(lat, lng, addr));
          }
        }
      }, onError: (error) {
        debugPrint('Firestore user profile stream error: $error');
      });
    } catch (e) {
      debugPrint('User profile subscription exception: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String get _selectedCategoryName {
    if (_categories.isEmpty) return '';
    return _categories
        .firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => _categories.first,
        )
        .name;
  }

  void _emitFilteredState(Emitter<HomePageState> emit) {
    if (_allItems.isEmpty) {
      emit(_buildEmptyState(_selectedCategoryName));
      return;
    }
    emit(_buildLoadedState());
  }

  /// Recomputes the seller distance map using the buyer's current coordinates.
  void _computeDistances() {
    if (_userLat == 0.0 && _userLng == 0.0) {
      _distancesMap = {};
      return;
    }
    final map = <String, double>{};
    for (final seller in _featuredSellers) {
      if (seller.latitude == 0.0 && seller.longitude == 0.0) continue;
      map[seller.id] = calculateDistanceKm(
        _userLat,
        _userLng,
        seller.latitude,
        seller.longitude,
      );
    }
    _distancesMap = map;
  }

  /// Applies the active cuisine filter and sort strategy to the featured
  /// sellers entirely in memory (no additional Firestore reads).
  List<Seller> _computeDisplayedSellers() {
    var sellers = List<Seller>.from(_featuredSellers);

    if (_selectedCuisine.isNotEmpty) {
      final cuisine = _selectedCuisine.toLowerCase();
      sellers = sellers
          .where((s) => s.cuisines.any((c) => c.toLowerCase() == cuisine))
          .toList();
    }

    switch (_activeSortOption) {
      case RestaurantSortOption.rating:
        sellers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case RestaurantSortOption.distance:
        sellers.sort((a, b) {
          final da = _distancesMap[a.id] ?? double.infinity;
          final db = _distancesMap[b.id] ?? double.infinity;
          return da.compareTo(db);
        });
        break;
      case RestaurantSortOption.deliveryTime:
        sellers.sort((a, b) {
          final da = _distancesMap[a.id] ?? double.infinity;
          final db = _distancesMap[b.id] ?? double.infinity;
          return estimateDeliveryTimeMinutes(da)
              .compareTo(estimateDeliveryTimeMinutes(db));
        });
        break;
    }
    return sellers;
  }

  HomePageLoaded _buildLoadedState({
    List<FoodItem>? filteredItems,
    String? searchQuery,
  }) {
    return HomePageLoaded(
      allItems: _allItems,
      filteredItems: filteredItems ?? _allItems,
      selectedCategoryId: _selectedCategoryId,
      categories: _categories,
      currentAddress: _currentAddress,
      searchQuery: searchQuery ?? _searchQuery,
      sellerAvailabilities: Map.from(_sellerAvailabilities),
      banners: _banners,
      featuredSellers: _computeDisplayedSellers(),
      popularProducts: _popularProducts,
      recentlyOrderedItems: _recentlyOrderedItems,
      searchedSellers: _searchedSellers,
      activeSortOption: _activeSortOption,
      selectedCuisine: _selectedCuisine,
      userLat: _userLat,
      userLng: _userLng,
      distancesMap: Map.from(_distancesMap),
    );
  }

  HomePageEmpty _buildEmptyState(String categoryName) {
    return HomePageEmpty(
      categoryName,
      _selectedCategoryId,
      _categories,
      currentAddress: _currentAddress,
      banners: _banners,
      featuredSellers: _computeDisplayedSellers(),
      recentlyOrderedItems: _recentlyOrderedItems,
      popularProducts: _popularProducts,
      activeSortOption: _activeSortOption,
      distancesMap: Map.from(_distancesMap),
      sellerAvailabilities: Map.from(_sellerAvailabilities),
      selectedCuisine: _selectedCuisine,
      userLat: _userLat,
      userLng: _userLng,
    );
  }

  HomePageSearchEmpty _buildSearchEmptyState(String query) {
    return HomePageSearchEmpty(
      query,
      _selectedCategoryId,
      _categories,
      currentAddress: _currentAddress,
      banners: _banners,
      featuredSellers: _computeDisplayedSellers(),
      recentlyOrderedItems: _recentlyOrderedItems,
      popularProducts: _popularProducts,
      activeSortOption: _activeSortOption,
      distancesMap: Map.from(_distancesMap),
      sellerAvailabilities: Map.from(_sellerAvailabilities),
      selectedCuisine: _selectedCuisine,
      userLat: _userLat,
      userLng: _userLng,
    );
  }

  void _subscribeToSellerStatuses(List<String> sellerIds) {
    _cancelSellerStatusSubscriptions();
    _sellerAvailabilities = {};

    for (final sellerId in sellerIds) {
      final sub = _sellerStatusService.watchSellerStatus(sellerId).listen((status) {
        if (!isClosed) {
          _onSellerStatusReceived(sellerId, status);
        }
      });
      _sellerStatusSubscriptions[sellerId] = sub;
    }
  }

  void _onSellerStatusReceived(String sellerId, SellerAvailability status) {
    _sellerAvailabilities[sellerId] = status;
    _batchTimer?.cancel();
    _batchTimer = Timer(const Duration(milliseconds: 100), () {
      if (!isClosed) {
        add(_SellerAvailabilitiesUpdated(Map.from(_sellerAvailabilities)));
      }
    });
  }

  void _cancelSellerStatusSubscriptions() {
    for (final sub in _sellerStatusSubscriptions.values) {
      sub.cancel();
    }
    _sellerStatusSubscriptions.clear();
    _batchTimer?.cancel();
    _batchTimer = null;
  }

  // ── Event Handlers ────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    HomePageStarted event,
    Emitter<HomePageState> emit,
  ) async {
    if (_categories.isEmpty) {
      _categories = CategoryRepository.defaultCategories;
    }
    if (_selectedCategoryId.isEmpty) {
      _selectedCategoryId = _categories.first.id;
    }

    if (state is! HomePageLoaded &&
        state is! HomePageEmpty &&
        state is! HomePageSearchEmpty) {
      emit(HomePageLoading(_selectedCategoryId, _categories));
    }

    // Immediately trigger fetching default category products
    add(CategorySelected(_selectedCategoryId));

    // Immediately trigger fetching user delivery location
    add(const FetchUserLocation());

    // Subscribe to categories safely
    _categorySubscription?.cancel();
    _categorySubscription = _categoryRepository.getCategories().listen(
      (categories) {
        if (!isClosed) {
          add(CategoriesUpdated(categories));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(CategoriesUpdated(CategoryRepository.defaultCategories));
        }
      },
    );

    // Subscribe to sellers from Firestore in real-time
    _sellersSubscription?.cancel();
    _promotionsSubscription?.cancel();
    try {
      final db = _firestore ?? FirebaseFirestore.instance;
      _sellersSubscription = db
          .collection('sellers')
          .snapshots()
          .listen((snapshot) {
        final sellers = <Seller>[];
        for (final doc in snapshot.docs) {
          try {
            sellers.add(Seller.fromFirestore(doc));
          } catch (e) {
            // Log individual parsing error without crashing the stream
            print('Error parsing seller doc ID ${doc.id}: $e');
          }
        }
        if (!isClosed) {
          add(FeaturedSellersUpdated(sellers));
        }
      }, onError: (error) {
        print('Firestore sellers stream error: $error');
      });

      // Subscribe to promotions from Firestore in real-time
      _promotionsSubscription = db
          .collection('promotions')
          .snapshots()
          .listen((snapshot) {
        final banners = <PromotionBanner>[];
        for (final doc in snapshot.docs) {
          try {
            banners.add(PromotionBanner.fromFirestore(doc.data(), doc.id));
          } catch (e) {
            print('Error parsing promotion doc ID ${doc.id}: $e');
          }
        }
        if (!isClosed) {
          add(PromotionsUpdated(banners));
        }
      }, onError: (error) {
        print('Firestore promotions stream error: $error');
        if (!isClosed) {
          add(const PromotionsUpdated([]));
        }
      });
    } catch (e) {
      print('Firebase not initialized in tests or fallback triggered: $e');
    }
  }

  Future<void> _onCategoriesUpdated(
    CategoriesUpdated event,
    Emitter<HomePageState> emit,
  ) async {
    if (event.categories.isNotEmpty) {
      _categories = event.categories;
    }

    if (_categories.isEmpty) {
      emit(_buildEmptyState(''));
      return;
    }

    // Initialize or fix selected category id
    if (_selectedCategoryId.isEmpty ||
        !_categories.any((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = _categories
          .firstWhere((c) => c.isSelected, orElse: () => _categories.first)
          .id;
      _searchQuery = '';
      _allItems = [];

      add(CategorySelected(_selectedCategoryId));
      return;
    }

    // If category didn't change, update state with new categories
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(categories: _categories));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState(_selectedCategoryName));
    }
  }

  Future<void> _onCategorySelected(
    CategorySelected event,
    Emitter<HomePageState> emit,
  ) async {
    _selectedCategoryId = event.categoryId;
    _searchQuery = '';
    _allItems = [];
    _cancelSellerStatusSubscriptions();

    emit(HomePageLoading(_selectedCategoryId, _categories));

    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!isClosed && state is HomePageLoading) {
        add(const _ProductsReceived([], isSearch: false));
      }
    });

    _productSubscription?.cancel();
    _productSubscription = _productRepository
        .getProductsByCategory(_selectedCategoryName)
        .listen(
      (products) {
        if (!isClosed) {
          try {
            final items = products.map((p) => FoodItemMapper.toViewModel(p)).toList();
            add(_ProductsReceived(items, isSearch: false));
          } catch (e) {
            add(_ProductsReceived(const [], isSearch: false));
          }
        }
      },
      onError: (e) {
        if (!isClosed) {
          add(_ProductErrorReceived('Failed to load products: $e'));
        }
      },
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<HomePageState> emit,
  ) async {
    _searchQuery = event.query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      add(const SearchCleared());
      return;
    }

    emit(HomePageLoading(_selectedCategoryId, _categories));

    _loadingTimeoutTimer?.cancel();
    _loadingTimeoutTimer = Timer(const Duration(milliseconds: 1500), () {
      if (!isClosed && state is HomePageLoading) {
        add(const _ProductsReceived([], isSearch: true, query: ''));
      }
    });

    _productSubscription?.cancel();
    _productSubscription = _productRepository
        .searchProducts(_searchQuery, _selectedCategoryName)
        .listen(
      (products) {
        if (!isClosed) {
          try {
            final items = products.map((p) => FoodItemMapper.toViewModel(p)).toList();
            add(_ProductsReceived(items, isSearch: true, query: _searchQuery));
          } catch (e) {
            add(_ProductsReceived(const [], isSearch: true, query: _searchQuery));
          }
        }
      },
      onError: (e) {
        if (!isClosed) {
          add(_ProductErrorReceived('Search failed: $e'));
        }
      },
    );
  }

  void _onProductsReceived(
    _ProductsReceived event,
    Emitter<HomePageState> emit,
  ) {
    _loadingTimeoutTimer?.cancel();

    if (event.isSearch) {
      if (event.items.isEmpty) {
        emit(_buildSearchEmptyState(event.query));
        return;
      }
      emit(
        _buildLoadedState(
          filteredItems: event.items,
          searchQuery: event.query,
        ),
      );
      return;
    }

    _allItems = event.items;
    _popularProducts = _allItems.where((item) => item.isBestSeller || item.rating >= 4.0).toList();
    if (_popularProducts.isEmpty && _allItems.isNotEmpty) {
      _popularProducts = _allItems.take(5).toList();
    }
    if (_recentlyOrderedItems.isEmpty && _allItems.isNotEmpty) {
      _recentlyOrderedItems = _allItems.take(3).toList();
    }

    final sellerIds = event.items.map((i) => i.sellerId).toSet().toList();
    _subscribeToSellerStatuses(sellerIds);

    if (_allItems.isEmpty) {
      _cancelSellerStatusSubscriptions();
      emit(_buildEmptyState(_selectedCategoryName));
      return;
    }

    _searchQuery = '';
    emit(_buildLoadedState());
  }

  void _onProductErrorReceived(
    _ProductErrorReceived event,
    Emitter<HomePageState> emit,
  ) {
    _loadingTimeoutTimer?.cancel();
    emit(
      HomePageError(
        event.message,
        _selectedCategoryId,
        _categories,
        currentAddress: _currentAddress,
      ),
    );
  }

  void _onSearchCleared(SearchCleared event, Emitter<HomePageState> emit) {
    _searchQuery = '';
    _emitFilteredState(emit);
  }

  void _onSellerAvailabilitiesUpdated(
    _SellerAvailabilitiesUpdated event,
    Emitter<HomePageState> emit,
  ) {
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        sellerAvailabilities: event.availabilities,
      ));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  Future<void> _onFetchUserLocation(FetchUserLocation event, Emitter<HomePageState> emit) async {
    try {
      final db = _firestore ?? FirebaseFirestore.instance;
      final uid = FirebaseAuth.instance.currentUser?.uid;
      bool hasAddress = false;

      if (uid != null) {
        _subscribeToUserProfile(uid);
        final doc = await db.collection('buyer_user').doc(uid).get();
        if (doc.exists) {
          final data = doc.data();
          final addr = data?['address']?.toString() ?? data?['deliveryAddress']?.toString();
          if (addr != null && addr.isNotEmpty && addr != 'Fetching location...' && addr != 'Fetching live location...') {
            _currentAddress = addr;
            hasAddress = true;
          }
          final lat = (data?['latitude'] as num?)?.toDouble() ?? (data?['lat'] as num?)?.toDouble();
          final lng = (data?['longitude'] as num?)?.toDouble() ?? (data?['lng'] as num?)?.toDouble();
          if (lat != null && lng != null && (lat != 0.0 || lng != 0.0)) {
            _userLat = lat;
            _userLng = lng;
          }
        }
      }

      // If user profile has no stored address or user is unauthenticated,
      // attempt device GPS location lookup with a short timeout
      if (!hasAddress) {
        try {
          final places = _placesService ?? GooglePlacesService.instance;
          final gpsDetails = await places.getCurrentLocationAddress()
              .timeout(const Duration(seconds: 4));
          if (gpsDetails != null && gpsDetails.formattedAddress.isNotEmpty) {
            _currentAddress = gpsDetails.formattedAddress;
            _userLat = gpsDetails.latitude ?? 0.0;
            _userLng = gpsDetails.longitude ?? 0.0;
            hasAddress = true;
            if (uid != null) {
              // Store auto-resolved location to Firestore
              db.collection('buyer_user').doc(uid).set({
                'address': _currentAddress,
                'deliveryAddress': _currentAddress,
                'latitude': _userLat,
                'longitude': _userLng,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true)).catchError((e) => debugPrint('Error saving auto-fetched location: $e'));
            }
          }
        } catch (e) {
          debugPrint('Device GPS fetch timed out or failed: $e');
        }
      }

      if (!hasAddress && (_currentAddress == 'Fetching location...' || _currentAddress == 'Fetching live location...')) {
        _currentAddress = 'Select delivery address';
      }
    } catch (_) {
      // Safe fallback when unauthenticated, offline, or in test environment
      if (_currentAddress == 'Fetching location...' || _currentAddress == 'Fetching live location...') {
        _currentAddress = 'Select delivery address';
      }
    }

    _computeDistances();
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        currentAddress: _currentAddress,
        userLat: _userLat,
        userLng: _userLng,
        distancesMap: Map.from(_distancesMap),
        featuredSellers: _computeDisplayedSellers(),
      ));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onLocationUpdated(LocationUpdated event, Emitter<HomePageState> emit) {
    _currentAddress = event.address;
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(currentAddress: _currentAddress));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onFeaturedSellersUpdated(FeaturedSellersUpdated event, Emitter<HomePageState> emit) {
    _featuredSellers = event.sellers;
    _computeDistances();
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        featuredSellers: _computeDisplayedSellers(),
        distancesMap: Map.from(_distancesMap),
      ));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onRecentOrdersUpdated(RecentOrdersUpdated event, Emitter<HomePageState> emit) {
    _recentlyOrderedItems = event.items;
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(recentlyOrderedItems: _recentlyOrderedItems));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onPromotionsUpdated(PromotionsUpdated event, Emitter<HomePageState> emit) {
    _banners = event.banners;
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(banners: _banners));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onRestaurantSortChanged(RestaurantSortChanged event, Emitter<HomePageState> emit) {
    _activeSortOption = event.sortOption;
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        activeSortOption: _activeSortOption,
        featuredSellers: _computeDisplayedSellers(),
      ));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onBuyerLocationUpdated(BuyerLocationUpdated event, Emitter<HomePageState> emit) {
    _userLat = event.lat;
    _userLng = event.lng;
    _currentAddress = event.address;
    _computeDistances();
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        currentAddress: _currentAddress,
        userLat: _userLat,
        userLng: _userLng,
        distancesMap: Map.from(_distancesMap),
        featuredSellers: _computeDisplayedSellers(),
      ));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }

  void _onCuisineFilterChanged(CuisineFilterChanged event, Emitter<HomePageState> emit) {
    _selectedCuisine = event.cuisine.trim();
    if (state is HomePageLoaded) {
      emit((state as HomePageLoaded).copyWith(
        selectedCuisine: _selectedCuisine,
        featuredSellers: _computeDisplayedSellers(),
      ));
    } else if (state is HomePageEmpty) {
      emit(_buildEmptyState((state as HomePageEmpty).categoryName));
    } else if (state is HomePageSearchEmpty) {
      emit(_buildSearchEmptyState((state as HomePageSearchEmpty).query));
    }
  }
}

final class _SellerAvailabilitiesUpdated extends HomePageEvent {
  final Map<String, SellerAvailability> availabilities;
  const _SellerAvailabilitiesUpdated(this.availabilities);
}

