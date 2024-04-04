import 'dart:convert';
import 'package:ParisinaApp/presentation/screens/domicilios.dart';
import 'package:ParisinaApp/presentation/screens/produccion.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:http/http.dart' as http;
import 'package:ParisinaApp/presentation/screens/auth-service.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isVisible = true;

  void apiLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      mostrarFlushbarFalse(context, "Por favor, llene todos los campos");
      return;
    }

    // Dentro de tu función apiLogin después de obtener la respuesta
    try {
      final response = await _authService.login(email, password);
      print('API Response: $response');

      if (response is Map<String, dynamic>) {
        final message = response['msg'] as String? ?? 'Bienvenido';
        final user = response['usuario'] as Map<String, dynamic>? ?? {};

        // Verifica si la respuesta contiene un token y un usuario
        if (response.containsKey('token') && user != null) {
          final rolId = user['rol_usuario'] as String? ?? 'ValorPredeterminado';
          final String correoEmpleado = user['correo_electronico'];

          Map<String, dynamic> datosEmpleado =
              await obtenerDatosEmpleadoPorCorreo(correoEmpleado);

          final areaEmpleado = datosEmpleado['area_empleado'];
          final areaEmpleadoProduccion =
              datosEmpleado['area_empleado_produccion'];
          final nombreEmpleado = datosEmpleado['nombre_empleado'];

          print(
              'AREA EMPLEADO..........: $areaEmpleado \nAREA PRODUCCION EMPLEADO: $areaEmpleadoProduccion');

          mostrarFlushbarTrue(context, 'Bienvenido $nombreEmpleado');

          // Ajusta el ID del rol según tu lógica
          Future.delayed(const Duration(milliseconds: 500), () {
            // Verifica el area del empleado y redirige a la pantalla correspondiente
            if (areaEmpleado == 'Producción' &&
                areaEmpleadoProduccion != null) {
              // Redirige a la pantalla de producción
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProduccionScreen(
                    areaProduccion: areaEmpleadoProduccion,
                  ),
                ),
              );
            } else if (areaEmpleado == 'Domiciliario') {
              // Redirige a la pantalla de domiciliario
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const DomiciliosScreen(),
                ),
              );
            }
          });
        } else {
          print('La respuesta no contiene un token o el usuario es nulo.');
        }
      } else {
        final errorMessage = response['msg']; // Capturar el mensaje de error
        print('Error durante el inicio de sesión: $errorMessage');
        // final snackBar = SnackBar(
        //   content: Text('Error en la respuesta de la API'),
        //   backgroundColor: Colors.red,
        // );

        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (error) {
      String errorMessage = 'Error en el inicio de sesión';
      if (error.toString().contains('Usuario/Contraseña incorrectos.')) {
        errorMessage = 'Usuario/Contraseña incorrectos.';
      } else if (error.toString().contains('El usuario está inactivo.')) {
        errorMessage = 'El usuario está inactivo.';
      } else if (error.toString().contains('Hable con el admin   ')) {
        errorMessage = 'Hable con el administrador.';
      }
      // Manejar el error
      print('Error during login: $error');
      mostrarFlushbarFalse(context, errorMessage);
    }
  }

  Future<Map<String, dynamic>> obtenerDatosEmpleadoPorCorreo(
      String correo) async {
    final apiUrl = 'https://api-parisina-2tpy.onrender.com/api';

    final response =
        await http.get(Uri.parse('$apiUrl/consultar-empleado/$correo'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener datos del empleado');
    }
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
    EdgeInsets padding = MediaQuery.of(context).viewInsets;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true, // Añade esta línea
        child: Padding(
          padding: EdgeInsets.only(
            bottom: padding.bottom > 0 ? padding.bottom + 20.0 : 1.0,
            top: padding.bottom > 0 ? 20.0 : 70.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 38),
                child: Column(
                  children: [
                    Container(
                      width: 200, // Ancho deseado
                      height: 200, // Alto deseado
                      child: Image.asset(
                        'assets/img/icon.png',
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(238, 221, 178, 0.965),
                            width: 2.0,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color:
                              Colors.black, // Cambia este color al que desees
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextField(
                      controller: passwordController,
                      obscureText: _isVisible,
                      decoration: InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _isVisible = !_isVisible;
                            });
                          },
                          icon: _isVisible
                              ? const Icon(Icons.visibility)
                              : const Icon(Icons.visibility_off),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color.fromRGBO(238, 221, 178, 0.965),
                            width: 2.0,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color:
                              Colors.black, // Cambia este color al que desees
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              ElevatedButton(
                onPressed: () {
                  apiLogin();
                },
                child: const Text(
                  "Iniciar Sesión",
                  style: TextStyle(color: Colors.white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromRGBO(235, 192, 83, 0.965),
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
