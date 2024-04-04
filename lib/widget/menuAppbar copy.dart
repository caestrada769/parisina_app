import 'package:ParisinaApp/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';

import '../presentation/screens/auth-service.dart';

class AppbarMenu extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const AppbarMenu({super.key, required this.title});

  @override
  State<AppbarMenu> createState() => _AppbarMenuState();

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}

class _AppbarMenuState extends State<AppbarMenu> {
  AuthService _authService = AuthService();
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold,)),
      backgroundColor:Color.fromARGB(246, 224, 200, 148),
      automaticallyImplyLeading: false,
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
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
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _authService.logout();
                        Navigator.push(context, MaterialPageRoute(builder:(context)=> LoginScreen())); 
                      },
                      style: TextButton.styleFrom(
                      backgroundColor: Color.fromRGBO(235, 192, 83, 0.965),
                      primary: Colors.black, // Color del texto
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      ),
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.logout),
        )
      ],
    );
  }
} 