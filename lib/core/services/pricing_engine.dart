// lib/core/services/pricing_engine.dart
//
// Enterprise-grade stateless Pricing & Multi-GST Calculation Engine.
// Strictly adheres to the rule:
// "Store Raw Data (basePrice, gstPercentage, discountPercentage, stock),
//  Compute Derived Data (gstAmount, discountAmount, roundOff, finalPrice)."

import 'package:equatable/equatable.dart';
import '../models/product_model.dart';
import '../../features/buyer_bloc_architecture/Cart Page/cart_models.dart';

/// Defines the price range of a product for presentation in Buyer UI.
class PriceRange extends Equatable {
  final double minPrice;
  final double maxPrice;
  final bool isRange;

  const PriceRange({
    required this.minPrice,
    required this.maxPrice,
    required this.isRange,
  });

  /// Formatted string: "₹95" or "₹95 – ₹187"
  String formatted({String symbol = '₹'}) {
    final minStr = minPrice.truncateToDouble() == minPrice
        ? minPrice.toInt().toString()
        : minPrice.toStringAsFixed(2);
    if (!isRange || (minPrice - maxPrice).abs() < 0.01) {
      return '$symbol$minStr';
    }
    final maxStr = maxPrice.truncateToDouble() == maxPrice
        ? maxPrice.toInt().toString()
        : maxPrice.toStringAsFixed(2);
    return '$symbol$minStr – $symbol$maxStr';
  }

  @override
  List<Object?> get props => [minPrice, maxPrice, isRange];
}

/// Detailed itemized tax breakdown per element (Base item, Variant, or Add-on).
class TaxLineItem extends Equatable {
  final String title;
  final double basePrice;
  final double discountAmount;
  final double taxableAmount;
  final double gstPercentage;
  final double gstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double finalPrice;

  const TaxLineItem({
    required this.title,
    required this.basePrice,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    required this.gstPercentage,
    required this.gstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    this.igstAmount = 0.0,
    required this.finalPrice,
  });

  @override
  List<Object?> get props => [
    title,
    basePrice,
    discountAmount,
    taxableAmount,
    gstPercentage,
    gstAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    finalPrice,
  ];
}

/// Comprehensive price breakdown for an individual configured item with add-ons.
class ItemPriceBreakdown extends Equatable {
  final TaxLineItem baseItem;
  final List<TaxLineItem> addons;
  final double rawTotal;
  final double totalBasePrice;
  final double totalDiscount;
  final double totalTaxableAmount;
  final double totalGstAmount;
  final double totalCgstAmount;
  final double totalSgstAmount;
  final double totalIgstAmount;
  final double roundOff;
  final double finalPayablePrice;
  final TaxStrategy taxStrategy;

  const ItemPriceBreakdown({
    required this.baseItem,
    this.addons = const [],
    required this.rawTotal,
    required this.totalBasePrice,
    required this.totalDiscount,
    required this.totalTaxableAmount,
    required this.totalGstAmount,
    required this.totalCgstAmount,
    required this.totalSgstAmount,
    this.totalIgstAmount = 0.0,
    required this.roundOff,
    required this.finalPayablePrice,
    required this.taxStrategy,
  });

  /// Whether breakdown contains inter-state IGST tax
  bool get isInterState => totalIgstAmount > 0;

  /// Converts this calculation breakdown into an immutable PriceSnapshot for cart/order locking.
  PriceSnapshot toPriceSnapshot({DateTime? timestamp}) {
    return PriceSnapshot(
      basePrice: totalBasePrice,
      discountAmount: totalDiscount,
      taxableAmount: totalTaxableAmount,
      gstPercentage: baseItem.gstPercentage,
      gstAmount: totalGstAmount,
      cgstAmount: totalCgstAmount,
      sgstAmount: totalSgstAmount,
      igstAmount: totalIgstAmount,
      roundOff: roundOff,
      finalPrice: finalPayablePrice,
      capturedAt: timestamp ?? DateTime.now(),
      taxStrategy: taxStrategy.name,
      itemizedLines: [
        {
          'title': baseItem.title,
          'basePrice': baseItem.basePrice,
          'discountAmount': baseItem.discountAmount,
          'taxableAmount': baseItem.taxableAmount,
          'gstPercentage': baseItem.gstPercentage,
          'gstAmount': baseItem.gstAmount,
          'finalPrice': baseItem.finalPrice,
        },
        ...addons.map((a) => {
          'title': a.title,
          'basePrice': a.basePrice,
          'taxableAmount': a.taxableAmount,
          'gstPercentage': a.gstPercentage,
          'gstAmount': a.gstAmount,
          'finalPrice': a.finalPrice,
        }),
      ],
    );
  }

