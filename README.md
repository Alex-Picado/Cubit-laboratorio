# TaskFlow

Aplicacion Flutter para gestionar tareas usando Cubit como estrategia de gestion de estado. El proyecto corresponde al laboratorio colaborativo de gestion de estado en Flutter.

## Manejador de estado utilizado

Se utiliza `Cubit` mediante el paquete `flutter_bloc`. Cubit guarda el estado actual y emite un nuevo estado cada vez que una accion cambia la informacion. No trabaja con eventos separados como BLoC: cada metodo publico del Cubit representa una accion directa.

## Funcionalidades

- Registrar una tarea con un titulo.
- Mostrar la lista de tareas.
- Ignorar titulos vacios o compuestos solo por espacios.
- Completar una tarea o volver a marcarla como pendiente desde su casilla.
- Distinguir tareas completadas con el titulo tachado y el estado visible.
- Eliminar una tarea desde el boton de su fila.
- Mostrar el total de tareas, las completadas y las pendientes en un tablero que se actualiza automaticamente.

## Estructura del proyecto

```text
lib/
  main.dart
  body_app.dart
  models/
    task.dart
  state/
    task_cubit.dart
    task_state.dart
  widgets/
    task_tile.dart
    task_counters.dart
test/
  widget_test.dart
```

## Como funciona cada archivo

### `lib/main.dart`

- `main()`: inicia Flutter con `MyApp`.
- `MyApp`: crea el `BlocProvider` que construye un `TaskManagerCubit` y lo pone a disposicion de toda la aplicacion.
- `MaterialApp`: configura el titulo, el tema Material 3 y la pantalla `BodyApp`.

El `BlocProvider` esta dentro de `MyApp` para que tanto la ejecucion normal como las pruebas reciban el mismo Cubit.

### `lib/models/task.dart`

- `Task.id`: identificador entero de la tarea.
- `Task.title`: texto que ve el usuario.
- `Task.completed`: indica si la tarea esta completada.
- `Task.copyWith()`: crea una tarea nueva conservando los datos originales y reemplazando solo los valores indicados.

La clase es inmutable: sus propiedades son `final`. Esto ayuda a que cada cambio produzca una nueva version del estado en vez de modificar la anterior.

### `lib/state/task_state.dart`

- `TaskManagerState.tasks`: lista actual de objetos `Task`.
- `totalTasks`: cantidad total de tareas.
- `completedTasks`: cantidad de tareas cuyo valor `completed` es `true`.
- `pendingTasks`: total menos completadas.

Los contadores son getters calculados a partir de `tasks`, por lo que no se pueden desincronizar de la lista.

### `lib/state/task_cubit.dart`

`TaskManagerCubit` extiende `Cubit<TaskManagerState>` y comienza con una lista vacia.

- `addTask(String description)`: limpia espacios, ignora texto vacio, crea un `Task` con un id nuevo y emite una lista nueva con la tarea agregada.
- `toggleTask(int id)`: busca la tarea por id, invierte `completed` usando `copyWith` y emite el estado actualizado.
- `removeTask(int id)`: filtra la tarea indicada por id y emite la lista resultante.

En todos los metodos se conserva el estado anterior y se emite un objeto nuevo. Esa es la parte central del flujo reactivo de Cubit.

### `lib/body_app.dart`

- `_BodyAppState.taskController`: controla el texto escrito en el formulario.
- `addTask()`: envia el texto al Cubit y limpia el campo.
- `BlocBuilder<TaskManagerCubit, TaskManagerState>`: escucha emisiones del Cubit y reconstruye la parte visual que depende del estado.
- `TextField`: permite escribir una tarea y agregarla con el boton o con Enter.
- `TaskTile`: muestra cada tarea y conecta sus controles con `toggleTask(task.id)` y `removeTask(task.id)` del Cubit. Cada fila usa `ValueKey(task.id)` para conservar su identidad al eliminar otras tareas.
- `TaskCounters`: recibe el mismo estado que la lista y muestra sus contadores, incluso cuando no hay tareas.

### `lib/widgets/task_tile.dart`

Implementa la fila y los controles de cada tarea (parte de las personas 5 y 6).

- Recibe la tarea y las funciones `onToggle` y `onDelete` desde `BodyApp`.
- `Checkbox`: refleja `task.completed` y llama a `onToggle` al pulsarlo. Permite completar y volver a marcar como pendiente.
- `Text`: muestra el titulo tachado si esta completada y un subtitulo con `Completada` o `Pendiente`. Los titulos largos se distribuyen en varias lineas.
- `IconButton`: muestra el icono de eliminar y llama a `onDelete`. Incluye un tooltip con el titulo de la tarea; la casilla tambien tiene una etiqueta para lectores de pantalla.

Es un `StatelessWidget`: no guarda una copia local del estado. Las acciones identifican la tarea por su id, por lo que dos tareas con el mismo titulo se pueden gestionar de forma independiente.

### `lib/widgets/task_counters.dart`

Implementa el tablero de contadores (parte de las personas 5 y 6).

- `TaskCounters`: recibe un `TaskManagerState` y muestra `totalTasks`, `completedTasks` y `pendingTasks`.
- `_TaskCounter`: presenta cada cantidad en una tarjeta con icono y etiqueta.
- `Wrap`: distribuye las tarjetas en varias lineas cuando el ancho disponible es pequeno.

