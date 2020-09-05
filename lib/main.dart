import 'package:bandnames/src/services/socket_service.dart';
import 'package:flutter/material.dart';
 
import 'package:provider/provider.dart';

// Pages
import 'package:bandnames/src/pages/status.dart';
import 'package:bandnames/src/pages/home.dart';

void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService())
      ],
      child: MaterialApp(
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(),
          'status': (_) => StatusPage(),
        }
      ),
    );
  }
}