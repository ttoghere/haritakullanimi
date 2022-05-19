// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:haritakullanimi/providers/app_bloc.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: AppBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Material App',
        home: HomePage(),
      ),
    );
  }
}
