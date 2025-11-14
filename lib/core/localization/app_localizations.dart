import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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

