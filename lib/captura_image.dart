import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class CapturaImagen extends StatefulWidget {
  const CapturaImagen({super.key});

  @override
  _CapturaImagenState createState() => _CapturaImagenState();
}

class _CapturaImagenState extends State<CapturaImagen> {
  CameraController? _cameraController;
  String _permissionStatusMessage = 'Verificando permiso de cámara...';
  List<CameraDescription>? cameras;
  bool isCameraInitialized = false;
  bool isPermissionGranted = false;
  bool isFrontCamera = false;
  String _responseMessage = ''; // Para mostrar la respuesta del backend

  @override
  void initState() {
    super.initState();
    _checkAndRequestCameraPermission();
  }

  // Verificar y solicitar permisos de cámara
  void _checkAndRequestCameraPermission() {
    Permission.camera.status.then((status) {
      if (status.isGranted) {
        setState(() {
          isPermissionGranted = true;
        });
        _initializeCamera();
      } else if (status.isDenied) {
        Permission.camera.request().then((result) {
          if (result.isGranted) {
            setState(() {
              isPermissionGranted = true;
            });
            _initializeCamera();
          } else {
            setState(() {
              _permissionStatusMessage = "Permiso de cámara denegado.";
            });
          }
        }).catchError((e) {
          print("Error al solicitar permisos: $e");
        });
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _permissionStatusMessage =
              "Permiso denegado permanentemente. Ve a configuración para habilitarlo.";
        });
        _showOpenSettingsDialog();
      }
    }).catchError((e) {
      print("Error al verificar permisos: $e");
    });
  }

  // Mostrar un cuadro de diálogo para redirigir a configuración
  void _showOpenSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permiso requerido"),
        content: const Text(
            "La cámara necesita permisos para funcionar. Por favor, actívalos en la configuración de la aplicación."),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings().then((_) => Navigator.of(context).pop());
            },
            child: const Text("Abrir configuración"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  // Inicializar la cámara
  void _initializeCamera() {
    availableCameras().then((cameraList) {
      cameras = cameraList;
      if (cameras != null && cameras!.isNotEmpty) {
        _cameraController = CameraController(
          cameras![isFrontCamera ? 1 : 0],
          ResolutionPreset.high,
        );

        _cameraController!.initialize().then((_) {
          setState(() {
            isCameraInitialized = true;
          });
        }).catchError((e) {
          print("Error al inicializar la cámara: $e");
        });
      } else {
        print("No se encontraron cámaras en el dispositivo.");
      }
    }).catchError((e) {
      print("Error al obtener la lista de cámaras: $e");
    });
  }

  // Cambiar entre cámara frontal y trasera
  void _toggleCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
    _initializeCamera();
  }

  // Enviar la imagen al backend
  Future<void> _sendImageToBackend(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      final bytes = imageFile.readAsBytesSync();
      final base64Image = base64Encode(bytes);
      print("aqui sigue el base 64");

      print(base64Image);
      final response = await http.post(
        Uri.parse('https://facerecognition-3.onrender.com/api/recognize'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Resultados del reconocimiento: $responseData');
        setState(() {
          _responseMessage = "Rostros detectados: ${responseData['faces']}";
        });
      } else {
        print('Error al enviar la imagen: ${response.statusCode}');
        setState(() {
          _responseMessage = "Error al enviar la imagen al servidor";
        });
      }
    } catch (e) {
      print('Error al enviar la imagen: $e');
      setState(() {
        _responseMessage = "Error al enviar la imagen: $e";
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Captura de Imagen'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isPermissionGranted
          ? isCameraInitialized
              ? Column(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: CameraPreview(_cameraController!),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final image = await _cameraController!.takePicture();
                            print("Imagen capturada: ${image.path}");

                            // Enviar la imagen al backend
                            await _sendImageToBackend(image.path);
                          } catch (e) {
                            print("Error al capturar la imagen: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Capturar Asistencia",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    // Mostrar la respuesta del backend
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _responseMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )
          : Center(
              child: Text(
                _permissionStatusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleCamera,
        tooltip: 'Cambiar cámara',
        backgroundColor: Colors.blueAccent,
        child: Icon(
          isFrontCamera ? Icons.camera_rear : Icons.camera_front,
          color: Colors.white,
        ),
      ),
    );
  }
}
