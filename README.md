# TaskFlow

Aplicacion Flutter para gestionar tareas usando Cubit como estrategia de gestion de estado. El proyecto corresponde al laboratorio colaborativo de gestion de estado en Flutter.

## Manejador de estado utilizado

Se utiliza `Cubit` mediante el paquete `flutter_bloc`. Cubit guarda el estado actual y emite un nuevo estado cada vez que una accion cambia la informacion. No trabaja con eventos separados como BLoC: cada metodo publico del Cubit representa una accion directa.

## Integrantes

El trabajo se dividio en responsabilidades:

- Personas 1 y 2: modelo, estado, Cubit y pruebas de agregar, alternar y eliminar.
- Personas 3 y 4: pantalla, formulario y conexion mediante `BlocProvider` y `BlocBuilder`.
- Personas 5 y 6: pendiente. Les corresponde agregar la fila completa, los controles de completar/eliminar y el tablero de contadores.

En esta version solo estan implementadas las responsabilidades de las personas 1 a 4.

## Funcionalidades

- Registrar una tarea con un titulo.
- Mostrar la lista de tareas.
- Ignorar titulos vacios o compuestos solo por espacios.

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
- `ListTile`: muestra el titulo de cada tarea.

Los controles para completar o eliminar, junto con el tablero de contadores, se reservan para las personas 5 y 6.

### `test/widget_test.dart`

Incluye tres pruebas:

1. Comprueba que el Cubit agrega, alterna y elimina una tarea.
2. Comprueba que las tareas vacias se ignoran.
3. Comprueba la pantalla: escribir y agregar una tarea a la lista.

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

## Requisitos del laboratorio cubiertos

- Proyecto Flutter funcional: si.
- Cubit como tecnologia asignada: si.
- Registrar y listar tareas: si.
- Completar, eliminar y tablero de contadores: pendiente para personas 5 y 6.
- Separacion entre estado y UI: si.
- Pruebas de la logica de personas 1 y 2 y de la pantalla de personas 3 y 4: si.
- README y explicacion del flujo: si.

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

## Mejoras posibles

Estas funciones no son necesarias para el laboratorio, pero serian utiles en una version posterior:

- Persistir tareas con SQLite, Hive o almacenamiento local.
- Agregar estados de carga y error si los datos vienen de una API.
- Permitir editar el titulo de una tarea.
- Separar la pantalla en widgets y agregar filtros por estado.
- Usar ids generados con `Uuid` si las tareas vienen de un servidor.
- Agregar accesibilidad, confirmacion antes de eliminar y fechas de entrega.
