# Flutter Recipes Clean Streams · Sazón

Aplicación Flutter para descubrir recetas de TheMealDB, buscar por nombre y consultar ingredientes e instrucciones. Organizada por funcionalidades con Clean Architecture, BLoC y búsqueda reactiva cancelable.

## Funcionalidades

- Inicio con recetas aleatorias, sin duplicados y con tolerancia a fallos parciales.
- Búsqueda por nombre desde dos caracteres, con debounce de 350 ms, cancelación HTTP e invalidación inmediata de respuestas anteriores.
- Categorías, listas por categoría y caché durante la vida de la pantalla.
- Detalle con ingredientes, medidas y pasos de preparación.
- Estados de carga, resultados vacíos, imágenes alternativas y reintentos de errores.
- Diseño adaptable; navegación y contenido probados con widgets a 320, 800 y 1280 px.

## Tecnologías y arquitectura

Flutter, Dart, flutter_bloc, Dio, GetIt y Equatable. El dominio no depende de Dio ni de widgets. Los modelos interpretan TheMealDB; los repositorios convierten excepciones en fallos de aplicación. GetIt crea un BLoC por pantalla y comparte el cliente HTTP.

```text
flutter_recipes_clean_streams/
├── lib/
│   ├── core/                  # Errores, HTTP, tema y utilidades
│   ├── injection/             # Registro y liberación de dependencias
│   ├── features/recipes/
│   │   ├── data/              # Fuentes remotas, modelos y repositorio
│   │   ├── domain/            # Entidades, contratos y casos de uso
│   │   └── presentation/      # BLoC, eventos, estados, páginas y widgets
│   └── main.dart
├── test/                      # Pruebas unitarias y de widgets sin API externa
└── integration_test/          # Recorrido de aplicación con repositorio simulado
```

Cada entrada de búsqueda invalida la operación anterior. Un temporizador espera 350 ms antes de consultar el caso de uso; la señal de cancelación se traduce a un `CancelToken` de Dio en datos. Una respuesta obsoleta no puede publicar resultados ni errores. La carga del inicio y la búsqueda mantienen estados independientes.

El cliente usa HTTPS y timeouts de conexión/envío de 15 s y recepción de 20 s. Las solicitudes no registran datos sensibles y los errores de transporte no exponen mensajes internos al usuario.

## Instalación y ejecución

Requiere Flutter con Dart 3.13.4 o compatible con el rango de `pubspec.yaml`. Entorno de validación: Flutter 3.47.5 y Dart 3.13.4. Conserva `pubspec.lock` para reproducir dependencias.

```bash
git clone https://github.com/MiguelArbelaez0/FLUTTER_RECIPES_CLEAN_STREAMS.git
cd FLUTTER_RECIPES_CLEAN_STREAMS/flutter_recipes_clean_streams
flutter pub get
flutter run -d chrome
# O selecciona un dispositivo Android con flutter devices:
flutter run -d <device-id>
```

No requiere credenciales privadas: la ruta del cliente usa el acceso público de ejemplo de TheMealDB. Las imágenes y recetas requieren conexión. No hay assets de recetas locales.

## Pruebas y compilaciones

Ejecuta siempre desde `flutter_recipes_clean_streams/`:

```bash
dart format lib test integration_test
flutter analyze
flutter test
flutter test --coverage
flutter test integration_test/app_test.dart -d <device-id>
flutter build web
flutter build apk --debug
```

Las pruebas cubren JSON y datos inválidos, casos de uso, repositorios con adaptadores HTTP simulados, timeouts, debounce con reloj de pruebas, cancelación real del transporte, búsquedas consecutivas, respuestas obsoletas, reintentos de categorías, descubrimiento, marcas temporales de recetas y navegación al detalle. No requieren una API externa activa. La prueba de integración también utiliza datos simulados y no certifica la disponibilidad del servicio.

Para Android se necesita un SDK con las licencias correspondientes y un JDK compatible con Gradle 8.14/AGP 8.11.1. La selección de Java puede aislarse por proceso con `scripts/flutter-local.ps1` desde la raíz del repositorio:
```powershell
./scripts/flutter-local.ps1 -JdkPath 'C:/ruta/al/jdk-17' -FlutterArguments @('build', 'apk', '--debug')
```

El script guarda ajustes ignorados por Git en `.tooling/`, ejecuta Flutter desde la raíz correcta y restaura las variables del proceso. Flutter puede priorizar el JDK de Android Studio sobre `JAVA_HOME`; este script selecciona el JDK indicado sin cambiar la configuración global.

## Plataformas

- Web: compilación release e inicio con `flutter run -d chrome` verificados. La interacción visual en Chrome sigue pendiente.
- Android: compilación APK debug verificada con JDK 17. En emulador Android 16/API 36 una comprobación automatizada con el repositorio real verificó descubrimiento, categorías, búsqueda, resultados vacíos, detalle con ingredientes e instrucciones y retorno a inicio. Las pruebas deterministas de integración cubren navegación y recuperación de errores con datos simulados.
- Widgets: inicio, búsqueda, detalle y retorno probados en tres tamaños de pantalla.
- iOS, macOS, Linux y Windows: existen carpetas de plataforma; compilación y ejecución no verificadas.

La compilación por sí sola no verifica interacción ni conectividad en un dispositivo. La validación de interacción en Chrome continúa pendiente. La disponibilidad del servicio externo debe comprobarse al ejecutar la aplicación.

## Limitaciones

- TheMealDB puede devolver información incompleta o en inglés. No se traducen recetas.
- El servicio externo puede responder con HTTP 522, timeouts o transferencias incompletas. La aplicación muestra errores y permite reintentar; una ejecución satisfactoria no garantiza disponibilidad continua.
- No hay almacenamiento offline, autenticación, paginación ni biblioteca de favoritos persistente. Los corazones son marcas locales de cada widget y se reinician al recrearlo.
- El descubrimiento intenta hasta nueve solicitudes para reunir seis recetas distintas; puede mostrar menos si hay duplicados o fallos.
- Las listas de categorías se conservan solo durante la pantalla y no se persisten en disco.
- Android conserva el identificador de ejemplo y firma debug; no está preparado para publicar en tiendas. El toolchain muestra avisos de futura retirada de soporte para Gradle/AGP/Kotlin actuales; no se han actualizado indiscriminadamente.
- Los iconos de lanzamiento son los generados por Flutter.

## Autor

**Miguel Arbeláez Vallejo**

Flutter & Dart · Full-Stack · Backend · AI/Data

[GitHub](https://github.com/MiguelArbelaez0) · [LinkedIn](https://www.linkedin.com/in/miguel-arbelaez-v-57719542b/) · [Repositorio](https://github.com/MiguelArbelaez0/FLUTTER_RECIPES_CLEAN_STREAMS)
