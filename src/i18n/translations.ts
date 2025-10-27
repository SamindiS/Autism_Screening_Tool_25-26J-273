// Multilingual Support for Autism Screening App
// Languages: English, Sinhala (සිංහල), Tamil (தமிழ்)

export type Language = 'en' | 'si' | 'ta';

export interface Translations {
  // Common
  appName: string;
  loading: string;
  cancel: string;
  confirm: string;
  back: string;
  next: string;
  save: string;
  delete: string;
  edit: string;
  close: string;
  
  // Authentication
  auth: {
    login: string;
    register: string;
    email: string;
    password: string;
    username: string;
    fullName: string;
    confirmPassword: string;
    forgotPassword: string;
    loginButton: string;
    registerButton: string;
    alreadyHaveAccount: string;
    dontHaveAccount: string;
    loginSuccess: string;
    loginError: string;
    registerSuccess: string;
    logout: string;
    logoutConfirm: string;
  };
  
  // Dashboard
  dashboard: {
    welcome: string;
    mainTitle: string;
    cognitiveFlexibility: string;
    socialCommunication: string;
    repetitiveBehaviors: string;
    sensoryProcessing: string;
    assessmentsToday: string;
    childrenRegistered: string;
    completionRate: string;
    viewReports: string;
    startAssessment: string;
    comingSoon: string;
  };
  
  // Child Management
  child: {
    addChild: string;
    childName: string;
    age: string;
    gender: string;
    male: string;
    female: string;
    other: string;
    dateOfBirth: string;
    guardianName: string;
    contactNumber: string;
    diagnosis: string;
    noChildren: string;
    registerChild: string;
    childRegistered: string;
    childrenList: string;
    selectChild: string;
  };
  
  // Assessment
  assessment: {
    startAssessment: string;
    selectAssessment: string;
    recommendedForAge: string;
    duration: string;
    trials: string;
    questions: string;
    startButton: string;
    backButton: string;
    nextButton: string;
    completeButton: string;
    practiceMode: string;
    realMode: string;
    progress: string;
  };
  
  // AI Doctor Bot
  aiBot: {
    title: string;
    subtitle: string;
    greeting: string;
    questionPrefix: string;
    answerPrompt: string;
    thankYou: string;
    processing: string;
    completed: string;
    
    // Question categories
    categories: {
      socialResponsiveness: string;
      cognitiveFlexibility: string;
      jointAttention: string;
      socialCommunication: string;
      sensoryProcessing: string;
      socialLearning: string;
      socialInteraction: string;
      communication: string;
    };
    
    // Questions (Ages 2-3)
    questions: {
      q1: string;
      q2: string;
      q3: string;
      q4: string;
      q5: string;
      q6: string;
      q7: string;
      q8: string;
      q9: string;
      q10: string;
    };
    
    // Answer options
    options: {
      always: string;
      usually: string;
      sometimes: string;
      rarely: string;
      never: string;
      adaptsEasily: string;
      needsTime: string;
      showsDistress: string;
      veryUpset: string;
      cannotAdapt: string;
    };
  };
  
  // Games
  games: {
    frogJump: {
      title: string;
      instructions: string;
      tapHappy: string;
      dontTapSleepy: string;
      ready: string;
      go: string;
      correct: string;
      wrong: string;
      greatJob: string;
      tryAgain: string;
      practiceTime: string;
      letsPlay: string;
      hearInstructions: string;
    };
    
    ruleSwitch: {
      title: string;
      instructions: string;
      colorRule: string;
      shapeRule: string;
      matchByColor: string;
      matchByShape: string;
      newRule: string;
      switchAnnouncement: string;
      blue: string;
      red: string;
      star: string;
      heart: string;
    };
  };
  
  // Results
  results: {
    title: string;
    sessionComplete: string;
    score: string;
    accuracy: string;
    reactionTime: string;
    switchCost: string;
    riskScore: string;
    riskLevel: string;
    low: string;
    moderate: string;
    high: string;
    recommendations: string;
    saveReport: string;
    exportPDF: string;
    viewHistory: string;
    backToDashboard: string;
    excellentPerformance: string;
    goodEffort: string;
    needsAttention: string;
  };
  
  // Settings
  settings: {
    title: string;
    language: string;
    selectLanguage: string;
    english: string;
    sinhala: string;
    tamil: string;
    notifications: string;
    darkMode: string;
    profile: string;
    about: string;
    version: string;
    support: string;
    privacyPolicy: string;
    termsOfService: string;
  };
  
  // Notifications
  notifications: {
    assessmentCompleted: string;
    childAdded: string;
    reportReady: string;
    reminderTitle: string;
    reminderMessage: string;
  };
  
  // Errors
  errors: {
    networkError: string;
    invalidInput: string;
    required: string;
    ageRange: string;
    emailInvalid: string;
    passwordMismatch: string;
    loginFailed: string;
    saveFailed: string;
    loadFailed: string;
    permissionDenied: string;
  };
}

