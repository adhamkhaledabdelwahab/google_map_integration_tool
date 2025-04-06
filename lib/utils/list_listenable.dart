import 'package:flutter/material.dart';

import 'app_status_model.dart';

class ListListenable extends ChangeNotifier {
  final List<AppStatus> _statusMessages = [];

  void addStatusMessage(AppStatus status) {
    if (_statusMessages.any((s) => s.type == status.type)) {
      final index = _statusMessages.indexWhere((s) => s.type == status.type);
      if (index != -1) {
        _statusMessages[index] = status;
      }
    } else {
      _statusMessages.add(status);
    }
    notifyListeners();
  }

  List<AppStatus> get statusMessages => _statusMessages;
}
