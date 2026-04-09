class BiometricAcceptResult {
  final bool authenticated;
  final bool passkeySupported;
  final String boardingStatus;
  final bool webAuthn;
  final bool isMobileLayout;

  BiometricAcceptResult({
    required this.authenticated,
    required this.passkeySupported,
    required this.boardingStatus,
    required this.webAuthn,
    required this.isMobileLayout,
  });
}
