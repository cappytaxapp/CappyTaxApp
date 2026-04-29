import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_repository_impl.dart';
import '../../domain/dashboard_repository.dart';
import '../../domain/tax_summary.dart';

// State model for Dashboard
class DashboardState {
  final bool isLoading;
  final TaxSummary? summary;
  final String? error;

  DashboardState({this.isLoading = false, this.summary, this.error});

  DashboardState copyWith({bool? isLoading, TaxSummary? summary, String? error}) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      error: error,
    );
  }
}

// ViewModel (Notifier)
class DashboardViewModel extends Notifier<DashboardState> {
  late final DashboardRepository _repository;

  @override
  DashboardState build() {
    _repository = ref.read(dashboardRepositoryProvider);
    // Fetch summary on load
    Future.microtask(() => fetchSummary());
    return DashboardState(isLoading: true);
  }

  Future<void> fetchSummary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final summary = await _repository.getTaxSummary();
      state = state.copyWith(isLoading: false, summary: summary);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardViewModelProvider = NotifierProvider<DashboardViewModel, DashboardState>(() {
  return DashboardViewModel();
});
