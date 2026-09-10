import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cubit_lab_desarrollo4/main.dart';
import 'package:cubit_lab_desarrollo4/state/task_cubit.dart';
import 'package:cubit_lab_desarrollo4/widgets/task_tile.dart';

void expectCounters({
  required int total,
  required int completed,
  required int pending,
}) {
  expect(find.text('Total: $total'), findsOneWidget);
  expect(find.text('Completadas: $completed'), findsOneWidget);
  expect(find.text('Pendientes: $pending'), findsOneWidget);
}

Future<void> addTask(WidgetTester tester, String title) async {
  await tester.enterText(find.byType(TextField), title);
  await tester.tap(find.byTooltip('Agregar tarea'));
  await tester.pumpAndSettle();
}

Finder taskControl(Finder task, Type controlType) {
  return find.descendant(of: task, matching: find.byType(controlType));
}

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
    expectCounters(total: 0, completed: 0, pending: 0);

    await addTask(tester, 'Preparar exposicion');

    expect(find.text('Preparar exposicion'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
    expectCounters(total: 1, completed: 0, pending: 1);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Completada'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Preparar exposicion')).style?.decoration,
      TextDecoration.lineThrough,
    );
    expectCounters(total: 1, completed: 1, pending: 0);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(find.text('Pendiente'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Preparar exposicion')).style?.decoration,
      TextDecoration.none,
    );
    expectCounters(total: 1, completed: 0, pending: 1);

    await tester.tap(find.byTooltip('Eliminar tarea: Preparar exposicion'));
    await tester.pumpAndSettle();

    expect(find.text('Preparar exposicion'), findsNothing);
    expect(find.text('No hay tareas registradas'), findsOneWidget);
    expectCounters(total: 0, completed: 0, pending: 0);
  });

  testWidgets('los controles distinguen tareas con el mismo titulo', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await addTask(tester, 'Estudiar');
    await addTask(tester, 'Estudiar');
    await addTask(tester, 'Entregar laboratorio');
    expectCounters(total: 3, completed: 0, pending: 3);

    final rows = find.byType(TaskTile);
    await tester.tap(taskControl(rows.at(1), Checkbox));
    await tester.pumpAndSettle();

    expect(
      tester.widget<Checkbox>(taskControl(rows.at(0), Checkbox)).value,
      isFalse,
    );
    expect(
      tester.widget<Checkbox>(taskControl(rows.at(1), Checkbox)).value,
      isTrue,
    );
    expectCounters(total: 3, completed: 1, pending: 2);

    await tester.tap(taskControl(rows.at(0), IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Estudiar'), findsOneWidget);
    expect(
      tester.widget<Checkbox>(taskControl(rows.at(0), Checkbox)).value,
      isTrue,
    );
    expectCounters(total: 2, completed: 1, pending: 1);

    await tester.tap(taskControl(rows.at(0), IconButton));
    await tester.pumpAndSettle();

    expect(find.text('Estudiar'), findsNothing);
    expect(find.text('Entregar laboratorio'), findsOneWidget);
    expectCounters(total: 1, completed: 0, pending: 1);

    await tester.tap(find.byTooltip('Eliminar tarea: Entregar laboratorio'));
    await tester.pumpAndSettle();
    expectCounters(total: 0, completed: 0, pending: 0);

    await addTask(tester, 'Nueva tarea despues de eliminar');
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expectCounters(total: 1, completed: 0, pending: 1);
  });

  testWidgets(
    'los contadores ignoran titulos vacios y agregar con Enter funciona',
    (tester) async {
      await tester.pumpWidget(const MyApp());
      await addTask(tester, '   ');

      expect(find.byType(TaskTile), findsNothing);
      expectCounters(total: 0, completed: 0, pending: 0);

      await tester.enterText(find.byType(TextField), '  Revisar README  ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(find.text('Revisar README'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      expectCounters(total: 1, completed: 0, pending: 1);
    },
  );

  testWidgets('la fila y los contadores caben en una pantalla estrecha', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    const title =
        'Preparar la presentacion del laboratorio de gestion de '
        'estado usando Cubit y revisar todos los ejemplos con el grupo';
    await addTask(tester, title);
    expect(tester.takeException(), isNull);
    expect(find.text(title), findsOneWidget);
    expectCounters(total: 1, completed: 0, pending: 1);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expectCounters(total: 1, completed: 1, pending: 0);

    await tester.tap(find.byTooltip('Eliminar tarea: $title'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('No hay tareas registradas'), findsOneWidget);
    expectCounters(total: 0, completed: 0, pending: 0);
  });
}
