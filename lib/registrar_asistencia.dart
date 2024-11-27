import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nikola_tesla/captura_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';


class RegistrarAsistencia extends StatefulWidget {
  const RegistrarAsistencia({super.key});

  @override
  _RegistrarAsistenciaState createState() => _RegistrarAsistenciaState();
}

class _RegistrarAsistenciaState extends State<RegistrarAsistencia> {
  // Coordenadas del centro educativo (ajustar según sea necesario)
  final LatLng centroEducativo = LatLng(-8.093262, -78.999452);
  LatLng ubicacionActual = LatLng(0, 0); // Ubicación inicial
  bool isLocationReady = false; // Para verificar si la ubicación está cargada
  bool isWithinDistance = false;
  @override
  void initState() {
    super.initState();
    _checkLocationService();
  }

  // Método para verificar el servicio de ubicación y los permisos
  Future<void> _checkLocationService() async {
    // Verificar si el servicio de ubicación está habilitado
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    print('Service enabled: $serviceEnabled'); // Verifica si el servicio está habilitado

    if (!serviceEnabled) {
      // Si el servicio no está habilitado, pedimos al usuario que lo active
      print('Ubicación desactivada, abriendo configuraciones...');
      await Geolocator.openLocationSettings();
    } else {
      // Verificar si los permisos de ubicación están concedidos
      PermissionStatus permissionStatus = await Permission.location.request();
      print('Permission status: $permissionStatus');

      if (permissionStatus.isGranted) {
        // Si el permiso es concedido, obtenemos la ubicación
        _getCurrentLocation();
      } else {
        // Si los permisos no son concedidos
        print('El usuario ha denegado los permisos de ubicación.');
        // Puedes mostrar un mensaje o redirigir a la configuración
      }
    }
  }

  // Método para obtener la ubicación actual
Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        ubicacionActual = LatLng(position.latitude, position.longitude);
        isLocationReady = true;

        // Calcular la distancia desde la ubicación actual al centro educativo
        double distanceInMeters = Geolocator.distanceBetween(
          centroEducativo.latitude,
          centroEducativo.longitude,
          ubicacionActual.latitude,
          ubicacionActual.longitude,
        );
        isWithinDistance = distanceInMeters <= 1000; // Verificar si está dentro de 1000 metros
        print('Distancia al centro educativo: $distanceInMeters metros');
      });
    } catch (e) {
      print('Error al obtener la ubicación: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Registrar mi asistencia',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Mapa en la mitad superior de la pantalla
          Container(
            height: MediaQuery.of(context).size.height / 2, // La mitad de la pantalla
            child: FlutterMap(
              options: MapOptions(
                initialCenter: isLocationReady ? ubicacionActual : centroEducativo, // Cambiar el centro según la ubicación
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: centroEducativo,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    if (isLocationReady)
                      Marker(
                        point: ubicacionActual,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 40,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isWithinDistance
                      ? ElevatedButton(
                          onPressed: () {
                            // Redirigir a la página de CapturaImagen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CapturaImagen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Registrar Asistencia',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        )
                      : const Text(
                          'No estás dentro del área permitida para registrar asistencia.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
