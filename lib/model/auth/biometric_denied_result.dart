class BiometricDeniedResult {
  final bool webAuthn;
  final String boardingStatus;
  final bool passkeySupported;

  BiometricDeniedResult({
    required this.webAuthn,
    required this.boardingStatus,
    required this.passkeySupported,
  });
}
