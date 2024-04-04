import 'package:ParisinaApp/presentation/screens/detallePedido.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../widget/menuAppbar.dart';

class DomiciliosScreen extends StatefulWidget {
  const DomiciliosScreen({Key? key}) : super(key: key);

  @override
  State<DomiciliosScreen> createState() => _DomiciliosScreenState();
}

class _DomiciliosScreenState extends State<DomiciliosScreen> {
  List<Map<String, dynamic>> usuarios = [];
  List<dynamic> pedidosDomiciliario = [];
  String? userEmail = '';

  String nuevoEstadoPedido = '';
  String nuevoEstadoPago = '';

  @override
  void initState() {
    super.initState();
    // Obtén el correo electrónico del usuario desde SharedPreferences
    obtenerCorreoDomiciliario();
  }

  Future<void> editarPedido(Map<String, dynamic> pedidoData) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                      child: const Text('Entregar Pedido',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold))),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DomiciliosScreen(),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey
                            .withOpacity(0.3), // Color de fondo con opacidad
                      ),
                      padding:
                          EdgeInsets.all(8), // Espacio interior del contenedor
                      child: Icon(Icons.close,
                          color: Colors.black), // Icono para cerrar la alerta
                    ),
                  )
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Estado pago:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: pedidoData['estado_pago'], // Establecer el valor inicial
                      items: <String>['Pendiente', 'Pagado']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (pedidoData['estado_pago'] ==
                              'Pagado') // Verificar si el valor inicial es "Pagado"
                          ? null // Si es "Pagado", establecer onChanged como null
                          : (newValue) {
                              setState(() {
                                print('Nuevo estado seleccionado: $newValue');
                                pedidoData['estado_pago'] = newValue!;
                              });
                            },
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    // Text('Estado pedido:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                    // DropdownButton<String>(
                    //   value: pedidoData['estado_pedido'],
                    //   items: <String>['Enviado', 'Entregado', 'Anulado']
                    //       .map<DropdownMenuItem<String>>((String value) {
                    //     return DropdownMenuItem<String>(
                    //       value: value,
                    //       child: Text(value),
                    //     );
                    //   }).toList(),
                    //   onChanged: (newValue) {
                    //     setState(() {
                    //       pedidoData['estado_pedido'] = newValue!;
                    //     });
                    //   },
                    // )
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2, // Flex 1 para el primer botón
                      child: TextButton(
                        onPressed: () {
                          if (pedidoData['estado_pago'] == 'Pagado') {
                            // Si el estado de pago es "Pagado", mostrar un mensaje
                            mostrarFlushbarFalse(context, 'No es posible anular un pedido que ha sido pagado');
                          } else {
                            anularPedido(pedidoData);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 238, 124, 124),
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        child: const Text('Anular'),
                      ),
                    ),
                    SizedBox(width: 10), // Espacio entre los botones
                    Expanded(
                      flex: 2, // Flex 2 para el segundo botón
                      child: TextButton(
                        onPressed: () async {
                          entregarPedido(pedidoData);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromRGBO(235, 192, 83, 0.965),
                          primary: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0),
                          ),
                        ),
                        child: const Text('Entregar'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> entregarPedido(Map<String, dynamic> pedidoData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
        print('Token no dosponible, vuelve a iniciar sesión');
        return;
      }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: const Text('¿El pedido ha sido entregado?',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold))),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(238, 221, 178, 0.965),
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    pedidoData['estado_pedido'] = 'Entregado';
                    final response = await http.put(
                      Uri.parse(
                          'https://proyectolaparisina.onrender.com/api/pedidos-empleado/${pedidoData['_id']}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'token': token!,
                      },
                      body: json.encode(pedidoData),
                    );

                    if (response.statusCode == 200) {
                      fetchDomiciliario(userEmail);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DomiciliosScreen(),
                        ),
                      );
                      mostrarFlushbarTrue(
                          context, 'El pedido ha sido entregado exitosamente');
                    } else {
                      // Manejar errores de actualización
                      mostrarFlushbarFalse(
                          context, 'Error al actualizar el pedido');
                      throw Exception('Error al actualizar el pedido');
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(235, 192, 83, 0.965),
                    primary: Colors.black, // Color del texto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: const Text('Si'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> anularPedido(Map<String, dynamic> pedidoData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    if (token == null) {
        print('Token no dosponible, vuelve a iniciar sesión');
        return;
      }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: const Text('¿El pedido ha sido anulado?',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold))),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(238, 221, 178, 0.965),
                    primary: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    pedidoData['estado_pedido'] = 'Anulado';
                    final response = await http.put(
                      Uri.parse(
                          'https://proyectolaparisina.onrender.com/api/pedidos-empleado/${pedidoData['_id']}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'token': token!,
                      },
                      body: json.encode(pedidoData),
                    );

                    if (response.statusCode == 200) {
                      fetchDomiciliario(userEmail);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DomiciliosScreen(),
                        ),
                      );
                      mostrarFlushbarTrue(
                          context, 'El pedido ha sido anulado exitosamente');
                    } else {
                      // Manejar errores de actualización
                      mostrarFlushbarFalse(
                          context, 'Error al actualizar el pedido');
                      throw Exception('Error al actualizar el pedido');
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 246, 86, 75),
                    primary: Colors.white, // Color del texto
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  child: const Text('Si'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Función para obtener el correo electrónico del usuario
  Future<void> obtenerCorreoDomiciliario() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('user_email');

    if (userEmail != null) {
      // Llama a fetchDomiciliario con el correo electrónico obtenido
      fetchDomiciliario(userEmail);
    } else {
      print('Error in getLoggedInUserEmail: User email not available');
    }
  }

  Future<void> fetchDomiciliario(String? correo) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');

      if (token == null) {
        print('Error in fetchDomiciliario: Token not available');
        return;
      }

      final response = await http.get(
        Uri.parse('https://proyectolaparisina.onrender.com/api/empleado/$correo'),
        headers: {'token': token},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        // Actualiza la lista de usuarios con la información obtenida.
        setState(() {
          pedidosDomiciliario = responseData;
        });
      } else {
        print('Error en la respuesta: ${response.statusCode}');
        print('Cuerpo de la respuesta: ${response.body}');
        mostrarFlushbarFalse(context, 'Error al cargar la lista de pedidos');
        throw Exception('Error al cargar la lista de pedidos');
      }
    } catch (error) {
      print('Error al obtener los pedidos: $error');
      // Puedes manejar el error aquí según tus necesidades.
    }
  }

  // Función para mostrar el toast
  void mostarToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 10,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

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
      duration: Duration(seconds: 5),
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
          color: Colors
              .white, // Puedes cambiar el color de fondo según tus preferencias
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                const Text(
                  'Domicilios pendientes',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (pedidosDomiciliario.isNotEmpty) // Agrega esta condición
                  Expanded(
                    child: ListView.builder(
                      itemCount: pedidosDomiciliario.length,
                      itemBuilder: (context, index) {
                        final pedido = pedidosDomiciliario[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color.fromRGBO(232, 195, 114, 0.965),
                                  width: 2.0),
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Text(
                                    //   'Cliente: ',
                                    //   style:
                                    //       TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    // ),
                                    Flexible(
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(251, 249, 243,
                                                0.965), // Color de fondo del contenedor
                                            border: Border.all(
                                              color: Color.fromRGBO(
                                                  232, 195, 114, 0.965),
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              pedido['tipo_cliente'] ==
                                                      'Persona jurídica'
                                                  ? '${pedido['nombre_juridico']}'
                                                  : '${pedido['nombre_contacto']}',
                                              softWrap: true,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),
                                Row(
                                  children: [
                                    Text(
                                      'Municipio: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['ciudad_cliente']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Barrio: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['barrio_cliente']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Dirección: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['direccion_entrega']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Fecha de entrega: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['fecha_entrega_pedido'].substring(0, 10)}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Total pedido: ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['precio_total_venta']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child:
                                          Container(), // Este contenedor ocupa el espacio disponible al principio
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetallePedidoScreen(
                                                    pedido: pedido),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Color.fromRGBO(
                                            249, 233, 192, 0.965),
                                        onPrimary: Colors
                                            .black, // Cambia el color a tu preferencia
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              14.0), // Cambia el valor del borderRadius
                                        ),
                                      ),
                                      child: const Text(
                                        'Detalles',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        editarPedido(pedido);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: Color.fromRGBO(
                                            249, 233, 192, 0.965),
                                        onPrimary: Colors
                                            .black, // Cambia el color a tu preferencia
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              14.0), // Cambia el valor del borderRadius
                                        ),
                                      ),
                                      child: const Text(
                                        'Entregar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
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
                  const Text('No hay pedidos pendientes por entregar'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Llama a fetchProductions nuevamente al hacer clic en el botón flotante
          fetchDomiciliario(userEmail);
          // mostarToast('Domicilios pendientes actualizados');
          mostrarFlushbarTrue(context, 'Domicilios pendientes actualizados');
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

//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------
//---------------------------------------------------------------------------------------

  void _mostrarDialogoConfirmacion(
      BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text(
              '¿Estás seguro de que deseas marcar el pedido como entregado?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enviarPeticionAPI(user);
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarModal(BuildContext context, Map<String, dynamic> user) {
    final List<Widget> widgets = [];

    widgets.add(
      Text('Detalles del usuario: ${user['nombre_contacto']}'),
    );

    widgets.add(
      SizedBox(height: 16),
    );

    for (var entry in user.entries) {
      if (entry.key == '_id') {
        // Excluir el campo '_id'
        continue;
      }

      if (user['tipo_cliente'] == 'Persona natural') {
        if (entry.key == 'correo_domiciliario' ||
            entry.key == 'nombre_juridico' ||
            entry.key == 'nit_empresa_cliente' ||
            entry.key == 'aumento_empresa' ||
            entry.key == 'empleado_id' ||
            entry.key == '__V:0') {
          continue;
        }
      } else if (user['tipo_cliente'] == 'Persona jurídica') {
        if (entry.key == 'quien_recibe' ||
            entry.key == 'correo_domiciliario' ||
            entry.key == 'aumento_empresa' ||
            entry.key == 'empleado_id' ||
            entry.key == '__v:0') {
          continue;
        }
      }

      if (entry.key == 'detalle_pedido' && entry.value is List<dynamic>) {
        final List<dynamic> detalle = entry.value;
        widgets.add(SizedBox(height: 16));

        widgets.add(
          Table(
            defaultColumnWidth: FlexColumnWidth(),
            children: [
              TableRow(
                children: [
                  Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Cantidad',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              TableRow(
                children: [
                  Text('${detalle[0]['nombre_producto']}'),
                  Text('${detalle[0]['cantidad_producto']}'),
                  Text('${detalle[0]['precio_total_producto']}'),
                ],
              ),
            ],
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(color: Colors.black),
            ),
          ),
        );
      }
    }

    widgets.add(
      SizedBox(height: 16),
    );

    widgets.add(
      ElevatedButton(
        onPressed: () {
          print('Botón dentro del modal presionado');
          Navigator.pop(context);
        },
        child: Text('Cerrar'),
      ),
    );

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widgets,
            ),
          ),
        );
      },
      isScrollControlled: true,
    );
  }

  void _enviarPeticionAPI(Map<String, dynamic> pedido) async {
    try {
      pedido['estado_pedido'] = 'Entregado';
      final response = await http.put(
        Uri.parse(
            'https://proyectolaparisina.onrender.com/api/pedidos/${pedido['_id']}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(pedido),
      );

      if (response.statusCode == 200) {
        // Update the state inside the setState callback
        setState(() {
          fetchDomiciliario(userEmail);
        });

        print('Petición API exitosa');
        print(response.body);
      } else {
        print('Error en la petición API: ${response.statusCode}');
        print(response.body);
      }
    } catch (error) {
      print('Error en la petición API: $error');
    }
  }
}
