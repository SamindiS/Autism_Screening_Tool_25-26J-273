/**
 * Autism Screening App - Pilot Study Version
 * Designed for clinical pilot testing with 2-6 year olds
 *
 * @format
 */

import React, { useState, useEffect } from 'react';
import {
  StatusBar, 
  useColorScheme, 
  View, 
  StyleSheet, 
  Text, 
  TouchableOpacity,
  ScrollView,
  Dimensions,
  Alert,
  Modal,
  TextInput
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import GameWebView from './src/components/GameWebView';
import SplashScreen from './src/screens/SplashScreen';
import LoginScreen from './src/screens/LoginScreen';
import RegistrationScreen from './src/screens/RegistrationScreen';
import MainDashboardScreen from './src/screens/MainDashboardScreen';
import { AuthProvider } from './src/context/AuthContext';

const { width, height } = Dimensions.get('window');

// Types for pilot study data
interface PilotSession {
  id: string;
  childId: string;
  childName?: string;
  childAge: number;
  childGender: 'M' | 'F';
  diagnosis: 'ASD' | 'Control' | 'Unknown';
  sessionDate: string;
  gameType: 'go_no_go' | 'rule_switching' | 'stroop';
  trials: Trial[];
  summary: SessionSummary;
  clinicianNotes: string;
  completionTime: number; // in seconds
}

interface Trial {
  trialNumber: number;
  stimulus: string;
  rule: string;
  response: string;
  reactionTime: number;
  correct: boolean;
  timestamp: string;
}

interface SessionSummary {
  totalTrials: number;
  accuracy: number;
  meanReactionTime: number;
  switchCost: number;
  errors: number;
  preSwitchAccuracy: number;
  postSwitchAccuracy: number;
}

// Doctor Login Screen
function DoctorLoginScreen({ onLogin }: { onLogin: (doctorId: string) => void }) {
  const [doctorId, setDoctorId] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = () => {
    // Test credentials for pilot study
    const validCredentials = [
      { id: 'DR001', password: 'password123' },
      { id: 'DR002', password: 'test123' },
      { id: 'admin', password: 'admin' },
      { id: 'pilot', password: 'pilot' }
    ];
    
    const isValid = validCredentials.some(cred => 
      cred.id === doctorId && cred.password === password
    );
    
    if (isValid) {
      onLogin(doctorId);
    } else if (!doctorId || !password) {
      Alert.alert('Error', 'Please enter both Doctor ID and Password');
    } else {
      Alert.alert('Invalid Credentials', 'Please use one of the test credentials:\n\nDR001 / password123\nDR002 / test123\nadmin / admin\npilot / pilot');
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.loginContainer}>
        <Text style={styles.title}>🧠 Autism Screening App</Text>
        <Text style={styles.subtitle}>Pilot Study Version</Text>
        <Text style={styles.description}>
          Clinical Assessment System for Children Aged 2-6
        </Text>
        
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Doctor ID</Text>
          <TextInput
            style={styles.inputBox}
            placeholder="Enter Doctor ID"
            value={doctorId}
            onChangeText={setDoctorId}
            autoCapitalize="none"
            autoCorrect={false}
          />
        </View>
        
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Password</Text>
          <TextInput
            style={styles.inputBox}
            placeholder="Enter Password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry={true}
            autoCapitalize="none"
            autoCorrect={false}
          />
        </View>
        
        <TouchableOpacity style={styles.loginButton} onPress={handleLogin}>
          <Text style={styles.loginButtonText}>Login as Doctor</Text>
        </TouchableOpacity>
        
        <Text style={styles.pilotNote}>
          Pilot Study - For Research Purposes Only
        </Text>
      </View>
    </View>
  );
}

// Child Registration Screen
function ChildRegistrationScreen({ onRegister, onBack }: { 
  onRegister: (child: any) => void; 
  onBack: () => void; 
}) {
  const [childId, setChildId] = useState('');
  const [childName, setChildName] = useState('');
  const [age, setAge] = useState('');
  const [gender, setGender] = useState<'M' | 'F' | ''>('');
  const [diagnosis, setDiagnosis] = useState<'ASD' | 'Control' | 'Unknown'>('Unknown');
  const [language, setLanguage] = useState<'English' | 'Sinhala' | 'Tamil'>('English');
  const [parentName, setParentName] = useState('');
  const [contactNumber, setContactNumber] = useState('');

  const handleRegister = () => {
    if (!childId || !childName || !age || !gender) {
      Alert.alert('Error', 'Please fill in all required fields (ID, Name, Age, Gender)');
      return;
    }
    
    const child = {
      id: childId,
      name: childName,
      age: parseInt(age),
      gender,
      diagnosis,
      language,
      parentName: parentName || 'Not provided',
      contactNumber: contactNumber || 'Not provided',
      registrationDate: new Date().toISOString()
    };
    
    onRegister(child);
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Child Registration</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.registrationContainer}>
        <Text style={styles.sectionTitle}>Child Information</Text>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Child ID *</Text>
          <TextInput
            style={styles.inputBox}
            placeholder="Enter Child ID (e.g., P001)"
            value={childId}
            onChangeText={setChildId}
            autoCapitalize="characters"
            autoCorrect={false}
          />
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Child Name *</Text>
          <TextInput
            style={styles.inputBox}
            placeholder="Enter Child's Full Name"
            value={childName}
            onChangeText={setChildName}
            autoCapitalize="words"
            autoCorrect={false}
          />
        </View>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Age *</Text>
          <View style={styles.ageButtons}>
            {[2, 3, 4, 5, 6].map(ageOption => (
              <TouchableOpacity 
                key={ageOption}
                style={[styles.ageButton, age === ageOption.toString() && styles.ageButtonSelected]}
                onPress={() => setAge(ageOption.toString())}
              >
                <Text style={[styles.ageButtonText, age === ageOption.toString() && styles.ageButtonTextSelected]}>
                  {ageOption}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Gender *</Text>
          <View style={styles.genderButtons}>
            <TouchableOpacity 
              style={[styles.genderButton, gender === 'M' && styles.genderButtonSelected]}
              onPress={() => setGender('M')}
            >
              <Text style={[styles.genderButtonText, gender === 'M' && styles.genderButtonTextSelected]}>
                Male
              </Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.genderButton, gender === 'F' && styles.genderButtonSelected]}
              onPress={() => setGender('F')}
            >
              <Text style={[styles.genderButtonText, gender === 'F' && styles.genderButtonTextSelected]}>
                Female
              </Text>
            </TouchableOpacity>
          </View>
        </View>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Diagnosis Group</Text>
          <View style={styles.diagnosisButtons}>
            <TouchableOpacity 
              style={[styles.diagnosisButton, diagnosis === 'ASD' && styles.diagnosisButtonSelected]}
              onPress={() => setDiagnosis('ASD')}
            >
              <Text style={[styles.diagnosisButtonText, diagnosis === 'ASD' && styles.diagnosisButtonTextSelected]}>
                ASD
              </Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.diagnosisButton, diagnosis === 'Control' && styles.diagnosisButtonSelected]}
              onPress={() => setDiagnosis('Control')}
            >
              <Text style={[styles.diagnosisButtonText, diagnosis === 'Control' && styles.diagnosisButtonTextSelected]}>
                Control
              </Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.diagnosisButton, diagnosis === 'Unknown' && styles.diagnosisButtonSelected]}
              onPress={() => setDiagnosis('Unknown')}
            >
              <Text style={[styles.diagnosisButtonText, diagnosis === 'Unknown' && styles.diagnosisButtonTextSelected]}>
                Unknown
              </Text>
            </TouchableOpacity>
          </View>
        </View>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Language</Text>
          <View style={styles.languageButtons}>
            <TouchableOpacity 
              style={[styles.languageButton, language === 'English' && styles.languageButtonSelected]}
              onPress={() => setLanguage('English')}
            >
              <Text style={[styles.languageButtonText, language === 'English' && styles.languageButtonTextSelected]}>
                English
              </Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.languageButton, language === 'Sinhala' && styles.languageButtonSelected]}
              onPress={() => setLanguage('Sinhala')}
            >
              <Text style={[styles.languageButtonText, language === 'Sinhala' && styles.languageButtonTextSelected]}>
                සිංහල
              </Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={[styles.languageButton, language === 'Tamil' && styles.languageButtonSelected]}
              onPress={() => setLanguage('Tamil')}
            >
              <Text style={[styles.languageButtonText, language === 'Tamil' && styles.languageButtonTextSelected]}>
                தமிழ்
              </Text>
            </TouchableOpacity>
          </View>
        </View>

        <Text style={styles.sectionTitle}>Parent/Guardian Information</Text>
        
        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Parent/Guardian Name</Text>
          <TextInput
            style={styles.inputBox}
            placeholder="Enter Parent/Guardian Name"
            value={parentName}
            onChangeText={setParentName}
            autoCapitalize="words"
            autoCorrect={false}
          />
        </View>

        <View style={styles.inputGroup}>
          <Text style={styles.inputLabel}>Contact Number</Text>
          <TextInput
            style={styles.inputBox}
            placeholder="Enter Contact Number"
            value={contactNumber}
            onChangeText={setContactNumber}
            keyboardType="phone-pad"
            autoCorrect={false}
          />
        </View>
        
        <TouchableOpacity style={styles.registerButton} onPress={handleRegister}>
          <Text style={styles.registerButtonText}>Register Child & Start Assessment</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

// Game Selection Screen
function GameSelectionScreen({ child, onSelectGame, onBack, onGoToDashboard }: { 
  child: any; 
  onSelectGame: (gameType: string) => void; 
  onBack: () => void; 
  onGoToDashboard: () => void;
}) {
  const getRecommendedGame = () => {
    if (child.age <= 3) return 'go_no_go';
    return 'rule_switching';
  };

  const games = [
    {
      id: 'go_no_go',
      name: '🐸 Frog Jump Game',
      description: 'Help the happy frog jump! Don\'t touch the sleepy turtle!',
      ageRange: '2-3 years',
      duration: '2-3 minutes',
      icon: '🐸',
      recommended: child.age <= 3,
      colors: ['#4CAF50', '#FF5722']
    },
    {
      id: 'stroop',
      name: '🌙 Day & Night Magic',
      description: 'When you see the sun, tap the moon! When you see the moon, tap the sun!',
      ageRange: '4-5 years',
      duration: '2-3 minutes',
      icon: '🌙',
      recommended: child.age >= 4 && child.age <= 5,
      colors: ['#FFD700', '#4169E1']
    },
    {
      id: 'rule_switching',
      name: '🎨 Color & Shape Adventure',
      description: 'First tap by color, then tap by shape! Watch the magic happen!',
      ageRange: '4-6 years',
      duration: '3-5 minutes',
      icon: '🎨',
      recommended: child.age >= 4,
      colors: ['#E91E63', '#2196F3', '#4CAF50', '#FF9800']
    }
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Select Game</Text>
        <TouchableOpacity 
          style={styles.dashboardButton}
          onPress={onGoToDashboard}
        >
          <Text style={styles.dashboardButtonText}>📊</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.childInfo}>
        <Text style={styles.childInfoText}>
          {child.name} (ID: {child.id}) | Age: {child.age} | {child.gender}
        </Text>
      </View>

      <View style={styles.gamesContainer}>
        {games.map((game) => (
          <TouchableOpacity 
            key={game.id}
            style={[
              styles.gameCard, 
              game.recommended && styles.gameCardRecommended
            ]}
            onPress={() => onSelectGame(game.id)}
          >
            <Text style={styles.gameIcon}>{game.icon}</Text>
            <View style={styles.gameContent}>
              <Text style={styles.gameName}>{game.name}</Text>
              <Text style={styles.gameDescription}>{game.description}</Text>
              <Text style={styles.gameDetails}>
                {game.ageRange} • {game.duration}
              </Text>
              {game.recommended && (
                <Text style={styles.recommendedText}>✓ Recommended for this age</Text>
              )}
            </View>
          </TouchableOpacity>
        ))}
      </View>
    </ScrollView>
  );
}

