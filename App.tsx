/**
 * Autism Screening App - Professional Dashboard Version
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
import CognitiveDashboardScreen from './src/screens/CognitiveDashboardScreen';
import ChildRegistrationScreen from './src/screens/ChildRegistrationScreen';
import AIDoctorBotScreen from './src/screens/AIDoctorBotScreen';
import { AuthProvider } from './src/context/AuthContext';
import { AppProvider } from './src/context/AppContext';
import { LanguageProvider } from './src/context/LanguageContext';
import { storageService } from './src/services/storage';

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
  correct: boolean;
  reactionTime: number;
  timestamp: string;
}

interface SessionSummary {
  totalTrials: number;
  correctTrials: number;
  accuracy: number;
  averageReactionTime: number;
  switchCost: number;
  errorRate: number;
  riskScore: number;
  recommendations: string[];
}


// Main App Component
function App() {
  const [showSplash, setShowSplash] = useState(true);
  const [currentScreen, setCurrentScreen] = useState('login');
  const [previousScreen, setPreviousScreen] = useState('mainDashboard');
  const [currentAuthScreen, setCurrentAuthScreen] = useState('login'); // 'login' or 'register'
  const [doctorId, setDoctorId] = useState('');
  const [currentChild, setCurrentChild] = useState<any>(null);
  const [sessions, setSessions] = useState<PilotSession[]>([]);
  const [currentGameType, setCurrentGameType] = useState<'frog_jump' | 'day_night' | 'color_shape' | null>(null);
  const [currentGameResults, setCurrentGameResults] = useState<PilotSession | null>(null);
  const [selectedComponent, setSelectedComponent] = useState<string | null>(null);
  const isDarkMode = useColorScheme() === 'dark';

  // Initialize storage service
  useEffect(() => {
    const initializeStorage = async () => {
      try {
        await storageService.initialize();
        console.log('Storage service initialized successfully');
      } catch (error) {
        console.error('Failed to initialize storage service:', error);
      }
    };
    
    initializeStorage();
  }, []);

  const handleLogin = (email: string, password: string) => {
    // Mock login - in real app, this would validate credentials
    const doctorId = email.split('@')[0];
    setDoctorId(doctorId);
    setCurrentScreen('mainDashboard');
  };

  const handleRegister = (userData: any) => {
    // Mock registration
    const doctorId = userData.email.split('@')[0];
    setDoctorId(doctorId);
    setCurrentScreen('mainDashboard');
  };

  const handleAuthSuccess = () => {
    setCurrentScreen('mainDashboard');
  };

  const handleChildRegister = () => {
    setCurrentScreen('childRegistration');
  };

  const handleChildAdded = (child: any) => {
    setCurrentChild(child);
    setCurrentScreen(previousScreen);
  };

  const handleChildRegistrationCancel = () => {
    setCurrentScreen(previousScreen);
  };

  const handleComponentSelect = (component: string) => {
    setSelectedComponent(component);
    
    if (component === 'cognitive_flexibility') {
      setCurrentScreen('ageSelection');
    } else {
      Alert.alert('Coming Soon', 'This component is not yet available');
    }
  };

  const handleAgeSelection = (age: number) => {
    if (!currentChild) {
      Alert.alert('Error', 'Please register a child first');
      return;
    }

    // Use the child's actual age instead of the selected age
    const childAge = currentChild.age;
    
    // Select appropriate game based on child's age group
    let gameType: 'frog_jump' | 'day_night' | 'color_shape';
    if (childAge >= 2 && childAge <= 3) {
      gameType = 'frog_jump'; // Go/No-Go for 2-3 years
    } else if (childAge >= 4 && childAge <= 5) {
      gameType = 'day_night'; // Stroop for 4-5 years
    } else if (childAge >= 5 && childAge <= 6) {
      gameType = 'color_shape'; // DCCS for 5-6 years
    } else {
      // Default to frog_jump for any edge cases
      gameType = 'frog_jump';
    }

    setCurrentGameType(gameType);
    setCurrentScreen('game');
  };

  const handleGameComplete = (results: any) => {
    // Transform game results to match PilotSession format
    const transformedResults = {
      id: Date.now().toString(),
      childId: currentChild?.id || '',
      childName: currentChild?.name || '',
      childAge: currentChild?.age || 0,
      childGender: currentChild?.gender || 'M',
      diagnosis: 'Unknown' as const,
      sessionDate: new Date().toISOString(),
      gameType: currentGameType || 'frog_jump',
      trials: results.trials || [],
      summary: {
        totalTrials: results.totalTrials || results.trials?.length || 0,
        correctTrials: results.correctTrials || 0,
        accuracy: results.accuracy || 0,
        averageReactionTime: results.avgReactionTime || results.averageReactionTime || 0,
        switchCost: 0,
        errorRate: 100 - (results.accuracy || 0),
        riskScore: results.accuracy >= 70 ? 25 : results.accuracy >= 50 ? 50 : 75,
        recommendations: [
          results.accuracy >= 70 ? 'Excellent performance!' : 'Good effort!',
          results.avgReactionTime < 2000 ? 'Quick reaction times' : 'Consider more practice',
          'Continue regular assessments to track progress'
        ]
      },
      clinicianNotes: '',
      completionTime: results.completionTime || 0
    };
    
    setCurrentGameResults(transformedResults as any);
    setSessions(prev => [...prev, transformedResults as any]);
    setCurrentScreen('results');
  };

  const handleBackToDashboard = () => {
    setCurrentScreen('mainDashboard');
    setCurrentGameType(null);
    setCurrentGameResults(null);
  };

  const handleNewSession = () => {
    setCurrentScreen('registration');
  };

  if (showSplash) {
    return <SplashScreen onFinish={() => setShowSplash(false)} />;
  }

  return (
    <LanguageProvider>
      <AuthProvider>
        <AppProvider>
          <View style={styles.container}>
        <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
        
        {currentScreen === 'login' && (
          <>
            {currentAuthScreen === 'login' ? (
              <LoginScreen
                onNavigateToRegister={() => setCurrentAuthScreen('register')}
                onAuthSuccess={handleAuthSuccess}
              />
            ) : (
              <RegistrationScreen
                onNavigateToLogin={() => setCurrentAuthScreen('login')}
                onAuthSuccess={handleAuthSuccess}
              />
            )}
          </>
        )}
        
        {currentScreen === 'mainDashboard' && (
          <MainDashboardScreen 
            navigation={{
              navigate: (screen: string, params?: any) => {
                if (screen === 'CognitiveDashboard') {
                  setCurrentScreen('cognitiveDashboard');
                } else if (screen === 'ChildRegistration') {
                  setPreviousScreen('mainDashboard');
                  setCurrentScreen('childRegistration');
                } else if (screen === 'AgeSelection') {
                  handleComponentSelect('cognitive_flexibility');
                } else if (screen === 'AddChild') {
                  setPreviousScreen('mainDashboard');
                  setCurrentScreen('childRegistration');
                } else if (screen === 'Reports') {
                  Alert.alert('Coming Soon', 'Reports feature coming soon');
                } else if (screen === 'Export') {
                  Alert.alert('Coming Soon', 'Export feature coming soon');
                } else if (screen === 'ChildrenList') {
                  Alert.alert('Coming Soon', 'Children list coming soon');
                } else if (screen === 'ChildDetails') {
                  Alert.alert('Coming Soon', 'Child details coming soon');
                } else if (screen === 'Notifications') {
                  Alert.alert('Coming Soon', 'Notifications coming soon');
                } else if (screen === 'Settings') {
                  Alert.alert('Coming Soon', 'Settings coming soon');
                }
              },
              goBack: () => setCurrentScreen('login'),
            }}
          />
        )}
        
        {currentScreen === 'cognitiveDashboard' && (
          <CognitiveDashboardScreen
            navigation={{
              navigate: (screen: string, params?: any) => {
                if (screen === 'ChildRegistration') {
                  setPreviousScreen('cognitiveDashboard');
                  setCurrentScreen('childRegistration');
                } else if (screen === 'AgeSelection') {
                  if (params?.childData) {
                    setCurrentChild(params.childData);
                  }
                  if (params?.gameType) {
                    setCurrentGameType(params.gameType);
                  }
                  setCurrentScreen('ageSelection');
                } else if (screen === 'AIDoctorBot') {
                  if (params?.child) {
                    setCurrentChild(params.child);
                  }
                  setPreviousScreen('cognitiveDashboard');
                  setCurrentScreen('aiBot');
                }
              },
              goBack: () => setCurrentScreen('mainDashboard'),
            }}
            route={{}}
          />
        )}
        
        {currentScreen === 'childRegistration' && (
          <ChildRegistrationScreen 
            onChildAdded={handleChildAdded}
            onCancel={handleChildRegistrationCancel}
          />
        )}
        
        {currentScreen === 'ageSelection' && (
          <View style={styles.container}>
            <View style={styles.header}>
              <TouchableOpacity style={styles.backButton} onPress={() => setCurrentScreen('cognitiveDashboard')}>
                <Text style={styles.backButtonText}>← Back</Text>
              </TouchableOpacity>
              <Text style={styles.title}>Start Assessment</Text>
            </View>
            <ScrollView style={styles.content}>
              {currentChild && (
                <View style={styles.childInfo}>
                  <Text style={styles.childName}>{currentChild.name}</Text>
                  <Text style={styles.childAge}>Age: {currentChild.age} years</Text>
                  <Text style={styles.childGender}>Gender: {currentChild.gender}</Text>
                </View>
              )}
              
              <Text style={styles.subtitle}>Based on the child's age, the appropriate assessment will be selected:</Text>
              
              {currentChild && (
                <View style={styles.gameInfo}>
                  <Text style={styles.gameInfoTitle}>Selected Game:</Text>
                  {currentChild.age >= 2 && currentChild.age <= 3 && (
                    <View style={styles.gameCard}>
                      <Text style={styles.gameName}>Go/No-Go Task</Text>
                      <Text style={styles.gameDescription}>Suitable for ages 2-3 years</Text>
                    </View>
                  )}
                  {currentChild.age >= 4 && currentChild.age <= 5 && (
                    <View style={styles.gameCard}>
                      <Text style={styles.gameName}>Day/Night Stroop</Text>
                      <Text style={styles.gameDescription}>Suitable for ages 4-5 years</Text>
                    </View>
                  )}
                  {currentChild.age >= 5 && currentChild.age <= 6 && (
                    <View style={styles.gameCard}>
                      <Text style={styles.gameName}>Color-Shape DCCS</Text>
                      <Text style={styles.gameDescription}>Suitable for ages 5-6 years</Text>
                    </View>
                  )}
                </View>
              )}
              
              <TouchableOpacity
                style={styles.startButton}
                onPress={() => handleAgeSelection(currentChild?.age || 3)}
              >
                <Text style={styles.startButtonText}>Start Assessment</Text>
              </TouchableOpacity>
            </ScrollView>
          </View>
        )}
        
        {currentScreen === 'game' && currentGameType && (
          <GameWebView
            gameType={currentGameType}
            childData={currentChild}
            onComplete={handleGameComplete}
            onBack={() => setCurrentScreen('ageSelection')}
          />
        )}
        
        {currentScreen === 'aiBot' && currentChild && (
          <AIDoctorBotScreen
            navigation={{
              navigate: (screen: string, params?: any) => {
                if (screen === 'results') {
                  setCurrentScreen('results');
                }
              },
              goBack: () => setCurrentScreen(previousScreen || 'cognitiveDashboard'),
            }}
            child={currentChild}
            onComplete={handleGameComplete}
            onBack={() => setCurrentScreen(previousScreen || 'cognitiveDashboard')}
          />
        )}
        
        {currentScreen === 'results' && currentGameResults && (
          <View style={styles.container}>
            <View style={styles.header}>
              <TouchableOpacity style={styles.backButton} onPress={handleBackToDashboard}>
                <Text style={styles.backButtonText}>← Back to Dashboard</Text>
              </TouchableOpacity>
              <Text style={styles.title}>Assessment Results</Text>
            </View>
            <ScrollView style={styles.content}>
              <View style={styles.resultsContainer}>
                <Text style={styles.resultsTitle}>Session Complete!</Text>
                <Text style={styles.resultsSubtitle}>
                  Assessment completed for {currentChild?.name} (Age: {currentChild?.age})
                </Text>
                
                <View style={styles.metricsContainer}>
                  <View style={styles.metricCard}>
                    <Text style={styles.metricValue}>{currentGameResults.summary.accuracy.toFixed(1)}%</Text>
                    <Text style={styles.metricLabel}>Accuracy</Text>
                  </View>
                  <View style={styles.metricCard}>
                    <Text style={styles.metricValue}>{currentGameResults.summary.averageReactionTime.toFixed(0)}ms</Text>
                    <Text style={styles.metricLabel}>Avg Reaction Time</Text>
                  </View>
                  <View style={styles.metricCard}>
                    <Text style={styles.metricValue}>{currentGameResults.summary.riskScore.toFixed(1)}</Text>
                    <Text style={styles.metricLabel}>Risk Score</Text>
                  </View>
                </View>
                
                <View style={styles.recommendationsContainer}>
                  <Text style={styles.recommendationsTitle}>Recommendations:</Text>
                  {currentGameResults.summary.recommendations.map((rec, index) => (
                    <Text key={index} style={styles.recommendationText}>• {rec}</Text>
                  ))}
                </View>
                
                <TouchableOpacity style={styles.newSessionButton} onPress={handleNewSession}>
                  <Text style={styles.newSessionButtonText}>Start New Session</Text>
                </TouchableOpacity>
              </View>
            </ScrollView>
          </View>
        )}
          </View>
        </AppProvider>
      </AuthProvider>
    </LanguageProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 20,
    paddingTop: 50,
    paddingBottom: 20,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  backButton: {
    marginRight: 15,
  },
  backButtonText: {
    fontSize: 16,
    color: '#007AFF',
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  content: {
    flex: 1,
    padding: 20,
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 20,
  },
  form: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
    marginTop: 15,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  genderContainer: {
    flexDirection: 'row',
    marginBottom: 15,
  },
  genderButton: {
    flex: 1,
    padding: 12,
    marginHorizontal: 5,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    alignItems: 'center',
    backgroundColor: '#f9f9f9',
  },
  genderButtonActive: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
  },
  genderText: {
    fontSize: 16,
    color: '#333',
  },
  genderTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  diagnosisContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginBottom: 20,
  },
  diagnosisButton: {
    padding: 10,
    margin: 5,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#ddd',
    backgroundColor: '#f9f9f9',
  },
  diagnosisButtonActive: {
    backgroundColor: '#007AFF',
    borderColor: '#007AFF',
  },
  diagnosisText: {
    fontSize: 14,
    color: '#333',
  },
  diagnosisTextActive: {
    color: '#fff',
    fontWeight: '600',
  },
  registerButton: {
    backgroundColor: '#007AFF',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
    marginTop: 20,
  },
  registerButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  ageButton: {
    backgroundColor: '#fff',
    padding: 20,
    marginVertical: 5,
    borderRadius: 10,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#e0e0e0',
  },
  ageButtonText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
  },
  resultsContainer: {
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
  },
  resultsTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    textAlign: 'center',
    marginBottom: 10,
  },
  resultsSubtitle: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  metricsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginBottom: 30,
  },
  metricCard: {
    alignItems: 'center',
    backgroundColor: '#f8f9fa',
    padding: 15,
    borderRadius: 8,
    minWidth: 80,
  },
  metricValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#007AFF',
  },
  metricLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  recommendationsContainer: {
    marginBottom: 30,
  },
  recommendationsTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  recommendationText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
    lineHeight: 20,
  },
  newSessionButton: {
    backgroundColor: '#34C759',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  newSessionButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  childInfo: {
    backgroundColor: '#f8f9fa',
    padding: 20,
    borderRadius: 10,
    marginBottom: 20,
    alignItems: 'center',
  },
  childName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  childAge: {
    fontSize: 16,
    color: '#666',
    marginBottom: 3,
  },
  childGender: {
    fontSize: 16,
    color: '#666',
  },
  gameInfo: {
    marginBottom: 30,
  },
  gameInfoTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 10,
  },
  gameCard: {
    backgroundColor: '#e3f2fd',
    padding: 15,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
  },
  gameName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1976D2',
    marginBottom: 5,
  },
  gameDescription: {
    fontSize: 14,
    color: '#666',
  },
  startButton: {
    backgroundColor: '#4CAF50',
    padding: 15,
    borderRadius: 8,
    alignItems: 'center',
  },
  startButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
  },
});

export default App;
