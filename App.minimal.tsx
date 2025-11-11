/**
 * Autism Screening App - Minimal Working Version
 * This version uses only basic React Native components to ensure compatibility
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
  Dimensions 
} from 'react-native';

const { width } = Dimensions.get('window');

// Simple Login Screen
function LoginScreen({ onLogin }: { onLogin: () => void }) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>🧠 Autism Screening App</Text>
      <Text style={styles.subtitle}>Clinical Assessment System</Text>
      <Text style={styles.description}>
        Cognitive Flexibility & Rule-Switching Component
      </Text>
      <TouchableOpacity style={styles.loginButton} onPress={onLogin}>
        <Text style={styles.loginButtonText}>Login as Doctor</Text>
      </TouchableOpacity>
    </View>
  );
}

// Simple Dashboard Screen
function DashboardScreen({ onStartAssessment, onLogout }: { 
  onStartAssessment: () => void; 
  onLogout: () => void; 
}) {
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Clinical Dashboard</Text>
        <Text style={styles.subtitle}>Welcome, Dr. Johnson</Text>
      </View>
      
      <View style={styles.statsContainer}>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>12</Text>
          <Text style={styles.statLabel}>Total Children</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>8</Text>
          <Text style={styles.statLabel}>Completed Sessions</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>3</Text>
          <Text style={styles.statLabel}>Pending Sessions</Text>
        </View>
        <View style={styles.statCard}>
          <Text style={styles.statNumber}>2</Text>
          <Text style={styles.statLabel}>High Risk Cases</Text>
        </View>
      </View>
      
      <View style={styles.componentsContainer}>
        <Text style={styles.sectionTitle}>Assessment Components</Text>
        
        <TouchableOpacity style={styles.componentCard} onPress={onStartAssessment}>
          <Text style={styles.componentIcon}>🧠</Text>
          <View style={styles.componentContent}>
            <Text style={styles.componentTitle}>Cognitive Flexibility</Text>
            <Text style={styles.componentDescription}>
              Rule-Switching Assessment
            </Text>
          </View>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.componentCard}>
          <Text style={styles.componentIcon}>🔄</Text>
          <View style={styles.componentContent}>
            <Text style={styles.componentTitle}>Restricted Behaviors</Text>
            <Text style={styles.componentDescription}>
              Repetitive Behavior Assessment
            </Text>
          </View>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.componentCard}>
          <Text style={styles.componentIcon}>👁️</Text>
          <View style={styles.componentContent}>
            <Text style={styles.componentTitle}>Visual Attention</Text>
            <Text style={styles.componentDescription}>
              Attention & Focus Assessment
            </Text>
          </View>
        </TouchableOpacity>
        
        <TouchableOpacity style={styles.componentCard}>
          <Text style={styles.componentIcon}>👂</Text>
          <View style={styles.componentContent}>
            <Text style={styles.componentTitle}>Response to Name</Text>
            <Text style={styles.componentDescription}>
              Social Attention Assessment
            </Text>
          </View>
        </TouchableOpacity>
      </View>
      
      <TouchableOpacity style={styles.logoutButton} onPress={onLogout}>
        <Text style={styles.logoutButtonText}>Logout</Text>
      </TouchableOpacity>
    </ScrollView>
  );
}

// Simple Age Selection Screen
function AgeSelectionScreen({ onAgeSelect, onBack }: { 
  onAgeSelect: (age: string) => void; 
  onBack: () => void; 
}) {
  const ageGroups = [
    { id: '2-3', label: '2-3 Years', description: 'Simple Go/No-Go tasks', color: '#FFB74D' },
    { id: '4-5', label: '4-5 Years', description: 'Go/No-Go + Stroop tasks', color: '#81C784' },
    { id: '5-6', label: '5-6 Years', description: 'All cognitive flexibility tasks', color: '#64B5F6' }
  ];
  
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>Select Age Group</Text>
        <View style={styles.placeholder} />
      </View>
      
      <View style={styles.ageGroupsContainer}>
        <Text style={styles.sectionTitle}>Choose Child's Age Group</Text>
        <Text style={styles.sectionSubtitle}>
          Select the age group that best matches the child's current age
        </Text>
        
        {ageGroups.map((age) => (
          <TouchableOpacity 
            key={age.id} 
            style={[styles.ageGroupCard, { borderLeftColor: age.color }]}
            onPress={() => onAgeSelect(age.id)}
          >
            <View style={[styles.ageGroupIcon, { backgroundColor: age.color }]}>
              <Text style={styles.ageGroupIconText}>
                {age.id === '2-3' ? '👶' : age.id === '4-5' ? '🧒' : '👦'}
              </Text>
            </View>
            <View style={styles.ageGroupContent}>
              <Text style={styles.ageGroupLabel}>{age.label}</Text>
              <Text style={styles.ageGroupDescription}>{age.description}</Text>
              <Text style={styles.ageGroupTime}>
                Max {age.id === '2-3' ? '3' : age.id === '4-5' ? '4' : '5'} minutes
              </Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>
    </ScrollView>
  );
}

// Simple Game Screen
function GameScreen({ ageGroup, onComplete, onBack }: { 
  ageGroup: string; 
  onComplete: (score: number) => void; 
  onBack: () => void; 
}) {
  const [score, setScore] = useState(0);
  const [trial, setTrial] = useState(1);
  const maxTrials = 10;
  
  const handleResponse = () => {
    setScore(score + 1);
    setTrial(trial + 1);
  };
  
  const handleComplete = () => {
    onComplete(score);
  };
  
  const getGameTitle = () => {
    if (ageGroup === '2-3') return 'Go/No-Go Game';
    if (ageGroup === '4-5') return 'Stroop Game';
    return 'DCCS Game';
  };
  
  const getRuleText = () => {
    if (ageGroup === '2-3') return 'Tap the GREEN circle';
    if (ageGroup === '4-5') return 'Tap the COLOR name';
    return 'Tap the SHAPE';
  };
  
  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={onBack}>
          <Text style={styles.backButtonText}>← Back</Text>
        </TouchableOpacity>
        <Text style={styles.title}>{getGameTitle()}</Text>
        <TouchableOpacity style={styles.stopButton}>
          <Text style={styles.stopButtonText}>Stop</Text>
        </TouchableOpacity>
      </View>
      
      <View style={styles.gameArea}>
        <Text style={styles.ruleText}>{getRuleText()}</Text>
        <Text style={styles.trialText}>Trial {trial} of {maxTrials}</Text>
        
        <View style={styles.stimulusContainer}>
          <View style={[styles.stimulus, { backgroundColor: '#4CAF50' }]}>
            <Text style={styles.stimulusText}>●</Text>
          </View>
        </View>
        
        <TouchableOpacity style={styles.responseButton} onPress={handleResponse}>
          <Text style={styles.responseButtonText}>Tap Here</Text>
        </TouchableOpacity>
        
        <View style={styles.scoreContainer}>
          <Text style={styles.scoreText}>Score: {score}/{trial - 1}</Text>
        </View>
        
        {trial > maxTrials && (
          <TouchableOpacity style={styles.completeButton} onPress={handleComplete}>
            <Text style={styles.completeButtonText}>Complete Assessment</Text>
          </TouchableOpacity>
        )}
      </View>
    </View>
  );
}

// Simple Results Screen
function ResultsScreen({ score, ageGroup, onBackToDashboard, onNewAssessment }: { 
  score: number; 
  ageGroup: string; 
  onBackToDashboard: () => void; 
  onNewAssessment: () => void; 
}) {
  const getRiskLevel = () => {
    if (score >= 8) return { level: 'Low Risk', color: '#4CAF50' };
    if (score >= 5) return { level: 'Moderate Risk', color: '#FF9800' };
    return { level: 'High Risk', color: '#F44336' };
  };
  
  const risk = getRiskLevel();
  
  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>Assessment Results</Text>
      </View>
      
      <View style={styles.resultsContainer}>
        <View style={[styles.riskCard, { backgroundColor: risk.color }]}>
          <Text style={styles.riskLevelText}>{risk.level}</Text>
          <Text style={styles.riskConfidence}>Confidence: 85%</Text>
        </View>
        
        <View style={styles.metricsContainer}>
          <Text style={styles.sectionTitle}>Performance Metrics</Text>
          
          <View style={styles.metricRow}>
            <Text style={styles.metricLabel}>Age Group:</Text>
            <Text style={styles.metricValue}>{ageGroup} Years</Text>
          </View>
          
          <View style={styles.metricRow}>
            <Text style={styles.metricLabel}>Score:</Text>
            <Text style={styles.metricValue}>{score}/10</Text>
          </View>
          
          <View style={styles.metricRow}>
            <Text style={styles.metricLabel}>Accuracy:</Text>
            <Text style={styles.metricValue}>{(score / 10 * 100).toFixed(1)}%</Text>
          </View>
        </View>
        
        <View style={styles.analysisContainer}>
          <Text style={styles.sectionTitle}>Analysis</Text>
          <Text style={styles.analysisText}>
            {score >= 8 
              ? 'The child shows typical cognitive flexibility patterns for their age group.'
              : score >= 5
              ? 'Some difficulties with cognitive flexibility were observed. Further assessment may be beneficial.'
              : 'Significant difficulties with cognitive flexibility were observed. Professional evaluation is recommended.'
            }
          </Text>
        </View>
        
        <View style={styles.recommendationsContainer}>
          <Text style={styles.sectionTitle}>Recommendations</Text>
          {score >= 8 ? (
            <>
              <Text style={styles.recommendationItem}>• Continue monitoring cognitive development</Text>
              <Text style={styles.recommendationItem}>• Encourage activities that promote executive functioning</Text>
              <Text style={styles.recommendationItem}>• Regular follow-up assessments recommended</Text>
            </>
          ) : score >= 5 ? (
            <>
              <Text style={styles.recommendationItem}>• Consider additional assessment tools</Text>
              <Text style={styles.recommendationItem}>• Implement targeted cognitive training exercises</Text>
              <Text style={styles.recommendationItem}>• Schedule follow-up assessment in 3-6 months</Text>
            </>
          ) : (
            <>
              <Text style={styles.recommendationItem}>• Immediate referral to developmental specialist recommended</Text>
              <Text style={styles.recommendationItem}>• Comprehensive developmental assessment needed</Text>
              <Text style={styles.recommendationItem}>• Consider early intervention services</Text>
            </>
          )}
        </View>
      </View>
      
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.secondaryButton} onPress={onNewAssessment}>
          <Text style={styles.secondaryButtonText}>New Assessment</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.primaryButton} onPress={onBackToDashboard}>
          <Text style={styles.primaryButtonText}>Back to Dashboard</Text>
        </TouchableOpacity>
      </View>
    </ScrollView>
  );
}

// Main App Component
function App() {
  const [currentScreen, setCurrentScreen] = useState('login');
  const [gameData, setGameData] = useState<{ ageGroup: string; score: number } | null>(null);
  
  const isDarkMode = useColorScheme() === 'dark';
  
  const handleLogin = () => setCurrentScreen('dashboard');
  const handleLogout = () => setCurrentScreen('login');
  const handleStartAssessment = () => setCurrentScreen('ageSelection');
  const handleAgeSelect = (ageGroup: string) => {
    setGameData({ ageGroup, score: 0 });
    setCurrentScreen('game');
  };
  const handleBackToAgeSelection = () => setCurrentScreen('ageSelection');
  const handleBackToDashboard = () => setCurrentScreen('dashboard');
  const handleGameComplete = (score: number) => {
    setGameData(prev => prev ? { ...prev, score } : { ageGroup: '2-3', score });
    setCurrentScreen('results');
  };
  const handleNewAssessment = () => {
    setGameData(null);
    setCurrentScreen('ageSelection');
  };
  
  return (
    <View style={styles.appContainer}>
      <StatusBar 
        barStyle={isDarkMode ? 'light-content' : 'dark-content'} 
        backgroundColor="#2E86AB"
      />
      
      {currentScreen === 'login' && <LoginScreen onLogin={handleLogin} />}
      {currentScreen === 'dashboard' && (
        <DashboardScreen 
          onStartAssessment={handleStartAssessment} 
          onLogout={handleLogout} 
        />
      )}
      {currentScreen === 'ageSelection' && (
        <AgeSelectionScreen 
          onAgeSelect={handleAgeSelect} 
          onBack={handleBackToDashboard} 
        />
      )}
      {currentScreen === 'game' && gameData && (
        <GameScreen 
          ageGroup={gameData.ageGroup} 
          onComplete={handleGameComplete} 
          onBack={handleBackToAgeSelection} 
        />
      )}
      {currentScreen === 'results' && gameData && (
        <ResultsScreen 
          score={gameData.score} 
          ageGroup={gameData.ageGroup} 
          onBackToDashboard={handleBackToDashboard} 
          onNewAssessment={handleNewAssessment} 
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
  stopButton: {
    paddingVertical: 5,
  },
  stopButtonText: {
    fontSize: 16,
    color: '#F44336',
    fontWeight: '600',
  },
  subtitle: {
    fontSize: 16,
    color: '#A23B72',
    textAlign: 'center',
    marginBottom: 20,
  },
  description: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
    lineHeight: 20,
  },
  loginButton: {
    backgroundColor: '#2E86AB',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
    marginBottom: 20,
  },
  loginButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
    textAlign: 'center',
  },
  statsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  statCard: {
    width: (width - 60) / 2,
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  statNumber: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2E86AB',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    textAlign: 'center',
  },
  componentsContainer: {
    paddingHorizontal: 20,
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  sectionSubtitle: {
    fontSize: 14,
    color: '#666',
    marginBottom: 15,
  },
  componentCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 15,
    marginBottom: 10,
    flexDirection: 'row',
    alignItems: 'center',
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
  logoutButton: {
    backgroundColor: '#F44336',
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderRadius: 8,
    marginHorizontal: 20,
    marginBottom: 20,
  },
  logoutButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
    textAlign: 'center',
  },
  ageGroupsContainer: {
    paddingHorizontal: 20,
  },
  ageGroupCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
    marginBottom: 15,
    flexDirection: 'row',
    alignItems: 'center',
    borderLeftWidth: 4,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  ageGroupIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 15,
  },
  ageGroupIconText: {
    fontSize: 28,
  },
  ageGroupContent: {
    flex: 1,
  },
  ageGroupLabel: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  ageGroupDescription: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  ageGroupTime: {
    fontSize: 12,
    color: '#2E86AB',
    fontWeight: '600',
  },
  gameArea: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  ruleText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 20,
    textAlign: 'center',
  },
  trialText: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
  },
  stimulusContainer: {
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
  responseButton: {
    backgroundColor: '#2E86AB',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
    marginBottom: 20,
  },
  responseButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: '600',
  },
  scoreContainer: {
    marginBottom: 20,
  },
  scoreText: {
    fontSize: 18,
    color: '#333',
    textAlign: 'center',
    fontWeight: '600',
  },
  completeButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 8,
  },
  completeButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  resultsContainer: {
    paddingHorizontal: 20,
  },
  riskCard: {
    padding: 20,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 20,
  },
  riskLevelText: {
    fontSize: 24,
    fontWeight: 'bold',
    color: 'white',
    marginBottom: 5,
  },
  riskConfidence: {
    fontSize: 14,
    color: 'white',
    opacity: 0.9,
  },
  metricsContainer: {
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
  metricRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
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
  analysisContainer: {
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
  analysisText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
  },
  recommendationsContainer: {
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
  recommendationItem: {
    fontSize: 14,
    color: '#333',
    lineHeight: 20,
    marginBottom: 8,
  },
  buttonContainer: {
    flexDirection: 'row',
    paddingHorizontal: 20,
    paddingBottom: 20,
    gap: 10,
  },
  primaryButton: {
    flex: 1,
    backgroundColor: '#2E86AB',
    borderRadius: 8,
    paddingVertical: 15,
    alignItems: 'center',
  },
  primaryButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  secondaryButton: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    paddingVertical: 15,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#E0E0E0',
  },
  secondaryButtonText: {
    color: '#333',
    fontSize: 16,
    fontWeight: '600',
  },
});

export default App;









