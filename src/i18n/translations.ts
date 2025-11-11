// Multilingual Support for Autism Screening App
// Languages: English, Sinhala (සිංහල), Tamil (தமிழ்)

import { ReactNode } from "react";

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
  
  // Common nested object
  common: {
    back: ReactNode;
    ok: string;
    yes: string;
    no: string;
    continue: string;
    skip: string;
    retry: string;
    english: string;
    sinhala: string;
    tamil: string;
  };
  
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
    // New professional login fields
    welcomeBack: string;
    clinicalAccess: string;
    emailPlaceholder: string;
    rememberMe: string;
    authenticating: string;
    quickAccess: string;
    clinician: string;
    hospital: string;
    researcher: string;
    researchCenter: string;
    newUser: string;
    requestAccess: string;
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
    registrationSuccess: string;
    registrationMessage: string;
    childrenList: string;
    selectChild: string;
    ageGroup: string;
    language: string;
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
    questionProgress: string;
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
  
  // Clinician Reflection
  reflection: {
    title: string;
    subtitle: string;
    infoTitle: string;
    infoSubtitle: string;
    infoNote: string;
    skip: string;
    skipWarningTitle: string;
    skipWarningMessage: string;
    skipAnyway: string;
    incompleteTitle: string;
    incompleteMessage: string;
    completeReflection: string;
    answerMore: string;
    answered: string;
    of: string;
    
    // Categories
    categories: {
      attention: string;
      inhibition: string;
      emotionalRegulation: string;
      motivation: string;
      comprehension: string;
      cognitiveFlexibility: string;
      perseveration: string;
      supportRequired: string;
      emotionalResponse: string;
      executiveFunction: string;
    };
    
    // Frog Jump Questions (Ages 3-5)
    frogJump: {
      q1: string; // Attention span
      q2: string; // Impulse control
      q3: string; // Frustration tolerance
      q4: string; // Engagement
      q5: string; // Understanding
    };
    
    // Rule Switch Questions (Ages 5-6)
    ruleSwitch: {
      q1: string; // Rule switch adaptation
      q2: string; // Perseveration
      q3: string; // Prompts needed
      q4: string; // Emotional response
      q5: string; // Mental flexibility
    };
    
    // Option labels (0-4 scale)
    options: {
      excellent: string;
      good: string;
      moderate: string;
      poor: string;
      unable: string;
      
      // Specific options
      excellentFocus: string;
      goodFocus: string;
      moderateFocus: string;
      poorFocus: string;
      unableAttention: string;
      
      excellentControl: string;
      goodControl: string;
      moderateControl: string;
      poorControl: string;
      noControl: string;
      
      stayedCalm: string;
      slightlyUpset: string;
      frustrated: string;
      veryUpset: string;
      couldNotContinue: string;
      
      highlyEngaged: string;
      generallyInterested: string;
      neutralInterest: string;
      lowInterest: string;
      refusedGame: string;
      
      understoodImmediately: string;
      understoodAfterOne: string;
      neededRepeated: string;
      difficultyGrasping: string;
      couldNotUnderstand: string;
      
      switchedImmediately: string;
      switchedQuickly: string;
      neededTime: string;
      struggled: string;
      couldNotAdapt: string;
      
      noOldRule: string;
      rarelyOldRule: string;
      sometimesOldRule: string;
      frequentlyOldRule: string;
      couldNotStop: string;
      
      noReminders: string;
      fewReminders: string;
      severalReminders: string;
      frequentReminders: string;
      constantReminders: string;
      
      excitedAboutChange: string;
      calmAccepted: string;
      slightlyConfused: string;
      upsetNeedReassurance: string;
      veryDistressed: string;
      
      veryFlexible: string;
      generallyFlexible: string;
      somewhatRigid: string;
      quiteRigid: string;
      veryRigid: string;
    };
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
    
    common: {
      ok: 'OK',
      yes: 'Yes',
      no: 'No',
      continue: 'Continue',
      skip: 'Skip',
      retry: 'Retry',
      english: 'English',
      sinhala: 'සිංහල',
      tamil: 'தமிழ்',
      back: undefined
    },
    
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
      // New professional login fields
      welcomeBack: 'Welcome Back',
      clinicalAccess: 'Clinical Portal Access',
      emailPlaceholder: 'your.name@healthcare.org',
      rememberMe: 'Remember Device',
      authenticating: 'Authenticating...',
      quickAccess: 'Quick Clinical Access',
      clinician: 'Clinical Specialist',
      hospital: "Children's Hospital",
      researcher: 'Research Fellow',
      researchCenter: 'Autism Research Center',
      newUser: 'New to SenseAI?',
      requestAccess: 'Request Access',
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
      registrationSuccess: 'Success!',
      registrationMessage: '{name} ({age} years old) has been registered successfully.',
      childrenList: 'Children List',
      selectChild: 'Select a child to start assessment',
      ageGroup: 'Age Group',
      language: 'Language',
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
      questionProgress: 'Question {current} of {total}',
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
    
    reflection: {
      title: 'Clinician Reflection',
      subtitle: 'Post-Assessment Observations',
      infoTitle: 'Clinician Reflection',
      infoSubtitle: 'Based on your observation of {childName} during the assessment, please answer these behavioral questions.',
      infoNote: 'These observations help improve AI accuracy by combining game metrics with real-world behavioral context.',
      skip: 'Skip',
      skipWarningTitle: 'Skip Reflection?',
      skipWarningMessage: 'The game results will be saved, but behavioral observations will be missing. This may reduce ML model accuracy.',
      skipAnyway: 'Skip Anyway',
      incompleteTitle: 'Incomplete',
      incompleteMessage: 'Please answer all questions before submitting.',
      completeReflection: 'Complete Reflection',
      answerMore: 'Answer {count} More',
      answered: 'answered',
      of: 'of',
      
      categories: {
        attention: 'Attention',
        inhibition: 'Inhibition',
        emotionalRegulation: 'Emotional Regulation',
        motivation: 'Motivation',
        comprehension: 'Comprehension',
        cognitiveFlexibility: 'Cognitive Flexibility',
        perseveration: 'Perseveration',
        supportRequired: 'Support Required',
        emotionalResponse: 'Emotional Response',
        executiveFunction: 'Executive Function',
      },
      
      frogJump: {
        q1: 'How well did the child maintain focus during the game?',
        q2: 'How well did the child control impulses (not tapping when turtle appeared)?',
        q3: 'How did the child handle mistakes during the game?',
        q4: 'How engaged was the child with the game?',
        q5: 'How well did the child understand the game instructions?',
      },
      
      ruleSwitch: {
        q1: 'How easily did the child adapt when the rule changed?',
        q2: 'Did the child continue using the old rule after the switch?',
        q3: 'How many reminders did the child need about the rule change?',
        q4: 'How did the child react emotionally to the rule change?',
        q5: 'Overall, how flexible was the child\'s thinking?',
      },
      
      options: {
        excellent: 'Excellent',
        good: 'Good',
        moderate: 'Moderate',
        poor: 'Poor',
        unable: 'Unable',
        
        excellentFocus: 'Excellent focus, no distractions',
        goodFocus: 'Good focus, minor distractions',
        moderateFocus: 'Moderate focus, some wandering',
        poorFocus: 'Poor focus, frequently distracted',
        unableAttention: 'Unable to maintain attention',
        
        excellentControl: 'Excellent control, no impulsive taps',
        goodControl: 'Good control, 1-2 impulse errors',
        moderateControl: 'Moderate control, several errors',
        poorControl: 'Poor control, frequent impulsive taps',
        noControl: 'No impulse control observed',
        
        stayedCalm: 'Stayed calm, continued playing',
        slightlyUpset: 'Slightly upset, recovered quickly',
        frustrated: 'Frustrated, needed encouragement',
        veryUpset: 'Very upset, needed multiple breaks',
        couldNotContinue: 'Could not continue after mistakes',
        
        highlyEngaged: 'Highly engaged, excited to play',
        generallyInterested: 'Generally interested, played willingly',
        neutralInterest: 'Neutral interest, needed prompting',
        lowInterest: 'Low interest, reluctant',
        refusedGame: 'Refused or avoided the game',
        
        understoodImmediately: 'Understood immediately',
        understoodAfterOne: 'Understood after one explanation',
        neededRepeated: 'Needed repeated explanations',
        difficultyGrasping: 'Difficulty grasping instructions',
        couldNotUnderstand: 'Could not understand instructions',
        
        switchedImmediately: 'Switched immediately, no errors',
        switchedQuickly: 'Switched quickly, 1-2 errors',
        neededTime: 'Needed time to adapt, several errors',
        struggled: 'Struggled to switch, many errors',
        couldNotAdapt: 'Could not adapt to new rule',
        
        noOldRule: 'No, immediately used new rule',
        rarelyOldRule: 'Rarely, 1-2 old rule uses',
        sometimesOldRule: 'Sometimes, needed reminders',
        frequentlyOldRule: 'Frequently, hard to break pattern',
        couldNotStop: 'Could not stop using old rule',
        
        noReminders: 'None, remembered independently',
        fewReminders: '1-2 gentle reminders',
        severalReminders: '3-4 reminders throughout',
        frequentReminders: 'Frequent reminders needed',
        constantReminders: 'Constant prompting required',
        
        excitedAboutChange: 'Excited about the change',
        calmAccepted: 'Calm, accepted the change',
        slightlyConfused: 'Slightly confused or frustrated',
        upsetNeedReassurance: 'Upset, needed reassurance',
        veryDistressed: 'Very distressed, wanted to quit',
        
        veryFlexible: 'Very flexible, enjoys variety',
        generallyFlexible: 'Generally flexible',
        somewhatRigid: 'Somewhat rigid, prefers routines',
        quiteRigid: 'Quite rigid, dislikes changes',
        veryRigid: 'Very rigid, cannot adapt',
      },
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
    
    common: {
      ok: 'හරි',
      yes: 'ඔව්',
      no: 'නැහැ',
      continue: 'ඉදිරියට යන්න',
      skip: 'මඟ හරින්න',
      retry: 'නැවත උත්සාහ කරන්න',
      english: 'English',
      sinhala: 'සිංහල',
      tamil: 'தமிழ்',
      back: undefined
    },
    
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
      // New professional login fields
      welcomeBack: 'නැවත පිළිගනිමු',
      clinicalAccess: 'සායනික පෝටල් ප්‍රවේශය',
      emailPlaceholder: 'your.name@healthcare.org',
      rememberMe: 'උපාංගය මතක තබා ගන්න',
      authenticating: 'සත්‍යාපනය කරමින්...',
      quickAccess: 'ඉක්මන් සායනික ප්‍රවේශය',
      clinician: 'සායනික විශේෂඥ',
      hospital: 'ළමා රෝහල',
      researcher: 'පර්යේෂණ සාමාජික',
      researchCenter: 'ස්වයංක්‍රීයත්ව පර්යේෂණ මධ්‍යස්ථානය',
      newUser: 'SenseAI සඳහා අළුත්ද?',
      requestAccess: 'ප්‍රවේශය ඉල්ලන්න',
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
      registrationSuccess: 'සාර්ථකයි!',
      registrationMessage: '{name} (වයස {age}) සාර්ථකව ලියාපදිංචි විය.',
      childrenList: 'දරුවන්ගේ ලැයිස්තුව',
      selectChild: 'තක්සේරුව ආරම්භ කිරීමට දරුවෙකු තෝරන්න',
      ageGroup: 'වයස් කාණ්ඩය',
      language: 'භාෂාව',
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
      questionProgress: 'ප්‍රශ්නය {current} / {total}',
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
    
    reflection: {
      title: 'සායනික නිරීක්ෂණය',
      subtitle: 'තක්සේරුවෙන් පසු නිරීක්ෂණ',
      infoTitle: 'සායනික නිරීක්ෂණය',
      infoSubtitle: 'තක්සේරුව අතරතුර {childName} ගැන ඔබේ නිරීක්ෂණය මත පදනම්ව, කරුණාකර මෙම හැසිරීම් ප්‍රශ්නවලට පිළිතුරු දෙන්න.',
      infoNote: 'මෙම නිරීක්ෂණ ක්‍රීඩා මිනුම් සහ සැබෑ-ලෝක හැසිරීම් සන්දර්භය ඒකාබද්ධ කරමින් AI නිරවද්‍යතාවය වැඩිදියුණු කිරීමට උපකාරී වේ.',
      skip: 'මඟ හරින්න',
      skipWarningTitle: 'නිරීක්ෂණය මඟ හරනවාද?',
      skipWarningMessage: 'ක්‍රීඩා ප්‍රතිඵල සුරකිනු ලැබේ, නමුත් හැසිරීම් නිරීක්ෂණ අස්ථානගත වේ. මෙය ML ආකෘතියේ නිරවද්‍යතාවය අඩු කළ හැක.',
      skipAnyway: 'කෙසේ හෝ මඟ හරින්න',
      incompleteTitle: 'අසම්පූර්ණයි',
      incompleteMessage: 'ඉදිරිපත් කිරීමට පෙර කරුණාකර සියලුම ප්‍රශ්නවලට පිළිතුරු දෙන්න.',
      completeReflection: 'නිරීක්ෂණය සම්පූර්ණ කරන්න',
      answerMore: 'තවත් {count} පිළිතුරු දෙන්න',
      answered: 'පිළිතුරු දුන්',
      of: 'න්',
      
      categories: {
        attention: 'අවධානය',
        inhibition: 'නිෂේධනය',
        emotionalRegulation: 'චිත්තවේගීය නියාමනය',
        motivation: 'අභිප්‍රේරණය',
        comprehension: 'අවබෝධය',
        cognitiveFlexibility: 'සංජානන නම්‍යශීලිත්වය',
        perseveration: 'පුනරාවර්තනය',
        supportRequired: 'අවශ්‍ය සහාය',
        emotionalResponse: 'චිත්තවේගීය ප්‍රතිචාරය',
        executiveFunction: 'විධායක කාර්යය',
      },
      
      frogJump: {
        q1: 'ක්‍රීඩාව අතරතුර දරුවා කෙතරම් හොඳින් අවධානය පවත්වා ගත්තේද?',
        q2: 'දරුවා ආවේගශීලී තට්ටු කිරීම් (කැස්බෑ පෙනෙන විට නොදැමීම) කෙතරම් හොඳින් පාලනය කළාද?',
        q3: 'ක්‍රීඩාව අතරතුර දරුවා වැරදි හැසිරවූයේ කෙසේද?',
        q4: 'ක්‍රීඩාව සමඟ දරුවා කෙතරම් නියැලී සිටියාද?',
        q5: 'ක්‍රීඩා උපදෙස් දරුවා කෙතරම් හොඳින් තේරුම් ගත්තාද?',
      },
      
      ruleSwitch: {
        q1: 'රීතිය වෙනස් වූ විට දරුවා කෙතරම් පහසුවෙන් අනුගත වූයේද?',
        q2: 'මාරුවෙන් පසු දරුවා පැරණි රීතිය දිගටම භාවිතා කළාද?',
        q3: 'රීති වෙනස් කිරීම ගැන දරුවාට කොපමණ සිහිකැඳවීම් අවශ්‍ය වූයේද?',
        q4: 'රීති වෙනස් කිරීමට දරුවා චිත්තවේගීයව ප්‍රතික්‍රියා කළේ කෙසේද?',
        q5: 'සමස්තයක් වශයෙන්, දරුවාගේ චින්තනය කෙතරම් නම්‍යශීලීද?',
      },
      
      options: {
        excellent: 'විශිෂ්ට',
        good: 'හොඳ',
        moderate: 'මධ්‍යස්ථ',
        poor: 'දුර්වල',
        unable: 'නොහැකි',
        
        excellentFocus: 'විශිෂ්ට අවධානය, බාධා නැත',
        goodFocus: 'හොඳ අවධානය, සුළු බාධා',
        moderateFocus: 'මධ්‍යස්ථ අවධානය, යම් සැරිසරීමක්',
        poorFocus: 'දුර්වල අවධානය, නිතර බාධා',
        unableAttention: 'අවධානය පවත්වා ගැනීමට නොහැකි',
        
        excellentControl: 'විශිෂ්ට පාලනය, ආවේගශීලී තට්ටු නැත',
        goodControl: 'හොඳ පාලනය, ආවේග දෝෂ 1-2',
        moderateControl: 'මධ්‍යස්ථ පාලනය, දෝෂ කිහිපයක්',
        poorControl: 'දුර්වල පාලනය, නිතර ආවේගශීලී තට්ටු',
        noControl: 'ආවේග පාලනයක් නිරීක්ෂණය නොවිණි',
        
        stayedCalm: 'සන්සුන්ව සිටියේය, සෙල්ලම දිගටම කළේය',
        slightlyUpset: 'තරමක් කලබල, ඉක්මනින් යථා තත්ත්වයට පැමිණියේය',
        frustrated: 'කලකිරීමට පත්, දිරිදීම අවශ්‍ය විය',
        veryUpset: 'ඉතා කලබල, බොහෝ විවේකයන් අවශ්‍ය විය',
        couldNotContinue: 'වැරදි වලින් පසු දිගටම නොහැකි විය',
        
        highlyEngaged: 'ඉතා නියැලී, සෙල්ලම් කිරීමට උද්යෝගිමත්',
        generallyInterested: 'සාමාන්‍යයෙන් උනන්දුවක්, කැමැත්තෙන් සෙල්ලම් කළේය',
        neutralInterest: 'මධ්‍යස්ථ උනන්දුවක්, පොළඹවීම අවශ්‍ය විය',
        lowInterest: 'අඩු උනන්දුවක්, අකමැත්තෙන්',
        refusedGame: 'ක්‍රීඩාව ප්‍රතික්ෂේප කළේය හෝ මග හැරියේය',
        
        understoodImmediately: 'වහාම තේරුම් ගත්තේය',
        understoodAfterOne: 'එක් පැහැදිලි කිරීමකින් පසු තේරුම් ගත්තේය',
        neededRepeated: 'නැවත නැවතත් පැහැදිලි කිරීම් අවශ්‍ය විය',
        difficultyGrasping: 'උපදෙස් ග්‍රහණය කිරීමේ දුෂ්කරතාව',
        couldNotUnderstand: 'උපදෙස් තේරුම් ගැනීමට නොහැකි විය',
        
        switchedImmediately: 'වහාම මාරු විය, දෝෂ නැත',
        switchedQuickly: 'ඉක්මනින් මාරු විය, දෝෂ 1-2',
        neededTime: 'අනුගත වීමට කාලය අවශ්‍ය විය, දෝෂ කිහිපයක්',
        struggled: 'මාරු වීමට පොරබදමින්, බොහෝ දෝෂ',
        couldNotAdapt: 'නව රීතියට අනුගත විය නොහැකි',
        
        noOldRule: 'නැත, වහාම නව රීතිය භාවිතා කළේය',
        rarelyOldRule: 'කලාතුරකින්, පැරණි රීති භාවිත 1-2',
        sometimesOldRule: 'සමහර විට, සිහිකැඳවීම් අවශ්‍ය විය',
        frequentlyOldRule: 'නිතර, රටාව බිඳීමට අපහසුයි',
        couldNotStop: 'පැරණි රීතිය භාවිතා කිරීම නතර කළ නොහැකි විය',
        
        noReminders: 'කිසිවක් නැත, ස්වාධීනව මතක තබා ගත්තේය',
        fewReminders: 'මෘදු සිහිකැඳවීම් 1-2',
        severalReminders: 'පුරා සිහිකැඳවීම් 3-4',
        frequentReminders: 'නිතර සිහිකැඳවීම් අවශ්‍ය විය',
        constantReminders: 'නිරන්තර පොළඹවීම අවශ්‍ය විය',
        
        excitedAboutChange: 'වෙනස ගැන උද්යෝගිමත්',
        calmAccepted: 'සන්සුන්, වෙනස පිළිගත්තේය',
        slightlyConfused: 'තරමක් ව්‍යාකූල හෝ කලකිරී',
        upsetNeedReassurance: 'කලබල, සහතික කිරීම අවශ්‍ය විය',
        veryDistressed: 'ඉතා දුක්ඛිත, ඉවත් වීමට අවශ්‍ය විය',
        
        veryFlexible: 'ඉතා නම්‍යශීලී, විවිධත්වය රස විඳියි',
        generallyFlexible: 'සාමාන්‍යයෙන් නම්‍යශීලී',
        somewhatRigid: 'තරමක් දැඩි, චර්යා වලට කැමැත්තෙයි',
        quiteRigid: 'තරමක් දැඩි, වෙනස්කම් අකැමැත්තෙන්',
        veryRigid: 'ඉතා දැඩි, අනුගත විය නොහැකි',
      },
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
    
    common: {
      ok: 'சரி',
      yes: 'ஆம்',
      no: 'இல்லை',
      continue: 'தொடர்க',
      skip: 'தவிர்க்கவும்',
      retry: 'மீண்டும் முயற்சிக்கவும்',
      english: 'English',
      sinhala: 'සිංහල',
      tamil: 'தமிழ்',
      back: undefined
    },
    
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
      // New professional login fields
      welcomeBack: 'மீண்டும் வரவேற்கிறோம்',
      clinicalAccess: 'மருத்துவ போர்டல் அணுகல்',
      emailPlaceholder: 'your.name@healthcare.org',
      rememberMe: 'சாதனத்தை நினைவில் வைத்துக்கொள்',
      authenticating: 'அங்கீகரிக்கிறது...',
      quickAccess: 'விரைவு மருத்துவ அணுகல்',
      clinician: 'மருத்துவ நிபுணர்',
      hospital: 'குழந்தைகள் மருத்துவமனை',
      researcher: 'ஆராய்ச்சி உறுப்பினர்',
      researchCenter: 'ஆட்டிசம் ஆராய்ச்சி மையம்',
      newUser: 'SenseAI-க்கு புதியவரா?',
      requestAccess: 'அணுகல் கோருக',
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
      registrationSuccess: 'வெற்றி!',
      registrationMessage: '{name} ({age} வயது) வெற்றிகரமாக பதிவு செய்யப்பட்டது.',
      childrenList: 'குழந்தைகள் பட்டியல்',
      selectChild: 'மதிப்பீட்டைத் தொடங்க ஒரு குழந்தையைத் தேர்ந்தெடுக்கவும்',
      ageGroup: 'வயது குழு',
      language: 'மொழி',
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
      questionProgress: 'கேள்வி {current} / {total}',
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
    
    reflection: {
      title: 'மருத்துவர் பிரதிபலிப்பு',
      subtitle: 'மதிப்பீட்டுக்குப் பிந்தைய அவதானிப்புகள்',
      infoTitle: 'மருத்துவர் பிரதிபலிப்பு',
      infoSubtitle: 'மதிப்பீட்டின் போது {childName} பற்றிய உங்கள் அவதானிப்பின் அடிப்படையில், தயவுசெய்து இந்த நடத்தை கேள்விகளுக்கு பதிலளிக்கவும்.',
      infoNote: 'இந்த அவதானிப்புகள் விளையாட்டு அளவீடுகள் மற்றும் நிஜ-உலக நடத்தை சூழலை இணைப்பதன் மூலம் AI துல்லியத்தை மேம்படுத்த உதவுகின்றன.',
      skip: 'தவிர்க்கவும்',
      skipWarningTitle: 'பிரதிபலிப்பைத் தவிர்க்கவா?',
      skipWarningMessage: 'விளையாட்டு முடிவுகள் சேமிக்கப்படும், ஆனால் நடத்தை அவதானிப்புகள் காணாமல் போகும். இது ML மாதிரி துல்லியத்தை குறைக்கலாம்.',
      skipAnyway: 'எப்படியும் தவிர்க்கவும்',
      incompleteTitle: 'முழுமையடையாதது',
      incompleteMessage: 'சமர்ப்பிக்கும் முன் அனைத்து கேள்விகளுக்கும் பதிலளிக்கவும்.',
      completeReflection: 'பிரதிபலிப்பை முடிக்கவும்',
      answerMore: 'மேலும் {count} பதிலளிக்கவும்',
      answered: 'பதிலளிக்கப்பட்டது',
      of: 'இல்',
      
      categories: {
        attention: 'கவனம்',
        inhibition: 'தடுப்பு',
        emotionalRegulation: 'உணர்ச்சி ஒழுங்குபடுத்தல்',
        motivation: 'உந்துதல்',
        comprehension: 'புரிதல்',
        cognitiveFlexibility: 'அறிவாற்றல் நெகிழ்வுத்தன்மை',
        perseveration: 'விடாமுயற்சி',
        supportRequired: 'தேவையான ஆதரவு',
        emotionalResponse: 'உணர்ச்சி பதில்',
        executiveFunction: 'நிர்வாக செயல்பாடு',
      },
      
      frogJump: {
        q1: 'விளையாட்டின் போது குழந்தை எவ்வளவு நன்றாக கவனம் செலுத்தியது?',
        q2: 'குழந்தை உந்துதல்களை (ஆமை தோன்றும்போது தொடாமல்) எவ்வளவு நன்றாக கட்டுப்படுத்தியது?',
        q3: 'விளையாட்டின் போது குழந்தை தவறுகளை எவ்வாறு கையாண்டது?',
        q4: 'விளையாட்டில் குழந்தை எவ்வளவு ஈடுபாடு கொண்டிருந்தது?',
        q5: 'விளையாட்டு வழிமுறைகளை குழந்தை எவ்வளவு நன்றாக புரிந்துகொண்டது?',
      },
      
      ruleSwitch: {
        q1: 'விதி மாறியபோது குழந்தை எவ்வளவு எளிதாக மாற்றியமைத்தது?',
        q2: 'மாற்றத்திற்குப் பிறகு குழந்தை பழைய விதியைத் தொடர்ந்து பயன்படுத்தியதா?',
        q3: 'விதி மாற்றம் பற்றி குழந்தைக்கு எத்தனை நினைவூட்டல்கள் தேவைப்பட்டன?',
        q4: 'விதி மாற்றத்திற்கு குழந்தை உணர்ச்சிபூர்வமாக எவ்வாறு பதிலளித்தது?',
        q5: 'ஒட்டுமொத்தமாக, குழந்தையின் சிந்தனை எவ்வளவு நெகிழ்வானதாக இருந்தது?',
      },
      
      options: {
        excellent: 'சிறந்தது',
        good: 'நல்லது',
        moderate: 'மிதமானது',
        poor: 'மோசமானது',
        unable: 'இயலாது',
        
        excellentFocus: 'சிறந்த கவனம், திசை திருப்பல்கள் இல்லை',
        goodFocus: 'நல்ல கவனம், சிறிய திசை திருப்பல்கள்',
        moderateFocus: 'மிதமான கவனம், சில அலைச்சல்',
        poorFocus: 'மோசமான கவனம், அடிக்கடி திசை திரும்புதல்',
        unableAttention: 'கவனத்தை பராமரிக்க முடியவில்லை',
        
        excellentControl: 'சிறந்த கட்டுப்பாடு, உந்துதல் தொடுதல்கள் இல்லை',
        goodControl: 'நல்ல கட்டுப்பாடு, 1-2 உந்துதல் பிழைகள்',
        moderateControl: 'மிதமான கட்டுப்பாடு, பல பிழைகள்',
        poorControl: 'மோசமான கட்டுப்பாடு, அடிக்கடி உந்துதல் தொடுதல்கள்',
        noControl: 'உந்துதல் கட்டுப்பாடு காணப்படவில்லை',
        
        stayedCalm: 'அமைதியாக இருந்தது, தொடர்ந்து விளையாடியது',
        slightlyUpset: 'சற்று கலக்கம், விரைவாக மீண்டது',
        frustrated: 'விரக்தியடைந்தது, ஊக்கம் தேவைப்பட்டது',
        veryUpset: 'மிகவும் கலக்கம், பல இடைவெளிகள் தேவைப்பட்டன',
        couldNotContinue: 'தவறுகளுக்குப் பிறகு தொடர முடியவில்லை',
        
        highlyEngaged: 'மிகவும் ஈடுபாடு, விளையாட உற்சாகம்',
        generallyInterested: 'பொதுவாக ஆர்வம், விருப்பத்துடன் விளையாடியது',
        neutralInterest: 'நடுநிலை ஆர்வம், தூண்டுதல் தேவைப்பட்டது',
        lowInterest: 'குறைந்த ஆர்வம், தயக்கம்',
        refusedGame: 'விளையாட்டை மறுத்தது அல்லது தவிர்த்தது',
        
        understoodImmediately: 'உடனடியாக புரிந்துகொண்டது',
        understoodAfterOne: 'ஒரு விளக்கத்திற்குப் பிறகு புரிந்துகொண்டது',
        neededRepeated: 'மீண்டும் மீண்டும் விளக்கங்கள் தேவைப்பட்டன',
        difficultyGrasping: 'வழிமுறைகளை புரிந்துகொள்வதில் சிரமம்',
        couldNotUnderstand: 'வழிமுறைகளை புரிந்துகொள்ள முடியவில்லை',
        
        switchedImmediately: 'உடனடியாக மாறியது, பிழைகள் இல்லை',
        switchedQuickly: 'விரைவாக மாறியது, 1-2 பிழைகள்',
        neededTime: 'மாற்றியமைக்க நேரம் தேவைப்பட்டது, பல பிழைகள்',
        struggled: 'மாற போராடியது, பல பிழைகள்',
        couldNotAdapt: 'புதிய விதிக்கு மாற்றியமைக்க முடியவில்லை',
        
        noOldRule: 'இல்லை, உடனடியாக புதிய விதியைப் பயன்படுத்தியது',
        rarelyOldRule: 'அரிதாக, 1-2 பழைய விதி பயன்பாடுகள்',
        sometimesOldRule: 'சில நேரங்களில், நினைவூட்டல்கள் தேவைப்பட்டன',
        frequentlyOldRule: 'அடிக்கடி, வடிவத்தை உடைக்க கடினம்',
        couldNotStop: 'பழைய விதியைப் பயன்படுத்துவதை நிறுத்த முடியவில்லை',
        
        noReminders: 'எதுவும் இல்லை, சுயாதீனமாக நினைவில் வைத்திருந்தது',
        fewReminders: '1-2 மென்மையான நினைவூட்டல்கள்',
        severalReminders: 'முழுவதும் 3-4 நினைவூட்டல்கள்',
        frequentReminders: 'அடிக்கடி நினைவூட்டல்கள் தேவைப்பட்டன',
        constantReminders: 'தொடர்ச்சியான தூண்டுதல் தேவைப்பட்டது',
        
        excitedAboutChange: 'மாற்றத்தைப் பற்றி உற்சாகமாக',
        calmAccepted: 'அமைதியாக, மாற்றத்தை ஏற்றுக்கொண்டது',
        slightlyConfused: 'சற்று குழப்பம் அல்லது விரக்தி',
        upsetNeedReassurance: 'வருத்தம், உறுதிப்படுத்தல் தேவைப்பட்டது',
        veryDistressed: 'மிகவும் துயரம், விட்டுவிட விரும்பியது',
        
        veryFlexible: 'மிகவும் நெகிழ்வானது, பல்வேறு வகைகளை விரும்புகிறது',
        generallyFlexible: 'பொதுவாக நெகிழ்வானது',
        somewhatRigid: 'ஓரளவு கடினம், வழக்கங்களை விரும்புகிறது',
        quiteRigid: 'மிகவும் கடினம், மாற்றங்களை விரும்பவில்லை',
        veryRigid: 'மிகவும் கடினம், மாற்றியமைக்க முடியாது',
      },
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


