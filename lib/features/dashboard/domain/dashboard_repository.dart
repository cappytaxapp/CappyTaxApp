import 'tax_summary.dart';

abstract class DashboardRepository {
  Future<TaxSummary> getTaxSummary();
}
