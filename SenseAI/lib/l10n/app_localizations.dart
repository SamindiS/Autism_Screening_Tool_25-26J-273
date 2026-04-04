import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SenseAI'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @cognitiveFlexibility.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get cognitiveFlexibility;

  /// No description provided for @ruleSwitching.
  ///
  /// In en, this message translates to:
  /// **'Rule Switching Assessment'**
  String get ruleSwitching;

  /// No description provided for @addChild.
  ///
  /// In en, this message translates to:
  /// **'Add Child'**
  String get addChild;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @recentChildren.
  ///
  /// In en, this message translates to:
  /// **'Recent Children'**
  String get recentChildren;

  /// No description provided for @totalChildren.
  ///
  /// In en, this message translates to:
  /// **'Total Children'**
  String get totalChildren;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @searchChildren.
  ///
  /// In en, this message translates to:
  /// **'Search children by name...'**
  String get searchChildren;

  /// No description provided for @noChildren.
  ///
  /// In en, this message translates to:
  /// **'No children added yet'**
  String get noChildren;

  /// No description provided for @addFirstChild.
  ///
  /// In en, this message translates to:
  /// **'Add your first child to start assessments'**
  String get addFirstChild;

  /// No description provided for @childName.
  ///
  /// In en, this message translates to:
  /// **'Child Name'**
  String get childName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @selectAge.
  ///
  /// In en, this message translates to:
  /// **'Select Age'**
  String get selectAge;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter Child Age'**
  String get enterAge;

  /// No description provided for @ageRange.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 2.0 and 6.0 years'**
  String get ageRange;

  /// No description provided for @startAssessment.
  ///
  /// In en, this message translates to:
  /// **'START ASSESSMENT'**
  String get startAssessment;

  /// No description provided for @ageGroups.
  ///
  /// In en, this message translates to:
  /// **'Age Groups'**
  String get ageGroups;

  /// No description provided for @ageGroup23.
  ///
  /// In en, this message translates to:
  /// **'2.0 - 3.4 years'**
  String get ageGroup23;

  /// No description provided for @ageGroup35.
  ///
  /// In en, this message translates to:
  /// **'3.5 - 5.5 years'**
  String get ageGroup35;

  /// No description provided for @ageGroup56.
  ///
  /// In en, this message translates to:
  /// **'5.6 - 6.0 years'**
  String get ageGroup56;

  /// No description provided for @assessment23.
  ///
  /// In en, this message translates to:
  /// **'Parent Interview Bot'**
  String get assessment23;

  /// No description provided for @assessment35.
  ///
  /// In en, this message translates to:
  /// **'Frog Jump Game (Go/No-Go)'**
  String get assessment35;

  /// No description provided for @assessment56.
  ///
  /// In en, this message translates to:
  /// **'Color-Shape Game (DCCS)'**
  String get assessment56;

  /// No description provided for @aiDoctorBot.
  ///
  /// In en, this message translates to:
  /// **'AI Doctor Bot'**
  String get aiDoctorBot;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @ofText.
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get ofText;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @assessmentResults.
  ///
  /// In en, this message translates to:
  /// **'Assessment Results'**
  String get assessmentResults;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export as PDF Report'**
  String get exportPdf;

  /// No description provided for @backToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Back to Dashboard'**
  String get backToDashboard;

  /// No description provided for @clinicianReflection.
  ///
  /// In en, this message translates to:
  /// **'Clinician Reflection'**
  String get clinicianReflection;

  /// No description provided for @clinicianProfile.
  ///
  /// In en, this message translates to:
  /// **'Clinician Profile'**
  String get clinicianProfile;

  /// No description provided for @clinicianReflection23.
  ///
  /// In en, this message translates to:
  /// **'Clinician Reflection (2-3.5 yrs)'**
  String get clinicianReflection23;

  /// No description provided for @manualTasks.
  ///
  /// In en, this message translates to:
  /// **'Manual Cognitive Flexibility Tasks'**
  String get manualTasks;

  /// No description provided for @behavioralObservations.
  ///
  /// In en, this message translates to:
  /// **'Behavioral Observations'**
  String get behavioralObservations;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No children found'**
  String get noResults;

  /// No description provided for @tryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearch;

  /// No description provided for @lastAssessment.
  ///
  /// In en, this message translates to:
  /// **'Last assessment'**
  String get lastAssessment;

  /// No description provided for @completedSessions.
  ///
  /// In en, this message translates to:
  /// **'completed'**
  String get completedSessions;

  /// No description provided for @pendingSession.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingSession;

  /// No description provided for @todayText.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayText;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @aiQuestion1.
  ///
  /// In en, this message translates to:
  /// **'Does {childName} respond when you call their name?'**
  String aiQuestion1(String childName);

  /// No description provided for @aiCategory1.
  ///
  /// In en, this message translates to:
  /// **'Social Responsiveness'**
  String get aiCategory1;

  /// No description provided for @aiQuestion1Option1.
  ///
  /// In en, this message translates to:
  /// **'Always responds immediately'**
  String get aiQuestion1Option1;

  /// No description provided for @aiQuestion1Option2.
  ///
  /// In en, this message translates to:
  /// **'Usually responds'**
  String get aiQuestion1Option2;

  /// No description provided for @aiQuestion1Option3.
  ///
  /// In en, this message translates to:
  /// **'Sometimes responds'**
  String get aiQuestion1Option3;

  /// No description provided for @aiQuestion1Option4.
  ///
  /// In en, this message translates to:
  /// **'Rarely responds'**
  String get aiQuestion1Option4;

  /// No description provided for @aiQuestion1Option5.
  ///
  /// In en, this message translates to:
  /// **'Never or almost never responds'**
  String get aiQuestion1Option5;

  /// No description provided for @aiQuestion2.
  ///
  /// In en, this message translates to:
  /// **'How does {childName} react when their daily routine changes?'**
  String aiQuestion2(Object childName);

  /// No description provided for @aiCategory2.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get aiCategory2;

  /// No description provided for @aiQuestion2Option1.
  ///
  /// In en, this message translates to:
  /// **'Adapts easily to changes'**
  String get aiQuestion2Option1;

  /// No description provided for @aiQuestion2Option2.
  ///
  /// In en, this message translates to:
  /// **'Needs a little time but adapts'**
  String get aiQuestion2Option2;

  /// No description provided for @aiQuestion2Option3.
  ///
  /// In en, this message translates to:
  /// **'Shows some distress, eventually adapts'**
  String get aiQuestion2Option3;

  /// No description provided for @aiQuestion2Option4.
  ///
  /// In en, this message translates to:
  /// **'Gets very upset, takes long to adapt'**
  String get aiQuestion2Option4;

  /// No description provided for @aiQuestion2Option5.
  ///
  /// In en, this message translates to:
  /// **'Cannot adapt, extreme distress'**
  String get aiQuestion2Option5;

  /// No description provided for @aiQuestion3.
  ///
  /// In en, this message translates to:
  /// **'When playing with toys, does {childName} switch between different activities or toys?'**
  String aiQuestion3(Object childName);

  /// No description provided for @aiCategory3.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get aiCategory3;

  /// No description provided for @aiQuestion3Option1.
  ///
  /// In en, this message translates to:
  /// **'Easily switches between toys/activities'**
  String get aiQuestion3Option1;

  /// No description provided for @aiQuestion3Option2.
  ///
  /// In en, this message translates to:
  /// **'Switches with gentle prompting'**
  String get aiQuestion3Option2;

  /// No description provided for @aiQuestion3Option3.
  ///
  /// In en, this message translates to:
  /// **'Switches but shows reluctance'**
  String get aiQuestion3Option3;

  /// No description provided for @aiQuestion3Option4.
  ///
  /// In en, this message translates to:
  /// **'Very difficult to get them to switch'**
  String get aiQuestion3Option4;

  /// No description provided for @aiQuestion3Option5.
  ///
  /// In en, this message translates to:
  /// **'Refuses to switch, fixates on one toy'**
  String get aiQuestion3Option5;

  /// No description provided for @aiQuestion4.
  ///
  /// In en, this message translates to:
  /// **'How often does {childName} make eye contact when you talk to them?'**
  String aiQuestion4(Object childName);

  /// No description provided for @aiCategory4.
  ///
  /// In en, this message translates to:
  /// **'Social Communication'**
  String get aiCategory4;

  /// No description provided for @aiQuestion4Option1.
  ///
  /// In en, this message translates to:
  /// **'Always makes good eye contact'**
  String get aiQuestion4Option1;

  /// No description provided for @aiQuestion4Option2.
  ///
  /// In en, this message translates to:
  /// **'Usually makes eye contact'**
  String get aiQuestion4Option2;

  /// No description provided for @aiQuestion4Option3.
  ///
  /// In en, this message translates to:
  /// **'Sometimes makes eye contact'**
  String get aiQuestion4Option3;

  /// No description provided for @aiQuestion4Option4.
  ///
  /// In en, this message translates to:
  /// **'Rarely makes eye contact'**
  String get aiQuestion4Option4;

  /// No description provided for @aiQuestion4Option5.
  ///
  /// In en, this message translates to:
  /// **'Avoids eye contact completely'**
  String get aiQuestion4Option5;

  /// No description provided for @aiQuestion5.
  ///
  /// In en, this message translates to:
  /// **'Does {childName} point to objects they want or find interesting?'**
  String aiQuestion5(Object childName);

  /// No description provided for @aiCategory5.
  ///
  /// In en, this message translates to:
  /// **'Joint Attention'**
  String get aiCategory5;

  /// No description provided for @aiQuestion5Option1.
  ///
  /// In en, this message translates to:
  /// **'Frequently points and shares interest'**
  String get aiQuestion5Option1;

  /// No description provided for @aiQuestion5Option2.
  ///
  /// In en, this message translates to:
  /// **'Often points to things'**
  String get aiQuestion5Option2;

  /// No description provided for @aiQuestion5Option3.
  ///
  /// In en, this message translates to:
  /// **'Occasionally points'**
  String get aiQuestion5Option3;

  /// No description provided for @aiQuestion5Option4.
  ///
  /// In en, this message translates to:
  /// **'Rarely points'**
  String get aiQuestion5Option4;

  /// No description provided for @aiQuestion5Option5.
  ///
  /// In en, this message translates to:
  /// **'Never or almost never points'**
  String get aiQuestion5Option5;

  /// No description provided for @aiQuestion6.
  ///
  /// In en, this message translates to:
  /// **'How does {childName} react to unexpected sounds or sensory experiences?'**
  String aiQuestion6(Object childName);

  /// No description provided for @aiCategory6.
  ///
  /// In en, this message translates to:
  /// **'Sensory Processing'**
  String get aiCategory6;

  /// No description provided for @aiQuestion6Option1.
  ///
  /// In en, this message translates to:
  /// **'Reacts appropriately, recovers quickly'**
  String get aiQuestion6Option1;

  /// No description provided for @aiQuestion6Option2.
  ///
  /// In en, this message translates to:
  /// **'Startles but calms down soon'**
  String get aiQuestion6Option2;

  /// No description provided for @aiQuestion6Option3.
  ///
  /// In en, this message translates to:
  /// **'Gets upset, needs comfort'**
  String get aiQuestion6Option3;

  /// No description provided for @aiQuestion6Option4.
  ///
  /// In en, this message translates to:
  /// **'Very distressed, takes long to calm'**
  String get aiQuestion6Option4;

  /// No description provided for @aiQuestion6Option5.
  ///
  /// In en, this message translates to:
  /// **'Extreme distress or complete shutdown'**
  String get aiQuestion6Option5;

  /// No description provided for @aiQuestion7.
  ///
  /// In en, this message translates to:
  /// **'Does {childName} imitate your actions or words?'**
  String aiQuestion7(Object childName);

  /// No description provided for @aiCategory7.
  ///
  /// In en, this message translates to:
  /// **'Social Learning'**
  String get aiCategory7;

  /// No description provided for @aiQuestion7Option1.
  ///
  /// In en, this message translates to:
  /// **'Frequently imitates spontaneously'**
  String get aiQuestion7Option1;

  /// No description provided for @aiQuestion7Option2.
  ///
  /// In en, this message translates to:
  /// **'Often imitates when prompted'**
  String get aiQuestion7Option2;

  /// No description provided for @aiQuestion7Option3.
  ///
  /// In en, this message translates to:
  /// **'Imitates some simple actions'**
  String get aiQuestion7Option3;

  /// No description provided for @aiQuestion7Option4.
  ///
  /// In en, this message translates to:
  /// **'Rarely imitates'**
  String get aiQuestion7Option4;

  /// No description provided for @aiQuestion7Option5.
  ///
  /// In en, this message translates to:
  /// **'Never or almost never imitates'**
  String get aiQuestion7Option5;

  /// No description provided for @aiQuestion8.
  ///
  /// In en, this message translates to:
  /// **'How does {childName} play with other children?'**
  String aiQuestion8(Object childName);

  /// No description provided for @aiCategory8.
  ///
  /// In en, this message translates to:
  /// **'Social Interaction'**
  String get aiCategory8;

  /// No description provided for @aiQuestion8Option1.
  ///
  /// In en, this message translates to:
  /// **'Actively engages and shares'**
  String get aiQuestion8Option1;

  /// No description provided for @aiQuestion8Option2.
  ///
  /// In en, this message translates to:
  /// **'Plays near others, some interaction'**
  String get aiQuestion8Option2;

  /// No description provided for @aiQuestion8Option3.
  ///
  /// In en, this message translates to:
  /// **'Parallel play, minimal interaction'**
  String get aiQuestion8Option3;

  /// No description provided for @aiQuestion8Option4.
  ///
  /// In en, this message translates to:
  /// **'Prefers solitary play, avoids others'**
  String get aiQuestion8Option4;

  /// No description provided for @aiQuestion8Option5.
  ///
  /// In en, this message translates to:
  /// **'No interest in other children'**
  String get aiQuestion8Option5;

  /// No description provided for @aiQuestion9.
  ///
  /// In en, this message translates to:
  /// **'Does {childName} show interest when you show them something?'**
  String aiQuestion9(Object childName);

  /// No description provided for @aiCategory9.
  ///
  /// In en, this message translates to:
  /// **'Joint Attention'**
  String get aiCategory9;

  /// No description provided for @aiQuestion9Option1.
  ///
  /// In en, this message translates to:
  /// **'Always looks and shows interest'**
  String get aiQuestion9Option1;

  /// No description provided for @aiQuestion9Option2.
  ///
  /// In en, this message translates to:
  /// **'Usually looks when you point'**
  String get aiQuestion9Option2;

  /// No description provided for @aiQuestion9Option3.
  ///
  /// In en, this message translates to:
  /// **'Sometimes follows your gaze/point'**
  String get aiQuestion9Option3;

  /// No description provided for @aiQuestion9Option4.
  ///
  /// In en, this message translates to:
  /// **'Rarely follows your attention'**
  String get aiQuestion9Option4;

  /// No description provided for @aiQuestion9Option5.
  ///
  /// In en, this message translates to:
  /// **'Never follows your gaze or point'**
  String get aiQuestion9Option5;

  /// No description provided for @aiQuestion10.
  ///
  /// In en, this message translates to:
  /// **'How does {childName} express their needs or wants?'**
  String aiQuestion10(Object childName);

  /// No description provided for @aiCategory10.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get aiCategory10;

  /// No description provided for @aiQuestion10Option1.
  ///
  /// In en, this message translates to:
  /// **'Uses words and gestures clearly'**
  String get aiQuestion10Option1;

  /// No description provided for @aiQuestion10Option2.
  ///
  /// In en, this message translates to:
  /// **'Uses gestures and some words'**
  String get aiQuestion10Option2;

  /// No description provided for @aiQuestion10Option3.
  ///
  /// In en, this message translates to:
  /// **'Mostly gestures, few words'**
  String get aiQuestion10Option3;

  /// No description provided for @aiQuestion10Option4.
  ///
  /// In en, this message translates to:
  /// **'Pulls you to objects, little gesture'**
  String get aiQuestion10Option4;

  /// No description provided for @aiQuestion10Option5.
  ///
  /// In en, this message translates to:
  /// **'Cries or tantrums, no clear communication'**
  String get aiQuestion10Option5;

  /// No description provided for @reflectionQuestionAttention.
  ///
  /// In en, this message translates to:
  /// **'How well did the child maintain attention during the game?'**
  String get reflectionQuestionAttention;

  /// No description provided for @reflectionLabelAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention Level'**
  String get reflectionLabelAttention;

  /// No description provided for @reflectionQuestionEngagement.
  ///
  /// In en, this message translates to:
  /// **'How engaged was the child with the game activities?'**
  String get reflectionQuestionEngagement;

  /// No description provided for @reflectionLabelEngagement.
  ///
  /// In en, this message translates to:
  /// **'Engagement Level'**
  String get reflectionLabelEngagement;

  /// No description provided for @reflectionQuestionFrustration.
  ///
  /// In en, this message translates to:
  /// **'How did the child handle frustration or mistakes?'**
  String get reflectionQuestionFrustration;

  /// No description provided for @reflectionLabelFrustration.
  ///
  /// In en, this message translates to:
  /// **'Frustration Tolerance'**
  String get reflectionLabelFrustration;

  /// No description provided for @reflectionQuestionInstructions.
  ///
  /// In en, this message translates to:
  /// **'How well did the child follow game instructions?'**
  String get reflectionQuestionInstructions;

  /// No description provided for @reflectionLabelInstructions.
  ///
  /// In en, this message translates to:
  /// **'Following Instructions'**
  String get reflectionLabelInstructions;

  /// No description provided for @reflectionQuestionOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall, how would you rate the child\'s behavior during assessment?'**
  String get reflectionQuestionOverall;

  /// No description provided for @reflectionLabelOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall Behavior'**
  String get reflectionLabelOverall;

  /// No description provided for @manualTask1Title.
  ///
  /// In en, this message translates to:
  /// **'Rule Switching Task - Color/Shape'**
  String get manualTask1Title;

  /// No description provided for @manualTask1Description.
  ///
  /// In en, this message translates to:
  /// **'Did the child switch between sorting by color and shape?'**
  String get manualTask1Description;

  /// No description provided for @manualTask1Label.
  ///
  /// In en, this message translates to:
  /// **'Rule Switching Ability'**
  String get manualTask1Label;

  /// No description provided for @manualTask1Task.
  ///
  /// In en, this message translates to:
  /// **'Give child blocks of different colors and shapes. First ask to sort by COLOR, then switch to SHAPE. Observe if child can switch rules.'**
  String get manualTask1Task;

  /// No description provided for @manualTask1Category.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get manualTask1Category;

  /// No description provided for @manualTask2Title.
  ///
  /// In en, this message translates to:
  /// **'Follow Changing Instructions'**
  String get manualTask2Title;

  /// No description provided for @manualTask2Description.
  ///
  /// In en, this message translates to:
  /// **'Did the child adapt when instructions changed?'**
  String get manualTask2Description;

  /// No description provided for @manualTask2Label.
  ///
  /// In en, this message translates to:
  /// **'Instruction Flexibility'**
  String get manualTask2Label;

  /// No description provided for @manualTask2Task.
  ///
  /// In en, this message translates to:
  /// **'Give child simple instructions that change (e.g., \"Put the red block here\" then \"Now put the blue block there\"). Observe adaptation.'**
  String get manualTask2Task;

  /// No description provided for @manualTask2Category.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get manualTask2Category;

  /// No description provided for @manualTask3Title.
  ///
  /// In en, this message translates to:
  /// **'Inhibition Task - Go/No-Go'**
  String get manualTask3Title;

  /// No description provided for @manualTask3Description.
  ///
  /// In en, this message translates to:
  /// **'Did the child inhibit responses when told not to?'**
  String get manualTask3Description;

  /// No description provided for @manualTask3Label.
  ///
  /// In en, this message translates to:
  /// **'Response Inhibition'**
  String get manualTask3Label;

  /// No description provided for @manualTask3Task.
  ///
  /// In en, this message translates to:
  /// **'Play a simple game: \"When I say GO, clap. When I say STOP, don\'t clap.\" Observe if child can inhibit clapping on STOP.'**
  String get manualTask3Task;

  /// No description provided for @manualTask3Category.
  ///
  /// In en, this message translates to:
  /// **'Inhibition Control'**
  String get manualTask3Category;

  /// No description provided for @manualTask4Title.
  ///
  /// In en, this message translates to:
  /// **'Perseveration Observation'**
  String get manualTask4Title;

  /// No description provided for @manualTask4Description.
  ///
  /// In en, this message translates to:
  /// **'Did the child get stuck on one activity or rule?'**
  String get manualTask4Description;

  /// No description provided for @manualTask4Label.
  ///
  /// In en, this message translates to:
  /// **'Perseveration'**
  String get manualTask4Label;

  /// No description provided for @manualTask4Task.
  ///
  /// In en, this message translates to:
  /// **'After switching rules, observe if child continues with old rule (perseveration) or adapts to new rule.'**
  String get manualTask4Task;

  /// No description provided for @manualTask4Category.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get manualTask4Category;

  /// No description provided for @manualTask5Title.
  ///
  /// In en, this message translates to:
  /// **'Task Switching - Play Activities'**
  String get manualTask5Title;

  /// No description provided for @manualTask5Description.
  ///
  /// In en, this message translates to:
  /// **'How well did the child switch between different play activities?'**
  String get manualTask5Description;

  /// No description provided for @manualTask5Label.
  ///
  /// In en, this message translates to:
  /// **'Activity Switching'**
  String get manualTask5Label;

  /// No description provided for @manualTask5Task.
  ///
  /// In en, this message translates to:
  /// **'Have child play with blocks, then ask to switch to drawing, then to toy. Observe ease of switching between activities.'**
  String get manualTask5Task;

  /// No description provided for @manualTask5Category.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get manualTask5Category;

  /// No description provided for @behavioralQuestionRuleSwitching.
  ///
  /// In en, this message translates to:
  /// **'How well did the child demonstrate cognitive flexibility during rule-switching tasks?'**
  String get behavioralQuestionRuleSwitching;

  /// No description provided for @behavioralLabelRuleSwitching.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get behavioralLabelRuleSwitching;

  /// No description provided for @behavioralCategoryRuleSwitching.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get behavioralCategoryRuleSwitching;

  /// No description provided for @behavioralQuestionAttention.
  ///
  /// In en, this message translates to:
  /// **'How well did the child maintain attention during the manual tasks?'**
  String get behavioralQuestionAttention;

  /// No description provided for @behavioralLabelAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention Level'**
  String get behavioralLabelAttention;

  /// No description provided for @behavioralCategoryAttention.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get behavioralCategoryAttention;

  /// No description provided for @behavioralQuestionFrustration.
  ///
  /// In en, this message translates to:
  /// **'How did the child handle frustration when tasks became difficult or rules changed?'**
  String get behavioralQuestionFrustration;

  /// No description provided for @behavioralLabelFrustration.
  ///
  /// In en, this message translates to:
  /// **'Frustration Tolerance'**
  String get behavioralLabelFrustration;

  /// No description provided for @behavioralCategoryFrustration.
  ///
  /// In en, this message translates to:
  /// **'Emotional Regulation'**
  String get behavioralCategoryFrustration;

  /// No description provided for @behavioralQuestionPerseveration.
  ///
  /// In en, this message translates to:
  /// **'Did you observe any repetitive behaviors or getting stuck on one activity?'**
  String get behavioralQuestionPerseveration;

  /// No description provided for @behavioralLabelPerseveration.
  ///
  /// In en, this message translates to:
  /// **'Perseveration Behavior'**
  String get behavioralLabelPerseveration;

  /// No description provided for @behavioralCategoryPerseveration.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Flexibility'**
  String get behavioralCategoryPerseveration;

  /// No description provided for @behavioralQuestionOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall, how would you rate the child\'s cognitive flexibility and rule-switching abilities?'**
  String get behavioralQuestionOverall;

  /// No description provided for @behavioralLabelOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall Cognitive Flexibility'**
  String get behavioralLabelOverall;

  /// No description provided for @behavioralCategoryOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall Assessment'**
  String get behavioralCategoryOverall;

  /// No description provided for @scaleAttention1.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get scaleAttention1;

  /// No description provided for @scaleAttention2.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get scaleAttention2;

  /// No description provided for @scaleAttention3.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get scaleAttention3;

  /// No description provided for @scaleAttention4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleAttention4;

  /// No description provided for @scaleAttention5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scaleAttention5;

  /// No description provided for @scaleEngagement1.
  ///
  /// In en, this message translates to:
  /// **'Not Engaged'**
  String get scaleEngagement1;

  /// No description provided for @scaleEngagement2.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get scaleEngagement2;

  /// No description provided for @scaleEngagement3.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get scaleEngagement3;

  /// No description provided for @scaleEngagement4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleEngagement4;

  /// No description provided for @scaleEngagement5.
  ///
  /// In en, this message translates to:
  /// **'Very Engaged'**
  String get scaleEngagement5;

  /// No description provided for @scaleFrustration1.
  ///
  /// In en, this message translates to:
  /// **'Very Low'**
  String get scaleFrustration1;

  /// No description provided for @scaleFrustration2.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get scaleFrustration2;

  /// No description provided for @scaleFrustration3.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get scaleFrustration3;

  /// No description provided for @scaleFrustration4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleFrustration4;

  /// No description provided for @scaleFrustration5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scaleFrustration5;

  /// No description provided for @scaleInstructions1.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get scaleInstructions1;

  /// No description provided for @scaleInstructions2.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get scaleInstructions2;

  /// No description provided for @scaleInstructions3.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get scaleInstructions3;

  /// No description provided for @scaleInstructions4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleInstructions4;

  /// No description provided for @scaleInstructions5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scaleInstructions5;

  /// No description provided for @scaleOverall1.
  ///
  /// In en, this message translates to:
  /// **'Concerning'**
  String get scaleOverall1;

  /// No description provided for @scaleOverall2.
  ///
  /// In en, this message translates to:
  /// **'Below Average'**
  String get scaleOverall2;

  /// No description provided for @scaleOverall3.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get scaleOverall3;

  /// No description provided for @scaleOverall4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleOverall4;

  /// No description provided for @scaleOverall5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scaleOverall5;

  /// No description provided for @scaleTask1.
  ///
  /// In en, this message translates to:
  /// **'Not Observed'**
  String get scaleTask1;

  /// No description provided for @scaleTask2.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get scaleTask2;

  /// No description provided for @scaleTask3.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get scaleTask3;

  /// No description provided for @scaleTask4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleTask4;

  /// No description provided for @scaleTask5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scaleTask5;

  /// No description provided for @scaleBehavior1.
  ///
  /// In en, this message translates to:
  /// **'Very Poor'**
  String get scaleBehavior1;

  /// No description provided for @scaleBehavior2.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get scaleBehavior2;

  /// No description provided for @scaleBehavior3.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get scaleBehavior3;

  /// No description provided for @scaleBehavior4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scaleBehavior4;

  /// No description provided for @scaleBehavior5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scaleBehavior5;

  /// No description provided for @pleaseAnswerAll.
  ///
  /// In en, this message translates to:
  /// **'Please answer all questions'**
  String get pleaseAnswerAll;

  /// No description provided for @pleaseCompleteAll.
  ///
  /// In en, this message translates to:
  /// **'Please complete all observations'**
  String get pleaseCompleteAll;

  /// No description provided for @selectDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get selectDateOfBirth;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Please select gender'**
  String get selectGender;

  /// No description provided for @saveChildContinue.
  ///
  /// In en, this message translates to:
  /// **'Save Child & Continue'**
  String get saveChildContinue;

  /// No description provided for @manualTaskInstructions.
  ///
  /// In en, this message translates to:
  /// **'The parent has completed the questionnaire. Now, please perform these manual cognitive flexibility tasks with the child (WITHOUT tablet) and observe their behavior. Focus on rule-switching and cognitive flexibility abilities.'**
  String get manualTaskInstructions;

  /// No description provided for @importantNote.
  ///
  /// In en, this message translates to:
  /// **'Important: Manual Assessment Only'**
  String get importantNote;

  /// No description provided for @importantNoteText.
  ///
  /// In en, this message translates to:
  /// **'This child (ages 2-3.5) did NOT play tablet games. Please use physical objects (blocks, toys, etc.) to assess cognitive flexibility and rule-switching. Observe how the child adapts when rules change.'**
  String get importantNoteText;

  /// No description provided for @taskToPerform.
  ///
  /// In en, this message translates to:
  /// **'Task to Perform:'**
  String get taskToPerform;

  /// No description provided for @submitReflectionResults.
  ///
  /// In en, this message translates to:
  /// **'Submit Reflection & View Results'**
  String get submitReflectionResults;

  /// No description provided for @ageGroup23Display.
  ///
  /// In en, this message translates to:
  /// **'Age Group: 2.0 - 3.4 years'**
  String get ageGroup23Display;

  /// No description provided for @rateBehavior.
  ///
  /// In en, this message translates to:
  /// **'Please rate the child\'s behavior during the game (1=Very Low, 5=Very High):'**
  String get rateBehavior;

  /// No description provided for @rateManualTasks.
  ///
  /// In en, this message translates to:
  /// **'Manual Task Observations (1=Very Low, 5=Very High):'**
  String get rateManualTasks;

  /// No description provided for @rateBehavioral.
  ///
  /// In en, this message translates to:
  /// **'Behavioral Observations (1=Very Low, 5=Very High):'**
  String get rateBehavioral;

  /// No description provided for @veryLow.
  ///
  /// In en, this message translates to:
  /// **'1 (Very Low)'**
  String get veryLow;

  /// No description provided for @veryHigh.
  ///
  /// In en, this message translates to:
  /// **'5 (Very High)'**
  String get veryHigh;

  /// No description provided for @moderateScale.
  ///
  /// In en, this message translates to:
  /// **'3 (Moderate)'**
  String get moderateScale;

  /// No description provided for @childShowsTypical.
  ///
  /// In en, this message translates to:
  /// **'Child shows typical developmental patterns for their age.'**
  String get childShowsTypical;

  /// No description provided for @continueMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Continue regular developmental monitoring.'**
  String get continueMonitoring;

  /// No description provided for @someAreasSupport.
  ///
  /// In en, this message translates to:
  /// **'Some developmental areas may benefit from targeted support.'**
  String get someAreasSupport;

  /// No description provided for @followUp36.
  ///
  /// In en, this message translates to:
  /// **'Consider a follow-up assessment in 3-6 months.'**
  String get followUp36;

  /// No description provided for @discussObservations.
  ///
  /// In en, this message translates to:
  /// **'Discuss specific observations with parents/guardians.'**
  String get discussObservations;

  /// No description provided for @multipleConcerns.
  ///
  /// In en, this message translates to:
  /// **'Multiple developmental concerns identified.'**
  String get multipleConcerns;

  /// No description provided for @comprehensiveEvaluation.
  ///
  /// In en, this message translates to:
  /// **'Recommend a comprehensive developmental evaluation by a specialist.'**
  String get comprehensiveEvaluation;

  /// No description provided for @referralSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Consider referral to a developmental pediatrician or child psychologist.'**
  String get referralSpecialist;

  /// No description provided for @assessmentSummary.
  ///
  /// In en, this message translates to:
  /// **'Assessment Summary'**
  String get assessmentSummary;

  /// No description provided for @autismRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Autism Risk Level:'**
  String get autismRiskLevel;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score:'**
  String get score;

  /// No description provided for @parentQuestionnaireResults.
  ///
  /// In en, this message translates to:
  /// **'Parent Questionnaire Results'**
  String get parentQuestionnaireResults;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @percentageScore.
  ///
  /// In en, this message translates to:
  /// **'Percentage Score'**
  String get percentageScore;

  /// No description provided for @riskScore.
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get riskScore;

  /// No description provided for @categoryScores.
  ///
  /// In en, this message translates to:
  /// **'Category Scores:'**
  String get categoryScores;

  /// No description provided for @frogJumpGameMetrics.
  ///
  /// In en, this message translates to:
  /// **'Frog Jump Game Metrics'**
  String get frogJumpGameMetrics;

  /// No description provided for @colorShapeGameMetrics.
  ///
  /// In en, this message translates to:
  /// **'Color-Shape Game Metrics'**
  String get colorShapeGameMetrics;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @avgReactionTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. Reaction Time'**
  String get avgReactionTime;

  /// No description provided for @totalTrials.
  ///
  /// In en, this message translates to:
  /// **'Total Trials'**
  String get totalTrials;

  /// No description provided for @correctTrials.
  ///
  /// In en, this message translates to:
  /// **'Correct Trials'**
  String get correctTrials;

  /// No description provided for @switchCost.
  ///
  /// In en, this message translates to:
  /// **'Switch Cost'**
  String get switchCost;

  /// No description provided for @perseverativeErrors.
  ///
  /// In en, this message translates to:
  /// **'Perseverative Errors'**
  String get perseverativeErrors;

  /// No description provided for @completionTime.
  ///
  /// In en, this message translates to:
  /// **'Completion Time'**
  String get completionTime;

  /// No description provided for @clinicianObservations.
  ///
  /// In en, this message translates to:
  /// **'Clinician Observations'**
  String get clinicianObservations;

  /// No description provided for @manualTaskScoresAvg.
  ///
  /// In en, this message translates to:
  /// **'Manual Task Scores (Avg):'**
  String get manualTaskScoresAvg;

  /// No description provided for @behavioralObservationScoresAvg.
  ///
  /// In en, this message translates to:
  /// **'Behavioral Observation Scores (Avg):'**
  String get behavioralObservationScoresAvg;

  /// No description provided for @avgManualTaskScore.
  ///
  /// In en, this message translates to:
  /// **'Avg. Manual Task Score'**
  String get avgManualTaskScore;

  /// No description provided for @avgBehavioralScore.
  ///
  /// In en, this message translates to:
  /// **'Avg. Behavioral Score'**
  String get avgBehavioralScore;

  /// No description provided for @attentionLevel.
  ///
  /// In en, this message translates to:
  /// **'Attention Level'**
  String get attentionLevel;

  /// No description provided for @engagementLevel.
  ///
  /// In en, this message translates to:
  /// **'Engagement Level'**
  String get engagementLevel;

  /// No description provided for @frustrationTolerance.
  ///
  /// In en, this message translates to:
  /// **'Frustration Tolerance'**
  String get frustrationTolerance;

  /// No description provided for @followingInstructions.
  ///
  /// In en, this message translates to:
  /// **'Following Instructions'**
  String get followingInstructions;

  /// No description provided for @overallBehavior.
  ///
  /// In en, this message translates to:
  /// **'Overall Behavior'**
  String get overallBehavior;

  /// No description provided for @furtherObservation.
  ///
  /// In en, this message translates to:
  /// **'Further observation recommended for {category} skills.'**
  String furtherObservation(Object category);

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'PIN is required'**
  String get pinRequired;

  /// No description provided for @pinMinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN must be at least 4 digits'**
  String get pinMinLength;

  /// No description provided for @pinsNotMatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match'**
  String get pinsNotMatch;

  /// No description provided for @hospitalRequired.
  ///
  /// In en, this message translates to:
  /// **'Hospital name is required'**
  String get hospitalRequired;

  /// No description provided for @registerContinue.
  ///
  /// In en, this message translates to:
  /// **'REGISTER & CONTINUE'**
  String get registerContinue;

  /// No description provided for @clinicianName.
  ///
  /// In en, this message translates to:
  /// **'Clinician Name'**
  String get clinicianName;

  /// No description provided for @hospitalName.
  ///
  /// In en, this message translates to:
  /// **'Hospital Name'**
  String get hospitalName;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @confirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPin;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @notRegistered.
  ///
  /// In en, this message translates to:
  /// **'Not registered yet?'**
  String get notRegistered;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered?'**
  String get alreadyRegistered;

  /// No description provided for @switchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Switch to Login'**
  String get switchToLogin;

  /// No description provided for @switchToRegister.
  ///
  /// In en, this message translates to:
  /// **'Switch to Register'**
  String get switchToRegister;

  /// No description provided for @senseaiBot.
  ///
  /// In en, this message translates to:
  /// **'SenseAI Bot'**
  String get senseaiBot;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @assessmentComponents.
  ///
  /// In en, this message translates to:
  /// **'Assessment Components'**
  String get assessmentComponents;

  /// No description provided for @rrb.
  ///
  /// In en, this message translates to:
  /// **'RRB'**
  String get rrb;

  /// No description provided for @restrictedRepetitive.
  ///
  /// In en, this message translates to:
  /// **'Restricted & Repetitive'**
  String get restrictedRepetitive;

  /// No description provided for @auditoryChecking.
  ///
  /// In en, this message translates to:
  /// **'Auditory Checking'**
  String get auditoryChecking;

  /// No description provided for @soundProcessing.
  ///
  /// In en, this message translates to:
  /// **'Sound Processing'**
  String get soundProcessing;

  /// No description provided for @visualChecking.
  ///
  /// In en, this message translates to:
  /// **'Visual Checking'**
  String get visualChecking;

  /// No description provided for @visualProcessing.
  ///
  /// In en, this message translates to:
  /// **'Visual Processing'**
  String get visualProcessing;

  /// No description provided for @viewReports.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReports;

  /// No description provided for @rrbComingSoon.
  ///
  /// In en, this message translates to:
  /// **'RRB Component - Coming Soon'**
  String get rrbComingSoon;

  /// No description provided for @auditoryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Auditory Checking - Coming Soon'**
  String get auditoryComingSoon;

  /// No description provided for @visualComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Visual Checking - Coming Soon'**
  String get visualComingSoon;

  /// No description provided for @viewReportsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'View Reports - Coming Soon'**
  String get viewReportsComingSoon;

  /// No description provided for @systemInformation.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInformation;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @pilotMode.
  ///
  /// In en, this message translates to:
  /// **'Pilot Mode'**
  String get pilotMode;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @offlineFirst.
  ///
  /// In en, this message translates to:
  /// **'Offline First'**
  String get offlineFirst;

  /// No description provided for @assessChildrenInfo.
  ///
  /// In en, this message translates to:
  /// **'Assess children aged 2-6 years for cognitive flexibility and rule-switching abilities'**
  String get assessChildrenInfo;

  /// No description provided for @noChildrenFound.
  ///
  /// In en, this message translates to:
  /// **'No children found matching \"{query}\"'**
  String noChildrenFound(Object query);

  /// No description provided for @senseaiDashboard.
  ///
  /// In en, this message translates to:
  /// **'SenseAI Dashboard'**
  String get senseaiDashboard;

  /// No description provided for @addNewChild.
  ///
  /// In en, this message translates to:
  /// **'Add New Child'**
  String get addNewChild;

  /// No description provided for @refreshed.
  ///
  /// In en, this message translates to:
  /// **'Refreshed'**
  String get refreshed;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @gameTitle.
  ///
  /// In en, this message translates to:
  /// **'Flower Game'**
  String get gameTitle;

  /// No description provided for @gameInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap COLOR or SHAPE.'**
  String get gameInstructions;

  /// No description provided for @gameInstructionsSimple.
  ///
  /// In en, this message translates to:
  /// **'Tap COLOR or SHAPE.'**
  String get gameInstructionsSimple;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get selectLanguage;

  /// No description provided for @colorButton.
  ///
  /// In en, this message translates to:
  /// **'COLOR'**
  String get colorButton;

  /// No description provided for @shapeButton.
  ///
  /// In en, this message translates to:
  /// **'SHAPE'**
  String get shapeButton;

  /// No description provided for @currentRule.
  ///
  /// In en, this message translates to:
  /// **'Rule'**
  String get currentRule;

  /// No description provided for @tapColorForPink.
  ///
  /// In en, this message translates to:
  /// **'Tap COLOR!'**
  String get tapColorForPink;

  /// No description provided for @tapShapeForRound.
  ///
  /// In en, this message translates to:
  /// **'Tap SHAPE!'**
  String get tapShapeForRound;

  /// No description provided for @greatJob.
  ///
  /// In en, this message translates to:
  /// **'Good!'**
  String get greatJob;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again!'**
  String get tryAgain;

  /// No description provided for @gameComplete.
  ///
  /// In en, this message translates to:
  /// **'Done!'**
  String get gameComplete;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Good!'**
  String get wellDone;

  /// No description provided for @frogJumpGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Frog Jump Game!'**
  String get frogJumpGameTitle;

  /// No description provided for @frogJumpGameInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap the HAPPY frogs when you see them! 😊'**
  String get frogJumpGameInstructions;

  /// No description provided for @tapMe.
  ///
  /// In en, this message translates to:
  /// **'✅ TAP the happy frog!'**
  String get tapMe;

  /// No description provided for @dontTap.
  ///
  /// In en, this message translates to:
  /// **'❌ DON\'T tap sleepy turtle!'**
  String get dontTap;

  /// No description provided for @getReady.
  ///
  /// In en, this message translates to:
  /// **'Get Ready!'**
  String get getReady;

  /// No description provided for @tapHappyFrog.
  ///
  /// In en, this message translates to:
  /// **'Tap the Happy Frog! 🐸'**
  String get tapHappyFrog;

  /// No description provided for @dontTapSleepyTurtle.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Tap! It\'s Sleepy! 🐢'**
  String get dontTapSleepyTurtle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @backendConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Backend configuration'**
  String get backendConfiguration;

  /// No description provided for @backendUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend URL'**
  String get backendUrl;

  /// No description provided for @backendHelper.
  ///
  /// In en, this message translates to:
  /// **'Use your laptop IP from ipconfig (Wi-Fi adapter) for real devices.'**
  String get backendHelper;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing...'**
  String get testing;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @resetToDefault.
  ///
  /// In en, this message translates to:
  /// **'Reset to default'**
  String get resetToDefault;

  /// No description provided for @networkChecklist.
  ///
  /// In en, this message translates to:
  /// **'Network checklist'**
  String get networkChecklist;

  /// No description provided for @networkTipSameWifi.
  ///
  /// In en, this message translates to:
  /// **'Laptop and tablet must be on the same Wi-Fi network.'**
  String get networkTipSameWifi;

  /// No description provided for @networkTipBackend.
  ///
  /// In en, this message translates to:
  /// **'Run `npm start` (backend) before opening the app.'**
  String get networkTipBackend;

  /// No description provided for @networkTipBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open http://<your-ip>:3000/health in a mobile browser to verify access.'**
  String get networkTipBrowser;

  /// No description provided for @networkTipFirewall.
  ///
  /// In en, this message translates to:
  /// **'Allow inbound TCP port 3000 in Windows Defender Firewall.'**
  String get networkTipFirewall;

  /// No description provided for @networkTipUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update the URL here whenever your laptop IP changes.'**
  String get networkTipUpdate;

  /// No description provided for @aboutThisBuild.
  ///
  /// In en, this message translates to:
  /// **'About this build'**
  String get aboutThisBuild;

  /// No description provided for @dataMode.
  ///
  /// In en, this message translates to:
  /// **'Data mode'**
  String get dataMode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
