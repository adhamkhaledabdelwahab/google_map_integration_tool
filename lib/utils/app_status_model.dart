import 'status_enums.dart';

class AppStatus {
  final StatusMessageType type;
  final StatusMessage status;
  final String message;

  AppStatus(this.type, this.status, this.message);
}