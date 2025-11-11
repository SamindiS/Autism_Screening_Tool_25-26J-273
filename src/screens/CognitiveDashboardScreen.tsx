/**
 * Cognitive Flexibility Dashboard - Professional Clinical Edition
 * Advanced real-world clinical assessment management system
 * Features: Filtering, Search, Sorting, Analytics, Bulk Actions
 */

import React, { useState, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
  StatusBar,
  RefreshControl,
  Animated,
  Dimensions,
  LayoutAnimation,
  Platform,
  UIManager,
  TextInput,
  Modal,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import LinearGradient from 'react-native-linear-gradient';
import { useLanguage } from '../context/LanguageContext';
import { COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import { storageService } from '../services/storage.simple';
import { Child } from '../types';
import { calculateAge, getAssessmentType, AgeDetails } from '../utils/ageCalculator';

// Enable LayoutAnimation for Android
if (Platform.OS === 'android' && UIManager.setLayoutAnimationEnabledExperimental) {
  UIManager.setLayoutAnimationEnabledExperimental(true);
}

interface CognitiveDashboardScreenProps {
  navigation: any;
  route: any;
}

type FilterType = 'all' | 'completed' | 'pending' | '2-3' | '3-5' | '5-6' | 'male' | 'female';
type SortType = 'newest' | 'oldest' | 'name-asc' | 'name-desc' | 'age-asc' | 'age-desc';
type ViewMode = 'grid' | 'list';

const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = Dimensions.get('window');

const CognitiveDashboardScreen: React.FC<CognitiveDashboardScreenProps> = ({
  navigation,
  route,
}) => {
  const { t } = useLanguage();
  
  // Helper to get precise age from DOB (avoiding TypeScript inference issues)
  const getPreciseAge = (dateOfBirth: string): number => {
    const result = calculateAge(dateOfBirth) as unknown as AgeDetails;
    return result.ageInYears;
  };
  
  const [children, setChildren] = useState<Child[]>([]);
  const [filteredChildren, setFilteredChildren] = useState<Child[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [activeChildIndex, setActiveChildIndex] = useState<number | null>(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeFilters, setActiveFilters] = useState<FilterType[]>(['all']);
  const [sortBy, setSortBy] = useState<SortType>('newest');
  const [viewMode, setViewMode] = useState<ViewMode>('list');
  const [showFilterModal, setShowFilterModal] = useState(false);
  const [showSortModal, setShowSortModal] = useState(false);
  const [selectedChildren, setSelectedChildren] = useState<string[]>([]);
  const [selectionMode, setSelectionMode] = useState(false);
  const [stats, setStats] = useState({
    total: 0,
    completed: 0,
    pending: 0,
    thisWeek: 0,
    age2to3: 0,
    age3to5: 0,
    age5to6: 0,
    male: 0,
    female: 0,
  });

  // Animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(50)).current;
  const scaleValue = useRef(new Animated.Value(0.9)).current;

  useEffect(() => {
    loadChildren();
    startAnimations();
  }, []);

  useEffect(() => {
    applyFiltersAndSort();
  }, [children, searchQuery, activeFilters, sortBy]);

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
      Animated.timing(scaleValue, {
        toValue: 1,
        duration: 700,
        useNativeDriver: true,
      }),
    ]).start();
  };

  // Calculate current age from date of birth
  const calculateAge = (dateOfBirth: string): number => {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    console.log('📅 calculateAge - DOB:', dateOfBirth, '→ Age:', age, 'Today:', today.toISOString().split('T')[0]);
    
    return age;
  };

  const applyFiltersAndSort = () => {
    let filtered = [...children];

    // Apply search filter
    if (searchQuery.trim()) {
      filtered = filtered.filter(child =>
        child.name.toLowerCase().includes(searchQuery.toLowerCase())
      );
    }

    // Apply status and demographic filters
    if (!activeFilters.includes('all')) {
      filtered = filtered.filter(child => {
        // Status filters
        if (activeFilters.includes('completed') && !child.testCompleted) return false;
        if (activeFilters.includes('pending') && child.testCompleted) return false;
        
        // Age group filters - use precise age calculation from DOB
        if (activeFilters.includes('2-3')) {
          if (!child.dateOfBirth) {
            // Fallback to old age field
            if (child.age < 2 || child.age >= 3) return false;
          } else {
            const preciseAge = getPreciseAge(child.dateOfBirth);
            if (preciseAge < 2 || preciseAge >= 3.5) return false;
          }
        }
        if (activeFilters.includes('3-5')) {
          if (!child.dateOfBirth) {
            // Fallback to old age field
            if (child.age < 3 || child.age >= 5) return false;
          } else {
            const preciseAge = getPreciseAge(child.dateOfBirth);
            if (preciseAge < 3.5 || preciseAge >= 5.5) return false;
          }
        }
        if (activeFilters.includes('5-6')) {
          if (!child.dateOfBirth) {
            // Fallback to old age field
            if (child.age < 5 || child.age > 6) return false;
          } else {
            const preciseAge = getPreciseAge(child.dateOfBirth);
            if (preciseAge < 5.5 || preciseAge > 6) return false;
          }
        }
        
        // Gender filters
        if (activeFilters.includes('male') && child.gender !== 'male') return false;
        if (activeFilters.includes('female') && child.gender !== 'female') return false;
        
        return true;
      });
    }

    // Apply sorting
    filtered.sort((a, b) => {
      switch (sortBy) {
        case 'newest':
          return new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
        case 'oldest':
          return new Date(a.createdAt).getTime() - new Date(b.createdAt).getTime();
        case 'name-asc':
          return a.name.localeCompare(b.name);
        case 'name-desc':
          return b.name.localeCompare(a.name);
        case 'age-asc':
          return a.age - b.age;
        case 'age-desc':
          return b.age - a.age;
        default:
          return 0;
      }
    });

    LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
    setFilteredChildren(filtered);
  };

  const loadChildren = async () => {
    try {
      setLoading(true);
      const childrenData = await storageService.getChildren();
      
      // Recalculate ages from date of birth for all children
      const updatedChildren = childrenData.map(child => ({
        ...child,
        age: child.dateOfBirth ? calculateAge(child.dateOfBirth) : child.age
      }));
      
      // Calculate comprehensive statistics
      const completedCount = updatedChildren.filter(c => c.testCompleted).length;
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      const thisWeekCount = updatedChildren.filter(c => new Date(c.createdAt) > weekAgo).length;
      
      const age2to3Count = updatedChildren.filter(c => c.age >= 2 && c.age < 3).length;
      const age3to5Count = updatedChildren.filter(c => c.age >= 3 && c.age < 5).length;
      const age5to6Count = updatedChildren.filter(c => c.age >= 5 && c.age <= 6).length;
      const maleCount = updatedChildren.filter(c => c.gender === 'male').length;
      const femaleCount = updatedChildren.filter(c => c.gender === 'female').length;
      
      setStats({
        total: updatedChildren.length,
        completed: completedCount,
        pending: updatedChildren.length - completedCount,
        thisWeek: thisWeekCount,
        age2to3: age2to3Count,
        age3to5: age3to5Count,
        age5to6: age5to6Count,
        male: maleCount,
        female: femaleCount,
      });
      
      LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
      setChildren(updatedChildren);
    } catch (error) {
      console.error('Error loading children:', error);
      Alert.alert(t.errors.loadFailed, t.errors.loadFailed);
    } finally {
      setLoading(false);
    }
  };

  const handleRefresh = async () => {
    setRefreshing(true);
    await loadChildren();
    setRefreshing(false);
  };

  const handleAddChild = () => {
    navigation.navigate('ChildRegistration');
  };

  const toggleFilter = (filter: FilterType) => {
    setActiveFilters(prev => {
      if (filter === 'all') {
        return ['all'];
      }
      
      const withoutAll = prev.filter(f => f !== 'all');
      if (withoutAll.includes(filter)) {
        const newFilters = withoutAll.filter(f => f !== filter);
        return newFilters.length === 0 ? ['all'] : newFilters;
      } else {
        return [...withoutAll, filter];
      }
    });
  };

  const clearAllFilters = () => {
    setActiveFilters(['all']);
    setSearchQuery('');
  };

  const handleBulkDelete = () => {
    Alert.alert(
      'Delete Selected',
      `Delete ${selectedChildren.length} selected patient(s)?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              for (const childId of selectedChildren) {
                await storageService.deleteChild(childId);
              }
              setSelectedChildren([]);
              setSelectionMode(false);
              loadChildren();
            } catch (error) {
              Alert.alert('Error', 'Failed to delete patients');
            }
          },
        },
      ]
    );
  };

  const toggleChildSelection = (childId: string) => {
    setSelectedChildren(prev =>
      prev.includes(childId)
        ? prev.filter(id => id !== childId)
        : [...prev, childId]
    );
  };

  const selectAll = () => {
    setSelectedChildren(filteredChildren.map(c => c.id));
  };

  const deselectAll = () => {
    setSelectedChildren([]);
  };

  const handleDeleteChild = (child: Child) => {
    Alert.alert(
      'Delete Child',
      `Are you sure you want to delete ${child.name}?`,
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Delete',
          style: 'destructive',
          onPress: async () => {
            try {
              await storageService.deleteChild(child.id);
              LayoutAnimation.configureNext(LayoutAnimation.Presets.easeInEaseOut);
              loadChildren();
            } catch (error) {
              console.error('Error deleting child:', error);
              Alert.alert('Error', 'Failed to delete child');
            }
          },
        },
      ]
    );
  };

  const getRecommendedGame = (age: number) => {
    console.log('🎮 getRecommendedGame - Age:', age, 'Type:', typeof age);
    
    if (age >= 2 && age < 3) {
      console.log('✅ Routing to AI Doctor Bot (ages 2-3)');
      return {
        type: 'questionnaire',
        name: 'AI Doctor Bot',
        description: 'Parent-guided behavioral assessment (Ages 2-3)',
        icon: '🤖',
        color: COLORS.age2to3,
        gradient: [COLORS.age2to3, '#8E44AD'],
        route: 'AIDoctorBot',
        duration: '5-10 min',
        tasks: '10 questions',
      };
    } else if (age >= 3 && age < 5) {
      console.log('✅ Routing to Frog Jump Game (ages 3-5)');
      return {
        type: 'game',
        name: 'Frog Jump Game',
        description: 'Go/No-Go inhibition task (Ages 3-5)',
        icon: '🐸',
        color: COLORS.age4to5,
        gradient: [COLORS.age4to5, '#27AE60'],
        route: 'FrogJumpGame',
        gameType: 'frog_jump',
        duration: '5 min',
        tasks: '20 trials',
      };
    } else if (age >= 5 && age <= 6) {
      console.log('✅ Routing to Magic Garden (ages 5-6)');
      return {
        type: 'game',
        name: 'Magic Garden Adventure',
        description: 'DCCS cognitive flexibility task (Ages 5-6)',
        icon: '🌷',
        color: COLORS.age5to6,
        gradient: [COLORS.age5to6, '#2980B9'],
        route: 'ColorShapeGame',
        gameType: 'color_shape',
        duration: '5-7 min',
        tasks: '16 trials',
      };
    }
    return {
      type: 'none',
      name: t.assessment.selectAssessment,
      description: 'Age must be between 2-6 years',
      icon: '❓',
      color: COLORS.neutral,
      gradient: [COLORS.neutral, COLORS.textSecondary],
      route: null,
      duration: 'N/A',
      tasks: 'N/A',
    };
  };

  const handleStartAssessment = (child: Child, index: number) => {
    const game = getRecommendedGame(child.age);
    
    if (game.type === 'none') {
      Alert.alert('Cannot Start Assessment', 'Child age must be between 2-6 years');
      return;
    }

    setActiveChildIndex(index);
    setTimeout(() => setActiveChildIndex(null), 200);

    Alert.alert(
      t.assessment.startAssessment,
      `${game.name} - ${child.name} (${t.child.age} ${child.age})?\n\n${game.description}`,
      [
        { text: t.cancel, style: 'cancel' },
        {
          text: t.assessment.startButton,
          onPress: () => {
            if (game.type === 'questionnaire') {
              navigation.navigate(game.route, { child: child });
            } else if (game.type === 'game') {
              // Safety check for missing dateOfBirth
              if (!child.dateOfBirth) {
                Alert.alert(
                  'Missing Date of Birth',
                  `This child doesn't have a date of birth recorded. Please update their profile to use age-based routing.`,
                  [
                    { text: 'Cancel', style: 'cancel' },
                    {
                      text: 'Use Default Game',
                      onPress: () => {
                        // Fallback to frog_jump for old records
                        console.log('⚠️ Missing DOB - Using default Frog Jump game');
                        navigation.navigate('AgeSelection', {
                          childId: child.id,
                          childData: child,
                          gameType: 'frog_jump',
                          directToGame: true,
                        });
                      }
                    }
                  ]
                );
                return;
              }
              
              // Calculate precise age and route to appropriate assessment
              const preciseAge = getPreciseAge(child.dateOfBirth);
              const assessmentType = getAssessmentType(child.dateOfBirth);
              
              console.log(`🎯 Starting assessment for ${child.name}, age ${preciseAge} years`);
              console.log(`📍 Assessment type: ${assessmentType.toUpperCase()}`);
              
              // Navigate directly to the appropriate game based on age
              if (assessmentType === 'ai_bot') {
                console.log('✅ Navigating to AI Doctor Bot');
                navigation.navigate('AIDoctorBot', { child: child });
              } else if (assessmentType === 'frog_jump') {
                console.log('✅ Navigating to Frog Jump Game (games/index.html)');
                navigation.navigate('AgeSelection', {
                  childId: child.id,
                  childData: child,
                  gameType: 'frog_jump',
                  directToGame: true, // Flag to skip intermediate screen
                });
              } else if (assessmentType === 'color_shape') {
                console.log('✅ Navigating to Color-Shape Game (games/color-shape.html)');
                navigation.navigate('AgeSelection', {
                  childId: child.id,
                  childData: child,
                  gameType: 'color_shape',
                  directToGame: true, // Flag to skip intermediate screen
                });
              } else {
                Alert.alert(
                  'Age Out of Range',
                  `Age ${preciseAge} years is out of valid range (2-6 years)`,
                  [{ text: 'OK' }]
                );
              }
            }
          },
        },
      ]
    );
  };

  const getAgeGroupColor = (age: number) => {
    if (age >= 2 && age < 3) return COLORS.age2to3;
    if (age >= 3 && age < 5) return COLORS.age4to5;
    if (age >= 5 && age <= 6) return COLORS.age5to6;
    return COLORS.neutral;
  };

  const getAgeGroupLabel = (age: number) => {
    if (age >= 2 && age < 3) return '2-3 Years';
    if (age >= 3 && age < 5) return '3-5 Years';
    if (age >= 5 && age <= 6) return '5-6 Years';
    return 'Age Group';
  };

  const formatDate = (date: Date) => {
    const d = new Date(date);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  };

  const renderStatCard = (title: string, value: number, icon: string, color: string, subtitle?: string) => {
    return (
      <Animated.View 
        style={[
          styles.statCard,
          {
            opacity: fadeAnim,
            transform: [{ scale: scaleValue }]
          }
        ]}
      >
        <LinearGradient
          colors={[color, `${color}90`]}
          style={styles.statGradient}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
        >
          <View style={styles.statIconContainer}>
            <Icon name={icon} size={24} color="#FFF" />
          </View>
          <View style={styles.statContent}>
            <Text style={styles.statValue}>{value}</Text>
            <Text style={styles.statTitle}>{title}</Text>
            {subtitle && <Text style={styles.statSubtitle}>{subtitle}</Text>}
          </View>
        </LinearGradient>
      </Animated.View>
    );
  };

  const renderChildCard = (child: Child, index: number) => {
    const game = getRecommendedGame(child.age);
    const isActive = activeChildIndex === index;
    const isSelected = selectedChildren.includes(child.id);

    return (
      <Animated.View
        key={child.id}
        style={[
          styles.childCard,
          isSelected && styles.childCardSelected,
          {
            opacity: fadeAnim,
            transform: [
              { scale: isActive ? 0.97 : 1 },
              { translateY: Animated.multiply(slideAnim, new Animated.Value(index * 0.1)) }
            ]
          }
        ]}
      >
        <TouchableOpacity
          activeOpacity={0.8}
          onPress={() => {
            if (selectionMode) {
              toggleChildSelection(child.id);
            } else {
              handleStartAssessment(child, index);
            }
          }}
          onLongPress={() => {
            if (!selectionMode) {
              setSelectionMode(true);
              toggleChildSelection(child.id);
            }
          }}
        >
          {selectionMode && (
            <View style={styles.selectionCheckbox}>
              <View style={[styles.checkbox, isSelected && styles.checkboxSelected]}>
                {isSelected && <Icon name="check" size={18} color="#FFF" />}
              </View>
            </View>
          )}
          {/* Card Header with Patient Info */}
          <View style={styles.cardHeader}>
            <LinearGradient
              colors={game.gradient}
              style={styles.avatarGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <View style={styles.avatarContainer}>
                <Text style={styles.avatarText}>
                  {child.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)}
                </Text>
              </View>
            </LinearGradient>

            <View style={styles.patientInfo}>
              <View style={styles.nameRow}>
                <Text style={styles.patientName}>{child.name}</Text>
                <View style={[styles.statusBadge, { backgroundColor: child.testCompleted ? '#4CAF50' : '#FF9800' }]}>
                  <Text style={styles.statusText}>
                    {child.testCompleted ? 'Completed' : 'Pending'}
                  </Text>
                </View>
              </View>

              <View style={styles.infoRow}>
                <View style={styles.infoItem}>
                  <Icon name="calendar-clock" size={16} color={COLORS.textSecondary} />
                  <Text style={styles.infoText}>{child.age} yrs old</Text>
                </View>
                <View style={styles.infoDivider} />
                <View style={styles.infoItem}>
                  <Icon name={child.gender === 'male' ? 'gender-male' : 'gender-female'} size={16} color={COLORS.textSecondary} />
                  <Text style={styles.infoText}>{child.gender === 'male' ? 'Male' : 'Female'}</Text>
                </View>
                <View style={styles.infoDivider} />
                <View style={styles.infoItem}>
                  <Icon name="account-plus" size={16} color={COLORS.textSecondary} />
                  <Text style={styles.infoText}>{formatDate(child.createdAt)}</Text>
                </View>
              </View>
            </View>
          </View>

          {/* Age Group Badge */}
          <View style={styles.ageGroupContainer}>
            <LinearGradient
              colors={[`${getAgeGroupColor(child.age)}20`, `${getAgeGroupColor(child.age)}10`]}
              style={styles.ageGroupBadge}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Icon name="account-child" size={16} color={getAgeGroupColor(child.age)} />
              <Text style={[styles.ageGroupText, { color: getAgeGroupColor(child.age) }]}>
                {getAgeGroupLabel(child.age)} Age Group
              </Text>
            </LinearGradient>
          </View>

          {/* Recommended Assessment */}
          <View style={styles.assessmentSection}>
            <Text style={styles.assessmentLabel}>RECOMMENDED ASSESSMENT</Text>
            
            <LinearGradient
              colors={[...game.gradient, `${game.gradient[1]}70`]}
              style={styles.assessmentCard}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 1 }}
            >
              <View style={styles.assessmentHeader}>
                <View style={styles.assessmentIconBox}>
                  <Text style={styles.assessmentEmoji}>{game.icon}</Text>
                </View>
                <View style={styles.assessmentTitleBox}>
                  <Text style={styles.assessmentName}>{game.name}</Text>
                  <Text style={styles.assessmentType}>{game.description}</Text>
                </View>
                <View style={styles.playButton}>
                  <Icon name="play-circle-outline" size={32} color="#FFF" />
                </View>
              </View>

              <View style={styles.assessmentDetails}>
                <View style={styles.detailPill}>
                  <Icon name="clock-outline" size={14} color="rgba(255,255,255,0.9)" />
                  <Text style={styles.detailPillText}>{game.duration}</Text>
                </View>
                <View style={styles.detailPill}>
                  <Icon name="chart-box-outline" size={14} color="rgba(255,255,255,0.9)" />
                  <Text style={styles.detailPillText}>{game.tasks}</Text>
                </View>
                <View style={styles.detailPill}>
                  <Icon name="target" size={14} color="rgba(255,255,255,0.9)" />
                  <Text style={styles.detailPillText}>Evidence-based</Text>
                </View>
              </View>
            </LinearGradient>
          </View>

          {/* Action Footer */}
          <View style={styles.cardFooter}>
            <TouchableOpacity style={styles.footerButton}>
              <Icon name="chart-line" size={18} color={COLORS.primary} />
              <Text style={styles.footerButtonText}>View History</Text>
            </TouchableOpacity>
            <View style={styles.footerDivider} />
            <TouchableOpacity style={styles.footerButton}>
              <Icon name="file-document-outline" size={18} color={COLORS.primary} />
              <Text style={styles.footerButtonText}>Reports</Text>
            </TouchableOpacity>
            <View style={styles.footerDivider} />
            <TouchableOpacity style={styles.footerButton}>
              <Icon name="share-variant" size={18} color={COLORS.primary} />
              <Text style={styles.footerButtonText}>Share</Text>
            </TouchableOpacity>
          </View>
        </TouchableOpacity>
      </Animated.View>
    );
  };

  const renderEmptyState = () => (
    <Animated.View 
      style={[
        styles.emptyContainer,
        {
          opacity: fadeAnim,
          transform: [{ translateY: slideAnim }, { scale: scaleValue }]
        }
      ]}
    >
      <LinearGradient
        colors={['#E3F2FD', '#BBDEFB']}
        style={styles.emptyCard}
      >
        <View style={styles.emptyIconContainer}>
          <LinearGradient
            colors={[COLORS.primary, COLORS.secondary]}
            style={styles.emptyIconGradient}
          >
            <Icon name="account-multiple-plus" size={48} color="#FFF" />
          </LinearGradient>
        </View>
        
        <Text style={styles.emptyTitle}>No Children Registered Yet</Text>
        <Text style={styles.emptySubtitle}>
          Start by adding your first child to begin cognitive flexibility assessments
        </Text>
        
        <TouchableOpacity
          style={styles.emptyButton}
          onPress={handleAddChild}
        >
          <LinearGradient
            colors={[COLORS.primary, COLORS.secondary]}
            style={styles.emptyButtonGradient}
            start={{ x: 0, y: 0 }}
            end={{ x: 1, y: 0 }}
          >
            <Icon name="plus-circle" size={20} color="#FFF" />
            <Text style={styles.emptyButtonText}>Add First Child</Text>
          </LinearGradient>
        </TouchableOpacity>

        <View style={styles.emptyFeatures}>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={16} color={COLORS.success} />
            <Text style={styles.featureText}>Age-appropriate assessments</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={16} color={COLORS.success} />
            <Text style={styles.featureText}>Real-time progress tracking</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={16} color={COLORS.success} />
            <Text style={styles.featureText}>Clinical-grade reports</Text>
          </View>
        </View>
      </LinearGradient>
    </Animated.View>
  );

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor={COLORS.primary} />

      {/* Professional Header */}
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
              <Icon name="brain" size={28} color="#FFF" />
            </View>
            <View>
              <Text style={styles.headerTitle}>Cognitive Assessment</Text>
              <Text style={styles.headerSubtitle}>Patient Management Portal</Text>
            </View>
          </View>

          <TouchableOpacity style={styles.headerAction}>
            <Icon name="bell-outline" size={24} color="#FFF" />
            <View style={styles.notificationBadge}>
              <Text style={styles.notificationText}>{stats.pending}</Text>
            </View>
          </TouchableOpacity>
        </View>
      </LinearGradient>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
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
        {/* Statistics Dashboard */}
        <View style={styles.statsContainer}>
          <View style={styles.statsRow}>
            {renderStatCard('Total Patients', stats.total, 'account-group', '#5C6BC0', 'Registered')}
            {renderStatCard('Completed', stats.completed, 'check-circle', '#66BB6A', 'Assessments')}
          </View>
          <View style={styles.statsRow}>
            {renderStatCard('Pending', stats.pending, 'clock-alert', '#FFA726', 'To Complete')}
            {renderStatCard('This Week', stats.thisWeek, 'calendar-week', '#42A5F5', 'New Patients')}
          </View>
        </View>

        {/* Patients List Header */}
        <View style={styles.sectionHeader}>
          <View>
            <Text style={styles.sectionTitle}>Patient Records</Text>
            <Text style={styles.sectionSubtitle}>Tap a patient to start assessment</Text>
          </View>
          <TouchableOpacity style={styles.addButton} onPress={handleAddChild}>
            <LinearGradient
              colors={[COLORS.primary, COLORS.secondary]}
              style={styles.addButtonGradient}
              start={{ x: 0, y: 0 }}
              end={{ x: 1, y: 0 }}
            >
              <Icon name="plus" size={20} color="#FFF" />
              <Text style={styles.addButtonText}>Add Patient</Text>
            </LinearGradient>
          </TouchableOpacity>
        </View>

        {/* Search and Filter Bar */}
        <View style={styles.searchFilterContainer}>
          <View style={styles.searchBar}>
            <Icon name="magnify" size={20} color={COLORS.textSecondary} />
            <TextInput
              style={styles.searchInput}
              placeholder="Search patients by name..."
              placeholderTextColor={COLORS.textSecondary}
              value={searchQuery}
              onChangeText={setSearchQuery}
            />
            {searchQuery.length > 0 && (
              <TouchableOpacity onPress={() => setSearchQuery('')}>
                <Icon name="close-circle" size={20} color={COLORS.textSecondary} />
              </TouchableOpacity>
            )}
          </View>

          <View style={styles.actionBar}>
            <TouchableOpacity
              style={styles.filterButton}
              onPress={() => setShowFilterModal(true)}
            >
              <Icon name="filter-variant" size={18} color={COLORS.primary} />
              <Text style={styles.filterButtonText}>Filter</Text>
              {activeFilters.length > 1 || !activeFilters.includes('all') ? (
                <View style={styles.filterBadge}>
                  <Text style={styles.filterBadgeText}>
                    {activeFilters.filter(f => f !== 'all').length}
                  </Text>
                </View>
              ) : null}
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.sortButton}
              onPress={() => setShowSortModal(true)}
            >
              <Icon name="sort" size={18} color={COLORS.primary} />
              <Text style={styles.sortButtonText}>Sort</Text>
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.viewModeButton}
              onPress={() => setViewMode(viewMode === 'list' ? 'grid' : 'list')}
            >
              <Icon
                name={viewMode === 'list' ? 'view-grid' : 'view-list'}
                size={18}
                color={COLORS.primary}
              />
            </TouchableOpacity>

            {selectionMode && (
              <TouchableOpacity
                style={styles.bulkActionButton}
                onPress={handleBulkDelete}
              >
                <Icon name="delete" size={18} color="#FF5252" />
                <Text style={[styles.bulkActionText, { color: '#FF5252' }]}>
                  Delete ({selectedChildren.length})
                </Text>
              </TouchableOpacity>
            )}
          </View>

          {/* Active Filters */}
          {(activeFilters.length > 1 || !activeFilters.includes('all') || searchQuery) && (
            <View style={styles.activeFiltersContainer}>
              <ScrollView
                horizontal
                showsHorizontalScrollIndicator={false}
                style={styles.activeFiltersScroll}
              >
                {searchQuery && (
                  <View style={styles.activeFilterChip}>
                    <Text style={styles.activeFilterText}>Search: "{searchQuery}"</Text>
                    <TouchableOpacity onPress={() => setSearchQuery('')}>
                      <Icon name="close" size={14} color={COLORS.primary} />
                    </TouchableOpacity>
                  </View>
                )}
                {activeFilters.filter(f => f !== 'all').map(filter => (
                  <View key={filter} style={styles.activeFilterChip}>
                    <Text style={styles.activeFilterText}>
                      {filter === '2-3' ? 'Ages 2-3' :
                       filter === '3-5' ? 'Ages 3-5' :
                       filter === '5-6' ? 'Ages 5-6' :
                       filter.charAt(0).toUpperCase() + filter.slice(1)}
                    </Text>
                    <TouchableOpacity onPress={() => toggleFilter(filter)}>
                      <Icon name="close" size={14} color={COLORS.primary} />
                    </TouchableOpacity>
                  </View>
                ))}
                <TouchableOpacity
                  style={styles.clearFiltersButton}
                  onPress={clearAllFilters}
                >
                  <Text style={styles.clearFiltersText}>Clear All</Text>
                </TouchableOpacity>
              </ScrollView>
            </View>
          )}
        </View>

        {/* Selection Mode Banner */}
        {selectionMode && (
          <View style={styles.selectionBanner}>
            <Text style={styles.selectionText}>
              {selectedChildren.length} selected
            </Text>
            <View style={styles.selectionActions}>
              <TouchableOpacity onPress={selectAll} style={styles.selectionAction}>
                <Text style={styles.selectionActionText}>Select All</Text>
              </TouchableOpacity>
              <TouchableOpacity onPress={deselectAll} style={styles.selectionAction}>
                <Text style={styles.selectionActionText}>Deselect</Text>
              </TouchableOpacity>
              <TouchableOpacity
                onPress={() => {
                  setSelectionMode(false);
                  setSelectedChildren([]);
                }}
                style={styles.selectionAction}
              >
                <Text style={[styles.selectionActionText, { color: COLORS.error }]}>Cancel</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}

        {/* Results Summary */}
        <View style={styles.resultsSummary}>
          <Text style={styles.resultsText}>
            Showing {filteredChildren.length} of {children.length} patient{children.length !== 1 ? 's' : ''}
          </Text>
        </View>

        {/* Children List */}
        {loading ? (
          <View style={styles.loadingContainer}>
            <Text style={styles.loadingText}>Loading patient records...</Text>
          </View>
        ) : children.length === 0 ? (
          renderEmptyState()
        ) : filteredChildren.length === 0 ? (
          <View style={styles.noResultsContainer}>
            <Icon name="filter-remove" size={64} color={COLORS.textSecondary} />
            <Text style={styles.noResultsTitle}>No Matching Patients</Text>
            <Text style={styles.noResultsSubtitle}>
              Try adjusting your filters or search query
            </Text>
            <TouchableOpacity style={styles.clearFiltersBtn} onPress={clearAllFilters}>
              <Text style={styles.clearFiltersBtnText}>Clear All Filters</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <View style={styles.childrenList}>
            {filteredChildren.map((child, index) => renderChildCard(child, index))}
          </View>
        )}

        {/* Info Section */}
        {children.length > 0 && (
          <View style={styles.infoSection}>
            <LinearGradient
              colors={['#E8EAF6', '#C5CAE9']}
              style={styles.infoCard}
            >
              <View style={styles.infoHeader}>
                <Icon name="information" size={24} color={COLORS.primary} />
                <Text style={styles.infoTitle}>Assessment Guidelines</Text>
              </View>
              <View style={styles.infoContent}>
                <View style={styles.infoPoint}>
                  <Icon name="checkbox-marked-circle" size={18} color={COLORS.success} />
                  <Text style={styles.infoPointText}>
                    Ages 2-3: Parent-guided questionnaire (AI Doctor Bot)
                  </Text>
                </View>
                <View style={styles.infoPoint}>
                  <Icon name="checkbox-marked-circle" size={18} color={COLORS.success} />
                  <Text style={styles.infoPointText}>
                    Ages 3-5: Go/No-Go inhibition task (Frog Jump Game)
                  </Text>
                </View>
                <View style={styles.infoPoint}>
                  <Icon name="checkbox-marked-circle" size={18} color={COLORS.success} />
                  <Text style={styles.infoPointText}>
                    Ages 5-6: DCCS cognitive flexibility (Magic Garden)
                  </Text>
                </View>
              </View>
            </LinearGradient>
          </View>
        )}

        <View style={styles.bottomSpacer} />
      </ScrollView>

      {/* Filter Modal */}
      <Modal
        visible={showFilterModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowFilterModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Filter Patients</Text>
              <TouchableOpacity onPress={() => setShowFilterModal(false)}>
                <Icon name="close" size={24} color={COLORS.text} />
              </TouchableOpacity>
            </View>

            <ScrollView style={styles.modalBody}>
              {/* Status Filters */}
              <Text style={styles.filterSectionTitle}>Status</Text>
              <View style={styles.filterOptions}>
                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('all') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('all')}
                >
                  <Icon
                    name={activeFilters.includes('all') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('all') ? COLORS.primary : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>All Patients</Text>
                  <Text style={styles.filterOptionCount}>({stats.total})</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('completed') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('completed')}
                >
                  <Icon
                    name={activeFilters.includes('completed') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('completed') ? COLORS.success : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Completed</Text>
                  <Text style={styles.filterOptionCount}>({stats.completed})</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('pending') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('pending')}
                >
                  <Icon
                    name={activeFilters.includes('pending') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('pending') ? COLORS.warning : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Pending</Text>
                  <Text style={styles.filterOptionCount}>({stats.pending})</Text>
                </TouchableOpacity>
              </View>

              {/* Age Group Filters */}
              <Text style={styles.filterSectionTitle}>Age Groups</Text>
              <View style={styles.filterOptions}>
                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('2-3') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('2-3')}
                >
                  <Icon
                    name={activeFilters.includes('2-3') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('2-3') ? COLORS.age2to3 : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Ages 2-3</Text>
                  <Text style={styles.filterOptionCount}>({stats.age2to3})</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('3-5') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('3-5')}
                >
                  <Icon
                    name={activeFilters.includes('3-5') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('3-5') ? COLORS.age4to5 : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Ages 3-5</Text>
                  <Text style={styles.filterOptionCount}>({stats.age3to5})</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('5-6') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('5-6')}
                >
                  <Icon
                    name={activeFilters.includes('5-6') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('5-6') ? COLORS.age5to6 : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Ages 5-6</Text>
                  <Text style={styles.filterOptionCount}>({stats.age5to6})</Text>
                </TouchableOpacity>
              </View>

              {/* Gender Filters */}
              <Text style={styles.filterSectionTitle}>Gender</Text>
              <View style={styles.filterOptions}>
                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('male') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('male')}
                >
                  <Icon
                    name={activeFilters.includes('male') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('male') ? COLORS.info : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Male</Text>
                  <Text style={styles.filterOptionCount}>({stats.male})</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.filterOption, activeFilters.includes('female') && styles.filterOptionActive]}
                  onPress={() => toggleFilter('female')}
                >
                  <Icon
                    name={activeFilters.includes('female') ? 'checkbox-marked' : 'checkbox-blank-outline'}
                    size={20}
                    color={activeFilters.includes('female') ? COLORS.secondary : COLORS.textSecondary}
                  />
                  <Text style={styles.filterOptionText}>Female</Text>
                  <Text style={styles.filterOptionCount}>({stats.female})</Text>
                </TouchableOpacity>
              </View>
            </ScrollView>

            <View style={styles.modalFooter}>
              <TouchableOpacity
                style={styles.modalFooterButton}
                onPress={() => {
                  clearAllFilters();
                  setShowFilterModal(false);
                }}
              >
                <Text style={styles.modalFooterButtonTextSecondary}>Clear All</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.modalFooterButton, styles.modalFooterButtonPrimary]}
                onPress={() => setShowFilterModal(false)}
              >
                <Text style={styles.modalFooterButtonTextPrimary}>Apply Filters</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>

      {/* Sort Modal */}
      <Modal
        visible={showSortModal}
        transparent
        animationType="slide"
        onRequestClose={() => setShowSortModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Sort Patients</Text>
              <TouchableOpacity onPress={() => setShowSortModal(false)}>
                <Icon name="close" size={24} color={COLORS.text} />
              </TouchableOpacity>
            </View>

            <View style={styles.modalBody}>
              <TouchableOpacity
                style={[styles.sortOption, sortBy === 'newest' && styles.sortOptionActive]}
                onPress={() => {
                  setSortBy('newest');
                  setShowSortModal(false);
                }}
              >
                <Icon name="clock-outline" size={20} color={sortBy === 'newest' ? COLORS.primary : COLORS.textSecondary} />
                <Text style={[styles.sortOptionText, sortBy === 'newest' && styles.sortOptionTextActive]}>
                  Newest First
                </Text>
                {sortBy === 'newest' && <Icon name="check" size={20} color={COLORS.primary} />}
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.sortOption, sortBy === 'oldest' && styles.sortOptionActive]}
                onPress={() => {
                  setSortBy('oldest');
                  setShowSortModal(false);
                }}
              >
                <Icon name="clock-outline" size={20} color={sortBy === 'oldest' ? COLORS.primary : COLORS.textSecondary} />
                <Text style={[styles.sortOptionText, sortBy === 'oldest' && styles.sortOptionTextActive]}>
                  Oldest First
                </Text>
                {sortBy === 'oldest' && <Icon name="check" size={20} color={COLORS.primary} />}
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.sortOption, sortBy === 'name-asc' && styles.sortOptionActive]}
                onPress={() => {
                  setSortBy('name-asc');
                  setShowSortModal(false);
                }}
              >
                <Icon name="sort-alphabetical-ascending" size={20} color={sortBy === 'name-asc' ? COLORS.primary : COLORS.textSecondary} />
                <Text style={[styles.sortOptionText, sortBy === 'name-asc' && styles.sortOptionTextActive]}>
                  Name (A-Z)
                </Text>
                {sortBy === 'name-asc' && <Icon name="check" size={20} color={COLORS.primary} />}
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.sortOption, sortBy === 'name-desc' && styles.sortOptionActive]}
                onPress={() => {
                  setSortBy('name-desc');
                  setShowSortModal(false);
                }}
              >
                <Icon name="sort-alphabetical-descending" size={20} color={sortBy === 'name-desc' ? COLORS.primary : COLORS.textSecondary} />
                <Text style={[styles.sortOptionText, sortBy === 'name-desc' && styles.sortOptionTextActive]}>
                  Name (Z-A)
                </Text>
                {sortBy === 'name-desc' && <Icon name="check" size={20} color={COLORS.primary} />}
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.sortOption, sortBy === 'age-asc' && styles.sortOptionActive]}
                onPress={() => {
                  setSortBy('age-asc');
                  setShowSortModal(false);
                }}
              >
                <Icon name="sort-numeric-ascending" size={20} color={sortBy === 'age-asc' ? COLORS.primary : COLORS.textSecondary} />
                <Text style={[styles.sortOptionText, sortBy === 'age-asc' && styles.sortOptionTextActive]}>
                  Age (Youngest)
                </Text>
                {sortBy === 'age-asc' && <Icon name="check" size={20} color={COLORS.primary} />}
              </TouchableOpacity>

              <TouchableOpacity
                style={[styles.sortOption, sortBy === 'age-desc' && styles.sortOptionActive]}
                onPress={() => {
                  setSortBy('age-desc');
                  setShowSortModal(false);
                }}
              >
                <Icon name="sort-numeric-descending" size={20} color={sortBy === 'age-desc' ? COLORS.primary : COLORS.textSecondary} />
                <Text style={[styles.sortOptionText, sortBy === 'age-desc' && styles.sortOptionTextActive]}>
                  Age (Oldest)
                </Text>
                {sortBy === 'age-desc' && <Icon name="check" size={20} color={COLORS.primary} />}
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </Modal>
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
    position: 'relative',
  },
  notificationBadge: {
    position: 'absolute',
    top: 8,
    right: 8,
    backgroundColor: '#FF5252',
    width: 18,
    height: 18,
    borderRadius: 9,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#FFF',
  },
  notificationText: {
    fontSize: 10,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: SPACING.lg,
  },
  statsContainer: {
    marginBottom: SPACING.lg,
  },
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: SPACING.md,
  },
  statCard: {
    flex: 1,
    marginHorizontal: SPACING.xs,
    borderRadius: 16,
    overflow: 'hidden',
    ...SHADOWS.medium,
  },
  statGradient: {
    padding: SPACING.md,
    flexDirection: 'row',
    alignItems: 'center',
  },
  statIconContainer: {
    width: 48,
    height: 48,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.25)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING.sm,
  },
  statContent: {
    flex: 1,
  },
  statValue: {
    fontSize: 24,
    fontWeight: '700' as any,
    color: '#FFF',
    marginBottom: 2,
  },
  statTitle: {
    fontSize: 12,
    color: 'rgba(255,255,255,0.95)',
    fontWeight: '600' as any,
  },
  statSubtitle: {
    fontSize: 10,
    color: 'rgba(255,255,255,0.75)',
    marginTop: 2,
  },
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.md,
    marginTop: SPACING.sm,
  },
  sectionTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700' as any,
    color: COLORS.text,
  },
  sectionSubtitle: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.textSecondary,
    marginTop: 2,
  },
  addButton: {
    borderRadius: 12,
    overflow: 'hidden',
    ...SHADOWS.small,
  },
  addButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.sm,
    paddingHorizontal: SPACING.md,
  },
  addButtonText: {
    color: '#FFF',
    fontSize: FONTS.sizes.sm,
    fontWeight: '600' as any,
    marginLeft: SPACING.xs,
  },
  childrenList: {
    marginTop: SPACING.sm,
  },
  childCard: {
    backgroundColor: '#FFF',
    borderRadius: 20,
    marginBottom: SPACING.md,
    overflow: 'hidden',
    ...SHADOWS.medium,
  },
  cardHeader: {
    flexDirection: 'row',
    padding: SPACING.md,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  avatarGradient: {
    width: 64,
    height: 64,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING.md,
  },
  avatarContainer: {
    width: 60,
    height: 60,
    borderRadius: 14,
    backgroundColor: 'rgba(255,255,255,0.3)',
    alignItems: 'center',
    justifyContent: 'center',
  },
  avatarText: {
    fontSize: 20,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  patientInfo: {
    flex: 1,
    justifyContent: 'center',
  },
  nameRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: SPACING.xs,
  },
  patientName: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700' as any,
    color: COLORS.text,
  },
  statusBadge: {
    paddingHorizontal: SPACING.sm,
    paddingVertical: 4,
    borderRadius: 8,
  },
  statusText: {
    fontSize: 10,
    fontWeight: '600' as any,
    color: '#FFF',
  },
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infoItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  infoText: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.textSecondary,
    marginLeft: 4,
    fontWeight: '500' as any,
  },
  infoDivider: {
    width: 1,
    height: 12,
    backgroundColor: '#E0E0E0',
    marginHorizontal: SPACING.sm,
  },
  ageGroupContainer: {
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
  },
  ageGroupBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.xs,
    paddingHorizontal: SPACING.sm,
    borderRadius: 8,
    alignSelf: 'flex-start',
  },
  ageGroupText: {
    fontSize: FONTS.sizes.xs,
    fontWeight: '600' as any,
    marginLeft: 6,
  },
  assessmentSection: {
    padding: SPACING.md,
  },
  assessmentLabel: {
    fontSize: 11,
    fontWeight: '700' as any,
    color: COLORS.textSecondary,
    letterSpacing: 0.5,
    marginBottom: SPACING.sm,
  },
  assessmentCard: {
    borderRadius: 16,
    padding: SPACING.md,
    ...SHADOWS.small,
  },
  assessmentHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING.sm,
  },
  assessmentIconBox: {
    width: 48,
    height: 48,
    borderRadius: 12,
    backgroundColor: 'rgba(255,255,255,0.25)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: SPACING.sm,
  },
  assessmentEmoji: {
    fontSize: 24,
  },
  assessmentTitleBox: {
    flex: 1,
  },
  assessmentName: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
    color: '#FFF',
  },
  assessmentType: {
    fontSize: FONTS.sizes.xs,
    color: 'rgba(255,255,255,0.85)',
    marginTop: 2,
  },
  playButton: {
    opacity: 0.9,
  },
  assessmentDetails: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    marginTop: SPACING.xs,
  },
  detailPill: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.2)',
    paddingVertical: 6,
    paddingHorizontal: SPACING.sm,
    borderRadius: 12,
    marginRight: SPACING.xs,
    marginTop: SPACING.xs,
  },
  detailPillText: {
    fontSize: 11,
    color: 'rgba(255,255,255,0.95)',
    marginLeft: 4,
    fontWeight: '600' as any,
  },
  cardFooter: {
    flexDirection: 'row',
    borderTopWidth: 1,
    borderTopColor: '#F0F0F0',
  },
  footerButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: SPACING.md,
  },
  footerButtonText: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.primary,
    marginLeft: 6,
    fontWeight: '600' as any,
  },
  footerDivider: {
    width: 1,
    backgroundColor: '#F0F0F0',
  },
  emptyContainer: {
    marginTop: SPACING.xl,
  },
  emptyCard: {
    padding: SPACING.xl,
    borderRadius: 20,
    alignItems: 'center',
  },
  emptyIconContainer: {
    marginBottom: SPACING.lg,
  },
  emptyIconGradient: {
    width: 96,
    height: 96,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
  },
  emptyTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '700' as any,
    color: COLORS.text,
    marginBottom: SPACING.sm,
    textAlign: 'center',
  },
  emptySubtitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    textAlign: 'center',
    marginBottom: SPACING.lg,
    lineHeight: 22,
    paddingHorizontal: SPACING.md,
  },
  emptyButton: {
    borderRadius: 14,
    overflow: 'hidden',
    marginBottom: SPACING.lg,
    ...SHADOWS.medium,
  },
  emptyButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.md,
    paddingHorizontal: SPACING.xl,
  },
  emptyButtonText: {
    color: '#FFF',
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
    marginLeft: SPACING.sm,
  },
  emptyFeatures: {
    alignSelf: 'stretch',
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: SPACING.xs,
    paddingLeft: SPACING.md,
  },
  featureText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginLeft: SPACING.sm,
    fontWeight: '500' as any,
  },
  infoSection: {
    marginTop: SPACING.lg,
  },
  infoCard: {
    borderRadius: 16,
    padding: SPACING.md,
  },
  infoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING.md,
  },
  infoTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
    color: COLORS.primary,
    marginLeft: SPACING.sm,
  },
  infoContent: {},
  infoPoint: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: SPACING.sm,
  },
  infoPointText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.text,
    marginLeft: SPACING.sm,
    flex: 1,
    lineHeight: 20,
  },
  loadingContainer: {
    padding: SPACING.xl,
    alignItems: 'center',
  },
  loadingText: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
  },
  bottomSpacer: {
    height: SPACING.xl,
  },
  // Search and Filter Styles
  searchFilterContainer: {
    marginBottom: SPACING.md,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 12,
    marginBottom: SPACING.sm,
    ...SHADOWS.small,
  },
  searchInput: {
    flex: 1,
    marginLeft: SPACING.sm,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    padding: 0,
  },
  actionBar: {
    flexDirection: 'row',
    alignItems: 'center',
    flexWrap: 'wrap',
  },
  filterButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 10,
    marginRight: SPACING.sm,
    ...SHADOWS.small,
  },
  filterButtonText: {
    marginLeft: 6,
    fontSize: FONTS.sizes.sm,
    color: COLORS.primary,
    fontWeight: '600' as any,
  },
  filterBadge: {
    backgroundColor: COLORS.primary,
    width: 18,
    height: 18,
    borderRadius: 9,
    alignItems: 'center',
    justifyContent: 'center',
    marginLeft: 6,
  },
  filterBadgeText: {
    color: '#FFF',
    fontSize: 10,
    fontWeight: '700' as any,
  },
  sortButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFF',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 10,
    marginRight: SPACING.sm,
    ...SHADOWS.small,
  },
  sortButtonText: {
    marginLeft: 6,
    fontSize: FONTS.sizes.sm,
    color: COLORS.primary,
    fontWeight: '600' as any,
  },
  viewModeButton: {
    backgroundColor: '#FFF',
    padding: SPACING.sm,
    borderRadius: 10,
    marginRight: SPACING.sm,
    ...SHADOWS.small,
  },
  bulkActionButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFE5E5',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 10,
    marginRight: SPACING.sm,
  },
  bulkActionText: {
    marginLeft: 6,
    fontSize: FONTS.sizes.sm,
    fontWeight: '600' as any,
  },
  activeFiltersContainer: {
    marginTop: SPACING.sm,
  },
  activeFiltersScroll: {
    flexDirection: 'row',
  },
  activeFilterChip: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: `${COLORS.primary}15`,
    paddingHorizontal: SPACING.sm,
    paddingVertical: 6,
    borderRadius: 20,
    marginRight: SPACING.xs,
    borderWidth: 1,
    borderColor: `${COLORS.primary}30`,
  },
  activeFilterText: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.primary,
    fontWeight: '600' as any,
    marginRight: 4,
  },
  clearFiltersButton: {
    paddingHorizontal: SPACING.sm,
    paddingVertical: 6,
    borderRadius: 20,
    backgroundColor: '#F5F5F5',
  },
  clearFiltersText: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.textSecondary,
    fontWeight: '600' as any,
  },
  selectionBanner: {
    backgroundColor: COLORS.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 12,
    marginBottom: SPACING.sm,
  },
  selectionText: {
    color: '#FFF',
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
  },
  selectionActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  selectionAction: {
    marginLeft: SPACING.md,
  },
  selectionActionText: {
    color: '#FFF',
    fontSize: FONTS.sizes.sm,
    fontWeight: '600' as any,
  },
  resultsSummary: {
    paddingVertical: SPACING.xs,
    marginBottom: SPACING.sm,
  },
  resultsText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    fontWeight: '500' as any,
  },
  noResultsContainer: {
    alignItems: 'center',
    paddingVertical: SPACING.xxl * 2,
  },
  noResultsTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '700' as any,
    color: COLORS.text,
    marginTop: SPACING.lg,
    marginBottom: SPACING.xs,
  },
  noResultsSubtitle: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    textAlign: 'center',
    paddingHorizontal: SPACING.xl,
    marginBottom: SPACING.lg,
  },
  clearFiltersBtn: {
    backgroundColor: COLORS.primary,
    paddingHorizontal: SPACING.xl,
    paddingVertical: SPACING.md,
    borderRadius: 12,
  },
  clearFiltersBtnText: {
    color: '#FFF',
    fontSize: FONTS.sizes.md,
    fontWeight: '600' as any,
  },
  childCardSelected: {
    borderWidth: 2,
    borderColor: COLORS.primary,
  },
  selectionCheckbox: {
    position: 'absolute',
    top: SPACING.md,
    right: SPACING.md,
    zIndex: 10,
  },
  checkbox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    borderWidth: 2,
    borderColor: COLORS.textSecondary,
    backgroundColor: '#FFF',
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkboxSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  // Modal Styles
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.5)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: '#FFF',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    maxHeight: SCREEN_HEIGHT * 0.8,
    ...SHADOWS.large,
  },
  modalHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: SPACING.lg,
    paddingVertical: SPACING.md,
    borderBottomWidth: 1,
    borderBottomColor: '#F0F0F0',
  },
  modalTitle: {
    fontSize: FONTS.sizes.xl,
    fontWeight: '700' as any,
    color: COLORS.text,
  },
  modalBody: {
    padding: SPACING.lg,
    maxHeight: SCREEN_HEIGHT * 0.5,
  },
  filterSectionTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700' as any,
    color: COLORS.text,
    marginTop: SPACING.md,
    marginBottom: SPACING.sm,
  },
  filterOptions: {
    marginBottom: SPACING.md,
  },
  filterOption: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.sm,
    paddingHorizontal: SPACING.md,
    borderRadius: 10,
    marginBottom: SPACING.xs,
  },
  filterOptionActive: {
    backgroundColor: `${COLORS.primary}10`,
  },
  filterOptionText: {
    flex: 1,
    marginLeft: SPACING.sm,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    fontWeight: '500' as any,
  },
  filterOptionCount: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    fontWeight: '600' as any,
  },
  modalFooter: {
    flexDirection: 'row',
    padding: SPACING.lg,
    borderTopWidth: 1,
    borderTopColor: '#F0F0F0',
  },
  modalFooterButton: {
    flex: 1,
    paddingVertical: SPACING.md,
    borderRadius: 12,
    alignItems: 'center',
    marginHorizontal: SPACING.xs,
    borderWidth: 1,
    borderColor: COLORS.primary,
  },
  modalFooterButtonPrimary: {
    backgroundColor: COLORS.primary,
  },
  modalFooterButtonTextSecondary: {
    color: COLORS.primary,
    fontSize: FONTS.sizes.md,
    fontWeight: '600' as any,
  },
  modalFooterButtonTextPrimary: {
    color: '#FFF',
    fontSize: FONTS.sizes.md,
    fontWeight: '600' as any,
  },
  sortOption: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.md,
    paddingHorizontal: SPACING.md,
    borderRadius: 10,
    marginBottom: SPACING.xs,
  },
  sortOptionActive: {
    backgroundColor: `${COLORS.primary}10`,
  },
  sortOptionText: {
    flex: 1,
    marginLeft: SPACING.sm,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    fontWeight: '500' as any,
  },
  sortOptionTextActive: {
    color: COLORS.primary,
    fontWeight: '700' as any,
  },
});

export default CognitiveDashboardScreen;