// Frog Jump Game (Go/No-Go) Screen
function GoNoGoGameScreen({ child, onComplete, onBack }: { 
  child: any; 
  onComplete: (session: PilotSession) => void; 
  onBack: () => void; 
}) {
  const [currentTrial, setCurrentTrial] = useState(1);
  const [trials, setTrials] = useState<Trial[]>([]);
  const [gamePhase, setGamePhase] = useState<'instructions' | 'practice' | 'main' | 'complete'>('instructions');
  const [startTime, setStartTime] = useState<number | null>(null);
  const [currentStimulus, setCurrentStimulus] = useState<'frog' | 'turtle' | null>(null);
  const [sessionStartTime, setSessionStartTime] = useState<number>(Date.now());
  const [showCelebration, setShowCelebration] = useState(false);
  const [showEncouragement, setShowEncouragement] = useState(false);
  const [score, setScore] = useState(0);
  const [bounceAnimation, setBounceAnimation] = useState(false);
  
  const maxTrials = 20;
  const practiceTrials = 5;

  const getInstructions = () => {
    const instructions = {
      English: "🐸 Help the happy frog jump! Don't touch the sleepy turtle! 🐢",
      Sinhala: "🐸 සතුටු ගෙම්බාට පනින්න උදව් කරන්න! නිදිමත ගෙම්බාට ස්පර්ශ නොකරන්න! 🐢",
      Tamil: "🐸 மகிழ்ச்சியான தவளையை தாண்ட உதவுங்கள்! தூங்கும் ஆமையைத் தொடாதீர்கள்! 🐢"
    };
    return instructions[child.language as keyof typeof instructions] || instructions.English;
  };

  const generateStimulus = () => {
    // 70% frog (go), 30% turtle (no-go)
    return Math.random() < 0.7 ? 'frog' : 'turtle';
  };

  const handleResponse = (response: 'tap' | 'no_tap') => {
    if (!startTime || !currentStimulus) return;

    const reactionTime = Date.now() - startTime;
    const isCorrect = (currentStimulus === 'frog' && response === 'tap') || 
                     (currentStimulus === 'turtle' && response === 'no_tap');

    // Show celebration for correct responses
    if (isCorrect) {
      setShowCelebration(true);
      setScore(score + 1);
      setBounceAnimation(true);
      setTimeout(() => {
        setShowCelebration(false);
        setBounceAnimation(false);
      }, 1000);
    } else {
      setShowEncouragement(true);
      setTimeout(() => setShowEncouragement(false), 1500);
    }

    const trial: Trial = {
      trialNumber: currentTrial,
      stimulus: currentStimulus,
      rule: 'go_no_go',
      response: response,
      reactionTime,
      correct: isCorrect,
      timestamp: new Date().toISOString()
    };

    setTrials([...trials, trial]);

    if (currentTrial < maxTrials) {
      setTimeout(() => {
        setCurrentTrial(currentTrial + 1);
        if (currentTrial === practiceTrials) {
          setGamePhase('main');
        }
        setCurrentStimulus(generateStimulus());
        setStartTime(Date.now());
      }, isCorrect ? 1000 : 1500);
    } else {
      setTimeout(() => setGamePhase('complete'), 1000);
    }
  };

  const startGame = () => {
    setGamePhase('practice');
    setCurrentStimulus(generateStimulus());
    setStartTime(Date.now());
  };

  const calculateSummary = (): SessionSummary => {
    const correctTrials = trials.filter(t => t.correct);
    const goTrials = trials.filter(t => t.stimulus === 'green');
    const noGoTrials = trials.filter(t => t.stimulus === 'red');
    
    return {
      totalTrials: trials.length,
      accuracy: trials.length > 0 ? correctTrials.length / trials.length : 0,
      meanReactionTime: trials.length > 0 ? trials.reduce((sum, t) => sum + t.reactionTime, 0) / trials.length : 0,
      switchCost: 0, // Not applicable for Go/No-Go
      errors: trials.length - correctTrials.length,
      preSwitchAccuracy: goTrials.length > 0 ? goTrials.filter(t => t.correct).length / goTrials.length : 0,
      postSwitchAccuracy: noGoTrials.length > 0 ? noGoTrials.filter(t => t.correct).length / noGoTrials.length : 0
    };
  };

  const completeSession = () => {
    const summary = calculateSummary();
    const session: PilotSession = {
      id: `session_${Date.now()}`,
      childId: child.id,
      childName: child.name,
      childAge: child.age,
      childGender: child.gender,
      diagnosis: child.diagnosis,
      sessionDate: new Date().toISOString(),
      gameType: 'go_no_go',
      trials,
      summary,
      clinicianNotes: '',
      completionTime: Math.floor((Date.now() - sessionStartTime) / 1000)
    };
    
    onComplete(session);
  };

  if (gamePhase === 'instructions') {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>🐸 Frog Jump Game</Text>
          <View style={styles.placeholder} />
        </View>

        <View style={styles.instructionsContainer}>
          <View style={styles.gameIconLarge}>
            <Text style={styles.gameIconText}>🐸</Text>
          </View>
          <Text style={styles.instructionsTitle}>Let's Play!</Text>
          <Text style={styles.instructionsText}>{getInstructions()}</Text>
          
          <View style={styles.exampleContainer}>
            <Text style={styles.exampleTitle}>Watch and Learn:</Text>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#4CAF50' }]}>
                <Text style={styles.exampleText}>🐸</Text>
              </View>
              <Text style={styles.exampleLabel}>→ Tap the happy frog! 🎉</Text>
            </View>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#FF5722' }]}>
                <Text style={styles.exampleText}>🐢</Text>
              </View>
              <Text style={styles.exampleLabel}>→ Don't tap the sleepy turtle! 😴</Text>
            </View>
          </View>
          
          <TouchableOpacity style={styles.startButton} onPress={startGame}>
            <Text style={styles.startButtonText}>🎮 Start Playing!</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  if (gamePhase === 'complete') {
    const summary = calculateSummary();
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Game Complete!</Text>
          <View style={styles.placeholder} />
        </View>

        <ScrollView style={styles.resultsContainer}>
          <View style={styles.resultsCard}>
            <Text style={styles.resultsTitle}>Performance Results</Text>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Accuracy:</Text>
              <Text style={styles.metricValue}>{(summary.accuracy * 100).toFixed(1)}%</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Mean Reaction Time:</Text>
              <Text style={styles.metricValue}>{summary.meanReactionTime.toFixed(0)}ms</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Errors:</Text>
              <Text style={styles.metricValue}>{summary.errors}</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Completion Time:</Text>
              <Text style={styles.metricValue}>{Math.floor((Date.now() - sessionStartTime) / 1000)}s</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.completeButton} onPress={completeSession}>
            <Text style={styles.completeButtonText}>Save Session & Continue</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>🐸 Frog Jump Game</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.gameArea}>
        <View style={styles.gameInfo}>
          <Text style={styles.trialText}>
            {gamePhase === 'practice' ? 'Practice' : 'Main'} Trial {currentTrial} of {maxTrials}
          </Text>
        </View>

        {currentStimulus && (
          <View style={styles.stimulusContainer}>
            <TouchableOpacity 
              style={[
                styles.stimulus, 
                { backgroundColor: currentStimulus === 'frog' ? '#4CAF50' : '#FF5722' }
              ]}
              onPress={() => handleResponse('tap')}
            >
              <Text style={styles.stimulusText}>
                {currentStimulus === 'frog' ? '🐸' : '🐢'}
              </Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={styles.instructionText}>
          <Text style={styles.instructionLabel}>
            {currentStimulus === 'frog' ? 'Tap the happy frog! 🎉' : 'Don\'t tap the sleepy turtle! 😴'}
          </Text>
        </View>
      </View>
    </View>
  );
}

// Day-Night Stroop Game Screen
function StroopGameScreen({ child, onComplete, onBack }: { 
  child: any; 
  onComplete: (session: PilotSession) => void; 
  onBack: () => void; 
}) {
  const [currentTrial, setCurrentTrial] = useState(1);
  const [trials, setTrials] = useState<Trial[]>([]);
  const [gamePhase, setGamePhase] = useState<'instructions' | 'practice' | 'main' | 'complete'>('instructions');
  const [startTime, setStartTime] = useState<number | null>(null);
  const [currentStimulus, setCurrentStimulus] = useState<'sun' | 'moon' | null>(null);
  const [sessionStartTime, setSessionStartTime] = useState<number>(Date.now());
  
  const maxTrials = 16;
  const practiceTrials = 4;

  const getInstructions = () => {
    const instructions = {
      English: "When you see a SUN, tap NIGHT. When you see a MOON, tap DAY. Do the opposite!",
      Sinhala: "සූර්යයා දැකූ විට රාත්‍රිය තට්ටු කරන්න. හඳ දැකූ විට දිනය තට්ටු කරන්න. ප්‍රතිවිරුද්ධය කරන්න!",
      Tamil: "சூரியனைப் பார்த்தால் இரவைத் தொடவும். நிலவைப் பார்த்தால் பகலைத் தொடவும். எதிர்மாறாக செய்யவும்!"
    };
    return instructions[child.language as keyof typeof instructions] || instructions.English;
  };

  const generateStimulus = () => {
    return Math.random() < 0.5 ? 'sun' : 'moon';
  };

  const handleResponse = (response: 'day' | 'night') => {
    if (!startTime || !currentStimulus) return;

    const reactionTime = Date.now() - startTime;
    const isCorrect = (currentStimulus === 'sun' && response === 'night') || 
                     (currentStimulus === 'moon' && response === 'day');

    const trial: Trial = {
      trialNumber: currentTrial,
      stimulus: currentStimulus,
      rule: 'stroop',
      response: response,
      reactionTime,
      correct: isCorrect,
      timestamp: new Date().toISOString()
    };

    setTrials([...trials, trial]);

    if (currentTrial < maxTrials) {
      setCurrentTrial(currentTrial + 1);
      if (currentTrial === practiceTrials) {
        setGamePhase('main');
      }
      setCurrentStimulus(generateStimulus());
      setStartTime(Date.now());
    } else {
      setGamePhase('complete');
    }
  };

  const startGame = () => {
    setGamePhase('practice');
    setCurrentStimulus(generateStimulus());
    setStartTime(Date.now());
  };

  const calculateSummary = (): SessionSummary => {
    const correctTrials = trials.filter(t => t.correct);
    const sunTrials = trials.filter(t => t.stimulus === 'sun');
    const moonTrials = trials.filter(t => t.stimulus === 'moon');
    
    return {
      totalTrials: trials.length,
      accuracy: trials.length > 0 ? correctTrials.length / trials.length : 0,
      meanReactionTime: trials.length > 0 ? trials.reduce((sum, t) => sum + t.reactionTime, 0) / trials.length : 0,
      switchCost: 0, // Not applicable for Stroop
      errors: trials.length - correctTrials.length,
      preSwitchAccuracy: sunTrials.length > 0 ? sunTrials.filter(t => t.correct).length / sunTrials.length : 0,
      postSwitchAccuracy: moonTrials.length > 0 ? moonTrials.filter(t => t.correct).length / moonTrials.length : 0
    };
  };

  const completeSession = () => {
    const summary = calculateSummary();
    const session: PilotSession = {
      id: `session_${Date.now()}`,
      childId: child.id,
      childName: child.name,
      childAge: child.age,
      childGender: child.gender,
      diagnosis: child.diagnosis,
      sessionDate: new Date().toISOString(),
      gameType: 'stroop',
      trials,
      summary,
      clinicianNotes: '',
      completionTime: Math.floor((Date.now() - sessionStartTime) / 1000)
    };
    
    onComplete(session);
  };

  if (gamePhase === 'instructions') {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Day-Night Stroop Game</Text>
          <View style={styles.placeholder} />
        </View>

        <View style={styles.instructionsContainer}>
          <Text style={styles.instructionsTitle}>Instructions</Text>
          <Text style={styles.instructionsText}>{getInstructions()}</Text>
          
          <View style={styles.exampleContainer}>
            <Text style={styles.exampleTitle}>Examples:</Text>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#FFD700' }]}>
                <Text style={styles.exampleText}>☀️</Text>
              </View>
              <Text style={styles.exampleLabel}>→ Tap NIGHT</Text>
            </View>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#4169E1' }]}>
                <Text style={styles.exampleText}>🌙</Text>
              </View>
              <Text style={styles.exampleLabel}>→ Tap DAY</Text>
            </View>
          </View>
          
          <TouchableOpacity style={styles.startButton} onPress={startGame}>
            <Text style={styles.startButtonText}>Start Game</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  if (gamePhase === 'complete') {
    const summary = calculateSummary();
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Game Complete!</Text>
          <View style={styles.placeholder} />
        </View>

        <ScrollView style={styles.resultsContainer}>
          <View style={styles.resultsCard}>
            <Text style={styles.resultsTitle}>Performance Results</Text>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Accuracy:</Text>
              <Text style={styles.metricValue}>{(summary.accuracy * 100).toFixed(1)}%</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Mean Reaction Time:</Text>
              <Text style={styles.metricValue}>{summary.meanReactionTime.toFixed(0)}ms</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Errors:</Text>
              <Text style={styles.metricValue}>{summary.errors}</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Completion Time:</Text>
              <Text style={styles.metricValue}>{Math.floor((Date.now() - sessionStartTime) / 1000)}s</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.completeButton} onPress={completeSession}>
            <Text style={styles.completeButtonText}>Save Session & Continue</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Day-Night Stroop Game</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.gameArea}>
        <View style={styles.gameInfo}>
          <Text style={styles.trialText}>
            {gamePhase === 'practice' ? 'Practice' : 'Main'} Trial {currentTrial} of {maxTrials}
          </Text>
        </View>

        {currentStimulus && (
          <View style={styles.stimulusContainer}>
            <TouchableOpacity 
              style={[
                styles.stimulus, 
                { backgroundColor: currentStimulus === 'sun' ? '#FFD700' : '#4169E1' }
              ]}
              onPress={() => handleResponse(currentStimulus === 'sun' ? 'night' : 'day')}
            >
              <Text style={styles.stimulusText}>
                {currentStimulus === 'sun' ? '☀️' : '🌙'}
              </Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={styles.responseButtons}>
          <TouchableOpacity 
            style={[styles.responseButton, { backgroundColor: '#FFD700' }]}
            onPress={() => handleResponse('day')}
          >
            <Text style={styles.responseButtonText}>DAY</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={[styles.responseButton, { backgroundColor: '#4169E1' }]}
            onPress={() => handleResponse('night')}
          >
            <Text style={styles.responseButtonText}>NIGHT</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

// Rule Switching Game Screen
function RuleSwitchingGameScreen({ child, onComplete, onBack }: { 
  child: any; 
  onComplete: (session: PilotSession) => void; 
  onBack: () => void; 
}) {
  const [currentTrial, setCurrentTrial] = useState(1);
  const [trials, setTrials] = useState<Trial[]>([]);
  const [gamePhase, setGamePhase] = useState<'instructions' | 'practice' | 'main' | 'complete'>('instructions');
  const [startTime, setStartTime] = useState<number | null>(null);
  const [currentRule, setCurrentRule] = useState<'color' | 'shape'>('color');
  const [currentStimulus, setCurrentStimulus] = useState<any>(null);
  const [sessionStartTime, setSessionStartTime] = useState<number>(Date.now());
  
  const maxTrials = 24;
  const practiceTrials = 6;
  const switchPoint = 12; // Switch rule after 12 trials

  const stimuli = [
    { color: 'red', shape: 'circle', colorName: 'RED', shapeName: 'CIRCLE' },
    { color: 'blue', shape: 'square', colorName: 'BLUE', shapeName: 'SQUARE' },
    { color: 'green', shape: 'triangle', colorName: 'GREEN', shapeName: 'TRIANGLE' },
    { color: 'yellow', shape: 'circle', colorName: 'YELLOW', shapeName: 'CIRCLE' },
    { color: 'red', shape: 'square', colorName: 'RED', shapeName: 'SQUARE' },
    { color: 'blue', shape: 'triangle', colorName: 'BLUE', shapeName: 'TRIANGLE' }
  ];

  const getInstructions = () => {
    const instructions = {
      English: "First, tap by COLOR. After some trials, the rule will change to tap by SHAPE. Pay attention!",
      Sinhala: "පළමුව, වර්ණය අනුව තට්ටු කරන්න. ට්‍රයල් කිහිපයකට පසු, නීතිය හැඩය අනුව තට්ටු කිරීමට වෙනස් වේ. අවධානය යොමු කරන්න!",
      Tamil: "முதலில், நிறத்தின் அடிப்படையில் தொடவும். சில சோதனைகளுக்குப் பிறகு, விதி வடிவத்தின் அடிப்படையில் தொடுவதற்கு மாறும். கவனம் செலுத்துங்கள்!"
    };
    return instructions[child.language as keyof typeof instructions] || instructions.English;
  };

  const generateStimulus = () => {
    return stimuli[Math.floor(Math.random() * stimuli.length)];
  };

  const getCorrectAnswer = () => {
    return currentRule === 'color' ? currentStimulus.colorName : currentStimulus.shapeName;
  };

  const handleResponse = (response: string) => {
    if (!startTime || !currentStimulus) return;

    const reactionTime = Date.now() - startTime;
    const isCorrect = response === getCorrectAnswer();
    
    const trial: Trial = {
      trialNumber: currentTrial,
      stimulus: `${currentStimulus.color}_${currentStimulus.shape}`,
      rule: currentRule,
      response: response,
      reactionTime,
      correct: isCorrect,
      timestamp: new Date().toISOString()
    };

    setTrials([...trials, trial]);

    if (currentTrial < maxTrials) {
      const nextTrial = currentTrial + 1;
      setCurrentTrial(nextTrial);
      
      // Switch rule at switch point
      if (nextTrial === switchPoint + 1) {
        setCurrentRule(currentRule === 'color' ? 'shape' : 'color');
        Alert.alert('Rule Change!', `New rule: Tap by ${currentRule === 'color' ? 'SHAPE' : 'COLOR'}`);
      }
      
      // Switch from practice to main phase
      if (nextTrial === practiceTrials + 1) {
        setGamePhase('main');
      }
      
      // Generate new stimulus
      setCurrentStimulus(generateStimulus());
      setStartTime(Date.now());
    } else {
      setGamePhase('complete');
    }
  };

  const startGame = () => {
    setGamePhase('practice');
    setCurrentStimulus(generateStimulus());
    setStartTime(Date.now());
  };

  const calculateSummary = (): SessionSummary => {
    const correctTrials = trials.filter(t => t.correct);
    const preSwitch = trials.slice(0, switchPoint);
    const postSwitch = trials.slice(switchPoint);
    
    const preSwitchRT = preSwitch.length > 0 ? preSwitch.reduce((sum, t) => sum + t.reactionTime, 0) / preSwitch.length : 0;
    const postSwitchRT = postSwitch.length > 0 ? postSwitch.reduce((sum, t) => sum + t.reactionTime, 0) / postSwitch.length : 0;
    const switchCost = postSwitchRT - preSwitchRT;
    
    return {
      totalTrials: trials.length,
      accuracy: trials.length > 0 ? correctTrials.length / trials.length : 0,
      meanReactionTime: trials.length > 0 ? trials.reduce((sum, t) => sum + t.reactionTime, 0) / trials.length : 0,
      switchCost,
      errors: trials.length - correctTrials.length,
      preSwitchAccuracy: preSwitch.length > 0 ? preSwitch.filter(t => t.correct).length / preSwitch.length : 0,
      postSwitchAccuracy: postSwitch.length > 0 ? postSwitch.filter(t => t.correct).length / postSwitch.length : 0
    };
  };

  const completeSession = () => {
    const summary = calculateSummary();
    const session: PilotSession = {
      id: `session_${Date.now()}`,
      childId: child.id,
      childName: child.name,
      childAge: child.age,
      childGender: child.gender,
      diagnosis: child.diagnosis,
      sessionDate: new Date().toISOString(),
      gameType: 'rule_switching',
      trials,
      summary,
      clinicianNotes: '',
      completionTime: Math.floor((Date.now() - sessionStartTime) / 1000)
    };
    
    onComplete(session);
  };

  if (gamePhase === 'instructions') {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Rule Switching Game</Text>
          <View style={styles.placeholder} />
        </View>

        <View style={styles.instructionsContainer}>
          <Text style={styles.instructionsTitle}>Instructions</Text>
          <Text style={styles.instructionsText}>{getInstructions()}</Text>
          
          <View style={styles.exampleContainer}>
            <Text style={styles.exampleTitle}>Examples:</Text>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#F44336' }]}>
                <Text style={styles.exampleText}>●</Text>
              </View>
              <Text style={styles.exampleLabel}>Rule: COLOR → Tap RED</Text>
            </View>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#2196F3' }]}>
                <Text style={styles.exampleText}>■</Text>
              </View>
              <Text style={styles.exampleLabel}>Rule: SHAPE → Tap SQUARE</Text>
            </View>
          </View>
          
          <TouchableOpacity style={styles.startButton} onPress={startGame}>
            <Text style={styles.startButtonText}>Start Game</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  if (gamePhase === 'complete') {
    const summary = calculateSummary();
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Game Complete!</Text>
          <View style={styles.placeholder} />
        </View>

        <ScrollView style={styles.resultsContainer}>
          <View style={styles.resultsCard}>
            <Text style={styles.resultsTitle}>Performance Results</Text>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Accuracy:</Text>
              <Text style={styles.metricValue}>{(summary.accuracy * 100).toFixed(1)}%</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Mean Reaction Time:</Text>
              <Text style={styles.metricValue}>{summary.meanReactionTime.toFixed(0)}ms</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Switch Cost:</Text>
              <Text style={styles.metricValue}>{summary.switchCost.toFixed(0)}ms</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Pre-Switch Accuracy:</Text>
              <Text style={styles.metricValue}>{(summary.preSwitchAccuracy * 100).toFixed(1)}%</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Post-Switch Accuracy:</Text>
              <Text style={styles.metricValue}>{(summary.postSwitchAccuracy * 100).toFixed(1)}%</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Errors:</Text>
              <Text style={styles.metricValue}>{summary.errors}</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Completion Time:</Text>
              <Text style={styles.metricValue}>{Math.floor((Date.now() - sessionStartTime) / 1000)}s</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.completeButton} onPress={completeSession}>
            <Text style={styles.completeButtonText}>Save Session & Continue</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Rule Switching Game</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.gameArea}>
        <View style={styles.gameInfo}>
          <Text style={styles.trialText}>
            {gamePhase === 'practice' ? 'Practice' : 'Main'} Trial {currentTrial} of {maxTrials}
          </Text>
          <Text style={styles.ruleText}>
            Rule: Tap by {currentRule.toUpperCase()}
          </Text>
        </View>

        {currentStimulus && (
          <View style={styles.stimulusContainer}>
            <View style={[styles.stimulus, { backgroundColor: currentStimulus.color === 'red' ? '#F44336' : 
                                                      currentStimulus.color === 'blue' ? '#2196F3' :
                                                      currentStimulus.color === 'green' ? '#4CAF50' : '#FFD700' }]}>
              <Text style={styles.stimulusText}>
                {currentStimulus.shape === 'circle' ? '●' : 
                 currentStimulus.shape === 'square' ? '■' : '▲'}
              </Text>
            </View>
          </View>
        )}

        <View style={styles.responseButtons}>
          <TouchableOpacity 
            style={[styles.responseButton, { backgroundColor: '#F44336' }]}
            onPress={() => handleResponse(currentStimulus.colorName)}
          >
            <Text style={styles.responseButtonText}>{currentStimulus.colorName}</Text>
          </TouchableOpacity>
          
          <TouchableOpacity 
            style={[styles.responseButton, { backgroundColor: '#2196F3' }]}
            onPress={() => handleResponse(currentStimulus.shapeName)}
          >
            <Text style={styles.responseButtonText}>{currentStimulus.shapeName}</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );
}

// Professional Game Results Screen
function GameResultsScreen({ session, onBack, onNewGame }: { 
  session: PilotSession; 
  onBack: () => void; 
  onNewGame: () => void; 
}) {
  const getGameTitle = () => {
    switch (session.gameType) {
      case 'go_no_go': return '🐸 Frog Jump Game Results';
      case 'stroop': return '🌙 Day & Night Magic Results';
      case 'rule_switching': return '🎨 Color & Shape Adventure Results';
      default: return 'Game Results';
    }
  };

  const getRiskLevel = (accuracy: number, reactionTime: number) => {
    if (accuracy >= 0.8 && reactionTime <= 1500) return { level: 'Low', color: '#4CAF50' };
    if (accuracy >= 0.6 && reactionTime <= 2000) return { level: 'Moderate', color: '#FF9800' };
    return { level: 'High', color: '#F44336' };
  };

  const risk = getRiskLevel(session.summary?.accuracy || 0, session.summary?.meanReactionTime || 0);

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back to Dashboard</Text>
        </TouchableOpacity>
        <Text style={styles.title}>{getGameTitle()}</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.resultsContainer}>
        {/* Child Information */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Child Information</Text>
          <View style={styles.infoGrid}>
            <View style={styles.infoItem}>
              <Text style={styles.infoLabel}>Name:</Text>
              <Text style={styles.infoValue}>{session.childName}</Text>
            </View>
            <View style={styles.infoItem}>
              <Text style={styles.infoLabel}>Age:</Text>
              <Text style={styles.infoValue}>{session.childAge} years</Text>
            </View>
            <View style={styles.infoItem}>
              <Text style={styles.infoLabel}>Gender:</Text>
              <Text style={styles.infoValue}>{session.childGender}</Text>
            </View>
            <View style={styles.infoItem}>
              <Text style={styles.infoLabel}>Session Date:</Text>
              <Text style={styles.infoValue}>{new Date(session.sessionDate).toLocaleDateString()}</Text>
            </View>
          </View>
        </View>

        {/* Performance Metrics */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Performance Metrics</Text>
          <View style={styles.metricsGrid}>
            <View style={styles.metricCard}>
              <Text style={styles.metricValue}>{Math.round((session.summary?.accuracy || 0) * 100)}%</Text>
              <Text style={styles.metricLabel}>Accuracy</Text>
            </View>
            <View style={styles.metricCard}>
              <Text style={styles.metricValue}>{Math.round(session.summary?.meanReactionTime || 0)}ms</Text>
              <Text style={styles.metricLabel}>Avg Reaction Time</Text>
            </View>
            <View style={styles.metricCard}>
              <Text style={styles.metricValue}>{session.summary?.totalTrials || 0}</Text>
              <Text style={styles.metricLabel}>Total Trials</Text>
            </View>
            <View style={styles.metricCard}>
              <Text style={styles.metricValue}>{session.summary?.errors || 0}</Text>
              <Text style={styles.metricLabel}>Errors</Text>
            </View>
            {session.gameType === 'rule_switching' && (
              <View style={styles.metricCard}>
                <Text style={styles.metricValue}>{Math.round(session.summary?.switchCost || 0)}ms</Text>
                <Text style={styles.metricLabel}>Switch Cost</Text>
              </View>
            )}
            <View style={styles.metricCard}>
              <Text style={styles.metricValue}>{Math.round(session.completionTime / 60)}m {session.completionTime % 60}s</Text>
              <Text style={styles.metricLabel}>Completion Time</Text>
            </View>
          </View>
        </View>

        {/* Risk Assessment */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Risk Assessment</Text>
          <View style={[styles.riskCard, { borderColor: risk.color }]}>
            <Text style={[styles.riskLevel, { color: risk.color }]}>
              {risk.level} Risk
            </Text>
            <Text style={styles.riskDescription}>
              {risk.level === 'Low' && 'Child shows typical cognitive flexibility patterns.'}
              {risk.level === 'Moderate' && 'Child shows some difficulties with cognitive flexibility. Further assessment recommended.'}
              {risk.level === 'High' && 'Child shows significant difficulties with cognitive flexibility. Comprehensive evaluation recommended.'}
            </Text>
          </View>
        </View>

        {/* Clinical Notes */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Clinical Notes</Text>
          <TextInput
            style={styles.notesInput}
            placeholder="Add clinical observations and notes here..."
            multiline
            numberOfLines={4}
            value={session.clinicianNotes}
            onChangeText={(text) => {
              // Update notes in session
              session.clinicianNotes = text;
            }}
          />
        </View>

        {/* Action Buttons */}
        <View style={styles.actionButtons}>
          <TouchableOpacity style={styles.primaryButton} onPress={onNewGame}>
            <Text style={styles.primaryButtonText}>Start New Game</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.secondaryButton} onPress={onBack}>
            <Text style={styles.secondaryButtonText}>Back to Dashboard</Text>
          </TouchableOpacity>
        </View>
      </View>
    </ScrollView>
  );
}

// Cognitive Flexibility Dashboard Screen
function CognitiveFlexibilityDashboard({ onBack, onStartNewAssessment }: { 
  onBack: () => void; 
  onStartNewAssessment: () => void; 
}) {
  const [sessions, setSessions] = useState<PilotSession[]>([]);
  const [selectedChild, setSelectedChild] = useState<string | null>(null);
  const [viewMode, setViewMode] = useState<'overview' | 'child' | 'analytics'>('overview' as 'overview' | 'child' | 'analytics');

  useEffect(() => {
    loadSessions();
  }, []);

  const loadSessions = async () => {
    try {
      const savedSessions = await AsyncStorage.getItem('pilot_sessions');
      console.log('Loading sessions from AsyncStorage:', savedSessions);
      if (savedSessions) {
        const parsedSessions = JSON.parse(savedSessions);
        console.log('Parsed sessions:', parsedSessions);
        // Validate and fix session structure
        const validatedSessions = parsedSessions.map((session: any) => ({
          ...session,
          summary: session.summary || {
            totalTrials: 0,
            accuracy: 0,
            meanReactionTime: 0,
            switchCost: 0,
            errors: 0,
            preSwitchAccuracy: 0,
            postSwitchAccuracy: 0
          }
        }));
        setSessions(validatedSessions);
        console.log('Set sessions:', validatedSessions);
      } else {
        console.log('No sessions found in AsyncStorage');
        setSessions([]);
      }
    } catch (error) {
      console.error('Failed to load sessions:', error);
    }
  };

  const getChildSessions = (childId: string) => {
    return sessions.filter(session => session.childId === childId);
  };

  const getChildStats = (childId: string) => {
    const childSessions = getChildSessions(childId);
    if (childSessions.length === 0) return null;

    const totalSessions = childSessions.length;
    const avgAccuracy = childSessions.reduce((sum, s) => sum + (s.summary?.accuracy || 0), 0) / totalSessions;
    const avgReactionTime = childSessions.reduce((sum, s) => sum + (s.summary?.meanReactionTime || 0), 0) / totalSessions;
    const totalErrors = childSessions.reduce((sum, s) => sum + (s.summary?.errors || 0), 0);
    const lastSession = childSessions[childSessions.length - 1];

    return {
      totalSessions,
      avgAccuracy: avgAccuracy * 100,
      avgReactionTime,
      totalErrors,
      lastSessionDate: lastSession.sessionDate,
      riskLevel: getRiskLevel(avgAccuracy, avgReactionTime)
    };
  };

  const getRiskLevel = (accuracy: number, reactionTime: number) => {
    if (accuracy >= 0.8 && reactionTime <= 1500) return 'Low';
    if (accuracy >= 0.6 && reactionTime <= 2000) return 'Moderate';
    return 'High';
  };

  const getOverallStats = () => {
    const totalChildren = new Set(sessions.map(s => s.childId)).size;
    const totalSessions = sessions.length;
    const avgAccuracy = sessions.length > 0 ? sessions.reduce((sum, s) => sum + (s.summary?.accuracy || 0), 0) / sessions.length * 100 : 0;
    const avgReactionTime = sessions.length > 0 ? sessions.reduce((sum, s) => sum + (s.summary?.meanReactionTime || 0), 0) / sessions.length : 0;
    
    const riskDistribution = sessions.reduce((acc, s) => {
      const stats = getChildStats(s.childId);
      if (stats) {
        acc[stats.riskLevel] = (acc[stats.riskLevel] || 0) + 1;
      }
      return acc;
    }, {} as Record<string, number>);

    return {
      totalChildren,
      totalSessions,
      avgAccuracy,
      avgReactionTime,
      riskDistribution
    };
  };

  const getUniqueChildren = () => {
    console.log('Getting unique children from sessions:', sessions);
    const childIds = [...new Set(sessions.map(s => s.childId))];
    console.log('Child IDs found:', childIds);
    const children = childIds.map(id => {
      const childSessions = getChildSessions(id);
      const firstSession = childSessions[0];
      return {
        id,
        name: firstSession.childName || 'Unknown',
        age: firstSession.childAge,
        gender: firstSession.childGender,
        diagnosis: firstSession.diagnosis,
        sessionCount: childSessions.length,
        lastSession: childSessions[childSessions.length - 1].sessionDate
      };
    });
    console.log('Children data:', children);
    return children;
  };

  const overallStats = getOverallStats();
  const children = getUniqueChildren();

  if (viewMode === 'child' && selectedChild) {
    const childSessions = getChildSessions(selectedChild);
    const childStats = getChildStats(selectedChild);
    const child = children.find(c => c.id === selectedChild);

    return (
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={() => setViewMode('overview')}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Child Details</Text>
          <TouchableOpacity style={styles.newButton} onPress={onStartNewAssessment}>
            <Text style={styles.newButtonText}>+ New</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.childHeader}>
          <Text style={styles.childName}>{child?.name || 'Unknown'}</Text>
          <Text style={styles.childId}>ID: {selectedChild}</Text>
          <Text style={styles.childInfo}>
            Age: {child?.age} | {child?.gender} | {child?.diagnosis}
          </Text>
        </View>

        {childStats && (
          <View style={styles.statsContainer}>
            <Text style={styles.sectionTitle}>Performance Summary</Text>
            
            <View style={styles.metricGrid}>
              <View style={styles.metricCard}>
                <Text style={styles.metricValue}>{childStats.totalSessions}</Text>
                <Text style={styles.metricLabel}>Sessions</Text>
              </View>
              <View style={styles.metricCard}>
                <Text style={styles.metricValue}>{childStats.avgAccuracy.toFixed(1)}%</Text>
                <Text style={styles.metricLabel}>Avg Accuracy</Text>
              </View>
              <View style={styles.metricCard}>
                <Text style={styles.metricValue}>{childStats.avgReactionTime.toFixed(0)}ms</Text>
                <Text style={styles.metricLabel}>Avg RT</Text>
              </View>
              <View style={styles.metricCard}>
                <Text style={[styles.metricValue, { 
                  color: childStats.riskLevel === 'Low' ? '#4CAF50' : 
                         childStats.riskLevel === 'Moderate' ? '#FF9800' : '#F44336' 
                }]}>
                  {childStats.riskLevel}
                </Text>
                <Text style={styles.metricLabel}>Risk Level</Text>
              </View>
            </View>
          </View>
        )}

        <View style={styles.sessionsContainer}>
          <Text style={styles.sectionTitle}>Session History</Text>
          {childSessions.map((session, index) => (
            <View key={session.id} style={styles.sessionCard}>
              <View style={styles.sessionHeader}>
                <Text style={styles.sessionNumber}>Session {index + 1}</Text>
                <Text style={styles.sessionDate}>
                  {new Date(session.sessionDate).toLocaleDateString()}
                </Text>
              </View>
              <View style={styles.sessionMetrics}>
                <View style={styles.sessionMetric}>
                  <Text style={styles.sessionMetricLabel}>Game:</Text>
                  <Text style={styles.sessionMetricValue}>{session.gameType}</Text>
                </View>
                <View style={styles.sessionMetric}>
                  <Text style={styles.sessionMetricLabel}>Accuracy:</Text>
                  <Text style={styles.sessionMetricValue}>{((session.summary?.accuracy || 0) * 100).toFixed(1)}%</Text>
                </View>
                <View style={styles.sessionMetric}>
                  <Text style={styles.sessionMetricLabel}>RT:</Text>
                  <Text style={styles.sessionMetricValue}>{(session.summary?.meanReactionTime || 0).toFixed(0)}ms</Text>
                </View>
                <View style={styles.sessionMetric}>
                  <Text style={styles.sessionMetricLabel}>Errors:</Text>
                  <Text style={styles.sessionMetricValue}>{session.summary?.errors || 0}</Text>
                </View>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>
    );
  }

  if (viewMode === 'analytics') {
    return (
      <ScrollView style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={() => setViewMode('overview')}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Analytics</Text>
          <View style={styles.placeholder} />
        </View>

        <View style={styles.analyticsContainer}>
          <Text style={styles.sectionTitle}>Overall Performance</Text>
          
          <View style={styles.overviewStats}>
            <View style={styles.overviewCard}>
              <Text style={styles.overviewValue}>{overallStats.totalChildren}</Text>
              <Text style={styles.overviewLabel}>Total Children</Text>
            </View>
            <View style={styles.overviewCard}>
              <Text style={styles.overviewValue}>{overallStats.totalSessions}</Text>
              <Text style={styles.overviewLabel}>Total Sessions</Text>
            </View>
            <View style={styles.overviewCard}>
              <Text style={styles.overviewValue}>{overallStats.avgAccuracy.toFixed(1)}%</Text>
              <Text style={styles.overviewLabel}>Avg Accuracy</Text>
            </View>
            <View style={styles.overviewCard}>
              <Text style={styles.overviewValue}>{overallStats.avgReactionTime.toFixed(0)}ms</Text>
              <Text style={styles.overviewLabel}>Avg Reaction Time</Text>
            </View>
          </View>

          <View style={styles.riskDistribution}>
            <Text style={styles.sectionTitle}>Risk Level Distribution</Text>
            <View style={styles.riskBars}>
              <View style={styles.riskBar}>
                <View style={[styles.riskBarFill, { backgroundColor: '#4CAF50', width: `${(overallStats.riskDistribution.Low || 0) / overallStats.totalChildren * 100}%` }]} />
                <Text style={styles.riskBarLabel}>Low Risk: {overallStats.riskDistribution.Low || 0}</Text>
              </View>
              <View style={styles.riskBar}>
                <View style={[styles.riskBarFill, { backgroundColor: '#FF9800', width: `${(overallStats.riskDistribution.Moderate || 0) / overallStats.totalChildren * 100}%` }]} />
                <Text style={styles.riskBarLabel}>Moderate Risk: {overallStats.riskDistribution.Moderate || 0}</Text>
              </View>
              <View style={styles.riskBar}>
                <View style={[styles.riskBarFill, { backgroundColor: '#F44336', width: `${(overallStats.riskDistribution.High || 0) / overallStats.totalChildren * 100}%` }]} />
                <Text style={styles.riskBarLabel}>High Risk: {overallStats.riskDistribution.High || 0}</Text>
              </View>
            </View>
          </View>

          <View style={styles.gameDistribution}>
            <Text style={styles.sectionTitle}>Game Type Distribution</Text>
            <View style={styles.gameStats}>
              <View style={styles.gameStat}>
                <Text style={styles.gameStatLabel}>Go/No-Go:</Text>
                <Text style={styles.gameStatValue}>
                  {sessions.filter(s => s.gameType === 'go_no_go').length} sessions
                </Text>
              </View>
              <View style={styles.gameStat}>
                <Text style={styles.gameStatLabel}>Rule Switching:</Text>
                <Text style={styles.gameStatValue}>
                  {sessions.filter(s => s.gameType === 'rule_switching').length} sessions
                </Text>
              </View>
            </View>
          </View>
        </View>
      </ScrollView>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Cognitive Flexibility Dashboard</Text>
        <TouchableOpacity style={styles.newButton} onPress={onStartNewAssessment}>
          <Text style={styles.newButtonText}>+ New Assessment</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.dashboardContainer}>
        <View style={styles.overviewStats}>
          <View style={styles.overviewCard}>
            <Text style={styles.overviewValue}>{overallStats.totalChildren}</Text>
            <Text style={styles.overviewLabel}>Total Children</Text>
          </View>
          <View style={styles.overviewCard}>
            <Text style={styles.overviewValue}>{overallStats.totalSessions}</Text>
            <Text style={styles.overviewLabel}>Total Sessions</Text>
          </View>
          <View style={styles.overviewCard}>
            <Text style={styles.overviewValue}>{overallStats.avgAccuracy.toFixed(1)}%</Text>
            <Text style={styles.overviewLabel}>Avg Accuracy</Text>
          </View>
          <View style={styles.overviewCard}>
            <Text style={styles.overviewValue}>{overallStats.avgReactionTime.toFixed(0)}ms</Text>
            <Text style={styles.overviewLabel}>Avg RT</Text>
          </View>
        </View>

        <View style={styles.navigationButtons}>
          <TouchableOpacity 
            style={[styles.navButton, viewMode === 'overview' && styles.navButtonActive]}
            onPress={() => setViewMode('overview')}
          >
            <Text style={[styles.navButtonText, viewMode === 'overview' && styles.navButtonTextActive]}>
              Overview
            </Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.navButton, viewMode === 'child' && styles.navButtonActive]}
            onPress={() => setViewMode('child')}
          >
            <Text style={[styles.navButtonText, viewMode === 'child' && styles.navButtonTextActive]}>
              Children
            </Text>
          </TouchableOpacity>
          <TouchableOpacity 
            style={[styles.navButton, (viewMode as string) === 'analytics' && styles.navButtonActive]}
            onPress={() => setViewMode('analytics' as 'overview' | 'child' | 'analytics')}
          >
            <Text style={[styles.navButtonText, (viewMode as string) === 'analytics' && styles.navButtonTextActive]}>
              Analytics
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.childrenList}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Children List</Text>
            <TouchableOpacity 
              style={styles.addChildButton}
              onPress={onStartNewAssessment}
            >
              <Text style={styles.addChildButtonText}>+ Add New Child</Text>
            </TouchableOpacity>
            <TouchableOpacity 
              style={styles.refreshButton}
              onPress={loadSessions}
            >
              <Text style={styles.refreshButtonText}>🔄 Refresh</Text>
            </TouchableOpacity>
          </View>
          
          {children.length === 0 ? (
            <View style={styles.emptyState}>
              <Text style={styles.emptyStateIcon}>👶</Text>
              <Text style={styles.emptyStateTitle}>No Children Registered</Text>
              <Text style={styles.emptyStateText}>
                Start by adding a new child to begin assessments
              </Text>
              <TouchableOpacity 
                style={styles.emptyStateButton}
                onPress={onStartNewAssessment}
              >
                <Text style={styles.emptyStateButtonText}>Add First Child</Text>
              </TouchableOpacity>
            </View>
          ) : (
            children.map((child) => {
              const stats = getChildStats(child.id);
              return (
                <TouchableOpacity 
                  key={child.id} 
                  style={styles.childCard}
                  onPress={() => {
                    setSelectedChild(child.id);
                    setViewMode('child');
                  }}
                >
                  <View style={styles.childCardHeader}>
                    <View style={styles.childCardNameContainer}>
                      <Text style={styles.childCardName}>{child.name}</Text>
                      <Text style={styles.childCardId}>ID: {child.id}</Text>
                    </View>
                    <Text style={[styles.riskBadge, { 
                      backgroundColor: stats?.riskLevel === 'Low' ? '#4CAF50' : 
                                     stats?.riskLevel === 'Moderate' ? '#FF9800' : '#F44336' 
                    }]}>
                      {stats?.riskLevel || 'Unknown'}
                    </Text>
                  </View>
                  <Text style={styles.childCardInfo}>
                    Age: {child.age} | {child.gender} | {child.diagnosis}
                  </Text>
                  <Text style={styles.childCardSessions}>
                    {child.sessionCount} sessions | Last: {new Date(child.lastSession).toLocaleDateString()}
                  </Text>
                  {stats && (
                    <View style={styles.childCardMetrics}>
                      <Text style={styles.childCardMetric}>
                        Accuracy: {stats.avgAccuracy.toFixed(1)}%
                      </Text>
                      <Text style={styles.childCardMetric}>
                        RT: {stats.avgReactionTime.toFixed(0)}ms
                      </Text>
                    </View>
                  )}
                </TouchableOpacity>
              );
            })
          )}
        </View>
      </View>
    </ScrollView>
  );
}

// Advanced Cognitive Flexibility & Rule-Switching Game Screen
function AdvancedCognitiveFlexibilityScreen({ 
  child, 
  onComplete, 
  onBack 
}: { 
  child: any; 
  onComplete: (session: PilotSession) => void; 
  onBack: () => void; 
}) {
  const [gamePhase, setGamePhase] = useState<'instructions' | 'practice' | 'main' | 'complete'>('instructions');
  const [currentTrial, setCurrentTrial] = useState(0);
  const [currentRule, setCurrentRule] = useState<'color' | 'shape'>('color');
  const [currentStimulus, setCurrentStimulus] = useState<any>(null);
  const [startTime, setStartTime] = useState<number | null>(null);
  const [trials, setTrials] = useState<any[]>([]);
  const [score, setScore] = useState(0);
  const [showFeedback, setShowFeedback] = useState(false);
  const [feedbackType, setFeedbackType] = useState<'correct' | 'incorrect' | null>(null);
  const [progress, setProgress] = useState(0);
  const [showRuleSwitch, setShowRuleSwitch] = useState(false);
  const [celebrationVisible, setCelebrationVisible] = useState(false);

  const totalTrials = 20;
  const switchPoint = 10;

  const stimuli = [
    { color: 'red', shape: 'circle', emoji: '🔴' },
    { color: 'blue', shape: 'square', emoji: '🔵' },
    { color: 'green', shape: 'triangle', emoji: '🟢' },
    { color: 'yellow', shape: 'star', emoji: '⭐' },
  ];

  const generateStimulus = () => {
    const randomStimulus = stimuli[Math.floor(Math.random() * stimuli.length)];
    setCurrentStimulus(randomStimulus);
    setStartTime(Date.now());
  };

  const handleResponse = (response: 'color' | 'shape') => {
    if (!startTime || !currentStimulus) return;

    const reactionTime = Date.now() - startTime;
    const isCorrect = currentRule === 'color' ? 
      response === 'color' : response === 'shape';

    const trial = {
      trialNumber: currentTrial + 1,
      stimulus: currentStimulus,
      rule: currentRule,
      response: response,
      reactionTime: reactionTime,
      correct: isCorrect,
      timestamp: new Date().toISOString()
    };

    setTrials(prev => [...prev, trial]);
    
    if (isCorrect) {
      setScore(prev => prev + 1);
      setFeedbackType('correct');
    } else {
      setFeedbackType('incorrect');
    }

    setShowFeedback(true);
    setProgress(((currentTrial + 1) / totalTrials) * 100);

    // Show rule switch notification
    if (currentTrial + 1 === switchPoint) {
      setShowRuleSwitch(true);
      setTimeout(() => {
        setShowRuleSwitch(false);
        setCurrentRule('shape');
      }, 2000);
    }

    setTimeout(() => {
      setShowFeedback(false);
      setFeedbackType(null);
      
      if (currentTrial + 1 < totalTrials) {
        setCurrentTrial(prev => prev + 1);
        generateStimulus();
      } else {
        completeGame();
      }
    }, 1500);
  };

  const completeGame = () => {
    const accuracy = (score / totalTrials) * 100;
    const meanRT = trials.reduce((sum, trial) => sum + trial.reactionTime, 0) / trials.length;
    
    const preSwitchTrials = trials.slice(0, switchPoint);
    const postSwitchTrials = trials.slice(switchPoint);
    
    const preSwitchRT = preSwitchTrials.reduce((sum, trial) => sum + trial.reactionTime, 0) / preSwitchTrials.length;
    const postSwitchRT = postSwitchTrials.reduce((sum, trial) => sum + trial.reactionTime, 0) / postSwitchTrials.length;
    const switchCost = Math.max(0, postSwitchRT - preSwitchRT);

    const session: PilotSession = {
      id: Date.now().toString(),
      childId: child.id,
      childName: child.name,
      gameType: 'rule_switching',
      timestamp: new Date().toISOString(),
      summary: {
        accuracy: accuracy,
        meanReactionTime: meanRT,
        totalTrials: totalTrials,
        errors: totalTrials - score,
        switchCost: switchCost,
        preSwitchAccuracy: (preSwitchTrials.filter(t => t.correct).length / preSwitchTrials.length) * 100,
        postSwitchAccuracy: (postSwitchTrials.filter(t => t.correct).length / postSwitchTrials.length) * 100,
      }
    };

    setCelebrationVisible(true);
    setTimeout(() => {
      onComplete(session);
    }, 3000);
  };

  const startGame = () => {
    setGamePhase('main');
    generateStimulus();
  };

  if (gamePhase === 'instructions') {
    return (
      <View style={styles.advancedGameContainer}>
        <View style={styles.gameHeader}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.gameTitle}>Cognitive Flexibility Assessment</Text>
          <View style={styles.placeholder} />
        </View>

        <ScrollView style={styles.instructionsContainer}>
          <View style={styles.instructionsCard}>
            <Text style={styles.instructionsTitle}>🎯 Instructions</Text>
            <Text style={styles.instructionsText}>
              This game tests your ability to switch between different rules. 
              Pay attention to the instructions that appear on screen.
            </Text>
            
            <View style={styles.ruleSection}>
              <Text style={styles.ruleTitle}>Rule 1: Match by Color</Text>
              <View style={styles.ruleExample}>
                <Text style={styles.ruleEmoji}>🔴</Text>
                <Text style={styles.ruleText}>Tap the COLOR button</Text>
              </View>
            </View>

            <View style={styles.ruleSection}>
              <Text style={styles.ruleTitle}>Rule 2: Match by Shape</Text>
              <View style={styles.ruleExample}>
                <Text style={styles.ruleEmoji}>🔵</Text>
                <Text style={styles.ruleText}>Tap the SHAPE button</Text>
              </View>
            </View>

            <View style={styles.importantNote}>
              <Text style={styles.noteIcon}>⚠️</Text>
              <Text style={styles.noteText}>
                The rule will change halfway through the game. 
                Watch for the notification!
              </Text>
            </View>
          </View>

          <TouchableOpacity style={styles.startGameButton} onPress={startGame}>
            <Text style={styles.startGameButtonText}>Start Assessment</Text>
            <Text style={styles.startGameArrow}>→</Text>
          </TouchableOpacity>
        </ScrollView>
      </View>
    );
  }

  if (gamePhase === 'complete') {
    return (
      <View style={styles.advancedGameContainer}>
        <View style={styles.celebrationContainer}>
          <Text style={styles.celebrationIcon}>🎉</Text>
          <Text style={styles.celebrationTitle}>Great Job!</Text>
          <Text style={styles.celebrationSubtitle}>
            Assessment completed successfully
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.advancedGameContainer}>
      {/* Game Header */}
      <View style={styles.gameHeader}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.gameTitle}>Cognitive Flexibility</Text>
        <View style={styles.scoreContainer}>
          <Text style={styles.scoreText}>Score: {score}</Text>
        </View>
      </View>

      {/* Rule Switch Notification */}
      {showRuleSwitch && (
        <View style={styles.ruleSwitchNotification}>
          <Text style={styles.ruleSwitchIcon}>🔄</Text>
          <Text style={styles.ruleSwitchText}>Rule Changed! Now match by SHAPE</Text>
        </View>
      )}

      {/* Current Rule Display */}
      <View style={styles.ruleDisplay}>
        <Text style={styles.ruleLabel}>Current Rule:</Text>
        <Text style={styles.currentRuleText}>
          {currentRule === 'color' ? 'Match by COLOR' : 'Match by SHAPE'}
        </Text>
      </View>

      {/* Stimulus Display */}
      <View style={styles.stimulusContainer}>
        <Text style={styles.stimulusLabel}>What do you see?</Text>
        <View style={styles.stimulusDisplay}>
          <Text style={styles.stimulusEmoji}>{currentStimulus?.emoji}</Text>
        </View>
      </View>

      {/* Response Buttons */}
      <View style={styles.responseContainer}>
        <TouchableOpacity 
          style={[styles.responseButton, styles.colorButton]}
          onPress={() => handleResponse('color')}
        >
          <Text style={styles.responseButtonText}>COLOR</Text>
        </TouchableOpacity>
        
        <TouchableOpacity 
          style={[styles.responseButton, styles.shapeButton]}
          onPress={() => handleResponse('shape')}
        >
          <Text style={styles.responseButtonText}>SHAPE</Text>
        </TouchableOpacity>
      </View>

      {/* Feedback Display */}
      {showFeedback && (
        <View style={[
          styles.feedbackContainer,
          feedbackType === 'correct' ? styles.correctFeedback : styles.incorrectFeedback
        ]}>
          <Text style={styles.feedbackIcon}>
            {feedbackType === 'correct' ? '✅' : '❌'}
          </Text>
          <Text style={styles.feedbackText}>
            {feedbackType === 'correct' ? 'Correct!' : 'Try again!'}
          </Text>
        </View>
      )}

      {/* Progress Bar */}
      <View style={styles.progressContainer}>
        <View style={styles.progressBar}>
          <View style={[styles.progressFill, { width: `${progress}%` }]} />
        </View>
        <Text style={styles.progressText}>
          {currentTrial + 1} / {totalTrials} trials
        </Text>
      </View>

      {/* Celebration Animation */}
      {celebrationVisible && (
        <View style={styles.celebrationOverlay}>
          <Text style={styles.celebrationIcon}>🎉</Text>
          <Text style={styles.celebrationTitle}>Excellent Work!</Text>
        </View>
      )}
    </View>
  );
}

// Placeholder Components for Future Development
function RestrictedRepetitiveBehaviorsScreen({ onBack }: { onBack: () => void }) {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>🔄 Restricted & Repetitive Behaviors</Text>
        <View style={styles.placeholder} />
      </View>
      
      <View style={styles.placeholderContent}>
        <Text style={styles.placeholderIcon}>🚧</Text>
        <Text style={styles.placeholderTitle}>Coming Soon!</Text>
        <Text style={styles.placeholderText}>
          This component is under development and will be available in a future update.
        </Text>
      </View>
    </ScrollView>
  );
}

