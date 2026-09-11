import 'package:cognitive_care_games/features/games/data/drift/app_database.dart';

/// Opens an isolated in-memory Drift database for a single test.
///
/// Usage in a test:
/// ```dart
/// late AppDatabase db;
/// setUp(() => db = openTestDatabaseForTest());
/// tearDown(() => db.close());
/// ```
///
/// Each call produces a fresh, empty database — tests cannot bleed state
/// into each other.
AppDatabase openTestDatabaseForTest() => openTestDatabase();
