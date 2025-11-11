/**
 * Component Dashboard Screen - Advanced Professional Edition
 * Real-world clinical assessment system with statistics, insights, and scheduling
 * Features: Component analytics, recent assessments, progress tracking, recommendations
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Dimensions,
  StatusBar,
  Animated,
  RefreshControl,
  LayoutAnimation,
  Platform,
  UIManager,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { COMPONENTS, COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import LinearGradient from 'react-native-linear-gradient';
import { storageService } from '../services/storage.simple';
import { Child } from '../types';

// Enable LayoutAnimation for Android
if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

const { width, height: SCREEN_HEIGHT } = Dimensions.get('window');
const CARD_WIDTH = (width - SPACING.lg * 3) / 2;

interface ComponentDashboardScreenProps {
  navigation: any;
}

interface ComponentStats {
  totalChildren: number;
  completed: number;
  pending: number;
  averageAge: number;
  lastAssessment: Date | null;
  completionRate: number;
}

interface AssessmentHistory {
  childName: string;
  age: number;
  date: Date;
  componentKey: string;
  completed: boolean;
}

const ComponentDashboardScreen: React.FC<ComponentDashboardScreenProps> = ({ navigation }) => {
  const [children, setChildren] = useState<Child[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [recentAssessments, setRecentAssessments] = useState<AssessmentHistory[]>([]);
  const [componentStats, setComponentStats] = useState<Record<string, ComponentStats>>({});
  const [selectedComponent, setSelectedComponent] = useState<string | null>(null);
  const [fadeAnim] = useState(new Animated.Value(0));
  const [slideAnim] = useState(new Animated.Value(50));

  useEffect(() => {
    loadData();
    startAnimations();
  }, []);

  const startAnimations = () => {
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 600,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const loadData = async () => {
    try {
      setLoading(true);
      const childrenData = await storageService.getChildren();
      
      // Calculate ages from date of birth
      const updatedChildren = childrenData.map(child => ({
        ...child,
        age: child.dateOfBirth ? calculateAge(child.dateOfBirth) : child.age
      }));
      
      setChildren(updatedChildren);
      calculateComponentStats(updatedChildren);
      generateRecentAssessments(updatedChildren);
    } catch (error) {
      console.error('Error loading data:', error);
    } finally {
      setLoading(false);
    }
  };

  const calculateAge = (dateOfBirth: string): number => {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  };

  const calculateComponentStats = (childrenData: Child[]) => {
    const stats: Record<string, ComponentStats> = {};
    
    Object.keys(COMPONENTS).forEach(key => {
      const component = COMPONENTS[key as keyof typeof COMPONENTS];
      
      // Determine eligible children based on age ranges
      let eligibleChildren: Child[] = [];
      if (key === 'cognitiveFlexibility') {
        eligibleChildren = childrenData.filter(c => c.age >= 2 && c.age <= 6);
      } else if (key === 'socialCommunication') {
        eligibleChildren = childrenData.filter(c => c.age >= 2 && c.age <= 6);
      } else if (key === 'sensoryProcessing') {
        eligibleChildren = childrenData.filter(c => c.age >= 2 && c.age <= 6);
      } else if (key === 'repetitiveBehaviors') {
        eligibleChildren = childrenData.filter(c => c.age >= 2 && c.age <= 6);
      }
      
      const completed = eligibleChildren.filter(c => c.testCompleted).length;
      const pending = eligibleChildren.length - completed;
      const averageAge = eligibleChildren.length > 0
        ? eligibleChildren.reduce((sum, c) => sum + c.age, 0) / eligibleChildren.length
        : 0;
      
      const completionRate = eligibleChildren.length > 0
        ? (completed / eligibleChildren.length) * 100
        : 0;
      
      const lastAssessment = eligibleChildren.length > 0
        ? new Date(Math.max(...eligibleChildren.map(c => new Date(c.createdAt).getTime())))
        : null;
      
      stats[key] = {
        totalChildren: eligibleChildren.length,
        completed,
        pending,
        averageAge: Math.round(averageAge * 10) / 10,
        lastAssessment,
        completionRate: Math.round(completionRate),
      };
    });
    
    setComponentStats(stats);
  };

  const generateRecentAssessments = (childrenData: Child[]) => {
    const assessments: AssessmentHistory[] = childrenData
      .map(child => ({
        childName: child.name,
        age: child.age,
        date: new Date(child.createdAt),
        componentKey: getComponentForAge(child.age),
        completed: child.testCompleted || false,
      }))
      .sort((a, b) => b.date.getTime() - a.date.getTime())
      .slice(0, 5);
    
    setRecentAssessments(assessments);
  };

  const getComponentForAge = (age: number): string => {
    if (age >= 2 && age < 3) return 'cognitiveFlexibility';
    if (age >= 3 && age < 5) return 'socialCommunication';
    if (age >= 5 && age <= 6) return 'sensoryProcessing';
    return 'repetitiveBehaviors';
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleComponentPress = (componentKey: string) => {
    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    setSelectedComponent(selectedComponent === componentKey ? null : componentKey);
    
    setTimeout(() => {
      navigation.navigate('CognitiveDashboard', { componentKey });
    }, 300);
  };

  const formatDate = (date: Date) => {
    const now = new Date();
    const diffMs = now.getTime() - date.getTime();
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);
    
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  };

  const renderComponentCard = (key: string, index: number) => {
    const component = COMPONENTS[key as keyof typeof COMPONENTS];
    const stats = componentStats[key];
    const isSelected = selectedComponent === key;
    
    if (!stats) return null;
    
    return (
      <Animated.View
        key={key}
        style={[
          styles.componentCard,
          isSelected && styles.componentCardSelected,
          {
            opacity: fadeAnim,
            transform: [
              { scale: isSelected ? 1.02 : 1 },
              { translateY: Animated.multiply(slideAnim, new Animated.Value(index * 0.1)) }
            ]
          }
        ]}
      >
        <TouchableOpacity
          onPress={() => handleComponentPress(key)}
          activeOpacity={0.8}
        >
          <LinearGradient
            colors={[component.color, component.color + 'DD']}
            style={styles.cardGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          >
            {/* Header */}
            <View style={styles.cardHeader}>
              <View style={styles.iconContainer}>
                <Icon name={component.icon} size={32} color="#FFF" />
              </View>
              
              {stats.completionRate > 0 && (
                <View style={styles.progressBadge}>
                  <Text style={styles.progressText}>{stats.completionRate}%</Text>
                </View>
              )}
            </View>
            
            {/* Component Name */}
            <Text style={styles.componentName} numberOfLines={2}>
              {component.name}
            </Text>
            
            <Text style={styles.componentDescription} numberOfLines={2}>
              {component.description}
            </Text>
            
            {/* Stats Grid */}
            <View style={styles.statsGrid}>
              <View style={styles.statItem}>
                <Icon name="account-group" size={16} color="rgba(255,255,255,0.9)" />
                <Text style={styles.statValue}>{stats.totalChildren}</Text>
                <Text style={styles.statLabel}>Patients</Text>
              </View>
              
              <View style={styles.statDivider} />
              
              <View style={styles.statItem}>
                <Icon name="check-circle" size={16} color="rgba(255,255,255,0.9)" />
                <Text style={styles.statValue}>{stats.completed}</Text>
                <Text style={styles.statLabel}>Complete</Text>
              </View>
              
              <View style={styles.statDivider} />
              
              <View style={styles.statItem}>
                <Icon name="clock-alert" size={16} color="rgba(255,255,255,0.9)" />
                <Text style={styles.statValue}>{stats.pending}</Text>
                <Text style={styles.statLabel}>Pending</Text>
              </View>
            </View>
            
            {/* Action Button */}
            <View style={styles.cardFooter}>
              <View style={styles.lastAssessment}>
                <Icon name="calendar-clock" size={14} color="rgba(255,255,255,0.8)" />
                <Text style={styles.lastAssessmentText}>
                  {stats.lastAssessment
                    ? `Last: ${formatDate(stats.lastAssessment)}`
                    : 'No assessments yet'}
                </Text>
              </View>
              <Icon name="arrow-right-circle" size={24} color="rgba(255,255,255,0.9)" />
            </View>
          </LinearGradient>
        </TouchableOpacity>
      </Animated.View>
    );
  };

  const renderRecentAssessment = (assessment: AssessmentHistory, index: number) => {
    const component = COMPONENTS[assessment.componentKey as keyof typeof COMPONENTS];
    
    return (
      <Animated.View
        key={`${assessment.childName}-${index}`}
        style={[
          styles.assessmentItem,
          {
            opacity: fadeAnim,
            transform: [{ translateY: Animated.multiply(slideAnim, new Animated.Value(index * 0.05)) }]
          }
        ]}
      >
        <View style={[styles.assessmentIcon, { backgroundColor: `${component.color}20` }]}>
          <Icon name={component.icon} size={20} color={component.color} />
        </View>
        
        <View style={styles.assessmentInfo}>
          <Text style={styles.assessmentChildName}>{assessment.childName}</Text>
          <View style={styles.assessmentMeta}>
            <Text style={styles.assessmentMetaText}>{assessment.age} years old</Text>
            <View style={styles.metaDot} />
            <Text style={styles.assessmentMetaText}>{formatDate(assessment.date)}</Text>
          </View>
        </View>
        
        <View style={[
          styles.assessmentStatus,
          { backgroundColor: assessment.completed ? '#4CAF50' : '#FF9800' }
        ]}>
          <Text style={styles.assessmentStatusText}>
            {assessment.completed ? 'Done' : 'Pending'}
          </Text>
        </View>
      </Animated.View>
    );
  };

  const renderOverallStats = () => {
    const totalPatients = children.length;
    const totalCompleted = children.filter(c => c.testCompleted).length;
    const totalPending = totalPatients - totalCompleted;
    const overallCompletion = totalPatients > 0 ? Math.round((totalCompleted / totalPatients) * 100) : 0;
    
    return (
      <View style={styles.overallStatsContainer}>
        <LinearGradient
          colors={['#667eea', '#764ba2']}
          style={styles.overallStatsGradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
        >
          <View style={styles.overallStatsHeader}>
            <View>
              <Text style={styles.overallStatsTitle}>Assessment Overview</Text>
              <Text style={styles.overallStatsSubtitle}>All components combined</Text>
            </View>
            <View style={styles.completionCircle}>
              <Text style={styles.completionPercentage}>{overallCompletion}%</Text>
            </View>
          </View>
          
          <View style={styles.overallStatsRow}>
            <View style={styles.overallStatItem}>
              <Text style={styles.overallStatValue}>{totalPatients}</Text>
              <Text style={styles.overallStatLabel}>Total Patients</Text>
            </View>
            
            <View style={styles.overallStatDivider} />
            
            <View style={styles.overallStatItem}>
              <Text style={styles.overallStatValue}>{totalCompleted}</Text>
              <Text style={styles.overallStatLabel}>Completed</Text>
            </View>
            
            <View style={styles.overallStatDivider} />
            
            <View style={styles.overallStatItem}>
              <Text style={styles.overallStatValue}>{totalPending}</Text>
              <Text style={styles.overallStatLabel}>Pending</Text>
            </View>
          </View>
        </LinearGradient>
      </View>
    );
  };

  const renderRecommendations = () => {
    const recommendations = [];
    
    // Age-based recommendations
    const age2to3 = children.filter(c => c.age >= 2 && c.age < 3).length;
    const age3to5 = children.filter(c => c.age >= 3 && c.age < 5).length;
    const age5to6 = children.filter(c => c.age >= 5 && c.age <= 6).length;
    
    if (age2to3 > 0) {
      recommendations.push({
        icon: 'robot',
        color: COLORS.age2to3,
        title: `${age2to3} children (2-3 years)`,
        description: 'Ready for AI Doctor Bot questionnaire',
      });
    }
    
    if (age3to5 > 0) {
      recommendations.push({
        icon: 'frog',
        color: COLORS.age4to5,
        title: `${age3to5} children (3-5 years)`,
        description: 'Ready for Frog Jump Game assessment',
      });
    }
    
    if (age5to6 > 0) {
      recommendations.push({
        icon: 'flower',
        color: COLORS.age5to6,
        title: `${age5to6} children (5-6 years)`,
        description: 'Ready for Magic Garden DCCS task',
      });
    }
    
    if (recommendations.length === 0) {
      recommendations.push({
        icon: 'account-plus',
        color: COLORS.primary,
        title: 'No patients yet',
        description: 'Add patients to begin assessments',
      });
    }
    
    return (
      <View style={styles.recommendationsContainer}>
        <View style={styles.sectionHeader}>
          <Icon name="lightbulb-on" size={20} color={COLORS.warning} />
          <Text style={styles.sectionTitle}>Quick Insights</Text>
        </View>
        
        {recommendations.map((rec, index) => (
          <View key={index} style={styles.recommendationCard}>
            <View style={[styles.recommendationIcon, { backgroundColor: `${rec.color}20` }]}>
              <Icon name={rec.icon} size={24} color={rec.color} />
            </View>
            <View style={styles.recommendationContent}>
              <Text style={styles.recommendationTitle}>{rec.title}</Text>
              <Text style={styles.recommendationDescription}>{rec.description}</Text>
            </View>
          </View>
        ))}
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={COLORS.primary} />
      
      {/* Header */}
      <LinearGradient
        colors={[COLORS.primary, COLORS.secondary]}
        style={styles.header}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        <View style={styles.headerTop}>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <Icon name="arrow-left" size={24} color="#FFF" />
          </TouchableOpacity>
          
          <View style={styles.headerTitleContainer}>
            <View style={styles.headerIconBox}>
              <Icon name="view-dashboard" size={28} color="#FFF" />
            </View>
            <View>
              <Text style={styles.headerTitle}>Assessment Components</Text>
              <Text style={styles.headerSubtitle}>Clinical Evaluation Center</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.headerAction}>
            <Icon name="information" size={24} color="#FFF" />
          </TouchableOpacity>
        </View>
      </LinearGradient>

      <ScrollView
        style={styles.content}
        contentContainerStyle={styles.contentContainer}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={handleRefresh}
            colors={[COLORS.primary]}
            tintColor={COLORS.primary}
          />
        }
      >
        {/* Overall Statistics */}
        {renderOverallStats()}

        {/* Component Cards Grid */}
        <View style={styles.sectionHeaderContainer}>
          <Text style={styles.sectionTitleMain}>Assessment Components</Text>
          <Text style={styles.sectionSubtitle}>Tap a component to view details and start assessment</Text>
        </View>

        <View style={styles.cardsGrid}>
          {Object.keys(COMPONENTS).map((key, index) => 
            renderComponentCard(key, index)
          )}
        </View>

        {/* Recent Assessments */}
        {recentAssessments.length > 0 && (
          <View style={styles.recentSection}>
            <View style={styles.sectionHeader}>
              <Icon name="history" size={20} color={COLORS.primary} />
              <Text style={styles.sectionTitle}>Recent Activity</Text>
            </View>
            
            <View style={styles.recentList}>
              {recentAssessments.map((assessment, index) => 
                renderRecentAssessment(assessment, index)
              )}
            </View>
          </View>
        )}

        {/* Recommendations */}
        {renderRecommendations()}

        {/* Clinical Guidelines */}
        <View style={styles.guidelinesSection}>
          <LinearGradient
            colors={['#E8EAF6', '#C5CAE9']}
            style={styles.guidelinesCard}
          >
            <View style={styles.guidelinesHeader}>
              <Icon name="book-open-variant" size={24} color={COLORS.primary} />
              <Text style={styles.guidelinesTitle}>Clinical Guidelines</Text>
            </View>
            
            <View style={styles.guidelinesList}>
              <View style={styles.guidelineItem}>
                <View style={styles.guidelineBullet}>
                  <Icon name="circle-small" size={16} color={COLORS.primary} />
                </View>
                <Text style={styles.guidelineText}>
                  Each component assesses specific developmental domains using evidence-based methodologies
                </Text>
              </View>
              
              <View style={styles.guidelineItem}>
                <View style={styles.guidelineBullet}>
                  <Icon name="circle-small" size={16} color={COLORS.primary} />
                </View>
                <Text style={styles.guidelineText}>
                  Age-appropriate assessments are automatically recommended based on patient profile
                </Text>
              </View>
              
              <View style={styles.guidelineItem}>
                <View style={styles.guidelineBullet}>
                  <Icon name="circle-small" size={16} color={COLORS.primary} />
                </View>
                <Text style={styles.guidelineText}>
                  Comprehensive reports are generated after completing each assessment
                </Text>
              </View>
            </View>
          </LinearGradient>
        </View>

        <View style={styles.bottomSpacer} />
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F7FA',
  },
  header: {
    paddingTop: SPACING.xl,
    paddingBottom: SPACING.lg,
    paddingHorizontal: SPACING.lg,
    ...SHADOWS.large,
  },
  headerTop: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  backButton: {
    padding: SPACING.sm,
  },
  headerTitleContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
    marginLeft: SPACING.md,
  },
  headerIconBox: {
    width: 44,
    height: 44,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING.md,
  },
  headerTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '700' as any,
    color: '#FFF',
    letterSpacing: 0.5,
  },
  headerSubtitle: {
    fontSize: FONTS.sizes.xs,
    color: 'rgba(255,255,255,0.85)',
    marginTop: 2,
    fontWeight: '500' as any,
  },
  headerAction: {
    padding: SPACING.sm,
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: SPACING.lg,
  },
  // Overall Stats
  overallStatsContainer: {
    marginBottom: SPACING.lg,
  },
  overallStatsGradient: {
    borderRadius: 20,
    padding: SPACING.lg,
    ...SHADOWS.medium,
  },
  overallStatsHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.md,
  },
  overallStatsTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  overallStatsSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: 'rgba(255,255,255,0.85)',
    marginTop: 2,
  },
  completionCircle: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(255,255,255,0.25)',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 3,
    borderColor: 'rgba(255,255,255,0.5)',
  },
  completionPercentage: {
    fontSize: 18,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  overallStatsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 12,
    paddingVertical: SPACING.md,
  },
  overallStatItem: {
    alignItems: 'center',
  },
  overallStatValue: {
    fontSize: 28,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  overallStatLabel: {
    fontSize: FONTS.sizes.xs,
    color: 'rgba(255,255,255,0.85)',
    marginTop: 4,
    fontWeight: '500' as any,
  },
  overallStatDivider: {
    width: 1,
    backgroundColor: 'rgba(255,255,255,0.3)',
  },
  // Section Headers
  sectionHeaderContainer: {
    marginBottom: SPACING.md,
  },
  sectionTitleMain: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700' as any,
    color: COLORS.text,
  },
  sectionSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginTop: 4,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING.md,
  },
  sectionTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700' as any,
    color: COLORS.text,
    marginLeft: SPACING.sm,
  },
  // Component Cards
  cardsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: SPACING.xl,
  },
  componentCard: {
    width: CARD_WIDTH,
    marginBottom: SPACING.lg,
    borderRadius: 20,
    overflow: 'hidden',
    ...SHADOWS.large,
  },
  componentCardSelected: {
    borderWidth: 2,
    borderColor: COLORS.primary,
  },
  cardGradient: {
    padding: SPACING.md,
    minHeight: 260,
    justifyContent: 'space-between',
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: SPACING.sm,
  },
  iconContainer: {
    width: 56,
    height: 56,
    borderRadius: 16,
    backgroundColor: 'rgba(255,255,255,0.25)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  progressBadge: {
    backgroundColor: 'rgba(255,255,255,0.3)',
    paddingHorizontal: SPACING.sm,
    paddingVertical: 4,
    borderRadius: 12,
  },
  progressText: {
    fontSize: FONTS.sizes.xs,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  componentName: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
    color: '#FFF',
    marginBottom: SPACING.xs,
    lineHeight: 20,
  },
  componentDescription: {
    fontSize: FONTS.sizes.sm,
    color: 'rgba(255,255,255,0.9)',
    lineHeight: 18,
    marginBottom: SPACING.sm,
  },
  statsGrid: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    backgroundColor: 'rgba(255,255,255,0.2)',
    borderRadius: 12,
    paddingVertical: SPACING.sm,
    marginBottom: SPACING.sm,
  },
  statItem: {
    alignItems: 'center',
  },
  statValue: {
    fontSize: 18,
    fontWeight: '700' as any,
    color: '#FFF',
    marginTop: 2,
  },
  statLabel: {
    fontSize: 10,
    color: 'rgba(255,255,255,0.85)',
    marginTop: 2,
    fontWeight: '500' as any,
  },
  statDivider: {
    width: 1,
    backgroundColor: 'rgba(255,255,255,0.3)',
  },
  cardFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: SPACING.xs,
  },
  lastAssessment: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  lastAssessmentText: {
    fontSize: FONTS.sizes.xs,
    color: 'rgba(255,255,255,0.85)',
    marginLeft: 4,
    fontWeight: '500' as any,
  },
  // Recent Assessments
  recentSection: {
    marginBottom: SPACING.xl,
  },
  recentList: {
    backgroundColor: '#FFF',
    borderRadius: 16,
    padding: SPACING.sm,
    ...SHADOWS.small,
  },
  assessmentItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.sm,
    paddingHorizontal: SPACING.sm,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  assessmentIcon: {
    width: 40,
    height: 40,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING.sm,
  },
  assessmentInfo: {
    flex: 1,
  },
  assessmentChildName: {
    fontSize: FONTS.sizes.md,
    fontWeight: '600' as any,
    color: COLORS.text,
  },
  assessmentMeta: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  assessmentMetaText: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.textSecondary,
  },
  metaDot: {
    width: 3,
    height: 3,
    borderRadius: 1.5,
    backgroundColor: COLORS.textSecondary,
    marginHorizontal: 6,
  },
  assessmentStatus: {
    paddingHorizontal: SPACING.sm,
    paddingVertical: 4,
    borderRadius: 8,
  },
  assessmentStatusText: {
    fontSize: 10,
    fontWeight: '600' as any,
    color: '#FFF',
  },
  // Recommendations
  recommendationsContainer: {
    marginBottom: SPACING.xl,
  },
  recommendationCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF',
    padding: SPACING.md,
    borderRadius: 12,
    marginBottom: SPACING.sm,
    ...SHADOWS.small,
  },
  recommendationIcon: {
    width: 48,
    height: 48,
    borderRadius: 12,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING.md,
  },
  recommendationContent: {
    flex: 1,
  },
  recommendationTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: '600' as any,
    color: COLORS.text,
  },
  recommendationDescription: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginTop: 2,
  },
  // Guidelines
  guidelinesSection: {
    marginBottom: SPACING.xl,
  },
  guidelinesCard: {
    borderRadius: 16,
    padding: SPACING.lg,
  },
  guidelinesHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING.md,
  },
  guidelinesTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700' as any,
    color: COLORS.primary,
    marginLeft: SPACING.sm,
  },
  guidelinesList: {},
  guidelineItem: {
    flexDirection: 'row',
    marginBottom: SPACING.sm,
  },
  guidelineBullet: {
    marginRight: SPACING.xs,
  },
  guidelineText: {
    flex: 1,
    fontSize: FONTS.sizes.sm,
    color: COLORS.text,
    lineHeight: 20,
  },
  bottomSpacer: {
    height: SPACING.xl,
  },
});

export default ComponentDashboardScreen;
