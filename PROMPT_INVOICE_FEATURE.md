# FoodGo — Professional PDF Invoice Feature Prompt (v3.3)

Copy and paste the entire content below into Gemini / DeepSeek / Claude to generate the implementation.

---

```
I have a Flutter food delivery app called "FoodGo" with the following existing codebase. Implement a complete professional PDF invoice system with BLoC pattern, clean architecture, dependency injection, caching, testing, and cross-platform support.

## Existing Architecture
- **State Management:** flutter_bloc 9.x — all BLoCs receive dependencies via constructor injection (manual DI)
- **DI Pattern:** RepositoryProvider at app root (MultiRepositoryProvider in main.dart). Services are instantiated and passed to BLoCs manually. No GetIt.
- **Firebase:** cloud_firestore 6.x, FirebaseAuth
- **Theme:** Material 3, primary Color(0xFFE52121) (red), background Color(0xFFFBF5F5)

## Existing Models

### OrderModel (lib/core/models/order_model.dart)
```dart
class OrderModel extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String sellerId;
  final String? riderId;
  final OrderStatus status;
  final double amount;
  final DateTime timestamp;
  final List<OrderItemModel>? items;
  final String? deliveryAddress;
  final String? customerPhone;
  final String? paymentMethod;
  // fromMap(Map<String, dynamic> map, String docId) factory
  // toMap() serialization
  // copyWith()
}
```

### OrderItemModel (lib/core/models/order_item_model.dart)
```dart
class OrderItemModel extends Equatable {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final String? imageUrl;
  final String? specialInstructions;
}
```

### OrderStatus Enum (lib/core/models/order_status.dart)
newOrder, accepted, preparing, ready, outForDelivery, delivered, rejected, cancelled

### Existing Repositories
- lib/repositories/firebase_order_repository.dart (implements IOrderRepository)
  - Has getOrderById(String orderId) -> Future<OrderModel?>
- lib/repositories/firebase_product_repository.dart
- lib/repositories/firebase_cart_repository.dart

### Seller Collection (Firestore: 'sellers')
- Fields: businessName, address, phone, image, etc.

### Existing Invoice Button Locations (all have empty onTap: () {})
1. lib/features/buyer_bloc_architecture/Track_Order_page/Track_Order_page_ui.dart (lines ~944, ~1007)
2. lib/features/buyer_bloc_architecture/Chat_Page/buyer_chat_ui.dart (line ~843)

### Existing Testing Structure
- test/unit/ — unit tests
- test/widget/ — widget tests
- Uses mocktail and bloc_test packages
- Uses fake_cloud_firestore for Firestore mocking

## Dependencies Already Available
- share_plus: ^12.0.2
- intl: ^0.20.2
- equatable (inherited via flutter_bloc)

## CRITICAL RULES — Follow strictly

1. **DI Rule:** Do NOT instantiate InvoiceService or FirebaseFirestore directly inside the Bloc. Accept all dependencies via constructor injection. Use the project's existing DI pattern (manual injection, matching how other BLoCs receive their repositories).

2. **Repository Reuse:** Reuse the existing FirebaseOrderRepository's getOrderById() method. Do NOT create duplicate Firestore queries for fetching order data.

3. **Snapshot Consistency:** Fetch order data AND seller data in a single logical operation. Generate the PDF from one consistent snapshot so the invoice reflects a point-in-time state.

4. **Localization:** All visible strings must be localization-ready. Use a dedicated strings class or constants file for invoice-related text. Do NOT hardcode UI strings inline.

5. **Theme Integration:** The PDF visual design (colors, fonts, spacing) should use the same design tokens as the app theme. The primary color is 0xFFE52121, the background is 0xFFFBF5F5.

6. **Caching & Performance:** Cache generated PDF bytes in memory (Map<String, CachedInvoice>). Do NOT regenerate if a valid cached version exists. Invalidate the cache entry only when order data changes (e.g., status update, new timestamp). Cache key: orderId.

7. **Testing:** Create complete unit tests for InvoiceService and InvoicePdfGenerator. Create widget tests for InvoicePreviewScreen. Use mocktail for service mocking and bloc_test for Bloc testing. Follow the project's existing testing conventions (see test/ directory).

8. **Documentation Output:** After generating all code, return a summary containing:
   - List of created files with full paths
   - List of modified files with full paths
   - pubspec.yaml changes
   - Any required asset/configuration changes
   - Commands to verify the implementation

## Step 1: Add Dependencies to pubspec.yaml
  pdf: ^3.11.3
  printing: ^5.14.2
  path_provider: ^2.1.5

## Step 2: Create Clean Architecture Layers

### Layer 0 — Typed Models

#### InvoiceData (lib/core/models/invoice_data.dart)
```dart
class InvoiceData extends Equatable {
  final OrderModel order;
  final SellerModel? seller;
}
```

#### SellerModel (lib/core/models/seller_model.dart — create if not exists)
```dart
class SellerModel extends Equatable {
  final String businessName;
  final String? address;
  final String? phone;
  final String? image;
  // fromMap, toMap, copyWith
}
```

### Layer 1 — Invoice Repository (lib/core/repositories/i_invoice_repository.dart)
```dart
abstract interface class IInvoiceRepository {
  Future<InvoiceData> fetchOrderWithDetails(String orderId);
  // Uses FirebaseOrderRepository.getOrderById() internally for order data
  // Fetches seller data from Firestore 'sellers' collection using sellerId from order
  // Returns a single consistent InvoiceData snapshot
}
```

### Layer 2 — Invoice PDF Generator (lib/core/services/invoice_pdf_generator.dart)
```dart
class InvoicePdfGenerator {
  Future<Uint8List> generatePdf(OrderModel order, SellerModel? seller);
}
```

PDF Layout:
- **Page setup:** A4, 1 inch (72 pt) margins
- **Header section:**
  - Left: "FoodGo" branded text in primary red (#E52121), bold, 28pt font
  - Right: "INVOICE" title (18pt), invoice number below (10pt)
  - Invoice number format: INV-{YYYYMMDD}-{last5charsOfOrderId}
  - Horizontal rule in primary color
- **Order Info (two-column):** Left: Order ID, Date (dd MMM yyyy, hh:mm a), Payment Method. Right: Status, Delivery estimate.
- **Buyer Details:** Customer Name, Delivery Address, Phone
- **Seller Details:** Business Name, Address, Phone (from seller data)
- **Items Table:**
  - Columns: #, Item Name, Quantity, Unit Price, Total
  - Alternating row colors (white / Color(0xFFF5F5F5))
  - Header: dark background (Color(0xFF333333)), white text
- **Summary (right-aligned):** Subtotal, Delivery Charge (from order or configurable default), Tax (from order or configurable default), horizontal rule, Grand Total (bold, primary color, 14pt)
- **Footer:** "Thank you for your order! | FoodGo | support@foodgo.com" — centered, 8pt, gray
- **All amounts:** ₹ + 2 decimal places via NumberFormat.currency
- **Font:** Use built-in Helvetica (pdf package default). No custom font files.

### Layer 3 — Invoice Service (lib/core/services/invoice_service.dart)
```dart
class InvoiceService {
  InvoiceService({
    required IInvoiceRepository invoiceRepository,
    required InvoicePdfGenerator pdfGenerator,
  });

