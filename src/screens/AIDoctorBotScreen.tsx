import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Animated,
  Dimensions,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import { useLanguage, replacePlaceholders } from '../context/LanguageContext';

const { width, height } = Dimensions.get('window');

interface Question {
  id: number;
  question: string;
  category: string;
  options: {
    text: string;
    value: number;
  }[];
}

interface AIDoctorBotScreenProps {
  navigation: any;
  child: {
    id: string;
    name: string;
    age: number;
    gender: string;
  };
  onComplete: (results: any) => void;
  onBack: () => void;
}

const QUESTIONS: Question[] = [
  {
    id: 1,
    question: `Does ${'{childName}'} respond when you call their name?`,
    category: 'Social Responsiveness',
    options: [
      { text: 'Always responds immediately', value: 5 },
      { text: 'Usually responds', value: 4 },
      { text: 'Sometimes responds', value: 3 },
      { text: 'Rarely responds', value: 2 },
      { text: 'Never or almost never responds', value: 1 },
    ],
  },
  {
    id: 2,
    question: `How does ${'{childName}'} react when their daily routine changes?`,
    category: 'Cognitive Flexibility',
    options: [
      { text: 'Adapts easily to changes', value: 5 },
      { text: 'Needs a little time but adapts', value: 4 },
      { text: 'Shows some distress, eventually adapts', value: 3 },
      { text: 'Gets very upset, takes long to adapt', value: 2 },
      { text: 'Cannot adapt, extreme distress', value: 1 },
    ],
  },
  {
    id: 3,
    question: `When playing with toys, does ${'{childName}'} switch between different activities or toys?`,
    category: 'Cognitive Flexibility',
    options: [
      { text: 'Easily switches between toys/activities', value: 5 },
      { text: 'Switches with gentle prompting', value: 4 },
      { text: 'Switches but shows reluctance', value: 3 },
      { text: 'Very difficult to get them to switch', value: 2 },
      { text: 'Refuses to switch, fixates on one toy', value: 1 },
    ],
  },
  {
    id: 4,
    question: `How often does ${'{childName}'} make eye contact when you talk to them?`,
    category: 'Social Communication',
    options: [
      { text: 'Always makes good eye contact', value: 5 },
      { text: 'Usually makes eye contact', value: 4 },
      { text: 'Sometimes makes eye contact', value: 3 },
      { text: 'Rarely makes eye contact', value: 2 },
      { text: 'Avoids eye contact completely', value: 1 },
    ],
  },
  {
    id: 5,
    question: `Does ${'{childName}'} point to objects they want or find interesting?`,
    category: 'Joint Attention',
    options: [
      { text: 'Frequently points and shares interest', value: 5 },
      { text: 'Often points to things', value: 4 },
      { text: 'Occasionally points', value: 3 },
      { text: 'Rarely points', value: 2 },
      { text: 'Never or almost never points', value: 1 },
    ],
  },
  {
    id: 6,
    question: `How does ${'{childName}'} react to unexpected sounds or sensory experiences?`,
    category: 'Sensory Processing',
    options: [
      { text: 'Reacts appropriately, recovers quickly', value: 5 },
      { text: 'Startles but calms down soon', value: 4 },
      { text: 'Gets upset, needs comfort', value: 3 },
      { text: 'Very distressed, takes long to calm', value: 2 },
      { text: 'Extreme distress or complete shutdown', value: 1 },
    ],
  },
  {
    id: 7,
    question: `Does ${'{childName}'} imitate your actions or words?`,
    category: 'Social Learning',
    options: [
      { text: 'Frequently imitates spontaneously', value: 5 },
      { text: 'Often imitates when prompted', value: 4 },
      { text: 'Imitates some simple actions', value: 3 },
      { text: 'Rarely imitates', value: 2 },
      { text: 'Never or almost never imitates', value: 1 },
    ],
  },
  {
    id: 8,
    question: `How does ${'{childName}'} play with other children?`,
    category: 'Social Interaction',
    options: [
      { text: 'Actively engages and shares', value: 5 },
      { text: 'Plays near others, some interaction', value: 4 },
      { text: 'Parallel play, minimal interaction', value: 3 },
      { text: 'Prefers solitary play, avoids others', value: 2 },
      { text: 'No interest in other children', value: 1 },
    ],
  },
  {
    id: 9,
    question: `Does ${'{childName}'} show interest when you show them something?`,
    category: 'Joint Attention',
    options: [
      { text: 'Always looks and shows interest', value: 5 },
      { text: 'Usually looks when you point', value: 4 },
      { text: 'Sometimes follows your gaze/point', value: 3 },
      { text: 'Rarely follows your attention', value: 2 },
      { text: 'Never follows your gaze or point', value: 1 },
    ],
  },
  {
    id: 10,
    question: `How does ${'{childName}'} express their needs or wants?`,
    category: 'Communication',
    options: [
      { text: 'Uses words and gestures clearly', value: 5 },
      { text: 'Uses gestures and some words', value: 4 },
      { text: 'Mostly gestures, few words', value: 3 },
      { text: 'Pulls you to objects, little gesture', value: 2 },
      { text: 'Cries or tantrums, no clear communication', value: 1 },
    ],
  },
];

