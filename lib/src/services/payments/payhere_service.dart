class PayHereService {
  PayHereService._();
  static final instance = PayHereService._();

  /// Placeholder for PayHere payment integration.
  /// Implement SDK/webview integration and server-side verification.
  Future<String> processPayment({
    required double amount,
    required String currency,
  }) async {
    // TODO: implement PayHere checkout flow
    throw UnimplementedError('PayHere integration not implemented yet');
  }
}