  Future<Uint8List> generateInvoice(String orderId);
  // Internal caching: Map<String, CachedInvoice>
  // CachedInvoice contains: Uint8List bytes, DateTime orderTimestamp
  // Cache valid only if current order timestamp matches cached timestamp
}
```

### Layer 4 — Invoice File Service (lib/core/services/invoice_file_service.dart)
```dart
class InvoiceFileService {
  Future<String> savePdf(Uint8List pdfData, String orderId);
  Future<void> sharePdf(String filePath);
  Future<void> printPdf(Uint8List pdfData);
}
```

- **savePdf:** path_provider — use the best available writable directory for the current platform. Prefer a user-accessible location where supported; otherwise use the application documents directory.
- **sharePdf:** share_plus
- **printPdf:** printing package
- **Preview:** InvoicePreviewScreen itself is the primary PDF viewer (uses PdfPreview from printing package). No external "open with" method is needed.
- **No storage permission request needed** for Android 11+.

## Step 3: BLoC Implementation

### lib/features/buyer_bloc_architecture/Invoice_Page/

```dart
// invoice_event.dart
abstract class InvoiceEvent extends Equatable {}
class LoadInvoice extends InvoiceEvent { final String orderId; }
class DownloadInvoice extends InvoiceEvent {}
class ShareInvoice extends InvoiceEvent {}
class PrintInvoice extends InvoiceEvent {}

