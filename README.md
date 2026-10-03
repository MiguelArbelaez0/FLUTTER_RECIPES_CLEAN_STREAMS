# Flutter Recipes Clean Streams

A Flutter application for discovering and searching recipes, built with Flutter and Dart using Clean Architecture principles, BLoC/Streams for reactive state management, dependency injection, and REST API integration.

## 📱 Overview

Flutter Recipes Clean Streams is a recipe discovery application focused on clean separation of responsibilities and reactive data flows.

The project integrates the TheMealDB API and demonstrates how user input can be processed through a debounced stream before reaching the application and data layers.

## 🏗️ Architecture

The application follows a Clean Architecture-inspired structure:

```text
Presentation
     ↓
BLoC / Streams
     ↓
Use Case
     ↓
Repository
     ↓
Remote Data Source
     ↓
Dio
     ↓
TheMealDB API
```

This approach separates the user interface, business logic, domain rules, and external data access.

## 🚀 Features

- Recipe discovery
- Recipe search
- Reactive search using Streams
- Search input debouncing
- REST API integration
- Responsive interface
- BLoC-based state management
- Repository Pattern
- Use Case layer
- Dependency injection
- Error and loading state handling
- Unit and application-level testing

## 🔎 Reactive Search

One of the main technical aspects of the project is the use of Streams to process search input.

The search flow can be represented as:

```text
User Input
    ↓
Stream
    ↓
Debounce
    ↓
BLoC
    ↓
Use Case
    ↓
Repository
    ↓
Remote Data Source
    ↓
TheMealDB API
```

Debouncing prevents unnecessary API requests while the user is typing and provides a cleaner reactive search experience.

## 🧩 Technologies

| Technology | Usage |
|---|---|
| Flutter | Application framework |
| Dart | Programming language |
| flutter_bloc | State management |
| BLoC | Reactive application logic |
| Streams | Reactive data processing |
| Dio | HTTP client |
| GetIt | Dependency injection |
| Equatable | Value equality |
| TheMealDB API | Recipe data |
| Clean Architecture | Application organization |
| Repository Pattern | Data abstraction |

## 🌐 API Integration

The application consumes the public TheMealDB API to retrieve recipe information.

The API communication is isolated from the presentation layer through the repository and data-source layers.

This makes the external service easier to replace, test, and maintain without coupling the UI directly to HTTP requests.

## ⚡ State Management

BLoC is used to manage application state and coordinate the flow between the presentation layer and the domain/data layers.

Typical states include:

- Initial state
- Loading
- Successful results
- Empty results
- Error state

The UI reacts to state changes instead of directly controlling API operations.

## 💉 Dependency Injection

`GetIt` is used to register and resolve application dependencies.

This keeps dependency creation centralized and reduces direct coupling between application components.

## 📱 Responsive UI

The application is designed to adapt to different screen sizes, including mobile, tablet, and desktop layouts.

The UI separates reusable widgets from screen-level components to keep the presentation layer maintainable.

## 🧪 Testing

The project includes tests for application components and core functionality.

The separation provided by Clean Architecture, repositories, and use cases makes individual layers easier to test independently.

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/MiguelArbelaez0/FLUTTER_RECIPES_CLEAN_STREAMS.git
cd FLUTTER_RECIPES_CLEAN_STREAMS
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the application

```bash
flutter run
```

Make sure Flutter and Dart are correctly installed and configured on your development environment.

## 📂 Project Structure

The project separates responsibilities across the main application layers:

```text
lib/
├── core/
├── data/
├── domain/
└── presentation/
```

### Presentation

Contains screens, widgets, BLoCs, and reactive UI logic.

### Domain

Contains business logic, entities, repository contracts, and use cases.

### Data

Contains API communication, data sources, models, and repository implementations.

### Core

Contains shared functionality and application-level utilities.

## 🎯 What This Project Demonstrates

This project demonstrates practical experience with:

- Flutter and Dart
- BLoC and reactive Streams
- Clean Architecture principles
- Repository Pattern
- Use Case design
- REST API integration
- Dio
- Dependency injection with GetIt
- Search debouncing
- Responsive UI development
- Error and state handling
- Testing

## 📌 Project Status

The project is a completed academic/personal development project created to practice production-oriented Flutter architecture, reactive programming, and API-driven application development.

## 👨‍💻 Author

**Miguel Arbeláez Vallejo**

Software Developer | Flutter / Dart | Full-Stack Development

- GitHub: https://github.com/MiguelArbelaez0
- LinkedIn: https://www.linkedin.com/in/miguel-arbelaez-v-57719542b/
