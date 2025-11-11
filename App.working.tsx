/**
 * Autism Screening App - Clean Minimal Version
 * Only essential features: Dashboard, Navigation, Cognitive Flexibility Game
 * 
 * @format
 */

import React, { useState } from 'react';
import { 
  StatusBar, 
  useColorScheme, 
  View, 
  StyleSheet, 
  Text, 
  TouchableOpacity,
  ScrollView,
  Dimensions,
  Alert
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const { width, height } = Dimensions.get('window');

// Main Dashboard Screen
function MainDashboardScreen({ onNavigate }: { onNavigate: (screen: string) => void }) {
  const components = [
    { id: 'cognitive', name: 'Cognitive Flexibility', icon: '🧠', color: '#2E86AB' },
    { id: 'rrbs', name: 'Restricted & Repetitive Behaviors', icon: '🔄', color: '#A23B72' },
    { id: 'visual', name: 'Visual Attention', icon: '👁️', color: '#F18F01' },
    { id: 'auditory', name: 'Auditory Response to Name', icon: '👂', color: '#C73E1D' }
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Autism Screening App</Text>
        <Text style={styles.subtitle}>Clinical Assessment Dashboard</Text>
      </View>

      <View style={styles.componentsContainer}>
        <Text style={styles.sectionTitle}>Assessment Components</Text>
        
        {components.map((component) => (
          <TouchableOpacity 
            key={component.id}
            style={[styles.componentCard, { borderLeftColor: component.color }]}
            onPress={() => onNavigate(component.id)}
          >
            <Text style={styles.componentIcon}>{component.icon}</Text>
            <View style={styles.componentContent}>
              <Text style={styles.componentTitle}>{component.name}</Text>
              <Text style={styles.componentDescription}>
                {component.id === 'cognitive' 
                  ? 'Rule-switching and cognitive flexibility tasks'
                  : 'Assessment component (Coming Soon)'
                }
              </Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.statsContainer}>
        <Text style={styles.sectionTitle}>Recent Sessions</Text>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>0</Text>
          <Text style={styles.statLabel}>Completed Assessments</Text>
        </View>
      </View>
    </ScrollView>
  );
}

// Cognitive Flexibility Game Screen
function CognitiveFlexibilityScreen({ onBack }: { onBack: () => void }) {
  const [currentTrial, setCurrentTrial] = useState(1);
  const [score, setScore] = useState(0);
  const [reactionTimes, setReactionTimes] = useState<number[]>([]);
  const [currentRule, setCurrentRule] = useState('color');
  const [gamePhase, setGamePhase] = useState<'practice' | 'main' | 'complete'>('practice');
  const [startTime, setStartTime] = useState<number | null>(null);
  const [errors, setErrors] = useState(0);
  
  const maxTrials = 20;
  const practiceTrials = 5;
  const switchPoint = 10; // Switch rule after 10 trials

  const stimuli = [
    { color: 'red', shape: 'circle', correctResponse: 'color' },
    { color: 'blue', shape: 'square', correctResponse: 'color' },
    { color: 'green', shape: 'triangle', correctResponse: 'color' },
    { color: 'yellow', shape: 'circle', correctResponse: 'shape' },
    { color: 'red', shape: 'square', correctResponse: 'shape' },
    { color: 'blue', shape: 'triangle', correctResponse: 'shape' }
  ];

  const [currentStimulus, setCurrentStimulus] = useState(stimuli[0]);

  const getRuleText = () => {
    if (currentRule === 'color') return 'Tap the COLOR';
    return 'Tap the SHAPE';
  };

  const getCorrectAnswer = () => {
    return currentRule === 'color' ? currentStimulus.color : currentStimulus.shape;
  };

  const handleResponse = (response: string) => {
    if (!startTime) return;

    const reactionTime = Date.now() - startTime;
    const isCorrect = response === getCorrectAnswer();
    
    setReactionTimes([...reactionTimes, reactionTime]);
    
    if (isCorrect) {
      setScore(score + 1);
    } else {
      setErrors(errors + 1);
    }

    // Move to next trial
    if (currentTrial < maxTrials) {
      const nextTrial = currentTrial + 1;
      setCurrentTrial(nextTrial);
      
      // Switch rule at switch point
      if (nextTrial === switchPoint + 1) {
        setCurrentRule(currentRule === 'color' ? 'shape' : 'color');
        Alert.alert('Rule Change!', `New rule: ${currentRule === 'color' ? 'Tap the SHAPE' : 'Tap the COLOR'}`);
      }
      
      // Switch from practice to main phase
      if (nextTrial === practiceTrials + 1) {
        setGamePhase('main');
      }
      
      // Generate new stimulus
      const randomStimulus = stimuli[Math.floor(Math.random() * stimuli.length)];
      setCurrentStimulus(randomStimulus);
      setStartTime(Date.now());
    } else {
      setGamePhase('complete');
    }
  };

  const startGame = () => {
    setStartTime(Date.now());
    setGamePhase('practice');
  };

  const calculateMetrics = () => {
    if (reactionTimes.length === 0) return null;
    
    const preSwitch = reactionTimes.slice(0, switchPoint);
    const postSwitch = reactionTimes.slice(switchPoint);
    
    const preSwitchRT = preSwitch.reduce((a, b) => a + b, 0) / preSwitch.length;
    const postSwitchRT = postSwitch.reduce((a, b) => a + b, 0) / postSwitch.length;
    const switchCost = postSwitchRT - preSwitchRT;
    
    return {
      accuracy: (score / currentTrial) * 100,
      meanRT: reactionTimes.reduce((a, b) => a + b, 0) / reactionTimes.length,
      switchCost,
      errors
    };
  };

  const saveSession = async () => {
    const metrics = calculateMetrics();
    if (!metrics) return;

    const sessionData = {
      id: Date.now().toString(),
      timestamp: new Date().toISOString(),
      trials: currentTrial,
      score,
      accuracy: metrics.accuracy,
      meanRT: metrics.meanRT,
      switchCost: metrics.switchCost,
      errors,
      reactionTimes
    };

    try {
      const existingSessions = await AsyncStorage.getItem('sessions');
      const sessions = existingSessions ? JSON.parse(existingSessions) : [];
      sessions.push(sessionData);
      await AsyncStorage.setItem('sessions', JSON.stringify(sessions));
      Alert.alert('Success', 'Session data saved successfully!');
    } catch (error) {
      Alert.alert('Error', 'Failed to save session data');
    }
  };

  if (gamePhase === 'complete') {
    const metrics = calculateMetrics();
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity style={styles.backButton} onPress={onBack}>
            <Text style={styles.backButtonText}>← Back</Text>
          </TouchableOpacity>
          <Text style={styles.title}>Assessment Complete!</Text>
          <View style={styles.placeholder} />
        </View>

        <ScrollView style={styles.resultsContainer}>
          <View style={styles.resultsCard}>
            <Text style={styles.resultsTitle}>Performance Results</Text>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Accuracy:</Text>
              <Text style={styles.metricValue}>{metrics?.accuracy.toFixed(1)}%</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Mean Reaction Time:</Text>
              <Text style={styles.metricValue}>{metrics?.meanRT.toFixed(0)}ms</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Switch Cost:</Text>
              <Text style={styles.metricValue}>{metrics?.switchCost.toFixed(0)}ms</Text>
            </View>
            
            <View style={styles.metricRow}>
              <Text style={styles.metricLabel}>Errors:</Text>
              <Text style={styles.metricValue}>{metrics?.errors}</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.saveButton} onPress={saveSession}>
            <Text style={styles.saveButtonText}>Save Session Data</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.restartButton} onPress={() => {
            setCurrentTrial(1);
            setScore(0);
            setReactionTimes([]);
            setCurrentRule('color');
            setGamePhase('practice');
            setErrors(0);
            setStartTime(null);
          }}>
            <Text style={styles.restartButtonText}>Start New Assessment</Text>
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
        <Text style={styles.title}>Cognitive Flexibility</Text>
        <View style={styles.placeholder} />
      </View>

      <View style={styles.gameArea}>
        {gamePhase === 'practice' && !startTime && (
          <View style={styles.instructionsContainer}>
            <Text style={styles.instructionsTitle}>Practice Round</Text>
            <Text style={styles.instructionsText}>
              You will see colored shapes. Tap the correct answer based on the rule.
            </Text>
            <Text style={styles.ruleText}>Rule: {getRuleText()}</Text>
            <TouchableOpacity style={styles.startButton} onPress={startGame}>
              <Text style={styles.startButtonText}>Start Practice</Text>
            </TouchableOpacity>
          </View>
        )}

        {startTime && (
          <>
            <View style={styles.gameInfo}>
              <Text style={styles.trialText}>
                {gamePhase === 'practice' ? 'Practice' : 'Main'} Trial {currentTrial} of {maxTrials}
              </Text>
              <Text style={styles.scoreText}>Score: {score}</Text>
            </View>

            <Text style={styles.ruleText}>{getRuleText()}</Text>

            <View style={styles.stimulusContainer}>
              <View style={[styles.stimulus, { backgroundColor: currentStimulus.color }]}>
                <Text style={styles.stimulusText}>
                  {currentStimulus.shape === 'circle' ? '●' : 
                   currentStimulus.shape === 'square' ? '■' : '▲'}
                </Text>
              </View>
            </View>

            <View style={styles.responseButtons}>
              <TouchableOpacity 
                style={[styles.responseButton, { backgroundColor: '#4CAF50' }]}
                onPress={() => handleResponse(currentStimulus.color)}
              >
                <Text style={styles.responseButtonText}>{currentStimulus.color.toUpperCase()}</Text>
              </TouchableOpacity>
              
              <TouchableOpacity 
                style={[styles.responseButton, { backgroundColor: '#2196F3' }]}
                onPress={() => handleResponse(currentStimulus.shape)}
              >
                <Text style={styles.responseButtonText}>{currentStimulus.shape.toUpperCase()}</Text>
              </TouchableOpacity>
            </View>
          </>
        )}
      </View>
    </View>
  );
}

// Placeholder screens for other components
function PlaceholderScreen({ componentName, onBack }: { componentName: string; onBack: () => void }) {
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>{componentName}</Text>
        <View style={styles.placeholder} />
      </View>
      
      <View style={styles.placeholderContainer}>
        <Text style={styles.placeholderText}>🚧</Text>
        <Text style={styles.placeholderTitle}>Coming Soon</Text>
        <Text style={styles.placeholderDescription}>
          This component is under development and will be available in future updates.
        </Text>
      </View>
    </View>
  );
}

