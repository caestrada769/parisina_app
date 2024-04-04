import 'dart:convert';
import 'package:ParisinaApp/presentation/screens/domicilios.dart';
import 'package:ParisinaApp/widget/menuAppbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetallePedidoScreen extends StatefulWidget {
  final Map<String, dynamic> pedido;
  const DetallePedidoScreen({required this.pedido, Key? key}) : super(key: key);

  @override
  State<DetallePedidoScreen> createState() => DetallePedidoScreenState(pedido: pedido);
}

class DetallePedidoScreenState extends State<DetallePedidoScreen> {
  final Map<String, dynamic> pedido;
  bool mostrarDetalles = false;

  DetallePedidoScreenState({required this.pedido});
  List<dynamic> productions = [];
  String editedEstado = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarMenu(showBackButton: true),
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
                  'Detalle pedido',
                  style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold
                  ),
                ),
                if (pedido.isNotEmpty) // Agrega esta condición
                  Expanded(
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (context, index) {
                        final x = pedido;
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
                                    Flexible(
                                      child: Center(
                                        child: Container(
                                          padding: EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(251, 249, 243, 0.965),  // Color de fondo del contenedor
                                            border: Border.all(
                                              color: Color.fromRGBO(232, 195, 114, 0.965),
                                              width: 1.0,
                                            ),
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              pedido['tipo_cliente'] == 'Persona jurídica'
                                                  ? '${pedido['nombre_juridico']}'
                                                  : '${pedido['nombre_contacto']}',
                                              softWrap: true,
                                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const Text(
                                      'Dirección: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['direccion_entrega']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Cliente: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['nombre_contacto']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Documento: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['documento_cliente']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Teléfono: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['telefono_cliente']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Quien recibe: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['quien_recibe']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Ciudad: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['ciudad_cliente']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Barrio: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['barrio_cliente']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Fecha del pedido: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['fecha_pedido_tomado']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Fecha de entrega: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['fecha_entrega_pedido']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Método de pago: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['metodo_pago']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Estado del pago: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['estado_pago']}', // Texto a mostrar
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Nit empresa: ',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Visibility(
                                      visible: pedido['tipo_cliente'] == 'Persona jurídica',
                                      child: Text(
                                        '${pedido['nit_empresa_cliente']}', // Texto a mostrar
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Aumento empresa: ',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Visibility(
                                      visible: pedido['tipo_cliente'] == 'Persona jurídica',
                                      child: Text(
                                        '${pedido['aumento_empresa']}', // Texto a mostrar
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Valor Domicilio: ',
                                      style:
                                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${pedido['valor_domicilio']}', // Texto a mostrar
                                    ),
                                  ],
                                ),

                                TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Color.fromRGBO(244, 239, 223, 0.965),
                                          title: const Text('Productos',
                                          textAlign: TextAlign.center,),
                                          content: SizedBox(
                                            width: double.maxFinite,
                                            child: ListView.builder(
                                              itemCount: pedido['detalle_pedido'].length,
                                              itemBuilder: (context, index) {
                                                final detalle = pedido['detalle_pedido'][index];
                                                return Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(12.0),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      border: Border.all(
                                                        color: Color.fromRGBO(232, 195, 114, 0.965),
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Producto: ',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '${detalle['nombre_producto']}',
                                                                softWrap: true, // Permite dividir el texto en varias líneas
                                                                maxLines: 2, // Número máximo de líneas antes de truncar el texto
                                                                overflow: TextOverflow.ellipsis, // Muestra puntos suspensivos (...) al final del texto truncado
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Cantidad: ',
                                                              style:
                                                                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                            ),
                                                            Text(
                                                              '${detalle['cantidad_producto']}', // Texto a mostrar
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Precio unitario: ',
                                                              style:
                                                                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                            ),
                                                            Text(
                                                              pedido['tipo_cliente'] == 'Persona jurídica'
                                                              ? '${detalle['precio_por_mayor_ico']}'
                                                              : '${detalle['precio_ico']}', // Texto a mostrar
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Text(
                                                              'Precio Total: ',
                                                              style:
                                                                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                            ),
                                                            Text(
                                                              '${detalle['precio_total_producto']}', // Texto a mostrar
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Color.fromRGBO(238, 221, 178, 0.965),
                                                onPrimary: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(14.0),
                                                  side: BorderSide(color: Color.fromRGBO(243, 185, 38, 0.965),),
                                                ),
                                              ),
                                              child: const Text('Cerrar'),
                                            ),
                                          ],
                                        );

                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                      primary: Color.fromRGBO(243, 219, 158, 0.965),
                                      onPrimary: Colors.black, // Cambia el color a tu preferencia
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20.0), // Cambia el valor del borderRadius
                                        side: BorderSide(color: Color.fromRGBO(243, 185, 38, 0.965),),
                                      ),
                                    ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: const [
                                      Text('Ver Productos'),
                                    ],
                                  ),
                                ),



                                const SizedBox(height: 10,),
                                Container(
                                padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(251, 249, 243, 0.965),  // Color de fondo del contenedor
                                    border: Border.all(
                                      color: Color.fromRGBO(232, 195, 114, 0.965),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Total: ',
                                        style:
                                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        ' ${pedido['precio_total_venta']}',
                                        style:
                                            TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Texto a mostrar
                                      ),
                                    ],
                                  ),
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
    );
  }
}
