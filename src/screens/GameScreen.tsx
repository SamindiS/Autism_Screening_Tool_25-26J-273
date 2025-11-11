import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  Dimensions,
  Animated,
} from 'react-native';
import { useApp } from '../context/AppContext';
import { Trial, GameMetrics, MLFeatures } from '../types';
import { GAME_CONFIGS, COLORS, FONTS, SPACING } from '../constants';
import { storageService } from '../services/storage.simple';
import { apiService } from '../services/api';

const { width, height } = Dimensions.get('window');

interface GameScreenProps {
  navigation: any;
  route: any;
}

const GameScreen: React.FC<GameScreenProps> = ({ navigation, route }) => {
  const { componentType, ageGroup, gameType } = route.params;
  const { currentLanguage } = useApp();
  
  // Game state
  const [currentTrial, setCurrentTrial] = useState(0);
  const [gamePhase, setGamePhase] = useState<'practice' | 'pre_switch' | 'post_switch'>('practice');
  const [gameStatus, setGameStatus] = useState<'ready' | 'playing' | 'completed'>('ready');
  const [score, setScore] = useState(0);
  const [trials, setTrials] = useState<Trial[]>([]);
  const [currentStimulus, setCurrentStimulus] = useState<any>(null);
  const [showFeedback, setShowFeedback] = useState(false);
  const [feedbackType, setFeedbackType] = useState<'correct' | 'incorrect' | null>(null);
  
  // Animation refs
  const stimulusScale = useRef(new Animated.Value(1)).current;
  const feedbackOpacity = useRef(new Animated.Value(0)).current;
  const progressWidth = useRef(new Animated.Value(0)).current;
  
  // Game config
  const config = GAME_CONFIGS[gameType as keyof typeof GAME_CONFIGS];
  const totalTrials = config.maxTrials;
  const practiceTrials = config.practiceTrials;
  const switchPoint = 'switchPoint' in config ? config.switchPoint : Math.floor(totalTrials / 2);
  
  // Game data
  const [gameData, setGameData] = useState({
    startTime: new Date(),
    currentRule: 'color', // or 'shape'
    correctResponses: 0,
    totalResponses: 0,
    reactionTimes: [] as number[],
    errors: 0,
  });

  useEffect(() => {
    if (gameStatus === 'ready') {
      startGame();
    }
  }, [gameStatus]);

  const startGame = () => {
    setGameStatus('playing');
    setGamePhase('practice');
    setCurrentTrial(0);
    setScore(0);
    setTrials([]);
    setGameData({
      startTime: new Date(),
      currentRule: 'color',
      correctResponses: 0,
      totalResponses: 0,
      reactionTimes: [],
      errors: 0,
    });
    nextTrial();
  };

  const nextTrial = () => {
    if (currentTrial >= totalTrials) {
      completeGame();
      return;
    }

    // Determine game phase
    let phase: 'practice' | 'pre_switch' | 'post_switch' = 'practice';
    if (currentTrial >= practiceTrials && currentTrial < switchPoint) {
      phase = 'pre_switch';
    } else if (currentTrial >= switchPoint) {
      phase = 'post_switch';
      if (currentTrial === switchPoint) {
        // Switch the rule
        setGameData(prev => ({
          ...prev,
          currentRule: prev.currentRule === 'color' ? 'shape' : 'color',
        }));
      }
    }

    setGamePhase(phase);
    generateStimulus();
  };

  const generateStimulus = () => {
    const colors = ['red', 'blue', 'green', 'yellow'];
    const shapes = ['circle', 'square', 'triangle', 'star'];
    
    const color = colors[Math.floor(Math.random() * colors.length)];
    const shape = shapes[Math.floor(Math.random() * shapes.length)];
    
    setCurrentStimulus({
      color,
      shape,
      correctResponse: gameData.currentRule === 'color' ? color : shape,
    });

    // Animate stimulus appearance
    Animated.sequence([
      Animated.timing(stimulusScale, {
        toValue: 1.2,
        duration: 200,
        useNativeDriver: true,
      }),
      Animated.timing(stimulusScale, {
        toValue: 1,
        duration: 200,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const handleResponse = (response: string) => {
    const trialStartTime = Date.now();
    const reactionTime = trialStartTime - gameData.startTime.getTime();
    
    const isCorrect = response === currentStimulus.correctResponse;
    const trial: Trial = {
      id: `trial_${currentTrial}_${Date.now()}`,
      trialNumber: currentTrial + 1,
      stimulus: `${currentStimulus.color}_${currentStimulus.shape}`,
      rule: gameData.currentRule,
      response,
      reactionTime,
      correct: isCorrect,
      timestamp: new Date(),
      phase: gamePhase,
    };

    setTrials(prev => [...prev, trial]);
    setScore(prev => prev + (isCorrect ? 1 : 0));
    setGameData(prev => ({
      ...prev,
      correctResponses: prev.correctResponses + (isCorrect ? 1 : 0),
      totalResponses: prev.totalResponses + 1,
      reactionTimes: [...prev.reactionTimes, reactionTime],
      errors: prev.errors + (isCorrect ? 0 : 1),
    }));

    // Show feedback
    setFeedbackType(isCorrect ? 'correct' : 'incorrect');
    setShowFeedback(true);
    
    Animated.timing(feedbackOpacity, {
      toValue: 1,
      duration: 200,
      useNativeDriver: true,
    }).start();

    // Update progress
    const progress = (currentTrial + 1) / totalTrials;
    Animated.timing(progressWidth, {
      toValue: progress,
      duration: 300,
      useNativeDriver: false,
    }).start();

    // Hide feedback and move to next trial
    setTimeout(() => {
      setShowFeedback(false);
      Animated.timing(feedbackOpacity, {
        toValue: 0,
        duration: 200,
        useNativeDriver: true,
      }).start();
      
      setCurrentTrial(prev => prev + 1);
      nextTrial();
    }, config.feedbackDuration);
  };

  const completeGame = () => {
    setGameStatus('completed');
    calculateMetrics();
  };

  const calculateMetrics = () => {
    const metrics: GameMetrics = {
      accuracy: (gameData.correctResponses / gameData.totalResponses) * 100,
      meanReactionTime: gameData.reactionTimes.reduce((a, b) => a + b, 0) / gameData.reactionTimes.length,
      switchCost: calculateSwitchCost(),
      perseverativeErrors: calculatePerseverativeErrors(),
      inhibitionErrors: calculateInhibitionErrors(),
      recoveryTrials: calculateRecoveryTrials(),
      totalTrials: totalTrials,
      correctTrials: gameData.correctResponses,
    };

    const features: MLFeatures = {
      mean_rt: metrics.meanReactionTime,
      accuracy: metrics.accuracy,
      switch_cost: metrics.switchCost,
      perseverative_error_rate: (metrics.perseverativeErrors / totalTrials) * 100,
      inhibition_error_rate: (metrics.inhibitionErrors / totalTrials) * 100,
      recovery_speed: metrics.recoveryTrials,
      age: parseInt(ageGroup.split('-')[0]),
      gender: 0, // TODO: Get from child data
    };

    // Save session data
    saveSessionData(metrics, features);
  };

  const calculateSwitchCost = () => {
    const preSwitchTrials = trials.filter(t => t.phase === 'pre_switch');
    const postSwitchTrials = trials.filter(t => t.phase === 'post_switch');
    
    if (preSwitchTrials.length === 0 || postSwitchTrials.length === 0) return 0;
    
    const preSwitchRT = preSwitchTrials.reduce((sum, t) => sum + (t.reactionTime || 0), 0) / preSwitchTrials.length;
    const postSwitchRT = postSwitchTrials.reduce((sum, t) => sum + (t.reactionTime || 0), 0) / postSwitchTrials.length;
    
    return postSwitchRT - preSwitchRT;
  };

  const calculatePerseverativeErrors = () => {
    // Count errors in the first few trials after rule switch
    const postSwitchTrials = trials.filter(t => t.phase === 'post_switch');
    const firstFewTrials = postSwitchTrials.slice(0, 3);
    return firstFewTrials.filter(t => !t.correct).length;
  };

  const calculateInhibitionErrors = () => {
    // For Go/No-Go tasks, count incorrect responses to No-Go stimuli
    return trials.filter(t => !t.correct && t.stimulus.includes('no_go')).length;
  };

  const calculateRecoveryTrials = () => {
    const postSwitchTrials = trials.filter(t => t.phase === 'post_switch');
    let recoveryTrials = 0;
    
    for (let i = 0; i < postSwitchTrials.length; i++) {
      if (postSwitchTrials[i].correct) {
        recoveryTrials = i + 1;
        break;
      }
    }
    
    return recoveryTrials;
  };

  const saveSessionData = async (metrics: GameMetrics, features: MLFeatures) => {
    try {
      const sessionData = {
        childId: 'temp_child_id', // TODO: Get from navigation params
        componentType,
        gameType,
        ageGroup,
        startTime: gameData.startTime,
        endTime: new Date(),
        duration: Math.floor((new Date().getTime() - gameData.startTime.getTime()) / 1000),
        status: 'completed' as const,
        data: {
          trials,
          metrics,
          features,
        },
      };

      await storageService.saveSession(sessionData as any);
      
      // TODO: Send to backend for ML prediction
      // const prediction = await apiService.predictRisk(features);
      
      navigation.navigate('ResultScreen', {
        sessionData,
        metrics,
        features,
        // prediction,
      });
    } catch (error) {
      console.error('Failed to save session data:', error);
      Alert.alert('Error', 'Failed to save session data');
    }
  };

  const handlePause = () => {
    Alert.alert(
      'Pause Game',
      'Do you want to pause the assessment?',
      [
        { text: 'Continue', style: 'cancel' },
        { text: 'Pause', onPress: () => setGameStatus('ready') },
      ]
    );
  };

  const handleStop = () => {
    Alert.alert(
      'Stop Game',
      'Are you sure you want to stop the assessment? Progress will be lost.',
      [
        { text: 'Cancel', style: 'cancel' },
        { text: 'Stop', style: 'destructive', onPress: () => navigation.goBack() },
      ]
    );
  };

  const renderStimulus = () => {
    if (!currentStimulus) return null;

    return (
      <Animated.View
        style={[
          styles.stimulusContainer,
          { transform: [{ scale: stimulusScale }] },
        ]}
      >
        <View
          style={[
            styles.stimulus,
            { backgroundColor: currentStimulus.color },
          ]}
        >
          <Text style={styles.stimulusText}>
            {currentStimulus.shape === 'circle' ? '●' : 
             currentStimulus.shape === 'square' ? '■' :
             currentStimulus.shape === 'triangle' ? '▲' : '★'}
          </Text>
        </View>
      </Animated.View>
    );
  };

  const renderResponseButtons = () => {
    const colors = ['red', 'blue', 'green', 'yellow'];
    const shapes = ['circle', 'square', 'triangle', 'star'];
    
    const options = gameData.currentRule === 'color' ? colors : shapes;
    const symbols = gameData.currentRule === 'color' ? 
      ['🔴', '🔵', '🟢', '🟡'] : 
      ['●', '■', '▲', '★'];

    return (
      <View style={styles.responseContainer}>
        {options.map((option, index) => (
          <TouchableOpacity
            key={option}
            style={styles.responseButton}
            onPress={() => handleResponse(option)}
          >
            <Text style={styles.responseSymbol}>{symbols[index]}</Text>
            <Text style={styles.responseText}>{option}</Text>
          </TouchableOpacity>
        ))}
      </View>
    );
  };

  const renderFeedback = () => {
    if (!showFeedback || !feedbackType) return null;

    return (
      <Animated.View
        style={[
          styles.feedbackContainer,
          { opacity: feedbackOpacity },
        ]}
      >
        <Text style={[
          styles.feedbackText,
          { color: feedbackType === 'correct' ? COLORS.success : COLORS.error },
        ]}>
          {feedbackType === 'correct' ? '✓ Correct!' : '✗ Try Again'}
        </Text>
      </Animated.View>
    );
  };

  if (gameStatus === 'ready') {
    return (
      <View style={styles.container}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => navigation.goBack()}>
            <Text style={styles.backButton}>‹ Back</Text>
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Get Ready!</Text>
          <TouchableOpacity onPress={handleStop}>
            <Text style={styles.stopButton}>Stop</Text>
          </TouchableOpacity>
        </View>
        
        <View style={styles.readyContent}>
          <Text style={styles.readyTitle}>Assessment Starting</Text>
          <Text style={styles.readyDescription}>
            The child will see different colored shapes and need to respond based on the current rule.
          </Text>
          <Text style={styles.readyRule}>
            Current Rule: {gameData.currentRule === 'color' ? 'Color' : 'Shape'}
          </Text>
          <TouchableOpacity style={styles.startButton} onPress={startGame}>
            <Text style={styles.startButtonText}>Start Assessment</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  if (gameStatus === 'completed') {
    return (
      <View style={styles.container}>
        <View style={styles.completedContent}>
          <Text style={styles.completedTitle}>Assessment Complete!</Text>
          <Text style={styles.completedDescription}>
            Processing results...
          </Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity onPress={handlePause}>
          <Text style={styles.pauseButton}>Pause</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>
          Trial {currentTrial + 1} of {totalTrials}
        </Text>
        <TouchableOpacity onPress={handleStop}>
          <Text style={styles.stopButton}>Stop</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.progressContainer}>
        <View style={styles.progressBar}>
          <Animated.View
            style={[
              styles.progressFill,
              { width: progressWidth },
            ]}
          />
        </View>
      </View>

      <View style={styles.gameArea}>
        <Text style={styles.ruleText}>
          {gameData.currentRule === 'color' ? 'Choose the COLOR' : 'Choose the SHAPE'}
        </Text>
        
        {renderStimulus()}
        {renderResponseButtons()}
        {renderFeedback()}
      </View>

      <View style={styles.scoreContainer}>
        <Text style={styles.scoreText}>Score: {score}/{currentTrial + 1}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: SPACING.lg,
    paddingTop: SPACING.lg,
    paddingBottom: SPACING.md,
    backgroundColor: COLORS.surface,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  backButton: {
    fontSize: FONTS.sizes.lg,
    color: COLORS.primary,
    fontWeight: '600',
  },
  pauseButton: {
    fontSize: FONTS.sizes.md,
    color: COLORS.warning,
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: 'bold',
    color: COLORS.text,
  },
  stopButton: {
    fontSize: FONTS.sizes.md,
    color: COLORS.error,
    fontWeight: '600',
  },
  progressContainer: {
    paddingHorizontal: SPACING.lg,
    paddingVertical: SPACING.md,
  },
  progressBar: {
    height: 8,
    backgroundColor: COLORS.border,
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: COLORS.primary,
  },
  gameArea: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: SPACING.lg,
  },
  ruleText: {
    fontSize: FONTS.sizes.xl,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SPACING.xl,
    textAlign: 'center',
  },
  stimulusContainer: {
    marginBottom: SPACING.xl,
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
    color: COLORS.surface,
  },
  responseContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: SPACING.md,
  },
  responseButton: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SPACING.md,
    alignItems: 'center',
    minWidth: 80,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  responseSymbol: {
    fontSize: 32,
    marginBottom: SPACING.xs,
  },
  responseText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.text,
    fontWeight: '600',
  },
  feedbackContainer: {
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: [{ translateX: -50 }, { translateY: -50 }],
    backgroundColor: COLORS.surface,
    paddingHorizontal: SPACING.lg,
    paddingVertical: SPACING.md,
    borderRadius: 8,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  feedbackText: {
    fontSize: FONTS.sizes.xl,
    fontWeight: 'bold',
  },
  scoreContainer: {
    paddingHorizontal: SPACING.lg,
    paddingVertical: SPACING.md,
    backgroundColor: COLORS.surface,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  scoreText: {
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    textAlign: 'center',
    fontWeight: '600',
  },
  readyContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: SPACING.xl,
  },
  readyTitle: {
    fontSize: FONTS.sizes.xxl,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SPACING.lg,
    textAlign: 'center',
  },
  readyDescription: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    textAlign: 'center',
    lineHeight: 24,
    marginBottom: SPACING.lg,
  },
  readyRule: {
    fontSize: FONTS.sizes.lg,
    color: COLORS.primary,
    fontWeight: '600',
    marginBottom: SPACING.xl,
    textAlign: 'center',
  },
  startButton: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: SPACING.xl,
    paddingVertical: SPACING.md,
    borderRadius: 12,
  },
  startButtonText: {
    color: COLORS.surface,
    fontSize: FONTS.sizes.lg,
    fontWeight: '600',
  },
  completedContent: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: SPACING.xl,
  },
  completedTitle: {
    fontSize: FONTS.sizes.xxl,
    fontWeight: 'bold',
    color: COLORS.success,
    marginBottom: SPACING.lg,
    textAlign: 'center',
  },
  completedDescription: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
});

export default GameScreen;
