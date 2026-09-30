# Recipes Clean Streams

A Flutter recipe browser that uses the public TheMealDB API. The project demonstrates Clean Architecture, BLoC state management, stream transformations, Dio networking, GetIt dependency injection, and Equatable value objects.

## Toolchain

Target toolchain: Flutter 3.47.5 and Dart 3.13.4. The Dart SDK constraint is `>=3.13.4 <4.0.0`.

## Architecture and data flow

```text
UI → RecipesBloc → use case → RecipeRepository contract
  → RecipeRepositoryImpl → RecipeRemoteDataSource
  → shared Dio client → TheMealDB

TheMealDB → Dio → data source → RecipeModel / IngredientModel
  → RecipeEntity / IngredientEntity → use case → BLoC state → UI
```

`domain` owns immutable entities, the abstract repository contract, and use cases. It does not depend on `data`, JSON, Dio, or Flutter UI. `data` parses API responses into models, converts models to domain entities, and maps network exceptions to application failures. The UI dispatches BLoC events and renders states. GetIt registers dependencies in client, data source, repository, use cases, then BLoC order.

## Project structure

```text
lib/
  core/
    error/{exceptions,failures}/
    network/api_client.dart
  features/recipes/
    data/{datasources,models,repositories}/
    domain/{entities,repositories,usecases}/
    presentation/bloc/
  injection/injection_container.dart
  main.dart
  presentation/{routes,screens,widgets}/
test/
```

The meal model reads TheMealDB's `idMeal`, `strMeal`, category, area, instructions, thumbnail, and all 20 ingredient/measure pairs. Empty ingredient slots are omitted. The domain receives only clean ingredient name and measure values.

## API endpoints used

TheMealDB's public development endpoint uses the test key `1` in its URL; no private key or environment file is needed.

| Feature | Request |
|---|---|
| Search meals | `GET https://www.themealdb.com/api/json/v1/1/search.php?s=chicken` |
| Random meal | `GET https://www.themealdb.com/api/json/v1/1/random.php` |
| Meal detail | `GET https://www.themealdb.com/api/json/v1/1/lookup.php?i=52772` |

The free API is suitable for development and educational projects. Categories and ingredient/category filters exist in TheMealDB, but this app currently implements search, random meal, detail, refresh, ingredients, and meal imagery.

## State and streams

`RecipesBloc` handles random meal, search, detail, and refresh events. Recipe lists and detail have explicit initial, loading, success, and failure states. A successful empty search is represented by an empty result list and shown as a no-results message. Search events use a debounce stream transformation; BLoC's state stream is the single UI update stream, so the app does not create duplicate `StreamController`s.

## Install and run

```sh
flutter pub get
flutter run -d chrome
```

## Analysis and tests

```sh
flutter analyze
flutter test
```

Tests use fake repositories and a local Dio adapter. They do not require internet access and cover model conversion, search/no-results, random and detail endpoints, datasource failures, repository mapping, use cases, and BLoC states.
