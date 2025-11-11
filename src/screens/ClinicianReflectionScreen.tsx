/**
 * Clinician Reflection Screen
 * Post-assessment behavioral observations for ages 3-6
 * Collects contextual data to complement game metrics
 */

import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import LinearGradient from 'react-native-linear-gradient';
import { useLanguage, replacePlaceholders } from '../context/LanguageContext';
import { COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import { recordClinicalReflection } from '../utils/SessionRecorder';

interface ClinicianReflectionScreenProps {
  navigation: any;
  child: {
    id: string;
    name: string;
    age: number;
  };
  gameResults: any;
  onComplete: (reflectionData: any) => void;
  onSkip: () => void;
}

interface Question {
  id: string;
  question: string;
  category: string;
  options: {
    text: string;
    value: number;
    icon: string;
  }[];
}

const ClinicianReflectionScreen: React.FC<ClinicianReflectionScreenProps> = ({
  navigation,
  child,
  gameResults,
  onComplete,
  onSkip,
}) => {
  const { t } = useLanguage();
  const [answers, setAnswers] = useState<{ [key: string]: number }>({});

  // Context-aware questions based on game type (age-appropriate routing is handled by the system)
  const getQuestions = (): Question[] => {
    const gameType = gameResults.gameType || gameResults.assessmentType;
    
    // Questions for Frog Jump (ages 3.5-5.5) - Focus on inhibition
    if (gameType === 'frog_jump') {
      return [
        {
          id: 'attention_span',
          question: t.reflection.frogJump.q1,
          category: t.reflection.categories.attention,
          options: [
            { text: t.reflection.options.excellentFocus, value: 4, icon: 'star' },
            { text: t.reflection.options.goodFocus, value: 3, icon: 'check-circle' },
            { text: t.reflection.options.moderateFocus, value: 2, icon: 'alert-circle' },
            { text: t.reflection.options.poorFocus, value: 1, icon: 'close-circle' },
            { text: t.reflection.options.unableAttention, value: 0, icon: 'cancel' },
          ],
        },
        {
          id: 'impulse_control',
          question: t.reflection.frogJump.q2,
          category: t.reflection.categories.inhibition,
          options: [
            { text: t.reflection.options.excellentControl, value: 4, icon: 'star' },
            { text: t.reflection.options.goodControl, value: 3, icon: 'check-circle' },
            { text: t.reflection.options.moderateControl, value: 2, icon: 'alert-circle' },
            { text: t.reflection.options.poorControl, value: 1, icon: 'close-circle' },
            { text: t.reflection.options.noControl, value: 0, icon: 'cancel' },
          ],
        },
        {
          id: 'frustration_tolerance',
          question: t.reflection.frogJump.q3,
          category: t.reflection.categories.emotionalRegulation,
          options: [
            { text: t.reflection.options.stayedCalm, value: 4, icon: 'emoticon-happy' },
            { text: t.reflection.options.slightlyUpset, value: 3, icon: 'emoticon-neutral' },
            { text: t.reflection.options.frustrated, value: 2, icon: 'emoticon-sad' },
            { text: t.reflection.options.veryUpset, value: 1, icon: 'emoticon-angry' },
            { text: t.reflection.options.couldNotContinue, value: 0, icon: 'emoticon-cry' },
          ],
        },
        {
          id: 'engagement',
          question: t.reflection.frogJump.q4,
          category: t.reflection.categories.motivation,
          options: [
            { text: t.reflection.options.highlyEngaged, value: 4, icon: 'fire' },
            { text: t.reflection.options.generallyInterested, value: 3, icon: 'thumb-up' },
            { text: t.reflection.options.neutralInterest, value: 2, icon: 'minus-circle' },
            { text: t.reflection.options.lowInterest, value: 1, icon: 'thumb-down' },
            { text: t.reflection.options.refusedGame, value: 0, icon: 'close-octagon' },
          ],
        },
        {
          id: 'understanding',
          question: t.reflection.frogJump.q5,
          category: t.reflection.categories.comprehension,
          options: [
            { text: t.reflection.options.understoodImmediately, value: 4, icon: 'lightbulb-on' },
            { text: t.reflection.options.understoodAfterOne, value: 3, icon: 'lightbulb' },
            { text: t.reflection.options.neededRepeated, value: 2, icon: 'help-circle' },
            { text: t.reflection.options.difficultyGrasping, value: 1, icon: 'alert' },
            { text: t.reflection.options.couldNotUnderstand, value: 0, icon: 'cancel' },
          ],
        },
      ];
    }
    
    // Questions for Rule Switch (ages 5-6) - Focus on cognitive flexibility
    return [
      {
        id: 'rule_switch_adaptation',
        question: t.reflection.ruleSwitch.q1,
        category: t.reflection.categories.cognitiveFlexibility,
        options: [
          { text: t.reflection.options.switchedImmediately, value: 4, icon: 'star' },
          { text: t.reflection.options.switchedQuickly, value: 3, icon: 'check-circle' },
          { text: t.reflection.options.neededTime, value: 2, icon: 'alert-circle' },
          { text: t.reflection.options.struggled, value: 1, icon: 'close-circle' },
          { text: t.reflection.options.couldNotAdapt, value: 0, icon: 'cancel' },
        ],
      },
      {
        id: 'perseveration',
        question: t.reflection.ruleSwitch.q2,
        category: t.reflection.categories.perseveration,
        options: [
          { text: t.reflection.options.noOldRule, value: 4, icon: 'check-all' },
          { text: t.reflection.options.rarelyOldRule, value: 3, icon: 'check' },
          { text: t.reflection.options.sometimesOldRule, value: 2, icon: 'alert' },
          { text: t.reflection.options.frequentlyOldRule, value: 1, icon: 'close' },
          { text: t.reflection.options.couldNotStop, value: 0, icon: 'cancel' },
        ],
      },
      {
        id: 'prompts_needed',
        question: t.reflection.ruleSwitch.q3,
        category: t.reflection.categories.supportRequired,
        options: [
          { text: t.reflection.options.noReminders, value: 4, icon: 'brain' },
          { text: t.reflection.options.fewReminders, value: 3, icon: 'comment-alert' },
          { text: t.reflection.options.severalReminders, value: 2, icon: 'comment-multiple' },
          { text: t.reflection.options.frequentReminders, value: 1, icon: 'comment-quote' },
          { text: t.reflection.options.constantReminders, value: 0, icon: 'comment-text-multiple' },
        ],
      },
      {
        id: 'frustration_with_change',
        question: t.reflection.ruleSwitch.q4,
        category: t.reflection.categories.emotionalResponse,
        options: [
          { text: t.reflection.options.excitedAboutChange, value: 4, icon: 'emoticon-excited' },
          { text: t.reflection.options.calmAccepted, value: 3, icon: 'emoticon-happy' },
          { text: t.reflection.options.slightlyConfused, value: 2, icon: 'emoticon-neutral' },
          { text: t.reflection.options.upsetNeedReassurance, value: 1, icon: 'emoticon-sad' },
          { text: t.reflection.options.veryDistressed, value: 0, icon: 'emoticon-angry' },
        ],
      },
      {
        id: 'mental_flexibility',
        question: t.reflection.ruleSwitch.q5,
        category: t.reflection.categories.executiveFunction,
        options: [
          { text: t.reflection.options.veryFlexible, value: 4, icon: 'brain' },
          { text: t.reflection.options.generallyFlexible, value: 3, icon: 'head-lightbulb' },
          { text: t.reflection.options.somewhatRigid, value: 2, icon: 'head-question' },
          { text: t.reflection.options.quiteRigid, value: 1, icon: 'head-remove' },
          { text: t.reflection.options.veryRigid, value: 0, icon: 'head-minus' },
        ],
      },
    ];
  };

  const questions = getQuestions();
  const progress = (Object.keys(answers).length / questions.length) * 100;
  const allAnswered = Object.keys(answers).length === questions.length;

  const handleAnswer = (questionId: string, value: number) => {
    setAnswers({ ...answers, [questionId]: value });
  };

  const handleSubmit = async () => {
    if (!allAnswered) {
      Alert.alert(
        t.reflection.incompleteTitle,
        t.reflection.incompleteMessage,
        [{ text: t.common.ok }]
      );
      return;
    }

    // Calculate derived indices
    const totalScore = Object.values(answers).reduce((sum, val) => sum + val, 0);
    const maxScore = questions.length * 4;
    const percentageScore = (totalScore / maxScore) * 100;

    // Calculate category scores
    const categoryScores: { [key: string]: { total: number; count: number } } = {};
    questions.forEach((q) => {
      if (answers[q.id] !== undefined) {
        if (!categoryScores[q.category]) {
          categoryScores[q.category] = { total: 0, count: 0 };
        }
        categoryScores[q.category].total += answers[q.id];
        categoryScores[q.category].count += 1;
      }
    });

    const categoryAverages: { [key: string]: number } = {};
    Object.keys(categoryScores).forEach((category) => {
      categoryAverages[category] =
        (categoryScores[category].total / (categoryScores[category].count * 4)) * 100;
    });

    // Prepare reflection data
    const reflectionData = {
      responses: answers,
      totalScore,
      percentageScore,
      maxScore,
      categoryScores: categoryAverages,
      timestamp: new Date().toISOString(),
      assessedBy: 'clinician', // Could be dynamic based on auth
      childAge: child.age,
      gameType: gameResults.gameType || gameResults.assessmentType,
    };

    // 🔥 LOG TO CONSOLE - DATABASE READY JSON
    await recordClinicalReflection({
      child: child,
      gameType: gameResults.gameType || gameResults.assessmentType,
      reflectionData: reflectionData,
    });

    onComplete(reflectionData);
  };

  const handleSkip = () => {
    Alert.alert(
      t.reflection.skipWarningTitle,
      t.reflection.skipWarningMessage,
      [
        { text: t.cancel, style: 'cancel' },
        { 
          text: t.reflection.skipAnyway, 
          style: 'destructive',
          onPress: onSkip 
        },
      ]
    );
  };

  return (
    <LinearGradient colors={['#667eea', '#764ba2']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.skipButton} onPress={handleSkip}>
          <Text style={styles.skipButtonText}>{t.reflection.skip}</Text>
        </TouchableOpacity>
        
        <View style={styles.progressContainer}>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${progress}%` }]} />
          </View>
          <Text style={styles.progressText}>
            {Object.keys(answers).length} {t.reflection.of} {questions.length} {t.reflection.answered}
          </Text>
        </View>
      </View>

      <ScrollView
        style={styles.contentContainer}
        contentContainerStyle={styles.contentInner}
        showsVerticalScrollIndicator={false}
      >
        {/* Info Card */}
        <View style={styles.infoCard}>
          <Icon name="clipboard-text" size={32} color={COLORS.primary} />
          <Text style={styles.infoTitle}>{t.reflection.infoTitle}</Text>
          <Text style={styles.infoSubtitle}>
            {replacePlaceholders(t.reflection.infoSubtitle, { childName: child.name })}
          </Text>
          <View style={styles.infoNote}>
            <Icon name="information" size={16} color={COLORS.info} />
            <Text style={styles.infoNoteText}>
              {t.reflection.infoNote}
            </Text>
          </View>
        </View>

        {/* Questions */}
        {questions.map((question, index) => {
          const isAnswered = answers[question.id] !== undefined;
          
          return (
            <View key={question.id} style={styles.questionCard}>
              <View style={styles.questionHeader}>
                <View style={styles.questionNumber}>
                  <Text style={styles.questionNumberText}>{index + 1}</Text>
                </View>
                <View style={styles.questionHeaderText}>
                  <Text style={styles.categoryText}>{question.category}</Text>
                  <Text style={styles.questionText}>{question.question}</Text>
                </View>
              </View>

              <View style={styles.optionsContainer}>
                {question.options.map((option) => {
                  const isSelected = answers[question.id] === option.value;
                  
                  return (
                    <TouchableOpacity
                      key={option.value}
                      style={[
                        styles.optionButton,
                        isSelected && styles.optionButtonSelected,
                      ]}
                      onPress={() => handleAnswer(question.id, option.value)}
                    >
                      <Icon
                        name={option.icon}
                        size={20}
                        color={isSelected ? '#FFF' : COLORS.primary}
                      />
                      <Text
                        style={[
                          styles.optionText,
                          isSelected && styles.optionTextSelected,
                        ]}
                      >
                        {option.text}
                      </Text>
                      {isSelected && (
                        <Icon name="check-circle" size={20} color="#FFF" />
                      )}
                    </TouchableOpacity>
                  );
                })}
              </View>
            </View>
          );
        })}

        {/* Submit Button */}
        <TouchableOpacity
          style={[
            styles.submitButton,
            !allAnswered && styles.submitButtonDisabled,
          ]}
          onPress={handleSubmit}
          disabled={!allAnswered}
        >
          <LinearGradient
            colors={allAnswered ? [COLORS.success, '#27AE60'] : ['#CCC', '#AAA']}
            style={styles.submitButtonGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
          >
            <Icon name="check-circle" size={24} color="#FFF" />
            <Text style={styles.submitButtonText}>
              {allAnswered 
                ? t.reflection.completeReflection 
                : replacePlaceholders(t.reflection.answerMore, { 
                    count: (questions.length - Object.keys(answers).length).toString() 
                  })
              }
            </Text>
          </LinearGradient>
        </TouchableOpacity>

        <View style={styles.bottomSpacer} />
      </ScrollView>
    </LinearGradient>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    paddingTop: 50,
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  skipButton: {
    alignSelf: 'flex-end',
    padding: 10,
  },
  skipButtonText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '600',
  },
  progressContainer: {
    marginTop: 10,
  },
  progressBar: {
    height: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#FFF',
    borderRadius: 4,
  },
  progressText: {
    color: '#FFF',
    fontSize: 14,
    marginTop: 8,
    textAlign: 'center',
    fontWeight: '600',
  },
  contentContainer: {
    flex: 1,
  },
  contentInner: {
    padding: 20,
    paddingBottom: 40,
  },
  infoCard: {
    backgroundColor: '#FFF',
    borderRadius: 20,
    padding: 20,
    marginBottom: 20,
    alignItems: 'center',
    ...SHADOWS.medium,
  },
  infoTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '700' as any,
    color: COLORS.text,
    marginTop: 10,
    marginBottom: 5,
  },
  infoSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    textAlign: 'center',
    lineHeight: 20,
    marginBottom: 15,
  },
  infoNote: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: `${COLORS.info}15`,
    padding: 12,
    borderRadius: 10,
    borderLeftWidth: 3,
    borderLeftColor: COLORS.info,
  },
  infoNoteText: {
    flex: 1,
    fontSize: FONTS.sizes.xs,
    color: COLORS.text,
    marginLeft: 8,
    lineHeight: 18,
  },
  questionCard: {
    backgroundColor: '#FFF',
    borderRadius: 16,
    padding: 20,
    marginBottom: 20,
    ...SHADOWS.small,
  },
  questionHeader: {
    flexDirection: 'row',
    marginBottom: 15,
  },
  questionNumber: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: COLORS.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  questionNumberText: {
    color: '#FFF',
    fontSize: 16,
    fontWeight: '700' as any,
  },
  questionHeaderText: {
    flex: 1,
  },
  categoryText: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.primary,
    fontWeight: '600' as any,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 5,
  },
  questionText: {
    fontSize: FONTS.sizes.md,
    fontWeight: '600' as any,
    color: COLORS.text,
    lineHeight: 22,
  },
  optionsContainer: {
    gap: 10,
  },
  optionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    padding: 15,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  optionButtonSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  optionText: {
    flex: 1,
    marginLeft: 12,
    fontSize: FONTS.sizes.sm,
    color: COLORS.text,
    fontWeight: '500' as any,
  },
  optionTextSelected: {
    color: '#FFF',
    fontWeight: '600' as any,
  },
  submitButton: {
    borderRadius: 14,
    overflow: 'hidden',
    marginTop: 20,
    ...SHADOWS.medium,
  },
  submitButtonDisabled: {
    opacity: 0.6,
  },
  submitButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 16,
    paddingHorizontal: 24,
  },
  submitButtonText: {
    color: '#FFF',
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
    marginLeft: 10,
  },
  bottomSpacer: {
    height: 40,
  },
});

export default ClinicianReflectionScreen;

