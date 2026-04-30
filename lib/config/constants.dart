/// Game constants derived from the proposal specification.
///
/// All magic numbers live here — never use inline literals elsewhere.
library;

/// Board & grid
const int gridSize = 5;
const int totalCells = gridSize * gridSize; // 25

/// Basic mode
const int basicModeMaxNumber = 50;
const int basicModeFrontStart = 1;
const int basicModeFrontEnd = 25;
const int basicModeBackStart = 26;
const int basicModeBackEnd = 50;

/// Flip animation
const Duration flipAnimationDuration = Duration(milliseconds: 200);

/// Basic mode penalties / display
const double basicModeWrongPenaltySeconds = 5.0;
const int basicModeTimeDecimalPlaces = 3;

/// Infinite mode — survival timer
const double infiniteModeInitialTimeSeconds = 30.0;
const double infiniteModeTimeCapSeconds = 60.0;

/// Infinite mode — correct answer recovery
const double infiniteModeBaseRecoverySeconds = 1.0;
const double infiniteModeRecoveryDecreasePerLoop = 0.1;
const double infiniteModeMinRecoverySeconds = 0.1;

/// Infinite mode — wrong answer penalty
const double infiniteModeWrongPenaltySeconds = 5.0;

/// Infinite mode — number / loop limits
const int infiniteModeMaxNumberPerLoop = 999;
const int infiniteModeNumbersPerLoop = 1000; // 999 numbers + 1 icon
const int loopIconTypeCount = 20;

/// Pause / resume countdown
const int resumeCountdownSeconds = 3;

/// 백그라운드 체류가 이 값을 초과한 채 포그라운드 복귀하면 게임을 자동
/// 중단하고 결과 화면(aborted=true, bgTimeout=true)으로 전환한다.
const Duration backgroundGameOverThreshold = Duration(minutes: 5);

/// Timer bar warning thresholds (infinite mode)
const double timerWarningGreenThreshold = 30.0;
const double timerWarningGoldThreshold = 15.0;

/// Multi-touch block window after a valid tap.
const Duration multiTouchLockDuration = Duration(milliseconds: 80);

/// Board visual sizes (logical pixels, used in widgets).
const double boardMaxSize = 500.0;
const double cardSize = 60.0;
const double cardBorderRadius = 8.0;
const double boardSpacing = 4.0;

/// Button sizes
const double buttonWidth = 300.0;
const double buttonHeight = 56.0;
const double buttonBorderRadius = 12.0;

/// Infinite mode — card palette cycling
const int cardPaletteBucketSize = 25;
const Duration cardColorTweenDuration = Duration(milliseconds: 400);

/// 앱 메타.
const String appName = 'HBJJGAMES';
const String appVersion = '1.0.0';
const String companyName = 'HBJJGAMES';
const String copyrightYears = '2026';
