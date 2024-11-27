import 'package:flutter/material.dart';

class MisRegistros extends StatelessWidget {
  const MisRegistros({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo para la tabla
    final List<Map<String, String>> registros = [
      {"Nombre": "Juan Pérez", "Fecha": "2024-11-26", "Hora": "10:00 AM", "Estado": "Presente"},
      {"Nombre": "María López", "Fecha": "2024-11-26", "Hora": "10:05 AM", "Estado": "Tarde"},
      {"Nombre": "Carlos Gómez", "Fecha": "2024-11-25", "Hora": "09:55 AM", "Estado": "Presente"},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Mis Registros',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.blue[900],
        padding: const EdgeInsets.all(10),
        child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.deepPurple),
          columns: const [
            DataColumn(
              label: Text(
                'Nombre',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Fecha',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Hora',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Estado',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: registros
              .map(
                (registro) => DataRow(
                  cells: [
                    DataCell(Text(registro["Nombre"]!, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(registro["Fecha"]!, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(registro["Hora"]!, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(registro["Estado"]!, style: const TextStyle(color: Colors.white))),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
