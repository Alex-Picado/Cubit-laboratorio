import 'package:cubit_lab_desarrollo4/body_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'state/task_cubit.dart';
import 'state/task_state.dart';

void main() {
  runApp(BlocProvider(create: (_) => TaskManagerCubit(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Flow - Cubit Edition',
      home: const Scaffold(body: BodyApp()),
    );
  }
}