export const translations: Record<Language, Translations> = {
  // ENGLISH
  en: {
    appName: 'Autism Screening Tool',
    loading: 'Loading...',
    cancel: 'Cancel',
    confirm: 'Confirm',
    back: 'Back',
    next: 'Next',
    save: 'Save',
    delete: 'Delete',
    edit: 'Edit',
    close: 'Close',
    
    auth: {
      login: 'Login',
      register: 'Register',
      email: 'Email Address',
      password: 'Password',
      username: 'Username',
      fullName: 'Full Name',
      confirmPassword: 'Confirm Password',
      forgotPassword: 'Forgot Password?',
      loginButton: 'Sign In',
      registerButton: 'Create Account',
      alreadyHaveAccount: 'Already have an account?',
      dontHaveAccount: "Don't have an account?",
      loginSuccess: 'Login successful!',
      loginError: 'Invalid credentials',
      registerSuccess: 'Registration successful!',
      logout: 'Logout',
      logoutConfirm: 'Are you sure you want to logout?',
    },
    
    dashboard: {
      welcome: 'Welcome',
      mainTitle: 'Autism Screening Dashboard',
      cognitiveFlexibility: 'Cognitive Flexibility',
      socialCommunication: 'Social Communication',
      repetitiveBehaviors: 'Repetitive Behaviors',
      sensoryProcessing: 'Sensory Processing',
      assessmentsToday: 'Assessments Today',
      childrenRegistered: 'Children Registered',
      completionRate: 'Completion Rate',
      viewReports: 'View Reports',
      startAssessment: 'Start Assessment',
      comingSoon: 'Coming Soon',
    },
    
    child: {
      addChild: 'Add Child',
      childName: 'Child Name',
      age: 'Age',
      gender: 'Gender',
      male: 'Male',
      female: 'Female',
      other: 'Other',
      dateOfBirth: 'Date of Birth',
      guardianName: 'Guardian Name',
      contactNumber: 'Contact Number',
      diagnosis: 'Diagnosis',
      noChildren: 'No children registered yet',
      registerChild: 'Register New Child',
      childRegistered: 'Child registered successfully!',
      childrenList: 'Children List',
      selectChild: 'Select a child to start assessment',
    },
    
    assessment: {
      startAssessment: 'Start Assessment',
      selectAssessment: 'Select Assessment Type',
      recommendedForAge: 'Recommended for this age',
      duration: 'Duration',
      trials: 'Trials',
      questions: 'Questions',
      startButton: 'Start',
      backButton: 'Back',
      nextButton: 'Next',
      completeButton: 'Complete',
      practiceMode: 'Practice Mode',
      realMode: 'Real Assessment',
      progress: 'Progress',
    },
    
    aiBot: {
      title: 'AI Doctor Assistant',
      subtitle: 'Parent Interview',
      greeting: 'Hello! I will ask you some questions about your child. Please answer honestly.',
      questionPrefix: 'Question',
      answerPrompt: 'Please select an answer',
      thankYou: 'Thank you for your responses!',
      processing: 'Processing your answers...',
      completed: 'Assessment completed!',
      
      categories: {
        socialResponsiveness: 'Social Responsiveness',
        cognitiveFlexibility: 'Cognitive Flexibility',
        jointAttention: 'Joint Attention',
        socialCommunication: 'Social Communication',
        sensoryProcessing: 'Sensory Processing',
        socialLearning: 'Social Learning',
        socialInteraction: 'Social Interaction',
        communication: 'Communication',
      },
      
      questions: {
        q1: 'Does {childName} respond when you call their name?',
        q2: 'How does {childName} react when their daily routine changes?',
        q3: 'When playing with toys, does {childName} switch between different activities or toys?',
        q4: 'How often does {childName} make eye contact when you talk to them?',
        q5: 'Does {childName} point to objects they want or find interesting?',
        q6: 'How does {childName} react to unexpected sounds or sensory experiences?',
        q7: 'Does {childName} imitate your actions or words?',
        q8: 'How does {childName} play with other children?',
        q9: 'Does {childName} show interest when you show them something?',
        q10: 'How does {childName} express their needs or wants?',
      },
      
      options: {
        always: 'Always responds immediately',
        usually: 'Usually responds',
        sometimes: 'Sometimes responds',
        rarely: 'Rarely responds',
        never: 'Never or almost never responds',
        adaptsEasily: 'Adapts easily to changes',
        needsTime: 'Needs a little time but adapts',
        showsDistress: 'Shows some distress, eventually adapts',
        veryUpset: 'Gets very upset, takes long to adapt',
        cannotAdapt: 'Cannot adapt, extreme distress',
      },
    },
    
    games: {
      frogJump: {
        title: 'Animal Friends Game',
        instructions: 'Tap the HAPPY animals when you see them! Don\'t tap the sleepy ones!',
        tapHappy: 'Tap the Happy Animal!',
        dontTapSleepy: "Don't Tap! It's Sleepy!",
        ready: 'Get Ready!',
        go: 'Go!',
        correct: 'Correct!',
        wrong: 'Try Again!',
        greatJob: 'Great Job!',
        tryAgain: 'Keep Trying!',
        practiceTime: 'Practice Time!',
        letsPlay: "Let's Play!",
        hearInstructions: 'Hear Instructions',
      },
      
      ruleSwitch: {
        title: 'Rule Switch Game',
        instructions: 'Sort cards by following the rules. Listen carefully - the rule will change!',
        colorRule: 'Color Rule',
        shapeRule: 'Shape Rule',
        matchByColor: 'Match by color!',
        matchByShape: 'Match by shape!',
        newRule: 'NEW RULE!',
        switchAnnouncement: 'The rule has changed!',
        blue: 'Blue',
        red: 'Red',
        star: 'Star',
        heart: 'Heart',
      },
    },
    
    results: {
      title: 'Assessment Results',
      sessionComplete: 'Session Complete!',
      score: 'Score',
      accuracy: 'Accuracy',
      reactionTime: 'Reaction Time',
      switchCost: 'Switch Cost',
      riskScore: 'Risk Score',
      riskLevel: 'Risk Level',
      low: 'Low Risk',
      moderate: 'Moderate Risk',
      high: 'High Risk',
      recommendations: 'Recommendations',
      saveReport: 'Save Report',
      exportPDF: 'Export PDF',
      viewHistory: 'View History',
      backToDashboard: 'Back to Dashboard',
      excellentPerformance: 'Excellent performance!',
      goodEffort: 'Good effort!',
      needsAttention: 'May need further assessment',
    },
    
    settings: {
      title: 'Settings',
      language: 'Language',
      selectLanguage: 'Select Language',
      english: 'English',
      sinhala: 'සිංහල (Sinhala)',
      tamil: 'தமிழ் (Tamil)',
      notifications: 'Notifications',
      darkMode: 'Dark Mode',
      profile: 'Profile',
      about: 'About',
      version: 'Version',
      support: 'Support',
      privacyPolicy: 'Privacy Policy',
      termsOfService: 'Terms of Service',
    },
    
    notifications: {
      assessmentCompleted: 'Assessment completed successfully!',
      childAdded: 'Child added to system',
      reportReady: 'Report is ready to view',
      reminderTitle: 'Assessment Reminder',
      reminderMessage: 'Time for scheduled assessment',
    },
    
    errors: {
      networkError: 'Network connection error',
      invalidInput: 'Invalid input',
      required: 'This field is required',
      ageRange: 'Age must be between 2 and 6 years',
      emailInvalid: 'Invalid email address',
      passwordMismatch: 'Passwords do not match',
      loginFailed: 'Login failed. Please check your credentials.',
      saveFailed: 'Failed to save data',
      loadFailed: 'Failed to load data',
      permissionDenied: 'Permission denied',
    },
  },
  
  // SINHALA (සිංහල)
  si: {
    appName: 'ඔටිසම් තීරණ මෙවලම',
    loading: 'පූරණය වෙමින්...',
    cancel: 'අවලංගු කරන්න',
    confirm: 'තහවුරු කරන්න',
    back: 'ආපසු',
    next: 'ඊළඟ',
    save: 'සුරකින්න',
    delete: 'මකන්න',
    edit: 'සංස්කරණය',
    close: 'වසන්න',
    
    auth: {
      login: 'ඇතුළු වන්න',
      register: 'ලියාපදිංචි වන්න',
      email: 'විද්‍යුත් තැපැල් ලිපිනය',
      password: 'මුරපදය',
      username: 'පරිශීලක නාමය',
      fullName: 'සම්පූර්ණ නම',
      confirmPassword: 'මුරපදය තහවුරු කරන්න',
      forgotPassword: 'මුරපදය අමතක වුණාද?',
      loginButton: 'පුරන්න',
      registerButton: 'ගිණුමක් සාදන්න',
      alreadyHaveAccount: 'දැනටමත් ගිණුමක් තිබේද?',
      dontHaveAccount: 'ගිණුමක් නැද්ද?',
      loginSuccess: 'ඇතුල් වීම සාර්ථකයි!',
      loginError: 'වලංගු නොවන අක්තපත්‍ර',
      registerSuccess: 'ලියාපදිංචිය සාර්ථකයි!',
      logout: 'ඉවත් වන්න',
      logoutConfirm: 'ඔබට ඉවත් වීමට අවශ්‍යද?',
    },
    
    dashboard: {
      welcome: 'ආයුබෝවන්',
      mainTitle: 'ඔටිසම් පරීක්ෂණ උපකරණ පුවරුව',
      cognitiveFlexibility: 'සංජානන නම්‍යශීලිත්වය',
      socialCommunication: 'සමාජ සන්නිවේදනය',
      repetitiveBehaviors: 'පුනරාවර්තන හැසිරීම්',
      sensoryProcessing: 'සංවේදී සැකසුම',
      assessmentsToday: 'අද තක්සේරු',
      childrenRegistered: 'ලියාපදිංචි දරුවන්',
      completionRate: 'සම්පූර්ණ කිරීමේ අනුපාතය',
      viewReports: 'වාර්තා බලන්න',
      startAssessment: 'තක්සේරුව ආරම්භ කරන්න',
      comingSoon: 'ඉක්මනින් එනවා',
    },
    
    child: {
      addChild: 'දරුවෙකු එක් කරන්න',
      childName: 'දරුවාගේ නම',
      age: 'වයස',
      gender: 'ස්ත්‍රී පුරුෂ භාවය',
      male: 'පිරිමි',
      female: 'ගැහැණු',
      other: 'වෙනත්',
      dateOfBirth: 'උපන් දිනය',
      guardianName: 'භාරකරුගේ නම',
      contactNumber: 'සම්බන්ධතා අංකය',
      diagnosis: 'රෝග විනිශ්චය',
      noChildren: 'තවමත් දරුවන් ලියාපදිංචි කර නැත',
      registerChild: 'නව දරුවෙකු ලියාපදිංචි කරන්න',
      childRegistered: 'දරුවා සාර්ථකව ලියාපදිංචි විය!',
      childrenList: 'දරුවන්ගේ ලැයිස්තුව',
      selectChild: 'තක්සේරුව ආරම්භ කිරීමට දරුවෙකු තෝරන්න',
    },
    
    assessment: {
      startAssessment: 'තක්සේරුව ආරම්භ කරන්න',
      selectAssessment: 'තක්සේරු වර්ගය තෝරන්න',
      recommendedForAge: 'මෙම වයස සඳහා නිර්දේශිතයි',
      duration: 'කාලසීමාව',
      trials: 'අත්හදා බැලීම්',
      questions: 'ප්‍රශ්න',
      startButton: 'ආරම්භ කරන්න',
      backButton: 'ආපසු',
      nextButton: 'ඊළඟ',
      completeButton: 'සම්පූර්ණ කරන්න',
      practiceMode: 'පුහුණු මාදිලිය',
      realMode: 'සැබෑ තක්සේරුව',
      progress: 'ප්‍රගතිය',
    },
    
    aiBot: {
      title: 'AI වෛද්‍ය සහායක',
      subtitle: 'දෙමාපිය සම්මුඛ පරීක්ෂණය',
      greeting: 'ආයුබෝවන්! මම ඔබේ දරුවා ගැන ප්‍රශ්න කිහිපයක් අහනවා. කරුණාකර අවංකව පිළිතුරු දෙන්න.',
      questionPrefix: 'ප්‍රශ්නය',
      answerPrompt: 'කරුණාකර පිළිතුරක් තෝරන්න',
      thankYou: 'ඔබේ ප්‍රතිචාර සඳහා ස්තූතියි!',
      processing: 'ඔබේ පිළිතුරු සකසමින්...',
      completed: 'තක්සේරුව සම්පූර්ණයි!',
      
      categories: {
        socialResponsiveness: 'සමාජ ප්‍රතිචාරය',
        cognitiveFlexibility: 'සංජානන නම්‍යශීලිත්වය',
        jointAttention: 'ඒකාබද්ධ අවධානය',
        socialCommunication: 'සමාජ සන්නිවේදනය',
        sensoryProcessing: 'සංවේදී සැකසුම',
        socialLearning: 'සමාජ ඉගෙනීම',
        socialInteraction: 'සමාජ අන්තර්ක්‍රියා',
        communication: 'සන්නිවේදනය',
      },
      
      questions: {
        q1: 'ඔබ {childName}ගේ නම කියනකොට ඔහු/ඇය ප්‍රතිචාර දක්වනවාද?',
        q2: '{childName}ගේ දෛනික චර්යාව වෙනස් වන විට ඔහු/ඇය ප්‍රතික්‍රියා කරන්නේ කෙසේද?',
        q3: 'සෙල්ලම් බඩු සමඟ සෙල්ලම් කරන විට, {childName} විවිධ ක්‍රියාකාරකම් හෝ සෙල්ලම් බඩු අතර මාරු වනවාද?',
        q4: 'ඔබ ඔවුන් සමඟ කතා කරන විට {childName} කොපමණ වාරයක් ඇස් සම්බන්ධතාවයක් ඇති කරනවාද?',
        q5: '{childName} ඔවුන්ට අවශ්‍ය හෝ රසවත් යැයි සිතන වස්තූන් පෙන්වනවාද?',
        q6: 'අනපේක්ෂිත ශබ්ද හෝ සංවේදී අත්දැකීම් වලට {childName} ප්‍රතික්‍රියා කරන්නේ කෙසේද?',
        q7: '{childName} ඔබේ ක්‍රියා හෝ වචන අනුකරණය කරනවාද?',
        q8: '{childName} අනෙකුත් දරුවන් සමඟ සෙල්ලම් කරන්නේ කෙසේද?',
        q9: 'ඔබ ඔවුන්ට යමක් පෙන්වන විට {childName} උනන්දුවක් දක්වනවාද?',
        q10: '{childName} ඔවුන්ගේ අවශ්‍යතා හෝ අවශ්‍යතා ප්‍රකාශ කරන්නේ කෙසේද?',
      },
      
      options: {
        always: 'සෑම විටම වහාම ප්‍රතිචාර දක්වයි',
        usually: 'සාමාන්‍යයෙන් ප්‍රතිචාර දක්වයි',
        sometimes: 'සමහර විට ප්‍රතිචාර දක්වයි',
        rarely: 'කලාතුරකින් ප්‍රතිචාර දක්වයි',
        never: 'කිසිවිටෙක හෝ පාහේ කිසිවිටෙක ප්‍රතිචාර නොදක්වයි',
        adaptsEasily: 'වෙනස්කම් වලට පහසුවෙන් අනුගත වෙයි',
        needsTime: 'ටිකක් කාලය අවශ්‍ය නමුත් අනුගත වෙයි',
        showsDistress: 'යම් දුකක් පෙන්වයි, අවසානයේ අනුගත වෙයි',
        veryUpset: 'ඉතා කලබල වෙයි, අනුගත වීමට බොහෝ කාලයක් ගතවෙයි',
        cannotAdapt: 'අනුගත විය නොහැකියි, අතිශය දුක',
      },
    },
    
    games: {
      frogJump: {
        title: 'සත්ව මිතුරන් ක්‍රීඩාව',
        instructions: 'ඔබට සතුටු සතුන් පෙනෙන විට ඔවුන් ටැප් කරන්න! නිදිමත් ඒවා ටැප් නොකරන්න!',
        tapHappy: 'සතුටු සතා ටැප් කරන්න!',
        dontTapSleepy: 'ටැප් නොකරන්න! එය නිදිමතයි!',
        ready: 'සූදානම්!',
        go: 'යන්න!',
        correct: 'නිවැරදියි!',
        wrong: 'නැවත උත්සාහ කරන්න!',
        greatJob: 'නියමයි!',
        tryAgain: 'දිගටම උත්සාහ කරන්න!',
        practiceTime: 'පුහුණු වේලාව!',
        letsPlay: 'සෙල්ලම් කරමු!',
        hearInstructions: 'උපදෙස් අසන්න',
      },
      
      ruleSwitch: {
        title: 'රීති මාරු ක්‍රීඩාව',
        instructions: 'රීති අනුගමනය කරමින් කාඩ්පත් වර්ග කරන්න. ප්‍රවේශමෙන් අසන්න - රීතිය වෙනස් වේ!',
        colorRule: 'වර්ණ රීතිය',
        shapeRule: 'හැඩ රීතිය',
        matchByColor: 'වර්ණයෙන් ගැලපේ!',
        matchByShape: 'හැඩයෙන් ගැලපේ!',
        newRule: 'නව රීතියක්!',
        switchAnnouncement: 'රීතිය වෙනස් වී ඇත!',
        blue: 'නිල්',
        red: 'රතු',
        star: 'තරුව',
        heart: 'හදවත',
      },
    },
    
    results: {
      title: 'තක්සේරු ප්‍රතිඵල',
      sessionComplete: 'සැසිය සම්පූර්ණයි!',
      score: 'ලකුණු',
      accuracy: 'නිරවද්‍යතාවය',
      reactionTime: 'ප්‍රතික්‍රියා කාලය',
      switchCost: 'මාරු වියදම',
      riskScore: 'අවදානම් ලකුණු',
      riskLevel: 'අවදානම් මට්ටම',
      low: 'අඩු අවදානම',
      moderate: 'මධ්‍යම අවදානම',
      high: 'ඉහළ අවදානම',
      recommendations: 'නිර්දේශ',
      saveReport: 'වාර්තාව සුරකින්න',
      exportPDF: 'PDF අපනයනය',
      viewHistory: 'ඉතිහාසය බලන්න',
      backToDashboard: 'උපකරණ පුවරුවට ආපසු',
      excellentPerformance: 'විශිෂ්ට කාර්ය සාධනයක්!',
      goodEffort: 'හොඳ උත්සාහයක්!',
      needsAttention: 'තවදුරටත් තක්සේරුවක් අවශ්‍ය විය හැක',
    },
    
    settings: {
      title: 'සැකසුම්',
      language: 'භාෂාව',
      selectLanguage: 'භාෂාව තෝරන්න',
      english: 'English (ඉංග්‍රීසි)',
      sinhala: 'සිංහල',
      tamil: 'தமிழ் (දෙමළ)',
      notifications: 'දැනුම්දීම්',
      darkMode: 'අඳුරු මාදිලිය',
      profile: 'පැතිකඩ',
      about: 'ගැන',
      version: 'අනුවාදය',
      support: 'සහාය',
      privacyPolicy: 'රහස්‍යතා ප්‍රතිපත්තිය',
      termsOfService: 'සේවා කොන්දේසි',
    },
    
    notifications: {
      assessmentCompleted: 'තක්සේරුව සාර්ථකව සම්පූර්ණ කරන ලදී!',
      childAdded: 'දරුවා පද්ධතියට එකතු කරන ලදී',
      reportReady: 'වාර්තාව බැලීමට සූදානම්',
      reminderTitle: 'තක්සේරු මතක් කිරීම',
      reminderMessage: 'සැලසුම් කළ තක්සේරුවේ කාලයයි',
    },
    
    errors: {
      networkError: 'ජාල සම්බන්ධතා දෝෂය',
      invalidInput: 'වැරදි ආදානය',
      required: 'මෙම ක්ෂේත්‍රය අවශ්‍යයි',
      ageRange: 'වයස අවුරුදු 2 සහ 6 අතර විය යුතුයි',
      emailInvalid: 'වලංගු නොවන විද්‍යුත් තැපැල් ලිපිනය',
      passwordMismatch: 'මුරපද නොගැලපේ',
      loginFailed: 'පිවිසීම අසාර්ථකයි. කරුණාකර ඔබේ අක්තපත්‍ර පරීක්ෂා කරන්න.',
      saveFailed: 'දත්ත සුරැකීමට අපොහොසත් විය',
      loadFailed: 'දත්ත පූරණය කිරීමට අපොහොසත් විය',
      permissionDenied: 'අවසරය ප්‍රතික්ෂේප විය',
    },
  },
  
  // TAMIL (தமிழ்)
  ta: {
    appName: 'மன இறுக்க சோதனை கருவி',
    loading: 'ஏற்றுகிறது...',
    cancel: 'ரத்து செய்',
    confirm: 'உறுதிப்படுத்து',
    back: 'பின்',
    next: 'அடுத்து',
    save: 'சேமி',
    delete: 'நீக்கு',
    edit: 'திருத்து',
    close: 'மூடு',
    
    auth: {
      login: 'உள்நுழை',
      register: 'பதிவு',
      email: 'மின்னஞ்சல் முகவரி',
      password: 'கடவுச்சொல்',
      username: 'பயனர் பெயர்',
      fullName: 'முழு பெயர்',
      confirmPassword: 'கடவுச்சொல்லை உறுதிப்படுத்து',
      forgotPassword: 'கடவுச்சொல்லை மறந்துவிட்டீர்களா?',
      loginButton: 'உள்நுழை',
      registerButton: 'கணக்கை உருவாக்கு',
      alreadyHaveAccount: 'ஏற்கனவே கணக்கு உள்ளதா?',
      dontHaveAccount: 'கணக்கு இல்லையா?',
      loginSuccess: 'உள்நுழைவு வெற்றிகரமாக!',
      loginError: 'தவறான சான்றுகள்',
      registerSuccess: 'பதிவு வெற்றிகரமாக!',
      logout: 'வெளியேறு',
      logoutConfirm: 'நீங்கள் வெளியேற விரும்புகிறீர்களா?',
    },
    
    dashboard: {
      welcome: 'வரவேற்கிறோம்',
      mainTitle: 'மன இறுக்க சோதனை டாஷ்போர்டு',
      cognitiveFlexibility: 'அறிவாற்றல் நெகிழ்வுத்தன்மை',
      socialCommunication: 'சமூக தொடர்பு',
      repetitiveBehaviors: 'மீண்டும் மீண்டும் நடத்தைகள்',
      sensoryProcessing: 'உணர்வு செயலாக்கம்',
      assessmentsToday: 'இன்றைய மதிப்பீடுகள்',
      childrenRegistered: 'பதிவு செய்யப்பட்ட குழந்தைகள்',
      completionRate: 'முடிப்பு விகிதம்',
      viewReports: 'அறிக்கைகளைக் காண்க',
      startAssessment: 'மதிப்பீட்டைத் தொடங்கு',
      comingSoon: 'விரைவில் வருகிறது',
    },
    
    child: {
      addChild: 'குழந்தையைச் சேர்க்கவும்',
      childName: 'குழந்தையின் பெயர்',
      age: 'வயது',
      gender: 'பாலினம்',
      male: 'ஆண்',
      female: 'பெண்',
      other: 'மற்றவை',
      dateOfBirth: 'பிறந்த தேதி',
      guardianName: 'பாதுகாவலரின் பெயர்',
      contactNumber: 'தொடர்பு எண்',
      diagnosis: 'நோய் கண்டறிதல்',
      noChildren: 'இதுவரை குழந்தைகள் பதிவு செய்யப்படவில்லை',
      registerChild: 'புதிய குழந்தையைப் பதிவு செய்',
      childRegistered: 'குழந்தை வெற்றிகரமாக பதிவு செய்யப்பட்டது!',
      childrenList: 'குழந்தைகள் பட்டியல்',
      selectChild: 'மதிப்பீட்டைத் தொடங்க ஒரு குழந்தையைத் தேர்ந்தெடுக்கவும்',
    },
    
    assessment: {
      startAssessment: 'மதிப்பீட்டைத் தொடங்கு',
      selectAssessment: 'மதிப்பீட்டு வகையைத் தேர்ந்தெடு',
      recommendedForAge: 'இந்த வயதுக்கு பரிந்துரைக்கப்படுகிறது',
      duration: 'காலம்',
      trials: 'சோதனைகள்',
      questions: 'கேள்விகள்',
      startButton: 'தொடங்கு',
      backButton: 'பின்',
      nextButton: 'அடுத்து',
      completeButton: 'முடி',
      practiceMode: 'பயிற்சி பயன்முறை',
      realMode: 'உண்மையான மதிப்பீடு',
      progress: 'முன்னேற்றம்',
    },
    
    aiBot: {
      title: 'AI மருத்துவ உதவியாளர்',
      subtitle: 'பெற்றோர் நேர்காணல்',
      greeting: 'வணக்கம்! உங்கள் குழந்தையைப் பற்றி நான் சில கேள்விகளைக் கேட்கிறேன். தயவுசெய்து நேர்மையாக பதிலளிக்கவும்.',
      questionPrefix: 'கேள்வி',
      answerPrompt: 'தயவுசெய்து ஒரு பதிலைத் தேர்ந்தெடுக்கவும்',
      thankYou: 'உங்கள் பதில்களுக்கு நன்றி!',
      processing: 'உங்கள் பதில்களை செயலாக்குகிறது...',
      completed: 'மதிப்பீடு முடிந்தது!',
      
      categories: {
        socialResponsiveness: 'சமூக பதிலளிப்பு',
        cognitiveFlexibility: 'அறிவாற்றல் நெகிழ்வுத்தன்மை',
        jointAttention: 'கூட்டு கவனம்',
        socialCommunication: 'சமூக தொடர்பு',
        sensoryProcessing: 'உணர்வு செயலாக்கம்',
        socialLearning: 'சமூக கற்றல்',
        socialInteraction: 'சமூக தொடர்பு',
        communication: 'தொடர்பு',
      },
      
      questions: {
        q1: 'நீங்கள் {childName} இன் பெயரை அழைக்கும்போது அவர்/அவள் பதிலளிக்கிறார்களா?',
        q2: '{childName} இன் தினசரி வழக்கம் மாறும்போது அவர்/அவள் எவ்வாறு எதிர்வினையாற்றுகிறார்கள்?',
        q3: 'பொம்மைகளுடன் விளையாடும்போது, {childName} வெவ்வேறு செயல்பாடுகள் அல்லது பொம்மைகளுக்கு இடையில் மாறுகிறார்களா?',
        q4: 'நீங்கள் அவர்களுடன் பேசும்போது {childName} எத்தனை முறை கண் தொடர்பு ஏற்படுத்துகிறார்கள்?',
        q5: '{childName} அவர்கள் விரும்பும் அல்லது சுவாரஸ்யமாகக் காணும் பொருட்களை சுட்டிக்காட்டுகிறார்களா?',
        q6: 'எதிர்பாராத ஒலிகள் அல்லது உணர்வு அனுபவங்களுக்கு {childName} எவ்வாறு எதிர்வினையாற்றுகிறார்கள்?',
        q7: '{childName} உங்கள் செயல்கள் அல்லது வார்த்தைகளை பின்பற்றுகிறார்களா?',
        q8: '{childName} மற்ற குழந்தைகளுடன் எவ்வாறு விளையாடுகிறார்கள்?',
        q9: 'நீங்கள் அவர்களுக்கு ஏதாவது காட்டும்போது {childName} ஆர்வம் காட்டுகிறார்களா?',
        q10: '{childName} தங்கள் தேவைகள் அல்லது விருப்பங்களை எவ்வாறு வெளிப்படுத்துகிறார்கள்?',
      },
      
      options: {
        always: 'எப்போதும் உடனடியாக பதிலளிக்கிறார்கள்',
        usually: 'பொதுவாக பதிலளிக்கிறார்கள்',
        sometimes: 'சில நேரங்களில் பதிலளிக்கிறார்கள்',
        rarely: 'அரிதாக பதிலளிக்கிறார்கள்',
        never: 'ஒருபோதும் அல்லது கிட்டத்தட்ட ஒருபோதும் பதிலளிப்பதில்லை',
        adaptsEasily: 'மாற்றங்களுக்கு எளிதில் தகவமைக்கிறார்கள்',
        needsTime: 'சிறிது நேரம் தேவை ஆனால் தகவமைக்கிறார்கள்',
        showsDistress: 'சில துயரத்தைக் காட்டுகிறார்கள், இறுதியில் தகவமைக்கிறார்கள்',
        veryUpset: 'மிகவும் வருத்தமடைகிறார்கள், தகவமைக்க நீண்ட நேரம் எடுக்கிறது',
        cannotAdapt: 'தகவமைக்க முடியாது, தீவிர துயரம்',
      },
    },
    
    games: {
      frogJump: {
        title: 'விலங்கு நண்பர்கள் விளையாட்டு',
        instructions: 'மகிழ்ச்சியான விலங்குகளைக் கண்டால் அவற்றைத் தொடவும்! தூங்குபவைகளை தொடாதீர்கள்!',
        tapHappy: 'மகிழ்ச்சியான விலங்கை தொடவும்!',
        dontTapSleepy: 'தொடாதீர்கள்! அது தூங்குகிறது!',
        ready: 'தயாராகுங்கள்!',
        go: 'செல்!',
        correct: 'சரி!',
        wrong: 'மீண்டும் முயற்சிக்கவும்!',
        greatJob: 'அருமை!',
        tryAgain: 'தொடர்ந்து முயற்சிக்கவும்!',
        practiceTime: 'பயிற்சி நேரம்!',
        letsPlay: 'விளையாடுவோம்!',
        hearInstructions: 'வழிமுறைகளைக் கேளுங்கள்',
      },
      
      ruleSwitch: {
        title: 'விதி மாற்று விளையாட்டு',
        instructions: 'விதிகளைப் பின்பற்றி அட்டைகளை வரிசைப்படுத்துங்கள். கவனமாகக் கேளுங்கள் - விதி மாறும்!',
        colorRule: 'நிற விதி',
        shapeRule: 'வடிவ விதி',
        matchByColor: 'நிறத்தால் பொருத்துங்கள்!',
        matchByShape: 'வடிவத்தால் பொருத்துங்கள்!',
        newRule: 'புதிய விதி!',
        switchAnnouncement: 'விதி மாறிவிட்டது!',
        blue: 'நீலம்',
        red: 'சிவப்பு',
        star: 'நட்சத்திரம்',
        heart: 'இதயம்',
      },
    },
    
    results: {
      title: 'மதிப்பீட்டு முடிவுகள்',
      sessionComplete: 'அமர்வு முடிந்தது!',
      score: 'மதிப்பெண்',
      accuracy: 'துல்லியம்',
      reactionTime: 'எதிர்வினை நேரம்',
      switchCost: 'மாற்று செலவு',
      riskScore: 'ஆபத்து மதிப்பெண்',
      riskLevel: 'ஆபத்து நிலை',
      low: 'குறைந்த ஆபத்து',
      moderate: 'மிதமான ஆபத்து',
      high: 'அதிக ஆபத்து',
      recommendations: 'பரிந்துரைகள்',
      saveReport: 'அறிக்கையைச் சேமிக்கவும்',
      exportPDF: 'PDF ஏற்றுமதி',
      viewHistory: 'வரலாற்றைக் காண்க',
      backToDashboard: 'டாஷ்போர்டுக்குத் திரும்பு',
      excellentPerformance: 'சிறந்த செயல்திறன்!',
      goodEffort: 'நல்ல முயற்சி!',
      needsAttention: 'மேலும் மதிப்பீடு தேவைப்படலாம்',
    },
    
    settings: {
      title: 'அமைப்புகள்',
      language: 'மொழி',
      selectLanguage: 'மொழியைத் தேர்ந்தெடு',
      english: 'English (ஆங்கிலம்)',
      sinhala: 'සිංහල (சிங்களம்)',
      tamil: 'தமிழ்',
      notifications: 'அறிவிப்புகள்',
      darkMode: 'இருண்ட பயன்முறை',
      profile: 'சுயவிவரம்',
      about: 'பற்றி',
      version: 'பதிப்பு',
      support: 'ஆதரவு',
      privacyPolicy: 'தனியுரிமை கொள்கை',
      termsOfService: 'சேவை விதிமுறைகள்',
    },
    
    notifications: {
      assessmentCompleted: 'மதிப்பீடு வெற்றிகரமாக முடிந்தது!',
      childAdded: 'குழந்தை அமைப்பில் சேர்க்கப்பட்டது',
      reportReady: 'அறிக்கை பார்க்க தயாராக உள்ளது',
      reminderTitle: 'மதிப்பீட்டு நினைவூட்டல்',
      reminderMessage: 'திட்டமிடப்பட்ட மதிப்பீட்டிற்கான நேரம்',
    },
    
    errors: {
      networkError: 'பிணைய இணைப்பு பிழை',
      invalidInput: 'தவறான உள்ளீடு',
      required: 'இந்த புலம் தேவை',
      ageRange: 'வயது 2 மற்றும் 6 வயதுக்கு இடையில் இருக்க வேண்டும்',
      emailInvalid: 'தவறான மின்னஞ்சல் முகவரி',
      passwordMismatch: 'கடவுச்சொற்கள் பொருந்தவில்லை',
      loginFailed: 'உள்நுழைவு தோல்வியுற்றது. உங்கள் சான்றுகளைச் சரிபார்க்கவும்.',
      saveFailed: 'தரவை சேமிக்க முடியவில்லை',
      loadFailed: 'தரவை ஏற்ற முடியவில்லை',
      permissionDenied: 'அனுமதி மறுக்கப்பட்டது',
    },
  },
};

// Helper function to get translations for a language
export const getTranslations = (language: Language): Translations => {
  return translations[language] || translations.en;
};

// Helper function to replace placeholders in text
export const replacePlaceholders = (
  text: string,
  replacements: Record<string, string>
): string => {
  let result = text;
  Object.keys(replacements).forEach((key) => {
    result = result.replace(`{${key}}`, replacements[key]);
  });
  return result;
};

