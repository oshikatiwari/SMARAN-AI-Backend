/// Public barrel export for the Games Module.
///
/// This is the ONLY file that teammates (dashboard, AI-analysis, routing)
/// should ever import. Importing individual files from inside
/// `lib/features/games/` directly is forbidden — route through this barrel.
///
/// As milestones complete, their public-facing symbols are re-exported here.
/// Internal implementation files (DAOs, DTOs, Flame components) are NOT
/// re-exported — they are implementation details.
library;

// ── Design System ──────────────────────────────────────────────────────────
export 'presentation/shared/design_system/app_colors.dart';
export 'presentation/shared/design_system/app_dimensions.dart';
export 'presentation/shared/design_system/app_text_styles.dart';

// ── Domain (public contracts) ───────────────────────────────────────────────
// Entities — consumed by dashboard and AI-analysis modules
export 'domain/entities/game_config.dart';
export 'domain/entities/game_result.dart';
export 'domain/entities/game_session.dart';

// Value objects
export 'domain/value_objects/difficulty.dart';
export 'domain/value_objects/game_type.dart';
export 'domain/value_objects/pattern_type.dart';
export 'domain/value_objects/session_status.dart';
export 'domain/value_objects/sync_status.dart';

// Repository interfaces — implemented by data layer, consumed by use-cases
export 'domain/repositories/i_game_config_repository.dart';
export 'domain/repositories/i_game_result_repository.dart';
export 'domain/repositories/i_game_session_repository.dart';

// Use-cases and DomainException — consumed by Riverpod notifiers
export 'domain/usecases/end_game_session.dart';
export 'domain/usecases/get_game_config.dart';
export 'domain/usecases/record_game_result.dart';
export 'domain/usecases/start_game_session.dart'
    show StartGameSession, DomainException;

// ── Shared UI Widgets (public design-system components) ────────────────────
export 'presentation/shared/widgets/attempt_counter_widget.dart';
export 'presentation/shared/widgets/difficulty_selector_widget.dart';
export 'presentation/shared/widgets/elderly_button.dart';
export 'presentation/shared/widgets/game_hud_widget.dart';
export 'presentation/shared/widgets/game_result_metrics_widget.dart';
export 'presentation/shared/widgets/game_timer_widget.dart';

// ── Screens (public navigation surfaces) ───────────────────────────────────
export 'presentation/memory_matching/screens/memory_game_menu_screen.dart'
    show MemoryGameMenuScreen;
export 'presentation/pattern_recognition/screens/pattern_game_menu_screen.dart'
    show PatternGameMenuScreen;

// ── Providers (public surface for app-level ProviderScope wiring) ──────────
export 'presentation/providers/database_provider.dart';
export 'presentation/providers/difficulty_provider.dart';
export 'presentation/providers/game_event_bus.dart'
    show GameEventBus, GameEvent, GameCompleteEvent, GameAbandonedEvent,
        HintRequestedEvent, gameEventBusProvider;
export 'presentation/providers/metrics_state_notifier.dart'
    show MetricsState, metricsNotifierProvider, gameTimerProvider;
export 'presentation/providers/repository_providers.dart';
export 'presentation/providers/session_state_notifier.dart'
    show SessionState, sessionNotifierProvider;
export 'presentation/providers/usecase_providers.dart';
