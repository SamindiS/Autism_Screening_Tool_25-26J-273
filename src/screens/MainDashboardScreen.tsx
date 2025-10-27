/**
 * Main Dashboard Screen - Updated Version
 * Shows 4 assessment components as the main feature
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
  Alert,
  Dimensions,
  Animated,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import { storageService } from '../services/storage';
import { Child } from '../types';
import { COMPONENTS, COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import LinearGradient from 'react-native-linear-gradient';
import LanguageSelector from '../components/LanguageSelector';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - SPACING.lg * 3) / 2;

interface MainDashboardScreenProps {
  navigation: any;
}

interface DashboardStats {
  totalChildren: number;
  completedSessions: number;
  pendingSessions: number;
  todaySessions: number;
}

const MainDashboardScreen: React.FC<MainDashboardScreenProps> = ({ navigation }) => {
  const { user, logout } = useAuth();
  const { t } = useLanguage();
  const [children, setChildren] = useState<Child[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [stats, setStats] = useState<DashboardStats>({
    totalChildren: 0,
    completedSessions: 0,
    pendingSessions: 0,
    todaySessions: 0,
  });

  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;

  useEffect(() => {
    loadData();
    
    // Entrance animation
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 600,
        useNativeDriver: true,
      }),
      Animated.timing(slideAnim, {
        toValue: 0,
        duration: 600,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const childrenData = await storageService.getChildren();
      setChildren(childrenData);
      
      // Calculate stats
      setStats({
        totalChildren: childrenData.length,
        completedSessions: childrenData.filter(c => c.testCompleted).length,
        pendingSessions: childrenData.filter(c => !c.testCompleted).length,
        todaySessions: 0, // TODO: Calculate from actual session data
      });
    } catch (error) {
      console.error('Failed to load data:', error);
    } finally {
      setLoading(false);
    }
  };

  const onRefresh = async () => {
    setRefreshing(true);
    await loadData();
    setRefreshing(false);
  };

  const handleLogout = () => {
    Alert.alert(
      t.auth.logout,
      t.auth.logoutConfirm,
      [
        { text: t.cancel, style: 'cancel' },
        { 
          text: t.auth.logout, 
          style: 'destructive', 
          onPress: () => {
            logout();
          }
        },
      ]
    );
  };

  const handleComponentPress = (componentKey: string) => {
    // For now, only Cognitive Flexibility is implemented
    if (componentKey === 'cognitive_flexibility') {
      navigation.navigate('CognitiveDashboard', { componentKey });
    } else {
      Alert.alert(
        t.dashboard.comingSoon,
        `${COMPONENTS[componentKey as keyof typeof COMPONENTS].name} ${t.dashboard.comingSoon}`,
        [{ text: 'OK' }]
      );
    }
  };

  const renderComponentCard = (key: string, index: number) => {
    const component = COMPONENTS[key as keyof typeof COMPONENTS];
    const delay = index * 100;
    
    return (
      <Animated.View
        key={key}
        style={[
          styles.componentCardWrapper,
          {
            opacity: fadeAnim,
            transform: [
              {
                translateY: slideAnim.interpolate({
                  inputRange: [0, 30],
                  outputRange: [0, 30 + delay],
                }),
              },
            ],
          },
        ]}
      >
        <TouchableOpacity
          style={styles.componentCard}
          onPress={() => handleComponentPress(key)}
          activeOpacity={0.8}
        >
          <LinearGradient
            colors={[component.color, component.color + 'CC']}
            style={styles.cardGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 1 }}
          >
            <View style={styles.cardIconContainer}>
              <Icon name={component.icon} size={36} color="#FFF" />
            </View>
            
            <Text style={styles.cardTitle} numberOfLines={2}>
              {component.name}
            </Text>
            
            <Text style={styles.cardDescription} numberOfLines={2}>
              {component.description}
            </Text>
            
            <View style={styles.cardFooter}>
              <Icon name="arrow-right-circle" size={24} color="#FFF" />
            </View>
          </LinearGradient>
        </TouchableOpacity>
      </Animated.View>
    );
  };

  const StatCard = ({ 
    title, 
    value, 
    icon, 
    color 
  }: { 
    title: string; 
    value: number; 
    icon: string; 
    color: string;
  }) => (
    <View style={styles.statCard}>
      <View style={[styles.statIcon, { backgroundColor: color + '20' }]}>
        <Icon name={icon} size={24} color={color} />
      </View>
      <View style={styles.statContent}>
        <Text style={styles.statValue}>{value}</Text>
        <Text style={styles.statTitle}>{title}</Text>
      </View>
    </View>
  );

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={COLORS.primary} />
        <Text style={styles.loadingText}>Loading Dashboard...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={COLORS.primary} />
      
      {/* Header */}
      <LinearGradient
        colors={[COLORS.primary, COLORS.secondary]}
        style={styles.header}
      >
        <View style={styles.headerTop}>
          <View style={styles.headerLeft}>
            <View style={styles.logoContainer}>
              <Icon name="brain" size={28} color="#FFF" />
            </View>
            <View>
              <Text style={styles.headerSubtitle}>{t.dashboard.welcome},</Text>
              <Text style={styles.headerTitle}>{user?.name || 'Doctor'}</Text>
            </View>
          </View>
          
          <View style={styles.headerActions}>
            <LanguageSelector />
            
            <TouchableOpacity 
              style={styles.headerButton}
              onPress={() => Alert.alert(t.notifications.reminderTitle, t.notifications.reminderMessage)}
            >
              <Icon name="bell-outline" size={24} color="#FFF" />
              <View style={styles.notificationBadge}>
                <Text style={styles.badgeText}>3</Text>
              </View>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={styles.headerButton}
              onPress={handleLogout}
            >
              <Icon name="logout" size={24} color="#FFF" />
            </TouchableOpacity>
          </View>
        </View>
      </LinearGradient>

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
        {/* Stats Section */}
        <Animated.View
          style={[
            styles.statsSection,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          <Text style={styles.sectionTitle}>Overview</Text>
          <View style={styles.statsGrid}>
            <StatCard
              title="Total Children"
              value={stats.totalChildren}
              icon="account-group"
              color={COLORS.primary}
            />
            <StatCard
              title="Completed"
              value={stats.completedSessions}
              icon="check-circle"
              color={COLORS.success}
            />
            <StatCard
              title="Pending"
              value={stats.pendingSessions}
              icon="clock-outline"
              color={COLORS.warning}
            />
            <StatCard
              title="Today"
              value={stats.todaySessions}
              icon="calendar-today"
              color={COLORS.info}
            />
          </View>
        </Animated.View>

        {/* Assessment Components Section */}
        <View style={styles.componentsSection}>
          <View style={styles.sectionHeader}>
            <Text style={styles.sectionTitle}>Assessment Components</Text>
            <Text style={styles.sectionSubtitle}>
              Choose a component to begin assessment
            </Text>
          </View>
          
          <View style={styles.componentsGrid}>
            {Object.keys(COMPONENTS).map((key, index) => 
              renderComponentCard(key, index)
            )}
          </View>
        </View>

        {/* Quick Actions */}
        <View style={styles.quickActionsSection}>
          <Text style={styles.sectionTitle}>Quick Actions</Text>
          
          <TouchableOpacity
            style={styles.quickActionButton}
            onPress={() => navigation.navigate('ChildRegistration')}
            activeOpacity={0.8}
          >
            <LinearGradient
              colors={[COLORS.success, COLORS.success + 'DD']}
              style={styles.quickActionGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Icon name="plus-circle" size={24} color="#FFF" />
              <Text style={styles.quickActionText}>Add New Child</Text>
              <Icon name="arrow-right" size={20} color="#FFF" />
            </LinearGradient>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.quickActionButton}
            onPress={() => Alert.alert('Coming Soon', 'Reports feature coming soon')}
            activeOpacity={0.8}
          >
            <LinearGradient
              colors={[COLORS.info, COLORS.info + 'DD']}
              style={styles.quickActionGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Icon name="chart-bar" size={24} color="#FFF" />
              <Text style={styles.quickActionText}>View Reports</Text>
              <Icon name="arrow-right" size={20} color="#FFF" />
            </LinearGradient>
          </TouchableOpacity>
        </View>

        {/* Info Section */}
        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Icon name="information" size={24} color={COLORS.info} />
            <View style={styles.infoContent}>
              <Text style={styles.infoTitle}>Clinical Screening System</Text>
              <Text style={styles.infoText}>
                SenseAI provides comprehensive early autism screening through multiple assessment components. Each component evaluates different developmental aspects for children aged 2-6 years.
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
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: COLORS.background,
  },
  loadingText: {
    marginTop: SPACING.md,
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
  },
  header: {
    paddingTop: 50,
    paddingBottom: 30,
    paddingHorizontal: SPACING.lg,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  logoContainer: {
    width: 48,
    height: 48,
    borderRadius: 24,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  headerSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: 'rgba(255,255,255,0.8)',
    marginBottom: 2,
  },
  headerTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '800',
    color: '#FFF',
  },
  headerActions: {
    flexDirection: 'row',
    gap: SPACING.sm,
  },
  headerButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  notificationBadge: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: COLORS.error,
    justifyContent: 'center',
    alignItems: 'center',
  },
  badgeText: {
    fontSize: 10,
    fontWeight: '700',
    color: '#FFF',
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: SPACING.lg,
  },
  statsSection: {
    marginBottom: SPACING.xl,
  },
  sectionTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '800',
    color: COLORS.text,
    marginBottom: SPACING.md,
  },
  sectionSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginTop: -SPACING.sm,
    marginBottom: SPACING.lg,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: SPACING.md,
  },
  statCard: {
    flex: 1,
    minWidth: '47%',
    backgroundColor: COLORS.surface,
    borderRadius: 16,
    padding: SPACING.md,
    flexDirection: 'row',
    alignItems: 'center',
    ...SHADOWS.small,
  },
  statIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  statContent: {
    flex: 1,
  },
  statValue: {
    fontSize: FONTS.sizes.xxl,
    fontWeight: '800',
    color: COLORS.text,
  },
  statTitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
  },
  componentsSection: {
    marginBottom: SPACING.xl,
  },
  sectionHeader: {
    marginBottom: SPACING.lg,
  },
  componentsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: SPACING.md,
  },
  componentCardWrapper: {
    width: CARD_WIDTH,
    marginBottom: SPACING.md,
  },
  componentCard: {
    width: '100%',
    height: 200,
    borderRadius: 20,
    overflow: 'hidden',
    ...SHADOWS.large,
  },
  cardGradient: {
    flex: 1,
    padding: SPACING.lg,
    justifyContent: 'space-between',
  },
  cardIconContainer: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  cardTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: '#FFF',
    marginTop: SPACING.sm,
  },
  cardDescription: {
    fontSize: FONTS.sizes.sm,
    color: 'rgba(255,255,255,0.9)',
    lineHeight: 18,
  },
  cardFooter: {
    alignSelf: 'flex-end',
  },
  quickActionsSection: {
    marginBottom: SPACING.xl,
  },
  quickActionButton: {
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: SPACING.md,
    ...SHADOWS.medium,
  },
  quickActionGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: SPACING.lg,
    paddingHorizontal: SPACING.lg,
  },
  quickActionText: {
    flex: 1,
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: '#FFF',
    marginLeft: SPACING.md,
  },
  infoSection: {
    marginBottom: SPACING.xl,
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
    marginBottom: SPACING.xs,
  },
  infoText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    lineHeight: 20,
  },
});

export default MainDashboardScreen;
