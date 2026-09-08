/// In-session KYC step flags. Reset on new login / new phone number.
class KycStatus {
  KycStatus._();

  static bool identityDone = false;
  static bool addressDone = false;
  static bool bankDone = false;
  static bool profilePhotoDone = false;

  static void markIdentityDone() => identityDone = true;

  static void markAddressDone() => addressDone = true;

  static void markBankDone() => bankDone = true;

  static void markProfilePhotoDone() => profilePhotoDone = true;

  /// Call when user starts with a new phone number (login submit).
  static void resetForNewNumber() {
    identityDone = false;
    addressDone = false;
    bankDone = false;
    profilePhotoDone = false;
  }
}
