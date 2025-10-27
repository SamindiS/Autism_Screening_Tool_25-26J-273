import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Alert,
  Dimensions,
} from 'react-native';
import { useApp } from '../context/AppContext';
import { AGE_GROUPS, COLORS, FONTS, SPACING } from '../constants';

const { width } = Dimensions.get('window');

interface AgeSelectionScreenProps {
  navigation: any;
  route: any;
}

const AgeSelectionScreen: React.FC<AgeSelectionScreenProps> = ({ navigation, route }) => {
  const { componentType } = route.params;
  const { currentLanguage } = useApp();
  const [selectedAgeGroup, setSelectedAgeGroup] = useState<string | null>(null);

  const handleAgeGroupSelect = (ageGroup: string) => {
    setSelectedAgeGroup(ageGroup);
  };

  const handleContinue = () => {
    if (!selectedAgeGroup) {
      Alert.alert('Selection Required', 'Please select an age group to continue');
      return;
    }

    // Navigate to the appropriate game based on component type and age group
    const ageGroupData = AGE_GROUPS[selectedAgeGroup as keyof typeof AGE_GROUPS];
    const availableGames = ageGroupData.games;

    if (componentType === 'cognitive_flexibility') {
      // For cognitive flexibility, select the appropriate game based on age
      let gameType = 'go_nogo'; // Default for 2-3 years
      
      if (selectedAgeGroup === '4-5') {
        gameType = 'stroop';
      } else if (selectedAgeGroup === '5-6') {
        gameType = 'dccs';
      }

      navigation.navigate('GameScreen', {
        componentType,
        ageGroup: selectedAgeGroup,
        gameType,
      });
    } else {
      // For other components, navigate to their respective screens
      navigation.navigate('GameScreen', {
        componentType,
        ageGroup: selectedAgeGroup,
        gameType: 'default',
      });
    }
  };

  const handleBack = () => {
    navigation.goBack();
  };

  const AgeGroupCard = ({ ageGroup, data, isSelected, onSelect }: any) => (
    <TouchableOpacity
      style={[
        styles.ageGroupCard,
        isSelected && styles.ageGroupCardSelected,
        { borderColor: data.color },
      ]}
      onPress={() => onSelect(ageGroup)}
    >
      <View style={[styles.ageGroupIcon, { backgroundColor: data.color }]}>
        <Text style={styles.ageGroupIconText}>
          {ageGroup === '2-3' ? '👶' : ageGroup === '4-5' ? '🧒' : '👦'}
        </Text>
      </View>
      <View style={styles.ageGroupContent}>
        <Text style={styles.ageGroupLabel}>{data.label}</Text>
        <Text style={styles.ageGroupDescription}>
          {ageGroup === '2-3' 
            ? 'Simple Go/No-Go tasks' 
            : ageGroup === '4-5' 
            ? 'Go/No-Go + Stroop tasks' 
            : 'All cognitive flexibility tasks'
          }
        </Text>
        <Text style={styles.ageGroupTime}>
          Max {data.maxSessionTime} minutes
        </Text>
      </View>
      {isSelected && (
        <View style={styles.selectedIndicator}>
          <Text style={styles.selectedCheckmark}>✓</Text>
        </View>
      )}
    </TouchableOpacity>
  );

  const getComponentTitle = () => {
    switch (componentType) {
      case 'cognitive_flexibility':
        return 'Cognitive Flexibility & Rule-Switching';
      case 'rrb':
        return 'Restricted & Repetitive Behaviors';
      case 'visual_attention':
        return 'Visual Attention Assessment';
      case 'rtn':
        return 'Response to Name Test';
      default:
        return 'Assessment Component';
    }
  };

  const getComponentDescription = () => {
    switch (componentType) {
      case 'cognitive_flexibility':
        return 'This assessment evaluates executive functioning and the ability to switch between rules. Select the appropriate age group to begin.';
      case 'rrb':
        return 'This assessment evaluates repetitive behaviors and restricted interests. Select the appropriate age group to begin.';
      case 'visual_attention':
        return 'This assessment measures visual attention and focus capabilities. Select the appropriate age group to begin.';
      case 'rtn':
        return 'This assessment tests social attention and name response. Select the appropriate age group to begin.';
      default:
        return 'Select the appropriate age group for this assessment.';
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <TouchableOpacity style={styles.backButton} onPress={handleBack}>
          <Text style={styles.backButtonText}>‹ Back</Text>
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Age Selection</Text>
        <View style={styles.placeholder} />
      </View>

      <ScrollView style={styles.content} showsVerticalScrollIndicator={false}>
        <View style={styles.titleSection}>
          <Text style={styles.title}>{getComponentTitle()}</Text>
          <Text style={styles.description}>{getComponentDescription()}</Text>
        </View>

        <View style={styles.ageGroupsSection}>
          <Text style={styles.sectionTitle}>Select Child's Age Group</Text>
          <Text style={styles.sectionSubtitle}>
            Choose the age group that best matches the child's current age
          </Text>

          <View style={styles.ageGroupsList}>
            {Object.entries(AGE_GROUPS).map(([ageGroup, data]) => (
              <AgeGroupCard
                key={ageGroup}
                ageGroup={ageGroup}
                data={data}
                isSelected={selectedAgeGroup === ageGroup}
                onSelect={handleAgeGroupSelect}
              />
            ))}
          </View>
        </View>

        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Text style={styles.infoIcon}>ℹ️</Text>
            <View style={styles.infoContent}>
              <Text style={styles.infoTitle}>Assessment Guidelines</Text>
              <Text style={styles.infoText}>
                • Ensure the child is comfortable and alert{'\n'}
                • Minimize distractions in the environment{'\n'}
                • The assessment will take 3-5 minutes{'\n'}
                • You can pause or stop at any time
              </Text>
            </View>
          </View>
        </View>
      </ScrollView>

      <View style={styles.footer}>
        <TouchableOpacity
          style={[
            styles.continueButton,
            !selectedAgeGroup && styles.continueButtonDisabled,
          ]}
          onPress={handleContinue}
          disabled={!selectedAgeGroup}
        >
          <Text style={styles.continueButtonText}>
            Continue to Assessment
          </Text>
        </TouchableOpacity>
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
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: SPACING.lg,
    paddingTop: SPACING.lg,
    paddingBottom: SPACING.md,
    backgroundColor: COLORS.surface,
    borderBottomWidth: 1,
    borderBottomColor: COLORS.border,
  },
  backButton: {
    paddingVertical: SPACING.sm,
  },
  backButtonText: {
    fontSize: FONTS.sizes.lg,
    color: COLORS.primary,
    fontWeight: '600',
  },
  headerTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: 'bold',
    color: COLORS.text,
  },
  placeholder: {
    width: 60,
  },
  content: {
    flex: 1,
    paddingHorizontal: SPACING.lg,
  },
  titleSection: {
    marginTop: SPACING.xl,
    marginBottom: SPACING.lg,
  },
  title: {
    fontSize: FONTS.sizes.xxl,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SPACING.sm,
  },
  description: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    lineHeight: 24,
  },
  ageGroupsSection: {
    marginBottom: SPACING.xl,
  },
  sectionTitle: {
    fontSize: FONTS.sizes.lg,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SPACING.xs,
  },
  sectionSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginBottom: SPACING.lg,
  },
  ageGroupsList: {
    gap: SPACING.md,
  },
  ageGroupCard: {
    backgroundColor: COLORS.surface,
    borderRadius: 16,
    padding: SPACING.lg,
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.border,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  ageGroupCardSelected: {
    borderColor: COLORS.primary,
    backgroundColor: COLORS.primary + '10',
  },
  ageGroupIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.md,
  },
  ageGroupIconText: {
    fontSize: 28,
  },
  ageGroupContent: {
    flex: 1,
  },
  ageGroupLabel: {
    fontSize: FONTS.sizes.lg,
    fontWeight: 'bold',
    color: COLORS.text,
    marginBottom: SPACING.xs,
  },
  ageGroupDescription: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginBottom: SPACING.xs,
  },
  ageGroupTime: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.primary,
    fontWeight: '600',
  },
  selectedIndicator: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
  selectedCheckmark: {
    color: COLORS.surface,
    fontSize: 16,
    fontWeight: 'bold',
  },
  infoSection: {
    marginBottom: SPACING.xl,
  },
  infoCard: {
    backgroundColor: COLORS.surface,
    borderRadius: 12,
    padding: SPACING.lg,
    flexDirection: 'row',
    alignItems: 'flex-start',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
  infoIcon: {
    fontSize: 24,
    marginRight: SPACING.md,
    marginTop: 2,
  },
  infoContent: {
    flex: 1,
  },
  infoTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: '600',
    color: COLORS.text,
    marginBottom: SPACING.sm,
  },
  infoText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    lineHeight: 20,
  },
  footer: {
    paddingHorizontal: SPACING.lg,
    paddingVertical: SPACING.lg,
    backgroundColor: COLORS.surface,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  continueButton: {
    backgroundColor: COLORS.primary,
    borderRadius: 12,
    paddingVertical: SPACING.md,
    alignItems: 'center',
  },
  continueButtonDisabled: {
    backgroundColor: COLORS.disabled,
  },
  continueButtonText: {
    color: COLORS.surface,
    fontSize: FONTS.sizes.lg,
    fontWeight: '600',
  },
});

export default AgeSelectionScreen;
