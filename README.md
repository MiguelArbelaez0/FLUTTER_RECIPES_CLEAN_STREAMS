# Flutter Recipes Clean Streams

Aplicación móvil desarrollada con Flutter y Dart para descubrir y buscar recetas, utilizando principios de Clean Architecture, BLoC/Streams, inyección de dependencias e integración con una API REST.

## 📱 Descripción general

Flutter Recipes Clean Streams es una aplicación centrada en el descubrimiento de recetas, la separación de responsabilidades y el procesamiento reactivo de búsquedas.

El proyecto integra la API de TheMealDB y procesa la entrada del usuario mediante un flujo con debounce antes de llegar a las capas de aplicación y datos.

## 🏗️ Arquitectura

```text
Presentación
     ↓
BLoC / Streams
     ↓
Caso de uso
     ↓
Repositorio
     ↓
Fuente de datos remota
     ↓
Dio
     ↓
API de TheMealDB
```

La estructura separa interfaz, lógica de negocio, reglas de dominio y acceso a servicios externos.

## 🚀 Funcionalidades

- Descubrimiento de recetas.
- Búsqueda de recetas.
- Búsqueda reactiva con Streams.
- Debounce de la búsqueda.
- Integración con API REST.
- Interfaz adaptable.
- Gestión de estado con BLoC.
- Repository Pattern.
- Capa de casos de uso.
- Inyección de dependencias.
- Manejo de errores y estados de carga.
- Pruebas unitarias y de aplicación.

## 🔎 Búsqueda reactiva

El proyecto utiliza Streams para procesar la entrada de búsqueda:

```text
Entrada del usuario
    ↓
Stream
    ↓
Debounce
    ↓
BLoC
    ↓
Caso de uso
    ↓
Repositorio
    ↓
Fuente de datos remota
    ↓
API de TheMealDB
```

El debounce reduce solicitudes innecesarias mientras el usuario escribe y mejora la eficiencia de la búsqueda.

## 🧩 Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter | Desarrollo de la aplicación |
| Dart | Lenguaje de programación |
| flutter_bloc | Gestión de estado |
| BLoC | Lógica reactiva |
| Streams | Procesamiento reactivo |
| Dio | Cliente HTTP |
| GetIt | Inyección de dependencias |
| Equatable | Comparación de valores |
| TheMealDB API | Datos de recetas |
| Clean Architecture | Organización de la aplicación |
| Repository Pattern | Abstracción de datos |

## 🌐 Integración con la API

La aplicación consume la API pública de TheMealDB para obtener información de recetas.

La comunicación se encuentra aislada de la presentación mediante las capas de repositorio y fuente de datos.

## ⚡ Gestión de estado

BLoC coordina el flujo entre presentación y las capas de dominio y datos.

Estados habituales:

- Inicial.
- Cargando.
- Resultados exitosos.
- Sin resultados.
- Error.

La interfaz reacciona a los cambios de estado sin controlar directamente las operaciones de la API.

## 💉 Inyección de dependencias

`GetIt` registra y resuelve las dependencias de la aplicación, centralizando su configuración y reduciendo el acoplamiento.

## 📱 Interfaz adaptable

La aplicación está preparada para diferentes tamaños de pantalla, incluyendo dispositivos móviles, tabletas y escritorio.

## 🧪 Pruebas

El proyecto incluye pruebas de componentes y funcionalidades principales.

La separación proporcionada por Clean Architecture, repositorios y casos de uso facilita las pruebas independientes.

## ⚙️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/MiguelArbelaez0/FLUTTER_RECIPES_CLEAN_STREAMS.git
cd FLUTTER_RECIPES_CLEAN_STREAMS
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Ejecutar

```bash
flutter run
```

## 📂 Estructura

```text
lib/
├── core/
├── data/
├── domain/
└── presentation/
```

### Presentación
Pantallas, widgets, BLoC y lógica reactiva de la interfaz.

### Dominio
Entidades, contratos de repositorio y casos de uso.

### Datos
Comunicación con la API, fuentes de datos, modelos e implementaciones de repositorios.

### Core
Funcionalidades compartidas y utilidades de la aplicación.

## 🎯 Qué demuestra este proyecto

- Flutter y Dart.
- BLoC y Streams.
- Principios de Clean Architecture.
- Repository Pattern.
- Diseño mediante casos de uso.
- Integración con APIs REST.
- Dio.
- Inyección de dependencias con GetIt.
- Debounce de búsquedas.
- Interfaces adaptables.
- Manejo de errores y estados.
- Pruebas.

## 📌 Estado del proyecto

**Proyecto de portafolio terminado.**

Desarrollado para demostrar arquitectura mantenible en Flutter, programación reactiva con Streams/BLoC, integración con APIs, inyección de dependencias y diseño orientado a pruebas.

## 👨‍💻 Autor

**Miguel Arbeláez Vallejo**

Flutter & Dart · Full-Stack · Backend · AI/Data
