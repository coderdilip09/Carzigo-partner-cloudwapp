import 'package:flutter/foundation.dart';

class BaseProvider extends ChangeNotifier {
  bool _disposed = false;

  void safeNotifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
