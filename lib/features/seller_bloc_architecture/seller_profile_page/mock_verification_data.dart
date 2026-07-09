class MockVerificationData {
  static final MockVerificationData _instance = MockVerificationData._internal();
  factory MockVerificationData() => _instance;
  MockVerificationData._internal();

  String storeName = '';
  String email = '';
  String phone = '';
  String address = '';
  String gstNumber = '';
  String taxDetails = '';
  String fssaiLicense = '';
  String bankAccountNumber = '';
  String ifscCode = '';
}