  @override
  List<Object?> get props => [
    baseItem,
    addons,
    rawTotal,
    totalBasePrice,
    totalDiscount,
    totalTaxableAmount,
    totalGstAmount,
    totalCgstAmount,
    totalSgstAmount,
    totalIgstAmount,
    roundOff,
    finalPayablePrice,
    taxStrategy,
  ];
}

/// Stateless pricing calculation utility.
class PricingEngine {
  const PricingEngine._();

  /// Calculates dynamic price range for a product.
  /// If product has multiple active variants, finds minimum and maximum price points.
  static PriceRange calculateProductPriceRange(Product product) {
    if (product.variants.isNotEmpty) {
      final activeVariants = product.variants.where((v) => v.isAvailable).toList();
      final variantsToEvaluate = activeVariants.isNotEmpty ? activeVariants : product.variants;

      double min = double.infinity;
      double max = 0.0;

      for (final v in variantsToEvaluate) {
        final eff = v.effectivePrice;
        if (eff < min) min = eff;
        if (eff > max) max = eff;
      }

      if (min == double.infinity) min = product.effectivePrice;
      if (max <= 0.0) max = product.effectivePrice;

      return PriceRange(
        minPrice: min,
        maxPrice: max,
        isRange: (max - min).abs() > 0.01,
      );
    }

    final price = product.effectivePrice;
    return PriceRange(
      minPrice: price,
      maxPrice: price,
      isRange: false,
    );
  }