function VisualAttentionScreen({ onBack }: { onBack: () => void }) {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>👁️ Visual Attention</Text>
        <View style={styles.placeholder} />
      </View>
      
      <View style={styles.placeholderContent}>
        <Text style={styles.placeholderIcon}>🚧</Text>
        <Text style={styles.placeholderTitle}>Coming Soon!</Text>
        <Text style={styles.placeholderText}>
          This component is under development and will be available in a future update.
        </Text>
      </View>
    </ScrollView>
  );
}

function AuditoryResponseScreen({ onBack }: { onBack: () => void }) {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>👂 Auditory Response to Name</Text>
        <View style={styles.placeholder} />
      </View>
      
      <View style={styles.placeholderContent}>
        <Text style={styles.placeholderIcon}>🚧</Text>
        <Text style={styles.placeholderTitle}>Coming Soon!</Text>
        <Text style={styles.placeholderText}>
          This component is under development and will be available in a future update.
        </Text>
      </View>
    </ScrollView>
  );
}

  const [searchQuery, setSearchQuery] = useState('');
  const [sessionStartTime] = useState(Date.now());
  const [currentTime, setCurrentTime] = useState(new Date());

  // Update current time every second
  useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const components = [
    {
      id: 'cognitive_flexibility',
      title: 'Cognitive Flexibility & Rule-Switching',
      description: 'Assess executive function and cognitive flexibility through rule-switching tasks',
      icon: '🧠',
      color: '#2196F3',
      gradient: ['#2196F3', '#03A9F4'],
      status: 'Active',
      duration: '3-5 min',
      difficulty: 'Moderate'
    },
    {
      id: 'restricted_repetitive_behaviors',
      title: 'Restricted & Repetitive Behaviors',
      description: 'Evaluate repetitive patterns and restricted interests in children',
      icon: '🔄',
      color: '#4CAF50',
      gradient: ['#4CAF50', '#8BC34A'],
      status: 'Coming Soon',
      duration: '4-6 min',
      difficulty: 'Easy'
    },
    {
      id: 'visual_attention',
      title: 'Visual Attention',
      description: 'Test visual processing and attention patterns using eye-tracking',
      icon: '👁️',
      color: '#9C27B0',
      gradient: ['#9C27B0', '#E1BEE7'],
      status: 'Coming Soon',
      duration: '2-4 min',
      difficulty: 'Easy'
    },
    {
      id: 'auditory_response',
      title: 'Auditory Response to Name',
      description: 'Assess response to auditory stimuli and name recognition',
      icon: '👂',
      color: '#FF9800',
      gradient: ['#FF9800', '#FFC107'],
      status: 'Coming Soon',
      duration: '3-5 min',
      difficulty: 'Easy'
    }
  ];

  const filteredComponents = components.filter(component =>
    component.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
    component.description.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const formatSessionTime = () => {
    const elapsed = Math.floor((Date.now() - sessionStartTime) / 1000);
    const minutes = Math.floor(elapsed / 60);
    const seconds = elapsed % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  };

  return (
    <View style={styles.advancedContainer}>
      {/* Animated Background */}
      <View style={styles.animatedBackground}>
        <View style={styles.floatingShape1} />
        <View style={styles.floatingShape2} />
        <View style={styles.floatingShape3} />
      </View>

      <ScrollView style={styles.container} showsVerticalScrollIndicator={false}>
        {/* Professional Header */}
        <View style={styles.professionalHeader}>
          <View style={styles.headerTop}>
            <TouchableOpacity style={styles.logoutButton} onPress={onBack}>
              <Text style={styles.logoutIcon}>🚪</Text>
              <Text style={styles.logoutText}>Logout</Text>
            </TouchableOpacity>
            
            <View style={styles.logoSection}>
              <View style={styles.logoContainer}>
                <Text style={styles.logoIcon}>🧩</Text>
              </View>
              <Text style={styles.appTitle}>Early Autism Detection System</Text>
              <Text style={styles.appSubtitle}>Clinical Assessment Platform</Text>
            </View>

            <View style={styles.sessionInfo}>
              <Text style={styles.sessionTime}>{formatSessionTime()}</Text>
              <Text style={styles.sessionLabel}>Session Time</Text>
            </View>
          </View>

          {/* Search Bar */}
          <View style={styles.searchContainer}>
            <Text style={styles.searchIcon}>🔍</Text>
            <TextInput
              style={styles.searchInput}
              placeholder="Search components or children..."
              placeholderTextColor="#999"
              value={searchQuery}
              onChangeText={setSearchQuery}
            />
            {searchQuery.length > 0 && (
              <TouchableOpacity 
                style={styles.clearSearchButton}
                onPress={() => setSearchQuery('')}
              >
                <Text style={styles.clearSearchIcon}>✕</Text>
              </TouchableOpacity>
            )}
          </View>
        </View>

        {/* Welcome Section */}
        <View style={styles.welcomeSection}>
          <Text style={styles.welcomeTitle}>Welcome, Dr. {doctorId}</Text>
          <Text style={styles.welcomeSubtitle}>
            Select an assessment component to begin comprehensive autism screening
          </Text>
        </View>

        {/* Components Grid */}
        <View style={styles.componentsGrid}>
          {filteredComponents.map((component, index) => (
            <TouchableOpacity
              key={component.id}
              style={[
                styles.advancedComponentCard,
                component.status === 'Coming Soon' && styles.comingSoonCard
              ]}
              onPress={() => onSelectComponent(component.id)}
              activeOpacity={0.8}
            >
              <View style={[styles.componentIconContainer, { backgroundColor: component.color }]}>
                <Text style={styles.componentIconText}>{component.icon}</Text>
                {component.status === 'Active' && (
                  <View style={styles.activeIndicator} />
                )}
              </View>
              
              <View style={styles.componentContent}>
                <Text style={styles.componentTitle}>{component.title}</Text>
                <Text style={styles.componentDescription}>{component.description}</Text>
                
                <View style={styles.componentMeta}>
                  <View style={styles.metaItem}>
                    <Text style={styles.metaIcon}>⏱️</Text>
                    <Text style={styles.metaText}>{component.duration}</Text>
                  </View>
                  <View style={styles.metaItem}>
                    <Text style={styles.metaIcon}>📊</Text>
                    <Text style={styles.metaText}>{component.difficulty}</Text>
                  </View>
                </View>
                
                <View style={styles.componentFooter}>
                  <View style={[
                    styles.statusBadge, 
                    { backgroundColor: component.status === 'Active' ? '#4CAF50' : '#FF9800' }
                  ]}>
                    <Text style={styles.statusText}>{component.status}</Text>
                  </View>
                  
                  {component.status === 'Active' && (
                    <View style={styles.startButton}>
                      <Text style={styles.startButtonText}>Start Assessment</Text>
                      <Text style={styles.startArrow}>→</Text>
                    </View>
                  )}
                </View>
              </View>
            </TouchableOpacity>
          ))}
        </View>

        {/* Clinical Information Section */}
        <View style={styles.clinicalInfoSection}>
          <Text style={styles.clinicalTitle}>Clinical Information</Text>
          <View style={styles.infoGrid}>
            <View style={styles.infoCard}>
              <Text style={styles.infoIcon}>👶</Text>
              <Text style={styles.infoValue}>2-6</Text>
              <Text style={styles.infoLabel}>Age Range</Text>
            </View>
            <View style={styles.infoCard}>
              <Text style={styles.infoIcon}>⏱️</Text>
              <Text style={styles.infoValue}>3-5</Text>
              <Text style={styles.infoLabel}>Min per Test</Text>
            </View>
            <View style={styles.infoCard}>
              <Text style={styles.infoIcon}>📊</Text>
              <Text style={styles.infoValue}>Real-time</Text>
              <Text style={styles.infoLabel}>Analysis</Text>
            </View>
            <View style={styles.infoCard}>
              <Text style={styles.infoIcon}>🔒</Text>
              <Text style={styles.infoValue}>HIPAA</Text>
              <Text style={styles.infoLabel}>Compliant</Text>
            </View>
          </View>
        </View>

        {/* Quick Actions */}
        <View style={styles.quickActionsSection}>
          <Text style={styles.quickActionsTitle}>Quick Actions</Text>
          <View style={styles.quickActionsGrid}>
            <TouchableOpacity style={styles.quickActionButton}>
              <Text style={styles.quickActionIcon}>👥</Text>
              <Text style={styles.quickActionText}>View All Children</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.quickActionButton}>
              <Text style={styles.quickActionIcon}>📈</Text>
              <Text style={styles.quickActionText}>View Reports</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.quickActionButton}>
              <Text style={styles.quickActionIcon}>⚙️</Text>
              <Text style={styles.quickActionText}>Settings</Text>
            </TouchableOpacity>
            <TouchableOpacity style={styles.quickActionButton}>
              <Text style={styles.quickActionIcon}>❓</Text>
              <Text style={styles.quickActionText}>Help</Text>
            </TouchableOpacity>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}

