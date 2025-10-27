/**
 * Cognitive Flexibility Dashboard
 * Manage children and start assessments for cognitive flexibility component
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
  StatusBar,
  RefreshControl,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import LinearGradient from 'react-native-linear-gradient';
import { useLanguage } from '../context/LanguageContext';
import { COLORS, FONTS, SPACING, SHADOWS, AGE_GROUPS } from '../constants';
import { storageService } from '../services/storage';
import { Child } from '../types';

interface CognitiveDashboardScreenProps {
  navigation: any;
  route: any;
}

const CognitiveDashboardScreen: React.FC<CognitiveDashboardScreenProps> = ({
  navigation,
  route,
}) => {
  const { t } = useLanguage();
  const [children, setChildren] = useState<Child[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadChildren();
  }, []);

  const loadChildren = async () => {
    try {
      setLoading(true);
      const childrenData = await storageService.getChildren();
      setChildren(childrenData);
    } catch (error) {
      console.error('Error loading children:', error);
      Alert.alert(t.errors.loadFailed, t.errors.loadFailed);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadChildren();
    setRefreshing(false);
  };

  const handleAddChild = () => {
    navigation.navigate('ChildRegistration', {
      onChildAdded: () => {
        loadChildren();
      },
    });
  };

  const getRecommendedGame = (age: number) => {
    if (age >= 2 && age < 3) {
      return {
        type: 'questionnaire',
        name: 'AI Doctor Bot',
        description: 'Parent-guided behavioral assessment',
        icon: '🤖',
        color: COLORS.age2to3,
        route: 'AIDoctorBot',
      };
    } else if (age >= 3 && age < 5) {
      return {
        type: 'game',
        name: 'Frog Jump Game',
        description: 'Go/No-Go inhibition task',
        icon: '🐸',
        color: COLORS.age4to5,
        route: 'FrogJumpGame',
        gameType: 'frog_jump',
      };
    } else if (age >= 5 && age <= 6) {
      return {
        type: 'game',
        name: 'Rule Switch Game',
        description: 'DCCS cognitive flexibility task',
        icon: '🔷',
        color: COLORS.age5to6,
        route: 'RuleSwitchGame',
        gameType: 'rule_switch',
      };
    }
    return {
      type: 'none',
      name: t.assessment.selectAssessment,
      description: t.errors.ageRange,
      icon: '❓',
      color: COLORS.neutral,
      route: null,
    };
  };

  const handleStartAssessment = (child: Child) => {
    const game = getRecommendedGame(child.age);
    
    if (game.type === 'none' || !game.route) {
      Alert.alert(
        t.errors.ageRange,
        t.errors.ageRange
      );
      return;
    }

    Alert.alert(
      t.assessment.startAssessment,
      `${game.name} - ${child.name} (${t.child.age} ${child.age})?\n\n${game.description}`,
      [
        { text: t.cancel, style: 'cancel' },
        {
          text: t.assessment.startButton,
          onPress: () => {
            // Route based on assessment type
            if (game.type === 'questionnaire') {
              // Navigate to AI Doctor Bot
              navigation.navigate(game.route, {
                child: child,
              });
            } else if (game.type === 'game') {
              // Navigate to game via AgeSelection
              navigation.navigate('AgeSelection', {
                childId: child.id,
                childData: child,
                gameType: game.gameType,
              });
            }
          },
        },
      ]
    );
  };

  const renderChildCard = (child: Child) => {
    const game = getRecommendedGame(child.age);

    return (
      <TouchableOpacity
        key={child.id}
        style={styles.childCard}
        onPress={() => handleStartAssessment(child)}
        activeOpacity={0.8}
      >
        <View style={styles.childCardHeader}>
          <View style={styles.childAvatarContainer}>
            <LinearGradient
              colors={[COLORS.primary, COLORS.secondary]}
              style={styles.childAvatar}
            >
              <Text style={styles.childInitial}>
                {child.name.charAt(0).toUpperCase()}
              </Text>
            </LinearGradient>
          </View>

          <View style={styles.childInfo}>
            <Text style={styles.childName}>{child.name}</Text>
            <View style={styles.childDetails}>
              <View style={styles.detailItem}>
                <Icon name="calendar" size={14} color={COLORS.textSecondary} />
                <Text style={styles.detailText}>{child.age} years</Text>
              </View>
              <View style={styles.detailItem}>
                <Icon
                  name={child.gender === 'male' ? 'gender-male' : 'gender-female'}
                  size={14}
                  color={COLORS.textSecondary}
                />
                <Text style={styles.detailText}>
                  {child.gender === 'male' ? 'Male' : 'Female'}
                </Text>
              </View>
            </View>
          </View>
        </View>

        {/* Recommended Game */}
        <View style={[styles.gameRecommendation, { backgroundColor: game.color + '20' }]}>
          <View style={styles.gameIcon}>
            <Text style={styles.gameEmoji}>{game.icon}</Text>
          </View>
          <View style={styles.gameInfo}>
            <Text style={styles.gameLabel}>Recommended Game:</Text>
            <Text style={styles.gameName}>{game.name}</Text>
            <Text style={styles.gameDescription}>{game.description}</Text>
          </View>
        </View>

        {/* Start Button */}
        <LinearGradient
          colors={[COLORS.primary, COLORS.secondary]}
          style={styles.startButton}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 0 }}
        >
          <Icon name="play-circle" size={20} color="#FFF" />
          <Text style={styles.startButtonText}>{t.assessment.startAssessment}</Text>
        </LinearGradient>
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={COLORS.primary} />

      {/* Header */}
      <LinearGradient
        colors={[COLORS.primary, COLORS.secondary]}
        style={styles.header}
      >
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Icon name="arrow-left" size={24} color="#FFF" />
        </TouchableOpacity>

        <View style={styles.headerContent}>
          <View style={styles.headerIcon}>
            <Icon name="brain" size={32} color="#FFF" />
          </View>
          <Text style={styles.headerTitle}>{t.dashboard.cognitiveFlexibility}</Text>
          <Text style={styles.headerSubtitle}>
            {t.dashboard.cognitiveFlexibility}
          </Text>
        </View>
      </LinearGradient>

      {/* Content */}
      <ScrollView
        style={styles.content}
        contentContainerStyle={styles.contentContainer}
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[COLORS.primary]}
            tintColor={COLORS.primary}
          />
        }
      >
        {/* Add Child Button */}
        <TouchableOpacity
          style={styles.addChildButton}
          onPress={handleAddChild}
          activeOpacity={0.8}
        >
          <LinearGradient
            colors={[COLORS.success, COLORS.success + 'DD']}
            style={styles.addChildGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
          >
            <Icon name="plus-circle" size={28} color="#FFF" />
            <Text style={styles.addChildText}>{t.child.addChild}</Text>
          </LinearGradient>
        </TouchableOpacity>

        {/* Children List */}
        <View style={styles.childrenSection}>
          <Text style={styles.sectionTitle}>
            {t.child.childrenList} ({children.length})
          </Text>

          {loading ? (
            <View style={styles.emptyState}>
              <Text style={styles.emptyText}>{t.loading}</Text>
            </View>
          ) : children.length === 0 ? (
            <View style={styles.emptyState}>
              <Icon name="account-off" size={64} color={COLORS.border} />
              <Text style={styles.emptyTitle}>{t.child.noChildren}</Text>
              <Text style={styles.emptyText}>
                {t.child.selectChild}
              </Text>
            </View>
          ) : (
            <View style={styles.childrenList}>
              {children.map((child) => renderChildCard(child))}
            </View>
          )}
        </View>

        {/* Info Section */}
        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Icon name="information" size={24} color={COLORS.info} />
            <View style={styles.infoContent}>
              <Text style={styles.infoTitle}>About This Assessment</Text>
              <Text style={styles.infoText}>
                • Evaluates cognitive flexibility and rule-switching abilities{'\n'}
                • Age-appropriate games (2-6 years){'\n'}
                • Maximum 5 minutes per session{'\n'}
                • Automatic game recommendation based on child's age
              </Text>
            </View>
          </View>
        </View>
      </ScrollView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    paddingTop: 50,
    paddingBottom: 30,
    paddingHorizontal: SPACING.lg,
  },
  backButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.md,
  },
  headerContent: {
    alignItems: 'center',
  },
  headerIcon: {
    width: 64,
    height: 64,
    borderRadius: 32,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.md,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: '800',
    color: '#FFF',
    marginBottom: SPACING.xs,
    textAlign: 'center',
  },
  headerSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: 'rgba(255,255,255,0.9)',
    textAlign: 'center',
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: SPACING.lg,
  },
  addChildButton: {
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: SPACING.xl,
    ...SHADOWS.medium,
  },
  addChildGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: SPACING.lg,
    paddingHorizontal: SPACING.xl,
  },
  addChildText: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: '#FFF',
    marginLeft: SPACING.md,
  },
  childrenSection: {
    marginBottom: SPACING.xl,
  },
  sectionTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: COLORS.text,
    marginBottom: SPACING.lg,
  },
  childrenList: {
    gap: SPACING.lg,
  },
  childCard: {
    backgroundColor: COLORS.surface,
    borderRadius: 20,
    padding: SPACING.lg,
    ...SHADOWS.medium,
  },
  childCardHeader: {
    flexDirection: 'row',
    marginBottom: SPACING.lg,
  },
  childAvatarContainer: {
    marginRight: SPACING.md,
  },
  childAvatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
  },
  childInitial: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFF',
  },
  childInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  childName: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: COLORS.text,
    marginBottom: SPACING.xs,
  },
  childDetails: {
    flexDirection: 'row',
    gap: SPACING.md,
  },
  detailItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  detailText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
  },
  gameRecommendation: {
    flexDirection: 'row',
    padding: SPACING.md,
    borderRadius: 12,
    marginBottom: SPACING.md,
  },
  gameIcon: {
    width: 48,
    height: 48,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  gameEmoji: {
    fontSize: 32,
  },
  gameInfo: {
    flex: 1,
  },
  gameLabel: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.textSecondary,
    marginBottom: 2,
  },
  gameName: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700',
    color: COLORS.text,
    marginBottom: 2,
  },
  gameDescription: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
  },
  startButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: SPACING.md,
    borderRadius: 12,
    gap: SPACING.sm,
  },
  startButtonText: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700',
    color: '#FFF',
  },
  emptyState: {
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: SPACING.xxxl,
  },
  emptyTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: COLORS.text,
    marginTop: SPACING.lg,
    marginBottom: SPACING.sm,
  },
  emptyText: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    textAlign: 'center',
    paddingHorizontal: SPACING.xl,
  },
  infoSection: {
    marginTop: SPACING.lg,
  },
  infoCard: {
    flexDirection: 'row',
    backgroundColor: COLORS.surface,
    padding: SPACING.lg,
    borderRadius: 16,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.info,
    ...SHADOWS.small,
  },
  infoContent: {
    flex: 1,
    marginLeft: SPACING.md,
  },
  infoTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700',
    color: COLORS.text,
    marginBottom: SPACING.sm,
  },
  infoText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    lineHeight: 20,
  },
});

export default CognitiveDashboardScreen;

