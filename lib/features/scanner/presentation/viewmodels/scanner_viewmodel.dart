import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/receipt_repository_impl.dart';
import '../../domain/receipt_repository.dart';

class ScannerState {
  final bool isInitializing;
  final bool isProcessing;
  final String? error;
  final Map<String, dynamic>? scanResult;

  ScannerState({
    this.isInitializing = true,
    this.isProcessing = false,
    this.error,
    this.scanResult,
  });

  ScannerState copyWith({
    bool? isInitializing,
    bool? isProcessing,
    String? error,
    Map<String, dynamic>? scanResult,
  }) {
    return ScannerState(
      isInitializing: isInitializing ?? this.isInitializing,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      scanResult: scanResult ?? this.scanResult,
    );
  }
}

class ScannerViewModel extends Notifier<ScannerState> {
  late final ReceiptRepository _repository;

  @override
  ScannerState build() {
    _repository = ref.read(receiptRepositoryProvider);
    return ScannerState();
  }

  void setInitializing(bool value) {
    state = state.copyWith(isInitializing: value);
  }

  Future<bool> processImage(XFile image) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      final result = await _repository.scanReceipt(image);
      state = state.copyWith(isProcessing: false, scanResult: result);
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }
}

final scannerViewModelProvider = NotifierProvider<ScannerViewModel, ScannerState>(() {
  return ScannerViewModel();
});
