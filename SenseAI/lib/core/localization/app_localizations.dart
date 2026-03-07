import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../services/localization_service.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  String translate(String key) {
    return LocalizationService.translate(key);
  }

  // Convenience getters for common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get dashboard => translate('dashboard');
  String get cognitiveFlexibility => translate('cognitive_flexibility');
  String get ruleSwitching => translate('rule_switching');
  String get addChild => translate('add_child');
  String get viewAll => translate('view_all');
  String get recentChildren => translate('recent_children');
  String get totalChildren => translate('total_children');
  String get completed => translate('completed');
  String get pending => translate('pending');
  String get today => translate('today');
  String get statistics => translate('statistics');
  String get quickActions => translate('quick_actions');
  String get searchChildren => translate('search_children');
  String get noChildren => translate('no_children');
  String get addFirstChild => translate('add_first_child');
  String get childName => translate('child_name');
  String get dateOfBirth => translate('date_of_birth');
  String get gender => translate('gender');
  String get language => translate('language');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get male => translate('male');
  String get female => translate('female');
  String get other => translate('other');
  String get english => translate('english');
  String get sinhala => translate('sinhala');
  String get tamil => translate('tamil');
  String get age => translate('age');
  String get years => translate('years');
  String get months => translate('months');
  String get selectAge => translate('select_age');
  String get enterAge => translate('enter_age');
  String get ageRange => translate('age_range');
  String get startAssessment => translate('start_assessment');
  String get ageGroups => translate('age_groups');
  String get ageGroup23 => translate('age_group_2_3');
  String get ageGroup35 => translate('age_group_3_5');
  String get ageGroup56 => translate('age_group_5_6');
  String get assessment23 => translate('assessment_2_3');
  String get assessment35 => translate('assessment_3_5');
  String get assessment56 => translate('assessment_5_6');
  String get aiDoctorBot => translate('ai_doctor_bot');
  String get question => translate('question');
  String get ofText => translate('of');
  String get next => translate('next');
  String get previous => translate('previous');
  String get submit => translate('submit');
  String get results => translate('results');
  String get assessmentResults => translate('assessment_results');
  String get riskLevel => translate('risk_level');
  String get low => translate('low');
  String get moderate => translate('moderate');
  String get high => translate('high');
  String get recommendations => translate('recommendations');
  String get exportPdf => translate('export_pdf');
  String get backToDashboard => translate('back_to_dashboard');
  String get clinicianReflection => translate('clinician_reflection');
  String get clinicianReflection2_3 => translate('clinician_reflection_2_3');
  String get clinicianProfile => translate('clinician_profile');
  String get manualTasks => translate('manual_tasks');
  String get behavioralObservations => translate('behavioral_observations');
  String get refresh => translate('refresh');
  String get noResults => translate('no_results');
  String get tryDifferentSearch => translate('try_different_search');
  String get lastAssessment => translate('last_assessment');
  String get completedSessions => translate('completed_sessions');
  String get pendingSession => translate('pending_session');
  String get todayText => translate('today_text');
  String get yesterday => translate('yesterday');
  String get daysAgo => translate('days_ago');
  String get welcomeBack => translate('welcome_back');
  String get senseaiDashboard => translate('senseai_dashboard');
  String get assessmentComponents => translate('assessment_components');
  String get addNewChild => translate('add_new_child');
  String get viewReports => translate('view_reports');
  String get systemInformation => translate('system_information');
  String get version => translate('version');
  String get status => translate('status');
  String get pilotMode => translate('pilot_mode');
  String get mode => translate('mode');
  String get offlineFirst => translate('offline_first');
  String get refreshed => translate('refreshed');
  String get error => translate('error');
  String get comingSoon => translate('coming_soon');
  String get rrb => translate('rrb');
  String get restrictedRepetitive => translate('restricted_repetitive');
  String get auditoryChecking => translate('auditory_checking');
  String get soundProcessing => translate('sound_processing');
  String get visualChecking => translate('visual_checking');
  String get visualProcessing => translate('visual_processing');
  String get rrbComingSoon => translate('rrb_coming_soon');
  String get auditoryComingSoon => translate('auditory_coming_soon');
  String get visualComingSoon => translate('visual_coming_soon');
  String get viewReportsComingSoon => translate('view_reports_coming_soon');
  String get retry => translate('retry');
  String get logoutConfirmation => translate('logout_confirmation');

  // Game UI strings (used by assessment games)
  String get greatJob => translate('greatJob');
  String get tryAgain => translate('tryAgain');
  String get wellDone => translate('wellDone');

  // Frog Jump game
  String get frogJumpGameTitle => translate('frogJumpGameTitle');
  String get frogJumpGameInstructions => translate('frogJumpGameInstructions');
  String get tapMe => translate('tapMe');
  String get dontTap => translate('dontTap');
  String get getReady => translate('getReady');
  String get tapHappyFrog => translate('tapHappyFrog');
  String get dontTapSleepyTurtle => translate('dontTapSleepyTurtle');
  String get gameComplete => translate('gameComplete');

  // Visual Attention & Preferences Getters
  String get visualCheckingTitle => translate('visualCheckingTitle');
  String get enhanceFocus => translate('enhanceFocus');
  String get childInfoTitle => translate('childInfoTitle');
  String get letsStartAdventure => translate('letsStartAdventure');
  String get whatsYourName => translate('whatsYourName');
  String get howOldAreYou => translate('howOldAreYou');
  String get letsGo => translate('letsGo');
  String get funGamesAhead => translate('funGamesAhead');
  String get playExcitingGames => translate('playExcitingGames');
  String get parentGuardianInfo => translate('parentGuardianInfo');
  String get tellUsAboutParent => translate('tellUsAboutParent');
  String get parentGuardianName => translate('parentGuardianName');
  String get emailAddress => translate('emailAddress');
  String get phoneNumber => translate('phoneNumber');
  String get includeCountryCode => translate('includeCountryCode');
  String get relationship => translate('relationship');
  String get backText => translate('backText');
  String get continueText => translate('continueText');
  String get safeAndSecure => translate('safeAndSecure');
  String get infoHelpsReport => translate('infoHelpsReport');
  String get calibrationTitle => translate('calibrationTitle');
  String get lookAtTheDot => translate('lookAtTheDot');
  String get nextButton => translate('nextButton');
  String get startGames => translate('startGames');
  String get bubblePopGame => translate('bubblePopGame');
  String get howToPlayGame => translate('howToPlayGame');
  String get seeTheBubbles => translate('seeTheBubbles');
  String get bubblesFloat => translate('bubblesFloat');
  String get tapToPop => translate('tapToPop');
  String get touchBubblesPop => translate('touchBubblesPop');
  String get haveFun => translate('haveFun');
  String get popAsMany => translate('popAsMany');
  String get thirtySeconds => translate('thirtySeconds');
  String get gameLasts30 => translate('gameLasts30');
  String get startGameBtn => translate('startGameBtn');
  String get butterflyGame => translate('butterflyGame');
  String get watchButterfly => translate('watchButterfly');
  String get butterflyFlyAround => translate('butterflyFlyAround');
  String get followEyes => translate('followEyes');
  String get tryLookWhere => translate('tryLookWhere');
  String get visitFlowers => translate('visitFlowers');
  String get butterflyLovesFlowers => translate('butterflyLovesFlowers');
  String get fifteenSeconds => translate('fifteenSeconds');
  String get gameLasts15 => translate('gameLasts15');
  String get allDone => translate('allDone');
  String get youDidGreat => translate('youDidGreat');
  String get amazingJob => translate('amazingJob');
  String get yourScore => translate('yourScore');
  String get specialReport => translate('specialReport');
  String get generatingReportReason => translate('generatingReportReason');
  String get getYourReport => translate('getYourReport');
  String get playAgain => translate('playAgain');

}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'si', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    await LocalizationService.load(locale);
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