Los valores se leen de los getters del estado. No se incrementan ni decrementan manualmente en la interfaz: al agregar, completar, desmarcar o eliminar una tarea, `BlocBuilder` reconstruye el tablero con el estado actualizado. Una lista vacia muestra los tres contadores en cero.

### `test/widget_test.dart`

Incluye seis pruebas:

1. Comprueba que el Cubit agrega, alterna y elimina una tarea.
2. Comprueba que las tareas vacias se ignoran.
3. Comprueba el flujo completo en pantalla: agregar, completar, volver a marcar pendiente y eliminar, verificando la casilla, el tachado, el estado vacio y los contadores.
4. Comprueba que las tareas con el mismo titulo se gestionan independientemente, que eliminar pendientes o completadas ajusta los contadores y que se pueden agregar tareas despues de vaciar la lista.
5. Comprueba que los titulos vacios no cambian el tablero y que agregar con Enter sigue funcionando.
6. Comprueba una pantalla de 320 px de ancho con un titulo largo, incluyendo completar y eliminar sin errores de distribucion.

## Flujo de actualizacion del estado

```text
Usuario
  -> escribe una tarea y pulsa agregar
  -> BodyApp llama addTask del TaskManagerCubit
  -> el Cubit crea un TaskManagerState nuevo
  -> Cubit emite el nuevo estado
  -> BlocBuilder recibe el estado
  -> Flutter reconstruye la lista
```

Ejemplo al agregar una tarea:

1. El usuario escribe un titulo y pulsa el boton o Enter.
2. La pantalla llama `addTask(texto)`.
3. El Cubit valida el titulo y crea una tarea.
4. Se emite un nuevo `TaskManagerState`.
5. `BlocBuilder` reconstruye la lista.

Ejemplo al completar o eliminar una tarea:

1. El usuario pulsa la casilla o el boton de eliminar de una fila.
2. `TaskTile` ejecuta la funcion recibida desde `BodyApp`.
3. `BodyApp` llama a `toggleTask(id)` o `removeTask(id)` del Cubit.
4. El Cubit emite un nuevo estado con la lista actualizada.
5. `BlocBuilder` reconstruye las filas y el tablero; los getters calculan las nuevas cantidades.

## Comprobacion manual de la fila y el tablero

1. Abrir la aplicacion: debe mostrar el mensaje de lista vacia y los tres contadores en cero.
2. Agregar dos tareas: total 2, completadas 0, pendientes 2.
3. Completar una tarea: su casilla queda marcada, el titulo aparece tachado y los contadores muestran 2, 1 y 1.
4. Desmarcarla: el titulo vuelve a su formato normal y los contadores muestran 2, 0 y 2.
5. Completarla otra vez y eliminarla: queda una tarea pendiente y los contadores muestran 1, 0 y 1.
6. Eliminar la ultima tarea: reaparece el mensaje de lista vacia y todos los contadores vuelven a cero.

## Donde se almacena el estado

El estado vive en memoria dentro de la instancia de `TaskManagerCubit` creada por `BlocProvider`. Al cerrar la aplicacion las tareas se pierden. Esta version no usa base de datos, archivos ni almacenamiento local.

## Ventajas encontradas

- Separa la logica de negocio de la interfaz.
- Los cambios de estado son explicitos y faciles de rastrear.
- Facilita las pruebas unitarias sin levantar toda la interfaz.
- Evita modificar directamente la lista que ya fue emitida.
- Es mas sencillo que BLoC porque no requiere definir eventos separados.

## Desventajas encontradas

- Hay que definir clases de estado y metodos de actualizacion.
- El estado solo dura mientras vive el Cubit si no se agrega persistencia.
- En aplicaciones grandes puede haber muchos metodos en un mismo Cubit si no se separan las responsabilidades.
- Una pantalla muy grande podria necesitar varios widgets mas pequenos para evitar reconstrucciones innecesarias.

## Escalabilidad

Para una aplicacion pequena o mediana, Cubit es una opcion clara y practica. Para una aplicacion grande tambien puede utilizarse, organizando varios Cubits por dominio, agregando repositorios, persistencia y estados de carga o error. Si se necesita modelar muchos eventos complejos y sus transiciones, BLoC podria ser mas adecuado.

## Ejecutar el proyecto

```bash
flutter pub get
flutter run
```

## Ejecutar las pruebas

```bash
flutter analyze
flutter test
```

## Documentacion consultada

- [flutter_bloc: BlocProvider, BlocBuilder y context.read](https://pub.dev/packages/flutter_bloc): conexion de las acciones y reconstruccion de la interfaz desde el estado del Cubit.
- [Flutter: ListTile](https://api.flutter.dev/flutter/material/ListTile-class.html): estructura de la fila con titulo, subtitulo y controles.
- [Flutter: Checkbox](https://api.flutter.dev/flutter/material/Checkbox-class.html): valor de la casilla y callback `onChanged`.
- [Flutter: IconButton](https://api.flutter.dev/flutter/material/IconButton-class.html): boton de eliminar y accion `onPressed`.
- [Flutter: Wrap](https://api.flutter.dev/flutter/widgets/Wrap-class.html): distribucion del tablero cuando falta espacio horizontal.

