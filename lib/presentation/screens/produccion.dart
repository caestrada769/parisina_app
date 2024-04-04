import 'dart:convert';
import 'package:ParisinaApp/widget/menuAppbar.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProduccionScreen extends StatefulWidget {
  final String areaProduccion;
  const ProduccionScreen({required this.areaProduccion, Key? key}) : super(key: key);

  @override
  State<ProduccionScreen> createState() => _ProduccionScreenState(areaProduccion: areaProduccion);
}

class _ProduccionScreenState extends State<ProduccionScreen> {
  final String areaProduccion;

  _ProduccionScreenState({required this.areaProduccion});
  List<dynamic> productions = [];
  String editedEstado = '';

  @override
  void initState() {
    super.initState();
    fetchProductions();
  }

  Future<void> editProduction(Map<String, dynamic> productionData) async {
    editedEstado = 'Terminado';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
        print('Token no dosponible, vuelve a iniciar sesión');
        mostrarFlushbarFalse(context, 'Token no dosponible, vuelve a iniciar sesión');
        return;
      }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Color.fromRGBO(238, 221, 178, 0.965), // Cambia el color del borde a tu preferencia
              width: 2.0, // Cambia el grosor del borde según sea necesario
            ),
            borderRadius: BorderRadius.circular(25.0), // Cambia el radio del borde
          ),
          title: const Text('¿Terminar Producción?'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Producto: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['nombre_producto']}', // Texto a mostrar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Área: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['nombre_area']}', // Texto a mostrar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Cantidad: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['cantidad_producto']}', // Texto a mostrar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Fecha de entrega: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['fecha_entrega_pedido'].substring(0, 10)}', // Texto a mostrar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Estado Orden: ',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${productionData['estado_orden']}', // Texto a mostrar
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
              backgroundColor: Color.fromRGBO(238, 221, 178, 0.965),
              primary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              ),
              child: const Text('Cancelar',  style: TextStyle(fontWeight: FontWeight.normal,)),
            ),
            TextButton(
              onPressed: () async {
                final response = await http.put(
                  //put porque es para editar
                  Uri.parse(
                      'https://api-parisina-2tpy.onrender.com/api/actualizar-produccion-empleado/${productionData['_id']}'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'token': token!,
                    },
                    body: jsonEncode(<String, dynamic>{
                      'estado_orden': editedEstado,
                    },
                  ),
                );

                if (response.statusCode == 200) {
                  fetchProductions();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  mostrarFlushbarTrue(context, 'La orden ha sido terminada exitosamente');
                } else {
                  // Manejar errores de actualización
                  mostrarFlushbarFalse(context, 'Error al actualizar la producción');
                  throw Exception('Error al actualizar la producción');
                }
              },
              style: TextButton.styleFrom(
              backgroundColor: Color.fromRGBO(235, 192, 83, 0.965),
              primary: Colors.black, // Color del texto
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.0),
              ),
              ),
              child: const Text('Confirmar', style: TextStyle(fontWeight: FontWeight.normal,)),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchProductions() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
        print('Token no dosponible, vuelve a iniciar sesión');
        mostrarFlushbarFalse(context, 'Vuelve a iniciar sesión');
        return;
      }

    final response = await http.get(
        Uri.parse('https://api-parisina-2tpy.onrender.com/api/consultar-produccion-empleado'),
        headers: {'token': token},);
    if (response.statusCode == 200) {
      setState(() {
        final List<dynamic> productionArea = json.decode(response.body);
        productions = productionArea
            .where((production) =>
                production['nombre_area'] == areaProduccion &&
                production['estado_orden'] == 'En preparación')
            .toList();
      });
    } else {
      print('Error en la respuesta: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
      mostrarFlushbarFalse(context, '${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al cargar la lista de producción"),
          backgroundColor: Colors.red,
        ),
      );
      throw Exception('Error al cargar la lista de producción');
    }
  }

  // Función para mostrar el flushbar
  void mostrarFlushbarTrue(BuildContext context, String mensaje) {
    Flushbar(
      message: mensaje,
      icon: Icon(
        Icons.check,
        size: 28.0,
        color: Colors.greenAccent,
        ),
      duration: Duration(seconds: 5),
      // leftBarIndicatorColor: Colors.green[300],
      margin: EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
    )..show(context);
  }

  void mostrarFlushbarFalse(BuildContext context, String mensaje) {
    Flushbar(
      message: mensaje,
      icon: Icon(
        Icons.error,
        size: 28.0,
        color: Colors.redAccent,
        ),
      duration: Duration(seconds: 8),
      // leftBarIndicatorColor: Colors.green[300],
      margin: EdgeInsets.all(30),
      padding: EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarMenu(showBackButton: false),
      backgroundColor: Color.fromARGB(246, 224, 200, 148),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
          color: Colors.white, // Puedes cambiar el color de fondo según tus preferencias
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Text(
                  'Ordenes de Producción',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20,),
                if (productions.isNotEmpty) // Agrega esta condición
                  Expanded(
                    child: ListView.builder(
                      itemCount: productions.length,
                      itemBuilder: (context, index) {
                        final production = productions[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Color.fromRGBO(232, 195, 114, 0.965)),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Producto: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${production['nombre_producto']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'Cantidad: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${production['cantidad_producto']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Fecha de ingreso: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${production['fecha_entrega_pedido'].substring(0, 10)}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Hora de ingreso: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${production['fecha_actualizacion_estado'].substring(production['fecha_actualizacion_estado'].indexOf(' ') + 1)}', 
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Estado Orden: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${production['estado_orden']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                children: [
                                  Expanded(
                                    child: Container(), // Este contenedor ocupa el espacio disponible al principio
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      editProduction(production);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Color.fromRGBO(249, 233, 192, 0.965),
                                      onPrimary: Colors.black, // Cambia el color a tu preferencia
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14.0), // Cambia el valor del borderRadius
                                      ),
                                    ),
                                    child: const Text('Terminar Producción', style: TextStyle(fontWeight: FontWeight.normal,),),
                                  ),
      
                                ],
                              ),
      
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Text('No hay ordenes de producción disponibles'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Llama a fetchProductions nuevamente al hacer clic en el botón flotante
          fetchProductions();
          mostrarFlushbarTrue(context, 'Ordenes de producción actualizadas');
        },
        child: Icon(Icons.refresh),
        backgroundColor: Color.fromRGBO(243, 240, 232, 0.965), // Color de fondo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Valor del border radius
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