// invoice_state.dart
abstract class InvoiceState extends Equatable {}
class InvoiceInitial extends InvoiceState {}
class InvoiceLoading extends InvoiceState {}
class InvoiceLoaded extends InvoiceState {
  final Uint8List pdfData;
  final String? savedPath;
}
class InvoiceError extends InvoiceState { final String message; }
class InvoiceActionSuccess extends InvoiceState { final String message; }

// invoice_bloc.dart
class InvoiceBloc extends Bloc<InvoiceEvent, InvoiceState> {
  InvoiceBloc({
    required InvoiceService invoiceService,
    required InvoiceFileService fileService,
  }) : ... {
    // LoadInvoice: calls invoiceService.generateInvoice(orderId), emits Loading -> Loaded/Error
    // DownloadInvoice: calls fileService.savePdf, emits ActionSuccess
    // ShareInvoice: calls fileService.sharePdf
    // PrintInvoice: calls fileService.printPdf
  }
  // Do NOT instantiate InvoiceService or InvoiceFileService inside this class. Accept via constructor.
}
```

## Step 4: Invoice Preview Screen

### lib/features/buyer_bloc_architecture/Invoice_Page/invoice_preview_screen.dart

```dart
class InvoicePreviewScreen extends StatelessWidget {
  final String orderId;
  // Receives InvoiceBloc via BlocProvider or constructor. Follow existing DI pattern.
  // On init: add LoadInvoice(orderId)
  // BlocBuilder:
  //   InvoiceLoading -> CircularProgressIndicator
  //   InvoiceLoaded -> PdfPreview(bytes: pdfData) from printing package
  //   InvoiceError -> error message + retry button
  // BottomAppBar: Download, Share, Print icons + SnackBar feedback
  // All button labels use localization-ready string references.
}
```

## Step 5: Wire Up Invoice Buttons

In Track_Order_page_ui.dart and buyer_chat_ui.dart, replace:
```dart
onTap: () {}
```
with:
```dart
onTap: () => Navigator.push(context, MaterialPageRoute(
  builder: (_) => InvoicePreviewScreen(orderId: order.id)  // Note: order.id, not order.orderId
))
```

## Step 6: Dependency Injection in main.dart

In main.dart's MultiRepositoryProvider, add the new services:
```dart
RepositoryProvider<IInvoiceRepository>(
  create: (_) => FirebaseInvoiceRepository(
    orderRepository: RepositoryProvider.of<IOrderRepository>(context),
    firestore: FirebaseFirestore.instance,
  ),
),
RepositoryProvider<InvoicePdfGenerator>(
  create: (_) => InvoicePdfGenerator(),
),
RepositoryProvider<InvoiceService>(
  create: (_) => InvoiceService(
    invoiceRepository: RepositoryProvider.of<IInvoiceRepository>(context),
    pdfGenerator: RepositoryProvider.of<InvoicePdfGenerator>(context),
  ),
),
RepositoryProvider<InvoiceFileService>(
  create: (_) => InvoiceFileService(),
),
```

InvoicePreviewScreen gets its Bloc via:
```dart
BlocProvider(
  create: (context) => InvoiceBloc(
    invoiceService: RepositoryProvider.of<InvoiceService>(context),
    fileService: RepositoryProvider.of<InvoiceFileService>(context),
  ),
)
```

## Step 7: Testing

### test/unit/invoice_service_test.dart
- Mock IInvoiceRepository and InvoicePdfGenerator using mocktail
- Test: generateInvoice returns Uint8List
- Test: savePdf saves and returns file path
- Test: caching — second call with same orderId returns cached PDF, does NOT regenerate
- Test: cache invalidation — order timestamp change triggers regeneration

### test/unit/invoice_file_service_test.dart
- Mock path_provider and share_plus
- Test: savePdf writes to correct directory
- Test: sharePdf calls Share.shareXFiles
- Test: printPdf calls Printing.sharePdf or Printing.printPdf

### test/widget/invoice_preview_screen_test.dart
- Use bloc_test and mock InvoiceBloc
- Test: Loading state shows CircularProgressIndicator
- Test: Loaded state shows PdfPreview
- Test: Error state shows error message + retry button
- Test: Download button fires DownloadInvoice event

## Platform-Specific Behavior
- **All platforms:** PdfPreview from printing package handles rendering natively.
- **Save:** path_provider → best available writable directory. Android 11+ scoped storage auto-handled.
- **Share:** share_plus — cross-platform.
- **Print:** printing package — cross-platform, including web.

## Edge Cases & Error Handling
- Seller data missing → skip seller section, continue with available data.
- Order not found → InvoiceError with "Order not found".
- Empty items → empty table with "No items" row.
- Network failure during fetch → InvoiceError with retry.
- PDF generation failure → catch + InvoiceError with details.
- File save failure → SnackBar error, offer share as alternative.
- Large item lists → auto-paginate across multiple PDF pages.

## Code Style Constraints
- REUSE existing FirebaseOrderRepository — do NOT duplicate Firestore queries.
- All dependencies via constructor injection.
- No comments in code.
- Use Equatable for all events, states, and models.
- Match existing import style, file naming, and conventions exactly.
- Primary color: 0xFFE52121, background: 0xFFFBF5F5.
- All monetary values: ₹ + 2 decimal places.
- All dates: "dd MMM yyyy, hh:mm a" (intl package).
- All UI strings: localization-ready (referenced from constants class, not hardcoded).

## Implementation Strategy

Implement the feature incrementally. Ensure each stage is internally consistent before moving to the next.

**Stage 1:** Add dependencies to pubspec.yaml. Create new models (InvoiceData, SellerModel if needed).

**Stage 2:** Implement FirebaseInvoiceRepository (reusing FirebaseOrderRepository), InvoicePdfGenerator, InvoiceService, InvoiceFileService.

**Stage 3:** Implement InvoiceBloc, InvoiceEvent, InvoiceState.

**Stage 4:** Implement InvoicePreviewScreen with BLoC integration and DI wiring in main.dart.

**Stage 5:** Wire existing invoice buttons in Track_Order_page_ui.dart and buyer_chat_ui.dart.

**Stage 6:** Add unit tests and widget tests.

After each stage, verify: no missing imports, no undefined symbols, no duplicate classes, no circular dependencies.

## Final Verification Checklist

Before returning the complete solution, confirm:

- [ ] Every referenced class exists in the codebase or is created in this implementation.
- [ ] Every import statement resolves to an existing file.
- [ ] No duplicate implementations (classes, methods, or widgets) exist.
- [ ] All constructor dependencies are injected — no `new` or `FirebaseFirestore.instance` calls inside BLoCs or services.
- [ ] All UI strings use localization-ready references, not hardcoded text.
- [ ] `flutter analyze` would report zero errors.
- [ ] `flutter test` would pass for all newly added tests.

## File Structure Summary
```
lib/
├── core/
│   ├── models/
│   │   ├── invoice_data.dart
│   │   └── seller_model.dart
│   ├── repositories/
│   │   └── i_invoice_repository.dart
│   └── services/
│       ├── invoice_pdf_generator.dart
│       ├── invoice_service.dart
│       └── invoice_file_service.dart
└── features/
    └── buyer_bloc_architecture/
        └── Invoice_Page/
            ├── invoice_bloc.dart
            ├── invoice_event.dart
            ├── invoice_state.dart
            └── invoice_preview_screen.dart
test/
├── unit/
│   ├── invoice_service_test.dart
│   ├── invoice_file_service_test.dart
│   └── invoice_pdf_generator_test.dart
└── widget/
    └── invoice_preview_screen_test.dart
```

## Output Requirements
After implementing ALL files, return:
1. Complete list of created files with full paths
2. Complete list of modified files with full paths
3. All pubspec.yaml changes (exact diff)
4. Any required asset or configuration changes
5. Commands to verify (flutter pub get, flutter test, etc.)
```
