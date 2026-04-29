import 'package:dio/dio.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../../../core/network/dio_client.dart';
import '../domain/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepositoryImpl(ref.read(dioProvider));
});

class ReceiptRepositoryImpl implements ReceiptRepository {
  final Dio _dio;

  ReceiptRepositoryImpl(this._dio);

  @override
  Future<Map<String, dynamic>> scanReceipt(XFile image) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) throw Exception("Not authenticated");

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        image.path,
        filename: 'receipt.jpg',
      ),
    });

    final response = await _dio.post(
      '/scan-receipt',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
        },
      ),
    );

    if (response.statusCode == 200 && response.data['status'] == 'success') {
      return response.data['data'];
    } else {
      throw Exception(response.data['message'] ?? "Failed to scan receipt");
    }
  }
}