// Main App Component
function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [currentScreen, setCurrentScreen] = useState('login');
  const [currentAuthScreen, setCurrentAuthScreen] = useState('login'); // 'login' or 'register'
  const [doctorId, setDoctorId] = useState('');
  const [currentChild, setCurrentChild] = useState<any>(null);
  const [sessions, setSessions] = useState<PilotSession[]>([]);
  const [currentGameType, setCurrentGameType] = useState<'frog_jump' | 'day_night' | 'color_shape' | null>(null);
  const [currentGameResults, setCurrentGameResults] = useState<PilotSession | null>(null);
  const [selectedComponent, setSelectedComponent] = useState<string | null>(null);
  const isDarkMode = useColorScheme() === 'dark';

  const handleSplashFinish = () => {
    setShowSplash(false);
  };

  const handleNavigateToRegister = () => {
    setCurrentAuthScreen('register');
  };

  const handleNavigateToLogin = () => {
    setCurrentAuthScreen('login');
  };

  const handleAuthSuccess = () => {
    setDoctorId('doctor_001');
    setCurrentScreen('mainDashboard');
  };

  const handleDoctorLogin = (id: string) => {
    setDoctorId(id);
    setCurrentScreen('mainDashboard');
  };

  const handleChildRegister = (child: any) => {
    setCurrentChild(child);
    setCurrentScreen('gameSelection');
  };

  const handleComponentSelect = (component: string) => {
    setSelectedComponent(component);
    if (component === 'cognitive_flexibility') {
      setCurrentScreen('cognitiveDashboard');
    } else if (component === 'restricted_repetitive_behaviors') {
      setCurrentScreen('rrbScreen');
    } else if (component === 'visual_attention') {
      setCurrentScreen('visualAttentionScreen');
    } else if (component === 'auditory_response') {
      setCurrentScreen('auditoryResponseScreen');
    }
  };

  const handleGameSelect = (gameType: string) => {
    if (gameType === 'go_no_go') {
      setCurrentGameType('frog_jump');
      setCurrentScreen('htmlGame');
    } else if (gameType === 'rule_switching') {
      setCurrentGameType('color_shape');
      setCurrentScreen('htmlGame');
    } else if (gameType === 'stroop') {
      setCurrentGameType('day_night');
      setCurrentScreen('htmlGame');
    }
  };

  const handleSessionComplete = async (results: any) => {
    try {
      // Create a proper PilotSession from the HTML game results
      const session: PilotSession = {
        id: `session_${Date.now()}`,
        childId: currentChild?.id || 'unknown',
        childName: currentChild?.name || 'Unknown',
        childAge: currentChild?.age || 0,
        childGender: currentChild?.gender || 'unknown',
        diagnosis: currentChild?.diagnosis || 'unknown',
        sessionDate: new Date().toISOString(),
        gameType: currentGameType === 'frog_jump' ? 'go_no_go' : 
                 currentGameType === 'day_night' ? 'stroop' : 'rule_switching',
        trials: results.trials || [],
        summary: {
          totalTrials: results.trials?.length || 0,
          accuracy: results.accuracy || 0,
          meanReactionTime: results.avgReactionTime || 0,
          switchCost: results.switchCost || 0,
          errors: results.trials ? results.trials.filter((t: any) => !t.correct).length : 0,
          preSwitchAccuracy: 0, // Will be calculated if needed
          postSwitchAccuracy: 0 // Will be calculated if needed
        },
        clinicianNotes: '',
        completionTime: results.completionTime || 0
      };
      
      const updatedSessions = [...sessions, session];
      setSessions(updatedSessions);
      await AsyncStorage.setItem('pilot_sessions', JSON.stringify(updatedSessions));
      
      // Show professional results screen
      setCurrentScreen('gameResults');
      setCurrentGameResults(session);
    } catch (error) {
      console.error('Error saving session:', error);
      Alert.alert('Error', 'Failed to save session data');
    }
  };


  // Show splash screen first
  if (showSplash) {
    return <SplashScreen onFinish={handleSplashFinish} />;
  }

  return (
    <AuthProvider>
      <View style={styles.appContainer}>
        <StatusBar 
          barStyle={isDarkMode ? 'light-content' : 'dark-content'} 
          backgroundColor="#2E86AB"
        />
        
        {currentScreen === 'login' && (
          <>
            {currentAuthScreen === 'login' && (
              <LoginScreen 
                onNavigateToRegister={handleNavigateToRegister}
                onAuthSuccess={handleAuthSuccess}
              />
            )}
            {currentAuthScreen === 'register' && (
              <RegistrationScreen 
                onNavigateToLogin={handleNavigateToLogin}
                onAuthSuccess={handleAuthSuccess}
              />
            )}
          </>
        )}
      {currentScreen === 'mainDashboard' && (
        <MainDashboardScreen 
          navigation={{
            navigate: (screen: string, params?: any) => {
              if (screen === 'AgeSelection') {
                handleComponentSelect('cognitive_flexibility');
              } else if (screen === 'AddChild') {
                // Handle add child navigation
                console.log('Navigate to AddChild');
              } else if (screen === 'Reports') {
                // Handle reports navigation
                console.log('Navigate to Reports');
              } else if (screen === 'Export') {
                // Handle export navigation
                console.log('Navigate to Export');
              } else if (screen === 'ChildrenList') {
                // Handle children list navigation
                console.log('Navigate to ChildrenList');
              } else if (screen === 'ChildDetails') {
                // Handle child details navigation
                console.log('Navigate to ChildDetails', params);
              } else if (screen === 'Notifications') {
                // Handle notifications navigation
                console.log('Navigate to Notifications');
              } else if (screen === 'Settings') {
                // Handle settings navigation
                console.log('Navigate to Settings');
              }
            }
          }}
        />
      )}
      {currentScreen === 'registration' && (
        <ChildRegistrationScreen 
          onRegister={handleChildRegister} 
          onBack={() => setCurrentScreen('login')} 
        />
      )}
      {currentScreen === 'gameSelection' && currentChild && (
        <GameSelectionScreen 
          child={currentChild}
          onSelectGame={handleGameSelect} 
          onBack={() => setCurrentScreen('registration')} 
          onGoToDashboard={() => setCurrentScreen('mainDashboard')}
        />
      )}
      {currentScreen === 'goNoGoGame' && currentChild && (
        <GoNoGoGameScreen 
          child={currentChild}
          onComplete={handleSessionComplete} 
          onBack={() => setCurrentScreen('gameSelection')} 
        />
      )}
      {currentScreen === 'stroopGame' && currentChild && (
        <StroopGameScreen 
          child={currentChild}
          onComplete={handleSessionComplete} 
          onBack={() => setCurrentScreen('gameSelection')} 
        />
      )}
      {currentScreen === 'ruleSwitchingGame' && currentChild && (
        <RuleSwitchingGameScreen 
          child={currentChild}
          onComplete={handleSessionComplete} 
          onBack={() => setCurrentScreen('gameSelection')} 
        />
      )}
        {currentScreen === 'cognitiveDashboard' && (
          <CognitiveFlexibilityDashboard 
            onBack={() => setCurrentScreen('mainDashboard')} 
            onStartNewAssessment={() => setCurrentScreen('registration')} 
          />
        )}
        {currentScreen === 'rrbScreen' && (
          <RestrictedRepetitiveBehaviorsScreen 
            onBack={() => setCurrentScreen('mainDashboard')} 
          />
        )}
        {currentScreen === 'visualAttentionScreen' && (
          <VisualAttentionScreen 
            onBack={() => setCurrentScreen('mainDashboard')} 
          />
        )}
        {currentScreen === 'auditoryResponseScreen' && (
          <AuditoryResponseScreen 
            onBack={() => setCurrentScreen('mainDashboard')} 
          />
        )}
      {currentScreen === 'htmlGame' && currentGameType && currentChild && (
        <GameWebView
          gameType={currentGameType}
          onGameComplete={handleSessionComplete}
          onGoBack={() => setCurrentScreen('gameSelection')}
          child={currentChild}
        />
      )}
      {currentScreen === 'gameResults' && currentGameResults && (
        <GameResultsScreen
          session={currentGameResults}
            onBack={() => setCurrentScreen('mainDashboard')}
          onNewGame={() => setCurrentScreen('gameSelection')}
        />
      )}
      </View>
    </AuthProvider>
  );
}