const AIDoctorBotScreen: React.FC<AIDoctorBotScreenProps> = ({
  navigation,
  child,
  onComplete,
  onBack,
}) => {
  const { t } = useLanguage();
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [answers, setAnswers] = useState<{ [key: number]: number }>({});
  const [botAnimation] = useState(new Animated.Value(0));
  const [questionAnimation] = useState(new Animated.Value(0));

  // Build translated questions with options
  const translatedQuestions = [
    { 
      id: 1, 
      question: replacePlaceholders(t.aiBot.questions.q1, { childName: child.name }), 
      category: t.aiBot.categories.socialResponsiveness,
      options: t.aiBot.options.frequency
    },
    { 
      id: 2, 
      question: replacePlaceholders(t.aiBot.questions.q2, { childName: child.name }), 
      category: t.aiBot.categories.cognitiveFlexibility,
      options: t.aiBot.options.routineChange
    },
    { 
      id: 3, 
      question: replacePlaceholders(t.aiBot.questions.q3, { childName: child.name }), 
      category: t.aiBot.categories.cognitiveFlexibility,
      options: t.aiBot.options.agreement
    },
    { 
      id: 4, 
      question: replacePlaceholders(t.aiBot.questions.q4, { childName: child.name }), 
      category: t.aiBot.categories.socialCommunication,
      options: t.aiBot.options.frequency
    },
    { 
      id: 5, 
      question: replacePlaceholders(t.aiBot.questions.q5, { childName: child.name }), 
      category: t.aiBot.categories.jointAttention,
      options: t.aiBot.options.frequency
    },
    { 
      id: 6, 
      question: replacePlaceholders(t.aiBot.questions.q6, { childName: child.name }), 
      category: t.aiBot.categories.sensoryProcessing,
      options: t.aiBot.options.sensoryResponse
    },
    { 
      id: 7, 
      question: replacePlaceholders(t.aiBot.questions.q7, { childName: child.name }), 
      category: t.aiBot.categories.socialLearning,
      options: t.aiBot.options.frequency
    },
    { 
      id: 8, 
      question: replacePlaceholders(t.aiBot.questions.q8, { childName: child.name }), 
      category: t.aiBot.categories.socialInteraction,
      options: t.aiBot.options.frequency
    },
    { 
      id: 9, 
      question: replacePlaceholders(t.aiBot.questions.q9, { childName: child.name }), 
      category: t.aiBot.categories.jointAttention,
      options: t.aiBot.options.frequency
    },
    { 
      id: 10, 
      question: replacePlaceholders(t.aiBot.questions.q10, { childName: child.name }), 
      category: t.aiBot.categories.communication,
      options: t.aiBot.options.expressNeeds
    },
  ];

  useEffect(() => {
    animateBot();
    animateQuestion();
  }, [currentQuestion]);

  const animateBot = () => {
    botAnimation.setValue(0);
    Animated.spring(botAnimation, {
      toValue: 1,
      friction: 3,
      tension: 40,
      useNativeDriver: true,
    }).start();
  };

  const animateQuestion = () => {
    questionAnimation.setValue(0);
    Animated.timing(questionAnimation, {
      toValue: 1,
      duration: 400,
      useNativeDriver: true,
    }).start();
  };

  const handleAnswer = (questionId: number, value: number) => {
    setAnswers({ ...answers, [questionId]: value });

    // Move to next question after a brief delay
    setTimeout(() => {
      if (currentQuestion < translatedQuestions.length - 1) {
        setCurrentQuestion(currentQuestion + 1);
      } else {
        // All questions answered, calculate results
        completeAssessment();
      }
    }, 300);
  };

  const completeAssessment = () => {
    const totalScore = Object.values(answers).reduce((sum, val) => sum + val, 0);
    const maxScore = translatedQuestions.length * 5;
    const percentageScore = (totalScore / maxScore) * 100;

    // Calculate category scores
    const categoryScores: { [key: string]: { total: number; count: number } } = {};
    
    translatedQuestions.forEach((q) => {
      if (answers[q.id]) {
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
        (categoryScores[category].total / (categoryScores[category].count * 5)) * 100;
    });

    // Calculate risk score (inverted - lower behavioral score = higher risk)
    const riskScore = 100 - percentageScore;

    const results = {
      id: Date.now().toString(),
      childId: child.id,
      childName: child.name,
      childAge: child.age,
      childGender: child.gender,
      sessionDate: new Date().toISOString(),
      assessmentType: 'ai_bot_questionnaire',
      responses: answers,
      totalScore: totalScore,
      percentageScore: percentageScore,
      riskScore: riskScore,
      categoryScores: categoryAverages,
      summary: {
        totalQuestions: translatedQuestions.length,
        answeredQuestions: Object.keys(answers).length,
        averageScore: percentageScore,
        riskLevel: riskScore < 30 ? 'Low' : riskScore < 60 ? 'Moderate' : 'High',
        recommendations: generateRecommendations(percentageScore, categoryAverages),
      },
      completionTime: Date.now(),
    };

    onComplete(results);
  };

  const generateRecommendations = (
    score: number,
    categoryScores: { [key: string]: number }
  ): string[] => {
    const recommendations: string[] = [];

    if (score >= 80) {
      recommendations.push('Child shows typical development patterns');
      recommendations.push('Continue regular developmental monitoring');
    } else if (score >= 60) {
      recommendations.push('Some areas may benefit from targeted support');
      recommendations.push('Consider follow-up assessment in 3-6 months');
    } else {
      recommendations.push('Multiple developmental concerns identified');
      recommendations.push('Recommend comprehensive developmental evaluation');
      recommendations.push('Consider referral to developmental specialist');
    }

    // Add category-specific recommendations
    Object.keys(categoryScores).forEach((category) => {
      if (categoryScores[category] < 60) {
        recommendations.push(`Focus on ${category.toLowerCase()} skills`);
      }
    });

    return recommendations;
  };

  const goBack = () => {
    if (currentQuestion > 0) {
      setCurrentQuestion(currentQuestion - 1);
    } else {
      onBack();
    }
  };

  const progress = ((currentQuestion + 1) / translatedQuestions.length) * 100;
  const question = translatedQuestions[currentQuestion];
  const questionText = question.question;

  const botScale = botAnimation.interpolate({
    inputRange: [0, 1],
    outputRange: [0.8, 1],
  });

  const questionOpacity = questionAnimation;

  return (
    <LinearGradient colors={['#667eea', '#764ba2']} style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={goBack}>
          <Text style={styles.backButtonText}>← {t.common.back}</Text>
        </TouchableOpacity>
        <View style={styles.progressContainer}>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${progress}%` }]} />
          </View>
          <Text style={styles.progressText}>
            {replacePlaceholders(t.aiBot.questionProgress, { current: currentQuestion + 1, total: translatedQuestions.length })}
          </Text>
        </View>
      </View>

      <ScrollView
        style={styles.contentContainer}
        contentContainerStyle={styles.contentInner}
        showsVerticalScrollIndicator={false}
      >
        {/* Bot Avatar */}
        <Animated.View
          style={[
            styles.botContainer,
            {
              transform: [{ scale: botScale }],
            },
          ]}
        >
          <View style={styles.botAvatar}>
            <Text style={styles.botEmoji}>🤖</Text>
          </View>
          <View style={styles.botSpeechBubble}>
            <Text style={styles.botName}>{t.aiBot.title}</Text>
          </View>
        </Animated.View>

        {/* Question Card */}
        <Animated.View
          style={[
            styles.questionCard,
            {
              opacity: questionOpacity,
            },
          ]}
        >
          <View style={styles.questionHeader}>
            <Text style={styles.categoryText}>{question.category}</Text>
          </View>
          <Text style={styles.questionText}>{questionText}</Text>

          {/* Answer Options */}
          <View style={styles.optionsContainer}>
            {question.options.map((option, index) => (
              <TouchableOpacity
                key={index}
                style={[
                  styles.optionButton,
                  answers[question.id] === option.value && styles.optionButtonSelected,
                ]}
                onPress={() => handleAnswer(question.id, option.value)}
              >
                <View style={styles.optionContent}>
                  <View
                    style={[
                      styles.optionCircle,
                      answers[question.id] === option.value &&
                        styles.optionCircleSelected,
                    ]}
                  >
                    {answers[question.id] === option.value && (
                      <Text style={styles.checkmark}>✓</Text>
                    )}
                  </View>
                  <Text
                    style={[
                      styles.optionText,
                      answers[question.id] === option.value &&
                        styles.optionTextSelected,
                    ]}
                  >
                    {option.text}
                  </Text>
                </View>
              </TouchableOpacity>
            ))}
          </View>
        </Animated.View>
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
  backButton: {
    alignSelf: 'flex-start',
    padding: 10,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
  progressContainer: {
    marginTop: 15,
  },
  progressBar: {
    height: 8,
    backgroundColor: 'rgba(255, 255, 255, 0.3)',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#fff',
    borderRadius: 4,
  },
  progressText: {
    color: '#fff',
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
  botContainer: {
    alignItems: 'center',
    marginBottom: 30,
  },
  botAvatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  botEmoji: {
    fontSize: 50,
  },
  botSpeechBubble: {
    marginTop: 15,
    backgroundColor: '#fff',
    paddingHorizontal: 20,
    paddingVertical: 10,
    borderRadius: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.2,
    shadowRadius: 4,
    elevation: 4,
  },
  botName: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#667eea',
  },
  questionCard: {
    backgroundColor: '#fff',
    borderRadius: 20,
    padding: 25,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 8,
    elevation: 6,
  },
  questionHeader: {
    marginBottom: 15,
  },
  categoryText: {
    fontSize: 14,
    color: '#667eea',
    fontWeight: '600',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  questionText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 25,
    lineHeight: 28,
  },
  optionsContainer: {
    gap: 12,
  },
  optionButton: {
    backgroundColor: '#f8f9fa',
    borderRadius: 15,
    padding: 18,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  optionButtonSelected: {
    backgroundColor: '#e8eaf6',
    borderColor: '#667eea',
  },
  optionContent: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  optionCircle: {
    width: 24,
    height: 24,
    borderRadius: 12,
    borderWidth: 2,
    borderColor: '#ccc',
    marginRight: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  optionCircleSelected: {
    backgroundColor: '#667eea',
    borderColor: '#667eea',
  },
  checkmark: {
    color: '#fff',
    fontSize: 16,
    fontWeight: 'bold',
  },
  optionText: {
    fontSize: 16,
    color: '#555',
    flex: 1,
    lineHeight: 22,
  },
  optionTextSelected: {
    color: '#333',
    fontWeight: '600',
  },
});

export default AIDoctorBotScreen;

