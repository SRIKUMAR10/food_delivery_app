import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/services/permission_service.dart';

class CustomCameraPage extends StatefulWidget {
  const CustomCameraPage({Key? key}) : super(key: key);

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _checkingPermission = true;
  String _errorMessage = '';
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkAndInitCamera();
  }

  Future<void> _checkAndInitCamera() async {
    if (kIsWeb) {
      setState(() {
        _checkingPermission = false;
        _isInitializing = true;
      });
      _initCamera();
      return;
    }

    final granted = await PermissionService.requestCameraOnly();
    if (!mounted) return;

    if (granted) {
      setState(() {
        _checkingPermission = false;
        _isInitializing = true;
      });
      _initCamera();
    } else {
      final cameraStatus = await PermissionService.getCameraStatus();
      if (!mounted) return;
      setState(() {
        _checkingPermission = false;
        _permanentlyDenied = PermissionService.isPermanentlyDenied(cameraStatus);
      });
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isInitializing = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No cameras available on this device.';
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing camera: $e';
        _isInitializing = false;
      });
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    try {
      final XFile picture = await _controller!.takePicture();
      if (mounted) {
        Navigator.pop(context, picture);
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to take picture: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Capture Photo', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _checkingPermission
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _permanentlyDenied || _errorMessage.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.camera_alt, size: 64, color: Colors.redAccent),
                                const SizedBox(height: 16),
                                Text(
                                  _permanentlyDenied
                                      ? 'Camera permission was permanently denied. Please enable it in your device settings.'
                                      : _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                                ),
                                if (_permanentlyDenied) ...[
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _checkingPermission = true;
                                        _permanentlyDenied = false;
                                      });
                                      _checkAndInitCamera();
                                    },
                                    child: const Text('Open Settings'),
                                  ),
                                ],
                              ],
                            ),
                          )
                        : _isInitializing
                            ? const CircularProgressIndicator(color: Colors.white)
                            : CameraPreview(_controller!),
              ),
            ),
            Container(
              height: 100,
              color: Colors.black,
              child: Center(
                child: _isInitializing || _errorMessage.isNotEmpty || _checkingPermission || _permanentlyDenied
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: _takePicture,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Center(
                            child: Container(
                              width: 55,
                              height: 55,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
