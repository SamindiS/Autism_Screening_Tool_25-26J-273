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
  Modal
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const { width, height } = Dimensions.get('window');

// Types for pilot study data
interface PilotSession {
  id: string;
  childId: string;
  childAge: number;
  childGender: 'M' | 'F';
  diagnosis: 'ASD' | 'Control' | 'Unknown';
  sessionDate: string;
  gameType: 'go_no_go' | 'rule_switching';
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
    // Simple authentication for pilot (in production, use proper auth)
    if (doctorId && password) {
      onLogin(doctorId);
    } else {
      Alert.alert('Error', 'Please enter both Doctor ID and Password');
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
          <View style={styles.inputBox}>
            <Text style={styles.inputText}>{doctorId || 'Enter Doctor ID'}</Text>
          </View>
        </View>
        
        <View style={styles.inputContainer}>
          <Text style={styles.inputLabel}>Password</Text>
          <View style={styles.inputBox}>
            <Text style={styles.inputText}>{password ? '••••••••' : 'Enter Password'}</Text>
          </View>
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
  const [age, setAge] = useState('');
  const [gender, setGender] = useState<'M' | 'F' | ''>('');
  const [diagnosis, setDiagnosis] = useState<'ASD' | 'Control' | 'Unknown'>('Unknown');
  const [language, setLanguage] = useState<'English' | 'Sinhala' | 'Tamil'>('English');

  const handleRegister = () => {
    if (!childId || !age || !gender) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }
    
    const child = {
      id: childId,
      age: parseInt(age),
      gender,
      diagnosis,
      language
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
          <View style={styles.inputBox}>
            <Text style={styles.inputText}>{childId || 'Enter Child ID (e.g., P001)'}</Text>
          </View>
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
        
        <TouchableOpacity style={styles.registerButton} onPress={handleRegister}>
          <Text style={styles.registerButtonText}>Register Child & Start Assessment</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

// Game Selection Screen
function GameSelectionScreen({ child, onSelectGame, onBack }: { 
  child: any; 
  onSelectGame: (gameType: string) => void; 
  onBack: () => void; 
}) {
  const getRecommendedGame = () => {
    if (child.age <= 3) return 'go_no_go';
    return 'rule_switching';
  };

  const games = [
    {
      id: 'go_no_go',
      name: 'Go/No-Go Game',
      description: 'Tap the green circle, don\'t tap the red stop sign',
      ageRange: '2-3 years',
      duration: '2-3 minutes',
      icon: '🟢',
      recommended: child.age <= 3
    },
    {
      id: 'rule_switching',
      name: 'Rule Switching Game',
      description: 'Switch between tapping by color and shape',
      ageRange: '4-6 years',
      duration: '3-5 minutes',
      icon: '🔄',
      recommended: child.age >= 4
    }
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Select Game</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.childInfo}>
        <Text style={styles.childInfoText}>
          Child: {child.id} | Age: {child.age} | {child.gender}
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

// Go/No-Go Game Screen
function GoNoGoGameScreen({ child, onComplete, onBack }: { 
  child: any; 
  onComplete: (session: PilotSession) => void; 
  onBack: () => void; 
}) {
  const [currentTrial, setCurrentTrial] = useState(1);
  const [trials, setTrials] = useState<Trial[]>([]);
  const [gamePhase, setGamePhase] = useState<'instructions' | 'practice' | 'main' | 'complete'>('instructions');
  const [startTime, setStartTime] = useState<number | null>(null);
  const [currentStimulus, setCurrentStimulus] = useState<'green' | 'red' | null>(null);
  const [sessionStartTime, setSessionStartTime] = useState<number>(Date.now());
  
  const maxTrials = 20;
  const practiceTrials = 5;

  const getInstructions = () => {
    const instructions = {
      English: "Tap the GREEN circle when you see it. Don't tap the RED stop sign!",
      Sinhala: "කොළ පැහැ වෘත්තය දැකූ විට එය තට්ටු කරන්න. රතු නවත්වන ලකුණ තට්ටු නොකරන්න!",
      Tamil: "பச்சை வட்டத்தை பார்த்தால் அதைத் தொடவும். சிவப்பு நிறுத்து அடையாளத்தைத் தொடாதீர்கள்!"
    };
    return instructions[child.language] || instructions.English;
  };

  const generateStimulus = () => {
    // 70% green (go), 30% red (no-go)
    return Math.random() < 0.7 ? 'green' : 'red';
  };

  const handleResponse = (response: 'tap' | 'no_tap') => {
    if (!startTime || !currentStimulus) return;

    const reactionTime = Date.now() - startTime;
    const isCorrect = (currentStimulus === 'green' && response === 'tap') || 
                     (currentStimulus === 'red' && response === 'no_tap');

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
          <Text style={styles.title}>Go/No-Go Game</Text>
          <View style={styles.placeholder} />
        </View>

        <View style={styles.instructionsContainer}>
          <Text style={styles.instructionsTitle}>Instructions</Text>
          <Text style={styles.instructionsText}>{getInstructions()}</Text>
          
          <View style={styles.exampleContainer}>
            <Text style={styles.exampleTitle}>Examples:</Text>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#4CAF50' }]}>
                <Text style={styles.exampleText}>●</Text>
              </View>
              <Text style={styles.exampleLabel}>TAP THIS</Text>
            </View>
            <View style={styles.exampleRow}>
              <View style={[styles.exampleStimulus, { backgroundColor: '#F44336' }]}>
                <Text style={styles.exampleText}>⛔</Text>
              </View>
              <Text style={styles.exampleLabel}>DON'T TAP</Text>
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
        <Text style={styles.title}>Go/No-Go Game</Text>
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
                { backgroundColor: currentStimulus === 'green' ? '#4CAF50' : '#F44336' }
              ]}
              onPress={() => handleResponse('tap')}
            >
              <Text style={styles.stimulusText}>
                {currentStimulus === 'green' ? '●' : '⛔'}
              </Text>
            </TouchableOpacity>
          </View>
        )}

        <View style={styles.instructionText}>
          <Text style={styles.instructionLabel}>
            {currentStimulus === 'green' ? 'TAP THIS!' : 'DON\'T TAP!'}
          </Text>
        </View>
      </View>
    </View>
  );
}

