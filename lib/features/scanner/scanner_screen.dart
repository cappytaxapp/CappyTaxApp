import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitializing = true;
  bool _isProcessing = false;

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
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final XFile image = await _controller!.takePicture();
      // Handle the captured image (Send to FastAPI)
      _processImage(image);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(XFile image) async {
    // TODO: Send image to FastAPI /scan-receipt endpoint using http package
    // For now, simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      // Show success and pop
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt scanned successfully!'), backgroundColor: AppTheme.primaryColor),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
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
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),
          
          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                // Top Bar
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
                        onPressed: () {
                          // Toggle flash
                        },
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Guidance Box Overlay (Visual only)
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.accentColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                
                const Spacer(),
                
                // Bottom Controls
                Container(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 20.0),
                  color: Colors.black54,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library, color: Colors.white, size: 30),
                        onPressed: () {
                          // Open gallery
                        },
                      ),
                      GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: _isProcessing ? AppTheme.primaryColor : Colors.transparent,
                          ),
                          child: Center(
                            child: _isProcessing 
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
                        onPressed: () {
                          // Switch to E-Tax PDF mode
                        },
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
