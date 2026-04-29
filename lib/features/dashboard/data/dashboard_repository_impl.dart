import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/dio_client.dart';
import '../domain/dashboard_repository.dart';
import '../domain/tax_summary.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.read(dioProvider));
});

class DashboardRepositoryImpl implements DashboardRepository {
  final Dio _dio;

  DashboardRepositoryImpl(this._dio);

  @override
  Future<TaxSummary> getTaxSummary() async {
    try {
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception("Not authenticated");
      }

      final response = await _dio.get(
        '/summary',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${session.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return TaxSummary.fromJson(response.data['data']);
      } else {
        throw Exception("Failed to load tax summary: ${response.data['message']}");
      }
    } catch (e) {
      throw Exception("Error fetching tax summary: $e");
    }
  }
}