// Main App Component
function App() {
  const [currentScreen, setCurrentScreen] = useState('login');
  const [doctorId, setDoctorId] = useState('');
  const [currentChild, setCurrentChild] = useState<any>(null);
  const [sessions, setSessions] = useState<PilotSession[]>([]);
  const isDarkMode = useColorScheme() === 'dark';

  const handleDoctorLogin = (id: string) => {
    setDoctorId(id);
    setCurrentScreen('registration');
  };

  const handleChildRegister = (child: any) => {
    setCurrentChild(child);
    setCurrentScreen('gameSelection');
  };

  const handleGameSelect = (gameType: string) => {
    if (gameType === 'go_no_go') {
      setCurrentScreen('goNoGoGame');
    } else {
      // Rule switching game would go here
      Alert.alert('Coming Soon', 'Rule Switching game will be available in the next version');
    }
  };

  const handleSessionComplete = async (session: PilotSession) => {
    try {
      const updatedSessions = [...sessions, session];
      setSessions(updatedSessions);
      await AsyncStorage.setItem('pilot_sessions', JSON.stringify(updatedSessions));
      Alert.alert('Success', 'Session data saved successfully!');
      setCurrentScreen('registration'); // Ready for next child
    } catch (error) {
      Alert.alert('Error', 'Failed to save session data');
    }
  };

  const loadSessions = async () => {
    try {
      const savedSessions = await AsyncStorage.getItem('pilot_sessions');
      if (savedSessions) {
        setSessions(JSON.parse(savedSessions));
      }
    } catch (error) {
      console.error('Failed to load sessions:', error);
    }
  };

  useEffect(() => {
    loadSessions();
  }, []);

  return (
    <View style={styles.appContainer}>
      <StatusBar 
        barStyle={isDarkMode ? 'light-content' : 'dark-content'} 
        backgroundColor="#2E86AB"
      />
      
      {currentScreen === 'login' && (
        <DoctorLoginScreen onLogin={handleDoctorLogin} />
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
        />
      )}
      {currentScreen === 'goNoGoGame' && currentChild && (
        <GoNoGoGameScreen 
          child={currentChild}
          onComplete={handleSessionComplete} 
          onBack={() => setCurrentScreen('gameSelection')} 
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  appContainer: {
    flex: 1,
    backgroundColor: '#F5F5F5',
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
  },
  inputText: {
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
});

export default App;









