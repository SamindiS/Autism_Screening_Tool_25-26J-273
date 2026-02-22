// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SenseAI';

  @override
  String get welcome => 'Welcome';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get cognitiveFlexibility => 'Cognitive Flexibility';

  @override
  String get ruleSwitching => 'Rule Switching Assessment';

  @override
  String get addChild => 'Add Child';

  @override
  String get viewAll => 'View All';

  @override
  String get recentChildren => 'Recent Children';

  @override
  String get totalChildren => 'Total Children';

  @override
  String get completed => 'Completed';

  @override
  String get pending => 'Pending';

  @override
  String get today => 'Today';

  @override
  String get statistics => 'Statistics';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get searchChildren => 'Search children by name...';

  @override
  String get noChildren => 'No children added yet';

  @override
  String get addFirstChild => 'Add your first child to start assessments';

  @override
  String get childName => 'Child Name';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get language => 'Language';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get other => 'Other';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get tamil => 'Tamil';

  @override
  String get age => 'Age';

  @override
  String get years => 'years';

  @override
  String get months => 'months';

  @override
  String get selectAge => 'Select Age';

  @override
  String get enterAge => 'Enter Child Age';

  @override
  String get ageRange => 'Age must be between 2.0 and 6.0 years';

  @override
  String get startAssessment => 'START ASSESSMENT';

  @override
  String get ageGroups => 'Age Groups';

  @override
  String get ageGroup23 => '2.0 - 3.4 years';

  @override
  String get ageGroup35 => '3.5 - 5.5 years';

  @override
  String get ageGroup56 => '5.6 - 6.0 years';

  @override
  String get assessment23 => 'Parent Interview Bot';

  @override
  String get assessment35 => 'Frog Jump Game (Go/No-Go)';

  @override
  String get assessment56 => 'Color-Shape Game (DCCS)';

  @override
  String get aiDoctorBot => 'AI Doctor Bot';

  @override
  String get question => 'Question';

  @override
  String get ofText => 'of';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get submit => 'Submit';

  @override
  String get results => 'Results';

  @override
  String get assessmentResults => 'Assessment Results';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get low => 'Low';

  @override
  String get moderate => 'Moderate';

  @override
  String get high => 'High';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get exportPdf => 'Export as PDF Report';

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get clinicianReflection => 'Clinician Reflection';

  @override
  String get clinicianProfile => 'Clinician Profile';

  @override
  String get clinicianReflection23 => 'Clinician Reflection (2-3.5 yrs)';

  @override
  String get manualTasks => 'Manual Cognitive Flexibility Tasks';

  @override
  String get behavioralObservations => 'Behavioral Observations';

  @override
  String get refresh => 'Refresh';

  @override
  String get noResults => 'No children found';

  @override
  String get tryDifferentSearch => 'Try a different search term';

  @override
  String get lastAssessment => 'Last assessment';

  @override
  String get completedSessions => 'completed';

  @override
  String get pendingSession => 'Pending';

  @override
  String get todayText => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get daysAgo => 'days ago';

  @override
  String aiQuestion1(String childName) {
    return 'Does $childName respond when you call their name?';
  }

  @override
  String get aiCategory1 => 'Social Responsiveness';

  @override
  String get aiQuestion1Option1 => 'Always responds immediately';

  @override
  String get aiQuestion1Option2 => 'Usually responds';

  @override
  String get aiQuestion1Option3 => 'Sometimes responds';

  @override
  String get aiQuestion1Option4 => 'Rarely responds';

  @override
  String get aiQuestion1Option5 => 'Never or almost never responds';

  @override
  String aiQuestion2(Object childName) {
    return 'How does $childName react when their daily routine changes?';
  }

  @override
  String get aiCategory2 => 'Cognitive Flexibility';

  @override
  String get aiQuestion2Option1 => 'Adapts easily to changes';

  @override
  String get aiQuestion2Option2 => 'Needs a little time but adapts';

  @override
  String get aiQuestion2Option3 => 'Shows some distress, eventually adapts';

  @override
  String get aiQuestion2Option4 => 'Gets very upset, takes long to adapt';

  @override
  String get aiQuestion2Option5 => 'Cannot adapt, extreme distress';

  @override
  String aiQuestion3(Object childName) {
    return 'When playing with toys, does $childName switch between different activities or toys?';
  }

  @override
  String get aiCategory3 => 'Cognitive Flexibility';

  @override
  String get aiQuestion3Option1 => 'Easily switches between toys/activities';

  @override
  String get aiQuestion3Option2 => 'Switches with gentle prompting';

  @override
  String get aiQuestion3Option3 => 'Switches but shows reluctance';

  @override
  String get aiQuestion3Option4 => 'Very difficult to get them to switch';

  @override
  String get aiQuestion3Option5 => 'Refuses to switch, fixates on one toy';

  @override
  String aiQuestion4(Object childName) {
    return 'How often does $childName make eye contact when you talk to them?';
  }

  @override
  String get aiCategory4 => 'Social Communication';

  @override
  String get aiQuestion4Option1 => 'Always makes good eye contact';

  @override
  String get aiQuestion4Option2 => 'Usually makes eye contact';

  @override
  String get aiQuestion4Option3 => 'Sometimes makes eye contact';

  @override
  String get aiQuestion4Option4 => 'Rarely makes eye contact';

  @override
  String get aiQuestion4Option5 => 'Avoids eye contact completely';

  @override
  String aiQuestion5(Object childName) {
    return 'Does $childName point to objects they want or find interesting?';
  }

  @override
  String get aiCategory5 => 'Joint Attention';

  @override
  String get aiQuestion5Option1 => 'Frequently points and shares interest';

  @override
  String get aiQuestion5Option2 => 'Often points to things';

  @override
  String get aiQuestion5Option3 => 'Occasionally points';

  @override
  String get aiQuestion5Option4 => 'Rarely points';

  @override
  String get aiQuestion5Option5 => 'Never or almost never points';

  @override
  String aiQuestion6(Object childName) {
    return 'How does $childName react to unexpected sounds or sensory experiences?';
  }

  @override
  String get aiCategory6 => 'Sensory Processing';

  @override
  String get aiQuestion6Option1 => 'Reacts appropriately, recovers quickly';

  @override
  String get aiQuestion6Option2 => 'Startles but calms down soon';

  @override
  String get aiQuestion6Option3 => 'Gets upset, needs comfort';

  @override
  String get aiQuestion6Option4 => 'Very distressed, takes long to calm';

  @override
  String get aiQuestion6Option5 => 'Extreme distress or complete shutdown';

  @override
  String aiQuestion7(Object childName) {
    return 'Does $childName imitate your actions or words?';
  }

  @override
  String get aiCategory7 => 'Social Learning';

  @override
  String get aiQuestion7Option1 => 'Frequently imitates spontaneously';

  @override
  String get aiQuestion7Option2 => 'Often imitates when prompted';

  @override
  String get aiQuestion7Option3 => 'Imitates some simple actions';

  @override
  String get aiQuestion7Option4 => 'Rarely imitates';

  @override
  String get aiQuestion7Option5 => 'Never or almost never imitates';

  @override
  String aiQuestion8(Object childName) {
    return 'How does $childName play with other children?';
  }

  @override
  String get aiCategory8 => 'Social Interaction';

  @override
  String get aiQuestion8Option1 => 'Actively engages and shares';

  @override
  String get aiQuestion8Option2 => 'Plays near others, some interaction';

  @override
  String get aiQuestion8Option3 => 'Parallel play, minimal interaction';

  @override
  String get aiQuestion8Option4 => 'Prefers solitary play, avoids others';

  @override
  String get aiQuestion8Option5 => 'No interest in other children';

  @override
  String aiQuestion9(Object childName) {
    return 'Does $childName show interest when you show them something?';
  }

  @override
  String get aiCategory9 => 'Joint Attention';

  @override
  String get aiQuestion9Option1 => 'Always looks and shows interest';

  @override
  String get aiQuestion9Option2 => 'Usually looks when you point';

  @override
  String get aiQuestion9Option3 => 'Sometimes follows your gaze/point';

  @override
  String get aiQuestion9Option4 => 'Rarely follows your attention';

  @override
  String get aiQuestion9Option5 => 'Never follows your gaze or point';

  @override
  String aiQuestion10(Object childName) {
    return 'How does $childName express their needs or wants?';
  }

  @override
  String get aiCategory10 => 'Communication';

  @override
  String get aiQuestion10Option1 => 'Uses words and gestures clearly';

  @override
  String get aiQuestion10Option2 => 'Uses gestures and some words';

  @override
  String get aiQuestion10Option3 => 'Mostly gestures, few words';

  @override
  String get aiQuestion10Option4 => 'Pulls you to objects, little gesture';

  @override
  String get aiQuestion10Option5 => 'Cries or tantrums, no clear communication';

  @override
  String get reflectionQuestionAttention =>
      'How well did the child maintain attention during the game?';

  @override
  String get reflectionLabelAttention => 'Attention Level';

  @override
  String get reflectionQuestionEngagement =>
      'How engaged was the child with the game activities?';

  @override
  String get reflectionLabelEngagement => 'Engagement Level';

  @override
  String get reflectionQuestionFrustration =>
      'How did the child handle frustration or mistakes?';

  @override
  String get reflectionLabelFrustration => 'Frustration Tolerance';

  @override
  String get reflectionQuestionInstructions =>
      'How well did the child follow game instructions?';

  @override
  String get reflectionLabelInstructions => 'Following Instructions';

  @override
  String get reflectionQuestionOverall =>
      'Overall, how would you rate the child\'s behavior during assessment?';

  @override
  String get reflectionLabelOverall => 'Overall Behavior';

  @override
  String get manualTask1Title => 'Rule Switching Task - Color/Shape';

  @override
  String get manualTask1Description =>
      'Did the child switch between sorting by color and shape?';

  @override
  String get manualTask1Label => 'Rule Switching Ability';

  @override
  String get manualTask1Task =>
      'Give child blocks of different colors and shapes. First ask to sort by COLOR, then switch to SHAPE. Observe if child can switch rules.';

  @override
  String get manualTask1Category => 'Cognitive Flexibility';

  @override
  String get manualTask2Title => 'Follow Changing Instructions';

  @override
  String get manualTask2Description =>
      'Did the child adapt when instructions changed?';

  @override
  String get manualTask2Label => 'Instruction Flexibility';

  @override
  String get manualTask2Task =>
      'Give child simple instructions that change (e.g., \"Put the red block here\" then \"Now put the blue block there\"). Observe adaptation.';

  @override
  String get manualTask2Category => 'Cognitive Flexibility';

  @override
  String get manualTask3Title => 'Inhibition Task - Go/No-Go';

  @override
  String get manualTask3Description =>
      'Did the child inhibit responses when told not to?';

  @override
  String get manualTask3Label => 'Response Inhibition';

  @override
  String get manualTask3Task =>
      'Play a simple game: \"When I say GO, clap. When I say STOP, don\'t clap.\" Observe if child can inhibit clapping on STOP.';

  @override
  String get manualTask3Category => 'Inhibition Control';

  @override
  String get manualTask4Title => 'Perseveration Observation';

  @override
  String get manualTask4Description =>
      'Did the child get stuck on one activity or rule?';

  @override
  String get manualTask4Label => 'Perseveration';

  @override
  String get manualTask4Task =>
      'After switching rules, observe if child continues with old rule (perseveration) or adapts to new rule.';

  @override
  String get manualTask4Category => 'Cognitive Flexibility';

  @override
  String get manualTask5Title => 'Task Switching - Play Activities';

  @override
  String get manualTask5Description =>
      'How well did the child switch between different play activities?';

  @override
  String get manualTask5Label => 'Activity Switching';

  @override
  String get manualTask5Task =>
      'Have child play with blocks, then ask to switch to drawing, then to toy. Observe ease of switching between activities.';

  @override
  String get manualTask5Category => 'Cognitive Flexibility';

  @override
  String get behavioralQuestionRuleSwitching =>
      'How well did the child demonstrate cognitive flexibility during rule-switching tasks?';

  @override
  String get behavioralLabelRuleSwitching => 'Cognitive Flexibility';

  @override
  String get behavioralCategoryRuleSwitching => 'Cognitive Flexibility';

  @override
  String get behavioralQuestionAttention =>
      'How well did the child maintain attention during the manual tasks?';

  @override
  String get behavioralLabelAttention => 'Attention Level';

  @override
  String get behavioralCategoryAttention => 'Attention';

  @override
  String get behavioralQuestionFrustration =>
      'How did the child handle frustration when tasks became difficult or rules changed?';

  @override
  String get behavioralLabelFrustration => 'Frustration Tolerance';

  @override
  String get behavioralCategoryFrustration => 'Emotional Regulation';

  @override
  String get behavioralQuestionPerseveration =>
      'Did you observe any repetitive behaviors or getting stuck on one activity?';

  @override
  String get behavioralLabelPerseveration => 'Perseveration Behavior';

  @override
  String get behavioralCategoryPerseveration => 'Cognitive Flexibility';

  @override
  String get behavioralQuestionOverall =>
      'Overall, how would you rate the child\'s cognitive flexibility and rule-switching abilities?';

  @override
  String get behavioralLabelOverall => 'Overall Cognitive Flexibility';

  @override
  String get behavioralCategoryOverall => 'Overall Assessment';

  @override
  String get scaleAttention1 => 'Very Poor';

  @override
  String get scaleAttention2 => 'Poor';

  @override
  String get scaleAttention3 => 'Average';

  @override
  String get scaleAttention4 => 'Good';

  @override
  String get scaleAttention5 => 'Excellent';

  @override
  String get scaleEngagement1 => 'Not Engaged';

  @override
  String get scaleEngagement2 => 'Minimal';

  @override
  String get scaleEngagement3 => 'Moderate';

  @override
  String get scaleEngagement4 => 'Good';

  @override
  String get scaleEngagement5 => 'Very Engaged';

  @override
  String get scaleFrustration1 => 'Very Low';

  @override
  String get scaleFrustration2 => 'Low';

  @override
  String get scaleFrustration3 => 'Moderate';

  @override
  String get scaleFrustration4 => 'Good';

  @override
  String get scaleFrustration5 => 'Excellent';

  @override
  String get scaleInstructions1 => 'Very Poor';

  @override
  String get scaleInstructions2 => 'Poor';

  @override
  String get scaleInstructions3 => 'Average';

  @override
  String get scaleInstructions4 => 'Good';

  @override
  String get scaleInstructions5 => 'Excellent';

  @override
  String get scaleOverall1 => 'Concerning';

  @override
  String get scaleOverall2 => 'Below Average';

  @override
  String get scaleOverall3 => 'Average';

  @override
  String get scaleOverall4 => 'Good';

  @override
  String get scaleOverall5 => 'Excellent';

  @override
  String get scaleTask1 => 'Not Observed';

  @override
  String get scaleTask2 => 'Poor';

  @override
  String get scaleTask3 => 'Fair';

  @override
  String get scaleTask4 => 'Good';

  @override
  String get scaleTask5 => 'Excellent';

  @override
  String get scaleBehavior1 => 'Very Poor';

  @override
  String get scaleBehavior2 => 'Poor';

  @override
  String get scaleBehavior3 => 'Average';

  @override
  String get scaleBehavior4 => 'Good';

  @override
  String get scaleBehavior5 => 'Excellent';

  @override
  String get pleaseAnswerAll => 'Please answer all questions';

  @override
  String get pleaseCompleteAll => 'Please complete all observations';

  @override
  String get selectDateOfBirth => 'Please select date of birth';

  @override
  String get selectGender => 'Please select gender';

  @override
  String get saveChildContinue => 'Save Child & Continue';

  @override
  String get manualTaskInstructions =>
      'The parent has completed the questionnaire. Now, please perform these manual cognitive flexibility tasks with the child (WITHOUT tablet) and observe their behavior. Focus on rule-switching and cognitive flexibility abilities.';

  @override
  String get importantNote => 'Important: Manual Assessment Only';

  @override
  String get importantNoteText =>
      'This child (ages 2-3.5) did NOT play tablet games. Please use physical objects (blocks, toys, etc.) to assess cognitive flexibility and rule-switching. Observe how the child adapts when rules change.';

  @override
  String get taskToPerform => 'Task to Perform:';

  @override
  String get submitReflectionResults => 'Submit Reflection & View Results';

  @override
  String get ageGroup23Display => 'Age Group: 2.0 - 3.4 years';

  @override
  String get rateBehavior =>
      'Please rate the child\'s behavior during the game (1=Very Low, 5=Very High):';

  @override
  String get rateManualTasks =>
      'Manual Task Observations (1=Very Low, 5=Very High):';

  @override
  String get rateBehavioral =>
      'Behavioral Observations (1=Very Low, 5=Very High):';

  @override
  String get veryLow => '1 (Very Low)';

  @override
  String get veryHigh => '5 (Very High)';

  @override
  String get moderateScale => '3 (Moderate)';

  @override
  String get childShowsTypical =>
      'Child shows typical developmental patterns for their age.';

  @override
  String get continueMonitoring => 'Continue regular developmental monitoring.';

  @override
  String get someAreasSupport =>
      'Some developmental areas may benefit from targeted support.';

  @override
  String get followUp36 => 'Consider a follow-up assessment in 3-6 months.';

  @override
  String get discussObservations =>
      'Discuss specific observations with parents/guardians.';

  @override
  String get multipleConcerns => 'Multiple developmental concerns identified.';

  @override
  String get comprehensiveEvaluation =>
      'Recommend a comprehensive developmental evaluation by a specialist.';

  @override
  String get referralSpecialist =>
      'Consider referral to a developmental pediatrician or child psychologist.';

  @override
  String get assessmentSummary => 'Assessment Summary';

  @override
  String get autismRiskLevel => 'Autism Risk Level:';

  @override
  String get score => 'Score:';

  @override
  String get parentQuestionnaireResults => 'Parent Questionnaire Results';

  @override
  String get totalScore => 'Total Score';

  @override
  String get percentageScore => 'Percentage Score';

  @override
  String get riskScore => 'Risk Score';

  @override
  String get categoryScores => 'Category Scores:';

  @override
  String get frogJumpGameMetrics => 'Frog Jump Game Metrics';

  @override
  String get colorShapeGameMetrics => 'Color-Shape Game Metrics';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get avgReactionTime => 'Avg. Reaction Time';

  @override
  String get totalTrials => 'Total Trials';

  @override
  String get correctTrials => 'Correct Trials';

  @override
  String get switchCost => 'Switch Cost';

  @override
  String get perseverativeErrors => 'Perseverative Errors';

  @override
  String get completionTime => 'Completion Time';

  @override
  String get clinicianObservations => 'Clinician Observations';

  @override
  String get manualTaskScoresAvg => 'Manual Task Scores (Avg):';

  @override
  String get behavioralObservationScoresAvg =>
      'Behavioral Observation Scores (Avg):';

  @override
  String get avgManualTaskScore => 'Avg. Manual Task Score';

  @override
  String get avgBehavioralScore => 'Avg. Behavioral Score';

  @override
  String get attentionLevel => 'Attention Level';

  @override
  String get engagementLevel => 'Engagement Level';

  @override
  String get frustrationTolerance => 'Frustration Tolerance';

  @override
  String get followingInstructions => 'Following Instructions';

  @override
  String get overallBehavior => 'Overall Behavior';

  @override
  String furtherObservation(Object category) {
    return 'Further observation recommended for $category skills.';
  }

  @override
  String get nameRequired => 'Name is required';

  @override
  String get pinRequired => 'PIN is required';

  @override
  String get pinMinLength => 'PIN must be at least 4 digits';

  @override
  String get pinsNotMatch => 'PINs do not match';

  @override
  String get hospitalRequired => 'Hospital name is required';

  @override
  String get registerContinue => 'REGISTER & CONTINUE';

  @override
  String get clinicianName => 'Clinician Name';

  @override
  String get hospitalName => 'Hospital Name';

  @override
  String get pin => 'PIN';

  @override
  String get confirmPin => 'Confirm PIN';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPin => 'Forgot PIN?';

  @override
  String get notRegistered => 'Not registered yet?';

  @override
  String get alreadyRegistered => 'Already registered?';

  @override
  String get switchToLogin => 'Switch to Login';

  @override
  String get switchToRegister => 'Switch to Register';

  @override
  String get senseaiBot => 'SenseAI Bot';

  @override
  String get loading => 'Loading...';

  @override
  String get errorLoading => 'Error loading data';

  @override
  String get noData => 'No data available';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSure => 'Are you sure?';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get assessmentComponents => 'Assessment Components';

  @override
  String get rrb => 'RRB';

  @override
  String get restrictedRepetitive => 'Restricted & Repetitive';

  @override
  String get auditoryChecking => 'Auditory Checking';

  @override
  String get soundProcessing => 'Sound Processing';

  @override
  String get visualChecking => 'Visual Checking';

  @override
  String get visualProcessing => 'Visual Processing';

  @override
  String get viewReports => 'View Reports';

  @override
  String get rrbComingSoon => 'RRB Component - Coming Soon';

  @override
  String get auditoryComingSoon => 'Auditory Checking - Coming Soon';

  @override
  String get visualComingSoon => 'Visual Checking - Coming Soon';

  @override
  String get viewReportsComingSoon => 'View Reports - Coming Soon';

  @override
  String get systemInformation => 'System Information';

  @override
  String get version => 'Version';

  @override
  String get status => 'Status';

  @override
  String get pilotMode => 'Pilot Mode';

  @override
  String get mode => 'Mode';

  @override
  String get offlineFirst => 'Offline First';

  @override
  String get assessChildrenInfo =>
      'Assess children aged 2-6 years for cognitive flexibility and rule-switching abilities';

  @override
  String noChildrenFound(Object query) {
    return 'No children found matching \"$query\"';
  }

  @override
  String get senseaiDashboard => 'SenseAI Dashboard';

  @override
  String get addNewChild => 'Add New Child';

  @override
  String get refreshed => 'Refreshed';

  @override
  String get error => 'Error';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get gameTitle => 'Flower Game';

  @override
  String get gameInstructions => 'Tap COLOR or SHAPE.';

  @override
  String get gameInstructionsSimple => 'Tap COLOR or SHAPE.';

  @override
  String get selectLanguage => 'Choose Language';

  @override
  String get colorButton => 'COLOR';

  @override
  String get shapeButton => 'SHAPE';

  @override
  String get currentRule => 'Rule';

  @override
  String get tapColorForPink => 'Tap COLOR!';

  @override
  String get tapShapeForRound => 'Tap SHAPE!';

  @override
  String get greatJob => 'Good!';

  @override
  String get tryAgain => 'Try again!';

  @override
  String get gameComplete => 'Done!';

  @override
  String get wellDone => 'Good!';

  @override
  String get frogJumpGameTitle => 'Frog Jump Game!';

  @override
  String get frogJumpGameInstructions =>
      'Tap the HAPPY frogs when you see them! 😊';

  @override
  String get tapMe => '✅ TAP the happy frog!';

  @override
  String get dontTap => '❌ DON\'T tap sleepy turtle!';

  @override
  String get getReady => 'Get Ready!';

  @override
  String get tapHappyFrog => 'Tap the Happy Frog! 🐸';

  @override
  String get dontTapSleepyTurtle => 'Don\'t Tap! It\'s Sleepy! 🐢';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get backendConfiguration => 'Backend configuration';

  @override
  String get backendUrl => 'Backend URL';

  @override
  String get backendHelper =>
      'Use your laptop IP from ipconfig (Wi-Fi adapter) for real devices.';

  @override
  String get testing => 'Testing...';

  @override
  String get testConnection => 'Test connection';

  @override
  String get resetToDefault => 'Reset to default';

  @override
  String get networkChecklist => 'Network checklist';

  @override
  String get networkTipSameWifi =>
      'Laptop and tablet must be on the same Wi-Fi network.';

  @override
  String get networkTipBackend =>
      'Run `npm start` (backend) before opening the app.';

  @override
  String get networkTipBrowser =>
      'Open http://<your-ip>:3000/health in a mobile browser to verify access.';

  @override
  String get networkTipFirewall =>
      'Allow inbound TCP port 3000 in Windows Defender Firewall.';

  @override
  String get networkTipUpdate =>
      'Update the URL here whenever your laptop IP changes.';

  @override
  String get aboutThisBuild => 'About this build';

  @override
  String get dataMode => 'Data mode';
}
