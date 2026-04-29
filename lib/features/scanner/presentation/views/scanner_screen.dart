import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../viewmodels/scanner_viewmodel.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    } finally {
      if (mounted) {
        ref.read(scannerViewModelProvider.notifier).setInitializing(false);
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final scannerState = ref.read(scannerViewModelProvider);
    if (_controller == null || !_controller!.value.isInitialized || scannerState.isProcessing) {
      return;
    }

    try {
      final XFile image = await _controller!.takePicture();
      final success = await ref.read(scannerViewModelProvider.notifier).processImage(image);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Receipt scanned successfully!'), backgroundColor: AppTheme.primaryColor),
          );
          context.pop();
        } else {
          final error = ref.read(scannerViewModelProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${error ?? "Unknown error"}'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerViewModelProvider);

    if (scannerState.isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scanner')),
        body: const Center(child: Text('Camera not available.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 30),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'Scan Receipt',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flash_on, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.accentColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: scannerState.isProcessing ? AppTheme.primaryColor : Colors.transparent,
                          ),
                          child: Center(
                            child: scannerState.isProcessing 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Container(
                                    width: 65,
                                    height: 65,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.description, color: Colors.white, size: 30),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
