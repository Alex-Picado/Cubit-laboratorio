// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cubit_lab_desarrollo4/main.dart';
import 'package:cubit_lab_desarrollo4/state/task_cubit.dart';

void main() {
  test('el Cubit agrega, alterna y elimina tareas', () async {
    final cubit = TaskManagerCubit();

    cubit.addTask('  Estudiar Cubit  ');
    expect(cubit.state.tasks.single.title, 'Estudiar Cubit');
    expect(cubit.state.tasks.single.completed, isFalse);

    final taskId = cubit.state.tasks.single.id;
    cubit.toggleTask(taskId);
    expect(cubit.state.completedTasks, 1);
    expect(cubit.state.pendingTasks, 0);

    cubit.removeTask(taskId);
    expect(cubit.state.tasks, isEmpty);

    await cubit.close();
  });

  test('el Cubit ignora tareas vacias', () async {
    final cubit = TaskManagerCubit();

    cubit.addTask('   ');

    expect(cubit.state.tasks, isEmpty);
    await cubit.close();
  });

  testWidgets('la pantalla permite gestionar una tarea', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('No hay tareas registradas'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Preparar exposicion');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('Preparar exposicion'), findsOneWidget);
  });
}