// Main App Component
function App() {
  const [currentScreen, setCurrentScreen] = useState('dashboard');
  const isDarkMode = useColorScheme() === 'dark';

  const navigateToScreen = (screen: string) => {
    setCurrentScreen(screen);
  };

  const navigateBack = () => {
    setCurrentScreen('dashboard');
  };

  return (
    <View style={styles.appContainer}>
      <StatusBar 
        barStyle={isDarkMode ? 'light-content' : 'dark-content'} 
        backgroundColor="#2E86AB"
      />
      
      {currentScreen === 'dashboard' && (
        <MainDashboardScreen onNavigate={navigateToScreen} />
      )}
      {currentScreen === 'cognitive' && (
        <CognitiveFlexibilityScreen onBack={navigateBack} />
      )}
      {currentScreen === 'rrbs' && (
        <PlaceholderScreen componentName="Restricted & Repetitive Behaviors" onBack={navigateBack} />
      )}
      {currentScreen === 'visual' && (
        <PlaceholderScreen componentName="Visual Attention" onBack={navigateBack} />
      )}
      {currentScreen === 'auditory' && (
        <PlaceholderScreen componentName="Auditory Response to Name" onBack={navigateBack} />
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
    marginBottom: 20,
  },
  componentsContainer: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 15,
  },
  componentCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    flexDirection: 'row',
    alignItems: 'center',
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  componentIcon: {
    fontSize: 24,
    marginRight: 15,
  },
  componentContent: {
    flex: 1,
  },
  componentTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  componentDescription: {
    fontSize: 14,
    color: '#666',
  },
  statsContainer: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  statCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  statNumber: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 5,
  },
  statLabel: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  gameArea: {
    flex: 1,
    paddingHorizontal: 20,
    justifyContent: 'center',
  },
  instructionsContainer: {
    alignItems: 'center',
  },
  instructionsTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
  },
  instructionsText: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    marginBottom: 20,
    lineHeight: 24,
  },
  ruleText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 30,
    textAlign: 'center',
  },
  startButton: {
    backgroundColor: '#2E86AB',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
  },
  startButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
  },
  gameInfo: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 20,
  },
  trialText: {
    fontSize: 16,
    color: '#333',
    fontWeight: '600',
  },
  scoreText: {
    fontSize: 16,
    color: '#2E86AB',
    fontWeight: '600',
  },
  stimulusContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },
  stimulus: {
    width: 120,
    height: 120,
    borderRadius: 60,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  stimulusText: {
    fontSize: 48,
    color: 'white',
  },
  responseButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  responseButton: {
    paddingHorizontal: 20,
    paddingVertical: 15,
    borderRadius: 8,
    minWidth: 100,
    alignItems: 'center',
  },
  responseButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
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
  saveButton: {
    backgroundColor: '#4CAF50',
    paddingVertical: 15,
    borderRadius: 8,
    marginBottom: 10,
  },
  saveButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  restartButton: {
    backgroundColor: '#2E86AB',
    paddingVertical: 15,
    borderRadius: 8,
  },
  restartButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  placeholderContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 40,
  },
  placeholderText: {
    fontSize: 64,
    marginBottom: 20,
  },
  placeholderTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  placeholderDescription: {
    fontSize: 16,
    color: '#666',
    textAlign: 'center',
    lineHeight: 24,
  },
});

export default App;