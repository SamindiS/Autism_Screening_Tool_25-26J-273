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

// Child Registration Screen
function ChildRegistrationScreen({ 
  onRegister, 
  onBack 
}: { 
  onRegister: (childData: any) => void; 
  onBack: () => void; 
}) {
  const [childData, setChildData] = useState({
    name: '',
    age: '',
    gender: 'M',
    diagnosis: 'Unknown'
  });

  const handleRegister = () => {
    if (!childData.name || !childData.age) {
      Alert.alert('Error', 'Please fill in all required fields');
      return;
    }
    onRegister(childData);
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Child Registration</Text>
      </View>

      <ScrollView style={styles.content}>
        <View style={styles.form}>
          <Text style={styles.label}>Child Name *</Text>
          <TextInput
            style={styles.input}
            value={childData.name}
            onChangeText={(text) => setChildData({...childData, name: text})}
            placeholder="Enter child's name"
          />

          <Text style={styles.label}>Age *</Text>
          <TextInput
            style={styles.input}
            value={childData.age}
            onChangeText={(text) => setChildData({...childData, age: text})}
            placeholder="Enter age (2-6 years)"
            keyboardType="numeric"
          />

          <Text style={styles.label}>Gender</Text>
          <View style={styles.genderContainer}>
            <TouchableOpacity
              style={[styles.genderButton, childData.gender === 'M' && styles.genderButtonActive]}
              onPress={() => setChildData({...childData, gender: 'M'})}
            >
              <Text style={[styles.genderText, childData.gender === 'M' && styles.genderTextActive]}>Male</Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[styles.genderButton, childData.gender === 'F' && styles.genderButtonActive]}
              onPress={() => setChildData({...childData, gender: 'F'})}
            >
              <Text style={[styles.genderText, childData.gender === 'F' && styles.genderTextActive]}>Female</Text>
            </TouchableOpacity>
          </View>

          <Text style={styles.label}>Diagnosis Status</Text>
          <View style={styles.diagnosisContainer}>
            {['ASD', 'Control', 'Unknown'].map((diagnosis) => (
              <TouchableOpacity
                key={diagnosis}
                style={[styles.diagnosisButton, childData.diagnosis === diagnosis && styles.diagnosisButtonActive]}
                onPress={() => setChildData({...childData, diagnosis})}
              >
                <Text style={[styles.diagnosisText, childData.diagnosis === diagnosis && styles.diagnosisTextActive]}>
                  {diagnosis}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <TouchableOpacity style={styles.registerButton} onPress={handleRegister}>
            <Text style={styles.registerButtonText}>Register Child</Text>
          </TouchableOpacity>
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

  // Splash screen timing is handled by the SplashScreen component itself

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

  const handleChildRegister = (childData: any) => {
    const newChild = {
      id: Date.now().toString(),
      ...childData,
      age: parseInt(childData.age),
      createdAt: new Date().toISOString()
    };
    setCurrentChild(newChild);
    setCurrentScreen('mainDashboard');
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

    // Select appropriate game based on age
    let gameType: 'frog_jump' | 'day_night' | 'color_shape';
    if (age <= 3) {
      gameType = 'frog_jump';
    } else if (age <= 4) {
      gameType = 'day_night';
    } else {
      gameType = 'color_shape';
    }

    setCurrentGameType(gameType);
    setCurrentScreen('game');
  };

  const handleGameComplete = (results: PilotSession) => {
    setCurrentGameResults(results);
    setSessions(prev => [...prev, results]);
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
    <AuthProvider>
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
                if (screen === 'AgeSelection') {
                  handleComponentSelect('cognitive_flexibility');
                } else if (screen === 'AddChild') {
                  setCurrentScreen('registration');
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
              }
            }}
          />
        )}
        
        {currentScreen === 'registration' && (
          <ChildRegistrationScreen 
            onRegister={handleChildRegister} 
            onBack={() => setCurrentScreen('mainDashboard')} 
          />
        )}
        
        {currentScreen === 'ageSelection' && (
          <View style={styles.container}>
            <View style={styles.header}>
              <TouchableOpacity style={styles.backButton} onPress={() => setCurrentScreen('mainDashboard')}>
                <Text style={styles.backButtonText}>← Back</Text>
              </TouchableOpacity>
              <Text style={styles.title}>Select Child Age</Text>
            </View>
            <ScrollView style={styles.content}>
              <Text style={styles.subtitle}>Choose the appropriate age group for the assessment:</Text>
              {[2, 3, 4, 5, 6].map((age) => (
                <TouchableOpacity
                  key={age}
                  style={styles.ageButton}
                  onPress={() => handleAgeSelection(age)}
                >
                  <Text style={styles.ageButtonText}>{age} years old</Text>
                </TouchableOpacity>
              ))}
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
    </AuthProvider>
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
});

export default App;