  /// Calculates item price breakdown for a product with its selected variant and add-ons.
  static ItemPriceBreakdown calculateItemBreakdown({
    required Product product,
    ProductVariant? selectedVariant,
    List<ProductAddon> selectedAddons = const [],
    TaxStrategy? overrideTaxStrategy,
    bool isInterState = false,
  }) {
    final strategy = overrideTaxStrategy ?? product.taxStrategy;

    // 1. Resolve Base Item / Variant Price & Tax
    final String baseTitle = selectedVariant != null
        ? '${product.name} (${selectedVariant.name})'
        : product.name;

    final double rawBase = selectedVariant != null && selectedVariant.basePrice > 0
        ? selectedVariant.basePrice
        : (product.basePrice > 0 ? product.basePrice : product.price);

    final double rawDiscountPct = selectedVariant != null
        ? selectedVariant.discountPercentage
        : (product.discountPercentage > 0
            ? product.discountPercentage
            : (product.price > 0 && product.discountPrice > 0 && product.discountPrice < product.price
                ? ((product.price - product.discountPrice) / product.price) * 100.0
                : (product.basePrice > 0 && product.discountPrice > 0 && product.discountPrice < product.basePrice
                    ? ((product.basePrice - product.discountPrice) / product.basePrice) * 100.0
                    : 0.0)));
    final double discountPct = (rawDiscountPct - rawDiscountPct.round()).abs() < 0.05
        ? rawDiscountPct.roundToDouble()
        : rawDiscountPct;

    final double discountAmt =
        ((rawBase * (discountPct / 100.0)) * 100).roundToDouble() / 100.0;
    final double taxableBase = (rawBase - discountAmt).clamp(0.0, double.infinity);

    final double baseGstRate = selectedVariant != null && selectedVariant.gstPercentage > 0
        ? selectedVariant.gstPercentage
        : (product.gstPercentage > 0 ? product.gstPercentage : 5.0);

    final bool baseIsInter = isInterState ||
        (selectedVariant != null && selectedVariant.taxType == 'interState') ||
        (product.taxType == 'interState');

    final double baseCgstRate = baseIsInter ? 0.0 : baseGstRate / 2.0;
    final double baseSgstRate = baseIsInter ? 0.0 : baseGstRate / 2.0;
    final double baseIgstRate = baseIsInter ? baseGstRate : 0.0;

    final double baseGstAmount =
        ((taxableBase * (baseGstRate / 100.0)) * 100).roundToDouble() / 100.0;
    final double baseCgst = baseIsInter
        ? 0.0
        : ((taxableBase * (baseCgstRate / 100.0)) * 100).roundToDouble() / 100.0;
    final double baseSgst = baseIsInter
        ? 0.0
        : ((taxableBase * (baseSgstRate / 100.0)) * 100).roundToDouble() / 100.0;
    final double baseIgst = baseIsInter
        ? baseGstAmount
        : 0.0;
    final double baseFinal = taxableBase + baseGstAmount;

    final baseTaxLine = TaxLineItem(
      title: baseTitle,
      basePrice: rawBase,
      discountAmount: discountAmt,
      taxableAmount: taxableBase,
      gstPercentage: baseGstRate,
      gstAmount: baseGstAmount,
      cgstAmount: baseCgst,
      sgstAmount: baseSgst,
      igstAmount: baseIgst,
      finalPrice: baseFinal,
    );

    // 2. Resolve Add-ons Tax Lines
    final List<TaxLineItem> addonLines = [];
    double addonsRawSum = 0.0;
    double addonsDiscountSum = 0.0;
    double addonsTaxableSum = 0.0;
    double addonsGstSum = 0.0;
    double addonsCgstSum = 0.0;
    double addonsSgstSum = 0.0;
    double addonsIgstSum = 0.0;

    for (final addon in selectedAddons) {
      final double addonBase = addon.basePrice > 0 ? addon.basePrice : addon.price;
      final double addonDiscountPct = addon.discountPercentage;
      final double addonDiscountAmt =
          ((addonBase * (addonDiscountPct / 100.0)) * 100).roundToDouble() / 100.0;
      final double addonTaxable = (addonBase - addonDiscountAmt).clamp(0.0, double.infinity);
      final double addonGstRate = addon.gstPercentage >= 0
          ? addon.gstPercentage
          : (strategy == TaxStrategy.restaurantLevel ? baseGstRate : 5.0);
      final bool addonIsInter = isInterState ||
          addon.taxType == 'interState' ||
          baseIsInter;

      final double addonCgstRate = addonIsInter ? 0.0 : addonGstRate / 2.0;
      final double addonSgstRate = addonIsInter ? 0.0 : addonGstRate / 2.0;
      final double addonIgstRate = addonIsInter ? addonGstRate : 0.0;

      final double addonGstAmount =
          ((addonTaxable * (addonGstRate / 100.0)) * 100).roundToDouble() / 100.0;
      final double addonCgst = addonIsInter
          ? 0.0
          : ((addonTaxable * (addonCgstRate / 100.0)) * 100).roundToDouble() / 100.0;
      final double addonSgst = addonIsInter
          ? 0.0
          : ((addonTaxable * (addonSgstRate / 100.0)) * 100).roundToDouble() / 100.0;
      final double addonIgst = addonIsInter
          ? addonGstAmount
          : 0.0;
      final double addonFinal = ((addonTaxable + addonGstAmount) * 100).roundToDouble() / 100.0;

      addonsRawSum += addonBase;
      addonsDiscountSum += addonDiscountAmt;
      addonsTaxableSum += addonTaxable;
      addonsGstSum += addonGstAmount;
      addonsCgstSum += addonCgst;
      addonsSgstSum += addonSgst;
      addonsIgstSum += addonIgst;

      addonLines.add(TaxLineItem(
        title: addon.name,
        basePrice: addonBase,
        discountAmount: addonDiscountAmt,
        taxableAmount: addonTaxable,
        gstPercentage: addonGstRate,
        gstAmount: addonGstAmount,
        cgstAmount: addonCgst,
        sgstAmount: addonSgst,
        igstAmount: addonIgst,
        finalPrice: addonFinal,
      ));
    }

    // 3. Aggregate Totals
    final double totalBasePrice = ((rawBase + addonsRawSum) * 100).roundToDouble() / 100.0;
    final double totalDiscount = ((discountAmt + addonsDiscountSum) * 100).roundToDouble() / 100.0;
    final double totalTaxableAmount = ((taxableBase + addonsTaxableSum) * 100).roundToDouble() / 100.0;
    final double totalCgstAmount = ((baseCgst + addonsCgstSum) * 100).roundToDouble() / 100.0;
    final double totalSgstAmount = ((baseSgst + addonsSgstSum) * 100).roundToDouble() / 100.0;
    final double totalIgstAmount = ((baseIgst + addonsIgstSum) * 100).roundToDouble() / 100.0;
    final double totalGstAmount = ((baseGstAmount + addonsGstSum) * 100).roundToDouble() / 100.0;

    final double rawTotal = totalTaxableAmount + totalGstAmount;
    final double roundedTotal = rawTotal.roundToDouble();
    final double roundOff = (((roundedTotal - rawTotal)) * 100).roundToDouble() / 100.0;

    return ItemPriceBreakdown(
      baseItem: baseTaxLine,
      addons: addonLines,
      rawTotal: rawTotal,
      totalBasePrice: totalBasePrice,
      totalDiscount: totalDiscount,
      totalTaxableAmount: totalTaxableAmount,
      totalGstAmount: totalGstAmount,
      totalCgstAmount: totalCgstAmount,
      totalSgstAmount: totalSgstAmount,
      totalIgstAmount: totalIgstAmount,
      roundOff: roundOff,
      finalPayablePrice: roundedTotal,
      taxStrategy: strategy,
    );
  }
}