const styles = StyleSheet.create({
  appContainer: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  // Advanced Main Dashboard Styles
  advancedContainer: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  animatedBackground: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    zIndex: 0,
  },
  floatingShape1: {
    position: 'absolute',
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: 'rgba(33, 150, 243, 0.1)',
    top: '10%',
    right: '10%',
    animation: 'float 6s ease-in-out infinite',
  },
  floatingShape2: {
    position: 'absolute',
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(76, 175, 80, 0.1)',
    top: '60%',
    left: '5%',
    animation: 'float 8s ease-in-out infinite reverse',
  },
  floatingShape3: {
    position: 'absolute',
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(156, 39, 176, 0.1)',
    top: '30%',
    left: '20%',
    animation: 'float 10s ease-in-out infinite',
  },
  professionalHeader: {
    backgroundColor: 'white',
    paddingTop: 20,
    paddingBottom: 20,
    paddingHorizontal: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 5,
    zIndex: 10,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 15,
    paddingVertical: 8,
    backgroundColor: '#F5F5F5',
    borderRadius: 20,
  },
  logoutIcon: {
    fontSize: 16,
    marginRight: 5,
  },
  logoutText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  logoSection: {
    alignItems: 'center',
    flex: 1,
  },
  logoContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#2196F3',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 8,
  },
  logoIcon: {
    fontSize: 24,
  },
  appTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1A1A1A',
    textAlign: 'center',
  },
  appSubtitle: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
    marginTop: 2,
  },
  sessionInfo: {
    alignItems: 'center',
  },
  sessionTime: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2196F3',
  },
  sessionLabel: {
    fontSize: 10,
    color: '#666',
    marginTop: 2,
  },
  searchContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    borderRadius: 25,
    paddingHorizontal: 15,
    paddingVertical: 10,
    borderWidth: 1,
    borderColor: '#E9ECEF',
  },
  searchIcon: {
    fontSize: 16,
    marginRight: 10,
    color: '#666',
  },
  searchInput: {
    flex: 1,
    fontSize: 16,
    color: '#333',
  },
  clearSearchButton: {
    padding: 5,
  },
  clearSearchIcon: {
    fontSize: 16,
    color: '#666',
  },
  dashboardContainer: {
    flex: 1,
    padding: 20,
  },
  welcomeSection: {
    alignItems: 'center',
    marginBottom: 30,
    paddingVertical: 20,
  },
  welcomeTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1A1A1A',
    textAlign: 'center',
    marginBottom: 8,
  },
  welcomeSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 22,
    paddingHorizontal: 20,
  },
  componentsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 30,
  },
  componentCard: {
    width: '48%',
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  advancedComponentCard: {
    width: '48%',
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 8,
    elevation: 6,
    borderWidth: 1,
    borderColor: '#F0F0F0',
  },
  comingSoonCard: {
    opacity: 0.6,
  },
  componentIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  componentIconContainer: {
    width: 70,
    height: 70,
    borderRadius: 35,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
    position: 'relative',
  },
  componentIconText: {
    fontSize: 32,
  },
  activeIndicator: {
    position: 'absolute',
    top: -2,
    right: -2,
    width: 20,
    height: 20,
    borderRadius: 10,
    backgroundColor: '#4CAF50',
    borderWidth: 3,
    borderColor: 'white',
  },
  componentContent: {
    flex: 1,
  },
  componentTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1A1A1A',
    marginBottom: 8,
    lineHeight: 22,
  },
  componentDescription: {
    fontSize: 13,
    color: '#666',
    lineHeight: 18,
    marginBottom: 12,
  },
  componentMeta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 15,
  },
  metaItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  metaIcon: {
    fontSize: 12,
    marginRight: 4,
  },
  metaText: {
    fontSize: 11,
    color: '#666',
    fontWeight: '500',
  },
  componentFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  statusBadge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
  },
  statusText: {
    fontSize: 12,
    fontWeight: 'bold',
    color: 'white',
  },
  startText: {
    fontSize: 12,
    color: '#2E86AB',
    fontWeight: 'bold',
  },
  startButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#2196F3',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 15,
  },
  startButtonText: {
    fontSize: 11,
    color: 'white',
    fontWeight: 'bold',
    marginRight: 4,
  },
  startArrow: {
    fontSize: 12,
    color: 'white',
    fontWeight: 'bold',
  },
  clinicalInfoSection: {
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  clinicalTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1A1A1A',
    marginBottom: 15,
    textAlign: 'center',
  },
  infoGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  infoCard: {
    width: '48%',
    alignItems: 'center',
    paddingVertical: 15,
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    marginBottom: 10,
  },
  infoIcon: {
    fontSize: 24,
    marginBottom: 8,
  },
  infoValue: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#2196F3',
    marginBottom: 4,
  },
  infoLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  quickActionsSection: {
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  quickActionsTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1A1A1A',
    marginBottom: 15,
    textAlign: 'center',
  },
  quickActionsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  quickActionButton: {
    width: '48%',
    alignItems: 'center',
    paddingVertical: 15,
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#E9ECEF',
  },
  quickActionIcon: {
    fontSize: 20,
    marginBottom: 8,
  },
  quickActionText: {
    fontSize: 12,
    color: '#333',
    textAlign: 'center',
    fontWeight: '500',
  },
  // Advanced Game Styles
  advancedGameContainer: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  gameHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingVertical: 15,
    backgroundColor: 'white',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  gameTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1A1A1A',
    flex: 1,
    textAlign: 'center',
  },
  scoreContainer: {
    backgroundColor: '#2196F3',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 15,
  },
  scoreText: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
  instructionsContainer: {
    flex: 1,
    padding: 20,
  },
  instructionsCard: {
    backgroundColor: 'white',
    borderRadius: 20,
    padding: 25,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  instructionsTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1A1A1A',
    marginBottom: 15,
    textAlign: 'center',
  },
  instructionsText: {
    fontSize: 16,
    color: '#666',
    lineHeight: 24,
    marginBottom: 20,
    textAlign: 'center',
  },
  ruleSection: {
    backgroundColor: '#F8F9FA',
    borderRadius: 15,
    padding: 20,
    marginBottom: 15,
  },
  ruleTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2196F3',
    marginBottom: 10,
  },
  ruleExample: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  ruleEmoji: {
    fontSize: 30,
    marginRight: 15,
  },
  ruleText: {
    fontSize: 16,
    color: '#333',
    fontWeight: '500',
  },
  importantNote: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF3CD',
    borderRadius: 10,
    padding: 15,
    borderLeftWidth: 4,
    borderLeftColor: '#FFC107',
  },
  noteIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  noteText: {
    fontSize: 14,
    color: '#856404',
    flex: 1,
  },
  startGameButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#2196F3',
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 25,
    marginTop: 20,
  },
  startGameButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
    marginRight: 10,
  },
  startGameArrow: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  ruleSwitchNotification: {
    backgroundColor: '#FF9800',
    paddingVertical: 15,
    paddingHorizontal: 20,
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'center',
  },
  ruleSwitchIcon: {
    fontSize: 20,
    marginRight: 10,
  },
  ruleSwitchText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  ruleDisplay: {
    backgroundColor: 'white',
    paddingVertical: 20,
    paddingHorizontal: 30,
    alignItems: 'center',
    marginHorizontal: 20,
    marginVertical: 10,
    borderRadius: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  ruleLabel: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  currentRuleText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2196F3',
  },
  stimulusContainer: {
    alignItems: 'center',
    paddingVertical: 30,
  },
  stimulusLabel: {
    fontSize: 18,
    color: '#333',
    marginBottom: 20,
    fontWeight: '500',
  },
  stimulusDisplay: {
    width: 150,
    height: 150,
    borderRadius: 75,
    backgroundColor: 'white',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 6,
  },
  stimulusEmoji: {
    fontSize: 80,
  },
  responseContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    paddingHorizontal: 40,
    paddingVertical: 20,
  },
  responseButton: {
    paddingVertical: 20,
    paddingHorizontal: 30,
    borderRadius: 25,
    minWidth: 120,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },
  colorButton: {
    backgroundColor: '#E91E63',
  },
  shapeButton: {
    backgroundColor: '#9C27B0',
  },
  responseButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  feedbackContainer: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -100 }, { translateY: -50 }],
    backgroundColor: 'white',
    paddingVertical: 20,
    paddingHorizontal: 30,
    borderRadius: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  correctFeedback: {
    borderWidth: 3,
    borderColor: '#4CAF50',
  },
  incorrectFeedback: {
    borderWidth: 3,
    borderColor: '#F44336',
  },
  feedbackIcon: {
    fontSize: 40,
    marginBottom: 10,
  },
  feedbackText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  progressContainer: {
    paddingHorizontal: 20,
    paddingVertical: 15,
  },
  progressBar: {
    height: 8,
    backgroundColor: '#E0E0E0',
    borderRadius: 4,
    overflow: 'hidden',
    marginBottom: 10,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#2196F3',
    borderRadius: 4,
  },
  progressText: {
    textAlign: 'center',
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  celebrationOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  celebrationContainer: {
    alignItems: 'center',
    backgroundColor: 'white',
    paddingVertical: 40,
    paddingHorizontal: 30,
    borderRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  celebrationIcon: {
    fontSize: 80,
    marginBottom: 20,
  },
  celebrationTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#2196F3',
    marginBottom: 10,
    textAlign: 'center',
  },
  celebrationSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
  },
  infoSection: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 15,
  },
  infoText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginBottom: 8,
  },
  // Placeholder Screen Styles
  placeholderContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  placeholderIcon: {
    fontSize: 80,
    marginBottom: 20,
  },
  placeholderTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 15,
    textAlign: 'center',
  },
  placeholderText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 24,
  },
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 20,
    paddingBottom: 10,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  backButton: {
    paddingVertical: 5,
  },
  backButtonText: {
    fontSize: 18,
    color: '#2E86AB',
    fontWeight: '600',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E86AB',
    textAlign: 'center',
  },
  placeholder: {
    width: 60,
  },
  subtitle: {
    fontSize: 16,
    color: '#A23B72',
    textAlign: 'center',
    marginBottom: 10,
  },
  description: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 20,
  },
  pilotNote: {
    fontSize: 12,
    color: '#999',
    textAlign: 'center',
    marginTop: 20,
    fontStyle: 'italic',
  },
  loginContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 40,
  },
  inputContainer: {
    marginBottom: 20,
    width: '100%',
  },
  inputLabel: {
    fontSize: 16,
    color: '#333',
    marginBottom: 8,
    fontWeight: '600',
  },
  inputBox: {
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    padding: 15,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    fontSize: 16,
    color: '#333',
  },
  loginButton: {
    backgroundColor: '#2E86AB',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
    marginTop: 20,
  },
  loginButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
    textAlign: 'center',
  },
  registrationContainer: {
    paddingHorizontal: 20,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  inputGroup: {
    marginBottom: 25,
  },
  ageButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  ageButton: {
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    paddingVertical: 15,
    paddingHorizontal: 20,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  ageButtonSelected: {
    backgroundColor: '#2E86AB',
    borderColor: '#2E86AB',
  },
  ageButtonText: {
    fontSize: 18,
    color: '#333',
    fontWeight: '600',
  },
  ageButtonTextSelected: {
    color: 'white',
  },
  genderButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  genderButton: {
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  genderButtonSelected: {
    backgroundColor: '#2E86AB',
    borderColor: '#2E86AB',
  },
  genderButtonText: {
    fontSize: 16,
    color: '#333',
    fontWeight: '600',
  },
  genderButtonTextSelected: {
    color: 'white',
  },
  diagnosisButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  diagnosisButton: {
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  diagnosisButtonSelected: {
    backgroundColor: '#A23B72',
    borderColor: '#A23B72',
  },
  diagnosisButtonText: {
    fontSize: 14,
    color: '#333',
    fontWeight: '600',
  },
  diagnosisButtonTextSelected: {
    color: 'white',
  },
  languageButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  languageButton: {
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    paddingVertical: 12,
    paddingHorizontal: 15,
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  languageButtonSelected: {
    backgroundColor: '#F18F01',
    borderColor: '#F18F01',
  },
  languageButtonText: {
    fontSize: 14,
    color: '#333',
    fontWeight: '600',
  },
  languageButtonTextSelected: {
    color: 'white',
  },
  registerButton: {
    backgroundColor: '#2E86AB',
    paddingVertical: 15,
    borderRadius: 8,
    marginTop: 20,
  },
  registerButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  childInfo: {
    backgroundColor: '#E3F2FD',
    padding: 15,
    marginHorizontal: 20,
    borderRadius: 8,
    marginBottom: 20,
  },
  childInfoText: {
    fontSize: 16,
    color: '#2E86AB',
    fontWeight: '600',
    textAlign: 'center',
  },
  gamesContainer: {
    paddingHorizontal: 20,
  },
  gameCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 20,
    marginBottom: 15,
    flexDirection: 'row',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  gameCardRecommended: {
    borderLeftWidth: 4,
    borderLeftColor: '#4CAF50',
  },
  dashboardCard: {
    borderLeftWidth: 4,
    borderLeftColor: '#2E86AB',
    backgroundColor: '#E3F2FD',
  },
  gameIcon: {
    fontSize: 32,
    marginRight: 15,
  },
  gameContent: {
    flex: 1,
  },
  gameName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  gameDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  gameDetails: {
    fontSize: 12,
    color: '#999',
  },
  recommendedText: {
    fontSize: 12,
    color: '#4CAF50',
    fontWeight: '600',
    marginTop: 5,
  },
  dashboardText: {
    color: '#2E86AB',
    fontSize: 12,
    fontWeight: '600',
    marginTop: 5,
  },
  instructionsContainer: {
    flex: 1,
    paddingHorizontal: 20,
    justifyContent: 'center',
  },
  instructionsTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  instructionsText: {
    fontSize: 18,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 26,
  },
  exampleContainer: {
    marginBottom: 30,
  },
  exampleTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
    textAlign: 'center',
  },
  exampleRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 15,
  },
  exampleStimulus: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  exampleText: {
    fontSize: 24,
    color: 'white',
  },
  exampleLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  startButton: {
    backgroundColor: '#2E86AB',
    paddingVertical: 15,
    borderRadius: 8,
  },
  startButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
    textAlign: 'center',
  },
  gameArea: {
    flex: 1,
    paddingHorizontal: 20,
    justifyContent: 'center',
  },
  gameInfo: {
    marginBottom: 30,
  },
  trialText: {
    fontSize: 18,
    color: '#333',
    fontWeight: '600',
    textAlign: 'center',
  },
  stimulusContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },
  stimulus: {
    width: 150,
    height: 150,
    borderRadius: 75,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  stimulusText: {
    fontSize: 64,
    color: 'white',
  },
  instructionText: {
    alignItems: 'center',
  },
  instructionLabel: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
  },
  resultsContainer: {
    flex: 1,
    paddingHorizontal: 20,
  },
  resultsCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  resultsTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  metricRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 15,
  },
  metricLabel: {
    fontSize: 16,
    color: '#666',
  },
  metricValue: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
  },
  completeButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 15,
    borderRadius: 8,
  },
  completeButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  ruleText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#2E86AB',
    textAlign: 'center',
    marginBottom: 20,
  },
  // Dashboard styles
  dashboardContainer: {
    paddingHorizontal: 20,
  },
  overviewStats: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  overviewCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    width: '48%',
    marginBottom: 10,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  overviewValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 5,
  },
  overviewLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  navigationButtons: {
    flexDirection: 'row',
    marginBottom: 20,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    padding: 4,
  },
  navButton: {
    flex: 1,
    paddingVertical: 10,
    paddingHorizontal: 15,
    borderRadius: 6,
    alignItems: 'center',
  },
  navButtonActive: {
    backgroundColor: '#2E86AB',
  },
  navButtonText: {
    fontSize: 14,
    color: '#666',
    fontWeight: '600',
  },
  navButtonTextActive: {
    color: 'white',
  },
  childrenList: {
    marginBottom: 20,
  },
  childCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  childCardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 8,
  },
  childCardName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  riskBadge: {
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
  },
  childCardInfo: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  childCardSessions: {
    fontSize: 12,
    color: '#999',
    marginBottom: 8,
  },
  childCardMetrics: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  childCardMetric: {
    fontSize: 12,
    color: '#2E86AB',
    fontWeight: '600',
  },
  childHeader: {
    backgroundColor: '#E3F2FD',
    padding: 15,
    marginHorizontal: 20,
    borderRadius: 8,
    marginBottom: 20,
  },
  childName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 5,
  },
  statsContainer: {
    marginBottom: 20,
  },
  metricGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  metricCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    width: '48%',
    marginBottom: 10,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  sessionsContainer: {
    marginBottom: 20,
  },
  sessionCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  sessionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 10,
  },
  sessionNumber: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
  },
  sessionDate: {
    fontSize: 12,
    color: '#666',
  },
  sessionMetrics: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  sessionMetric: {
    width: '48%',
    marginBottom: 5,
  },
  sessionMetricLabel: {
    fontSize: 12,
    color: '#666',
  },
  sessionMetricValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  analyticsContainer: {
    paddingHorizontal: 20,
  },
  riskDistribution: {
    marginBottom: 20,
  },
  riskBars: {
    marginTop: 10,
  },
  riskBar: {
    marginBottom: 10,
  },
  riskBarFill: {
    height: 20,
    borderRadius: 10,
    marginBottom: 5,
  },
  riskBarLabel: {
    fontSize: 12,
    color: '#666',
  },
  gameDistribution: {
    marginBottom: 20,
  },
  gameStats: {
    marginTop: 10,
  },
  gameStat: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  gameStatLabel: {
    fontSize: 14,
    color: '#666',
  },
  gameStatValue: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  newButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 6,
  },
  newButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  childId: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  addChildButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 15,
    paddingVertical: 8,
    borderRadius: 6,
  },
  addChildButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  refreshButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 8,
    paddingHorizontal: 15,
    borderRadius: 20,
    marginLeft: 10,
    alignItems: 'center',
  },
  refreshButtonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: 'bold',
  },
  emptyState: {
    alignItems: 'center',
    paddingVertical: 40,
    paddingHorizontal: 20,
  },
  emptyStateIcon: {
    fontSize: 48,
    marginBottom: 15,
  },
  emptyStateTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 8,
  },
  emptyStateText: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
  },
  emptyStateButton: {
    backgroundColor: '#2E86AB',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
  },
  emptyStateButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  childCardNameContainer: {
    flex: 1,
  },
  childCardId: {
    fontSize: 12,
    color: '#999',
    marginTop: 2,
  },
  dashboardButton: {
    backgroundColor: '#2E86AB',
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 6,
  },
  dashboardButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  // Child-friendly game styles
  gameIconLarge: {
    alignItems: 'center',
    marginBottom: 20,
  },
  gameIconText: {
    fontSize: 80,
  },
  scoreText: {
    fontSize: 20,
    color: '#FFD700',
    fontWeight: 'bold',
    textAlign: 'center',
    marginTop: 10,
  },
  celebrationContainer: {
    backgroundColor: '#E8F5E8',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#4CAF50',
  },
  celebrationText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#4CAF50',
    textAlign: 'center',
  },
  celebrationSubtext: {
    fontSize: 16,
    color: '#2E7D32',
    textAlign: 'center',
    marginTop: 5,
  },
  encouragementContainer: {
    backgroundColor: '#FFF3E0',
    borderRadius: 15,
    padding: 15,
    marginBottom: 20,
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#FF9800',
  },
  encouragementText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FF9800',
    textAlign: 'center',
  },
  stimulusLabel: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginTop: 15,
  },
  section: {
    backgroundColor: 'white',
    borderRadius: 15,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  infoGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  infoItem: {
    width: '48%',
    marginBottom: 10,
  },
  infoLabel: {
    fontSize: 14,
    color: '#666',
    fontWeight: '600',
  },
  infoValue: {
    fontSize: 16,
    color: '#333',
    fontWeight: 'bold',
  },
  metricsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
  },
  riskCard: {
    backgroundColor: '#F8F9FA',
    borderRadius: 10,
    padding: 20,
    borderWidth: 2,
    alignItems: 'center',
  },
  riskLevel: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  riskDescription: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 22,
  },
  notesInput: {
    borderWidth: 1,
    borderColor: '#DDD',
    borderRadius: 10,
    padding: 15,
    fontSize: 16,
    textAlignVertical: 'top',
    backgroundColor: '#F8F9FA',
  },
  actionButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 20,
  },
  primaryButton: {
    flex: 1,
    backgroundColor: '#4CAF50',
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 25,
    marginRight: 10,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  secondaryButton: {
    flex: 1,
    backgroundColor: '#6C757D',
    paddingVertical: 15,
    paddingHorizontal: 30,
    borderRadius: 25,
    marginLeft: 10,
    alignItems: 'center',
  },
  secondaryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
  // Missing styles for response buttons
  responseButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginTop: 20,
  },
  responseButton: {
    width: 120,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginHorizontal: 10,
  },
  responseButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: 'white',
  },
});

export default App;
