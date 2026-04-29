import 'package:camera/camera.dart';

abstract class ReceiptRepository {
  Future<Map<String, dynamic>> scanReceipt(XFile image);
}
