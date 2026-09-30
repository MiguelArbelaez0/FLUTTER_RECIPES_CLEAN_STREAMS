# Flutter Recipes Clean Streams

Aplicación Flutter para descubrimiento, búsqueda y consulta de recetas, desarrollada con Clean Architecture, BLoC, Streams, Dio y GetIt, utilizando TheMealDB como fuente de datos.

## Funcionalidades

- Home de descubrimiento con scroll vertical, categorías horizontales y secciones de recetas en carruseles.
- Carga de varias recetas aleatorias al iniciar, con límite de solicitudes y eliminación de duplicados.
- Búsqueda de recetas con debounce basado en Streams.
- Categorías obtenidas en tiempo de ejecución desde TheMealDB y búsqueda de recetas por categoría.
- Tarjetas con imágenes, nombre, categoría y área/cocina cuando está disponible.
- Detalle de receta con imagen, ingredientes, cantidades e instrucciones en pasos legibles.
- Estados de carga, error y búsqueda sin resultados.
- Diseño responsive para móvil, tablet y escritorio.

El botón de favorito es únicamente visual y local a la tarjeta o al detalle: no hay persistencia ni una función de favoritos guardados.

## Tecnologías

- Flutter y Dart
- Clean Architecture
- BLoC y Streams (`stream_transform`)
- Dio
- GetIt
- Equatable
- TheMealDB API

El paquete declara Dart `>=3.13.4 <4.0.0`; se ha trabajado con Flutter 3.47.5 y Dart 3.13.4.

## API

La aplicación utiliza TheMealDB como su única fuente de recetas. El cliente apunta al endpoint público de desarrollo `https://www.themealdb.com/api/json/v1/1`; no requiere una clave privada ni un archivo `.env`.

| Función | Endpoint | Uso |
|---|---|---|
| Buscar recetas | `GET /search.php?s={query}` | Busca platos por nombre. |
| Receta aleatoria | `GET /random.php` | Devuelve una receta aleatoria por llamada. Se hacen solicitudes acotadas para formar la colección inicial. |
| Detalle de receta | `GET /lookup.php?i={id}` | Obtiene la receta completa, ingredientes, cantidades e instrucciones a partir de su ID. |
| Categorías | `GET /categories.php` | Obtiene categorías y sus imágenes para la navegación horizontal. |
| Recetas por categoría | `GET /filter.php?c={category}` | Devuelve recetas asociadas a una categoría. |

Las fotografías de recetas y categorías también se cargan desde las URLs entregadas por TheMealDB.

## Arquitectura

```text
UI
 ↓
BLoC
 ↓
UseCase
 ↓
Contrato RecipeRepository
 ↓
RecipeRepositoryImpl
 ↓
RemoteDataSource
 ↓
Dio (ApiClient)
 ↓
TheMealDB
```

- **Presentation:** las páginas y widgets envían eventos al BLoC y representan su estado. No acceden a Dio ni al repositorio.
- **BLoC:** coordina carga, búsqueda, categorías, detalle y reintentos. El debounce de búsqueda usa una transformación de Streams con `stream_transform`.
- **Domain:** contiene entidades, contratos del repositorio y casos de uso independientes de Flutter, Dio y los modelos JSON.
- **Data:** los datasources solicitan y parsean respuestas; los modelos se convierten en entidades, y el repositorio traduce errores de red a fallos de la aplicación.
- **Injection:** GetIt configura Dio, datasources, repositorio, casos de uso y BLoC.

La colección aleatoria intenta reunir seis recetas distintas. Las solicitudes se lanzan en lotes de hasta tres, con un máximo de nueve llamadas; los fallos parciales no descartan las recetas que sí llegaron.

## Estructura del proyecto

El repositorio contiene el paquete Flutter dentro de `flutter_recipes_clean_streams/`:

```text
flutter_recipes_clean_streams/
├── lib/
│   ├── core/
│   │   ├── error/
│   │   │   ├── exceptions/
│   │   │   └── failures/
│   │   ├── network/api_client.dart
│   │   ├── theme/app_theme.dart
│   │   └── utils/normalized_text.dart
│   ├── features/recipes/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── injection/injection_container.dart
│   └── main.dart
├── test/
└── pubspec.yaml
```

## Instalación y ejecución

Desde la raíz del repositorio:

```bash
cd flutter_recipes_clean_streams
flutter pub get
flutter run -d chrome
```

Para ejecutar las comprobaciones:

```bash
flutter analyze
flutter test
```

Las pruebas usan dobles locales y un adaptador HTTP de prueba; no dependen de una conexión a Internet.
