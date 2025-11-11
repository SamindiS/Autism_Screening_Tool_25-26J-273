import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  Alert,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import { Child } from '../types';
import { COLORS, FONTS, SPACING, AGE_GROUPS } from '../constants';
import { storageService } from '../services/storage.simple';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { useLanguage, replacePlaceholders } from '../context/LanguageContext';

interface ChildRegistrationScreenProps {
  onChildAdded?: (child: Child) => void;
  onCancel?: () => void;
}

const ChildRegistrationScreen: React.FC<ChildRegistrationScreenProps> = ({ 
  onChildAdded, 
  onCancel 
}) => {
  const { t } = useLanguage();
  const [formData, setFormData] = useState({
    name: '',
    birthDay: '',
    birthMonth: '',
    birthYear: '',
    gender: 'male' as 'male' | 'female',
    language: 'en' as 'en' | 'si' | 'ta',
  });
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<{[key: string]: string}>({});

  // Calculate age from date of birth
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

  const validateForm = (): boolean => {
    const newErrors: {[key: string]: string} = {};

    if (!formData.name.trim()) {
      newErrors.name = t.errors.required;
    }

    // Validate date of birth
    if (!formData.birthDay || !formData.birthMonth || !formData.birthYear) {
      newErrors.dateOfBirth = 'Please enter complete date of birth';
    } else {
      const day = parseInt(formData.birthDay);
      const month = parseInt(formData.birthMonth);
      const year = parseInt(formData.birthYear);
      
      const currentYear = new Date().getFullYear();
      
      if (isNaN(day) || day < 1 || day > 31) {
        newErrors.birthDay = 'Invalid day (1-31)';
      }
      if (isNaN(month) || month < 1 || month > 12) {
        newErrors.birthMonth = 'Invalid month (1-12)';
      }
      if (isNaN(year) || year < 2018 || year > currentYear) {
        newErrors.birthYear = `Invalid year (2018-${currentYear})`;
      }
      
      // Check if date is valid
      if (!newErrors.birthDay && !newErrors.birthMonth && !newErrors.birthYear) {
        const dateString = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
        const birthDate = new Date(dateString);
        
        if (isNaN(birthDate.getTime())) {
          newErrors.dateOfBirth = 'Invalid date';
        } else if (birthDate > new Date()) {
          newErrors.dateOfBirth = 'Birth date cannot be in the future';
        } else {
          const age = calculateAge(dateString);
          if (age < 2 || age > 6) {
            newErrors.dateOfBirth = 'Child age must be between 2 and 6 years';
          }
        }
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const getAgeGroup = (age: number): '2-3' | '4-5' | '5-6' => {
    if (age >= 2 && age < 3) return '2-3'; // Ages 2-3: AI Bot
    if (age >= 3 && age < 5) return '4-5'; // Ages 3-5: Frog Jump
    return '5-6'; // Ages 5-6: Color Shape
  };

  const getAvailableGames = (age: number): string[] => {
    const ageGroup = getAgeGroup(age);
    return AGE_GROUPS[ageGroup].games;
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      // Create date of birth string
      const day = parseInt(formData.birthDay);
      const month = parseInt(formData.birthMonth);
      const year = parseInt(formData.birthYear);
      const dateOfBirth = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
      
      // Calculate age
      const age = calculateAge(dateOfBirth);
      const ageGroup = getAgeGroup(age);
      const availableGames = getAvailableGames(age);

      const child: Child = {
        id: `child_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        name: formData.name.trim(),
        age,
        dateOfBirth,
        gender: formData.gender,
        language: formData.language,
        testCompleted: false,
        createdAt: new Date(),
        updatedAt: new Date(),
        hospitalId: ''
      };

      await storageService.saveChild(child);

      // Determine assessment type based on age
      let assessmentType = '';
      if (age >= 2 && age < 3) {
        assessmentType = 'AI Doctor Bot questionnaire';
      } else if (age >= 3 && age < 5) {
        assessmentType = 'Frog Jump Game';
      } else if (age >= 5 && age <= 6) {
        assessmentType = 'Magic Garden Adventure';
      }

      Alert.alert(
        t.child.registrationSuccess,
        `${replacePlaceholders(t.child.registrationMessage, { name: child.name, age: age.toString() })}\n\nRecommended Assessment: ${assessmentType}\n\nTap "Start Assessment" to begin now!`,
        [
          {
            text: 'Start Assessment',
            onPress: () => {
              onChildAdded?.(child);
            },
            style: 'default',
          },
          {
            text: 'Later',
            onPress: () => {
              onCancel?.();
            },
            style: 'cancel',
          },
        ]
      );
    } catch (error) {
      console.error('Failed to add child:', error);
      Alert.alert(t.errors.saveFailed, t.errors.saveFailed);
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView 
      style={styles.container} 
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.header}>
          <TouchableOpacity onPress={onCancel} style={styles.cancelButton}>
            <Icon name="close" size={24} color={COLORS.text} />
          </TouchableOpacity>
          <Text style={styles.title}>{t.child.addChild}</Text>
          <View style={styles.placeholder} />
        </View>

        <View style={styles.form}>
          <View style={styles.inputGroup}>
            <Text style={styles.label}>{t.child.childName} *</Text>
            <TextInput
              style={[styles.input, errors.name && styles.inputError]}
              value={formData.name}
              onChangeText={(text) => setFormData({ ...formData, name: text })}
              placeholder={t.child.childName}
              placeholderTextColor={COLORS.textSecondary}
            />
            {errors.name && <Text style={styles.errorText}>{errors.name}</Text>}
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>Date of Birth * (DD / MM / YYYY)</Text>
            <View style={styles.dateInputRow}>
              <View style={styles.dateInputContainer}>
                <Text style={styles.dateInputLabel}>Day</Text>
                <TextInput
                  style={[
                    styles.dateInput,
                    (errors.birthDay || errors.dateOfBirth) && styles.inputError
                  ]}
                  value={formData.birthDay}
                  onChangeText={(text) => setFormData({ ...formData, birthDay: text })}
                  placeholder="DD"
                  placeholderTextColor={COLORS.textSecondary}
                  keyboardType="numeric"
                  maxLength={2}
                />
              </View>
              
              <View style={styles.dateInputContainer}>
                <Text style={styles.dateInputLabel}>Month</Text>
                <TextInput
                  style={[
                    styles.dateInput,
                    (errors.birthMonth || errors.dateOfBirth) && styles.inputError
                  ]}
                  value={formData.birthMonth}
                  onChangeText={(text) => setFormData({ ...formData, birthMonth: text })}
                  placeholder="MM"
                  placeholderTextColor={COLORS.textSecondary}
                  keyboardType="numeric"
                  maxLength={2}
                />
              </View>
              
              <View style={[styles.dateInputContainer, { flex: 1.5 }]}>
                <Text style={styles.dateInputLabel}>Year</Text>
                <TextInput
                  style={[
                    styles.dateInput,
                    (errors.birthYear || errors.dateOfBirth) && styles.inputError
                  ]}
                  value={formData.birthYear}
                  onChangeText={(text) => setFormData({ ...formData, birthYear: text })}
                  placeholder="YYYY"
                  placeholderTextColor={COLORS.textSecondary}
                  keyboardType="numeric"
                  maxLength={4}
                />
              </View>
            </View>
            {(errors.birthDay || errors.birthMonth || errors.birthYear || errors.dateOfBirth) && (
              <Text style={styles.errorText}>
                {errors.birthDay || errors.birthMonth || errors.birthYear || errors.dateOfBirth}
              </Text>
            )}
            {formData.birthDay && formData.birthMonth && formData.birthYear && !errors.dateOfBirth && (
              <View style={styles.ageDisplay}>
                <Icon name="calendar-check" size={16} color={COLORS.success} />
                <Text style={styles.ageDisplayText}>
                  Age: {calculateAge(`${formData.birthYear}-${String(formData.birthMonth).padStart(2, '0')}-${String(formData.birthDay).padStart(2, '0')}`)} years old
                </Text>
              </View>
            )}
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>{t.child.gender}</Text>
            <View style={styles.radioGroup}>
              <TouchableOpacity
                style={[
                  styles.radioButton,
                  formData.gender === 'male' && styles.radioButtonSelected,
                ]}
                onPress={() => setFormData({ ...formData, gender: 'male' })}
              >
                <Text
                  style={[
                    styles.radioText,
                    formData.gender === 'male' && styles.radioTextSelected,
                  ]}
                >
                  {t.child.male}
                </Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[
                  styles.radioButton,
                  formData.gender === 'female' && styles.radioButtonSelected,
                ]}
                onPress={() => setFormData({ ...formData, gender: 'female' })}
              >
                <Text
                  style={[
                    styles.radioText,
                    formData.gender === 'female' && styles.radioTextSelected,
                  ]}
                >
                  {t.child.female}
                </Text>
              </TouchableOpacity>
            </View>
          </View>

          <View style={styles.inputGroup}>
            <Text style={styles.label}>{t.child.language}</Text>
            <View style={styles.languageGroup}>
              {[
                { value: 'en', label: 'English' },
                { value: 'si', label: 'සිංහල' },
                { value: 'ta', label: 'தமிழ்' },
              ].map((lang) => (
                <TouchableOpacity
                  key={lang.value}
                  style={[
                    styles.languageButton,
                    formData.language === lang.value && styles.languageButtonSelected,
                  ]}
                  onPress={() => setFormData({ ...formData, language: lang.value as any })}
                >
                  <Text
                    style={[
                      styles.languageText,
                      formData.language === lang.value && styles.languageTextSelected,
                    ]}
                  >
                    {lang.label}
                  </Text>
                </TouchableOpacity>
              ))}
            </View>
          </View>

          <TouchableOpacity
            style={[styles.submitButton, loading && styles.submitButtonDisabled]}
            onPress={handleSubmit}
            disabled={loading}
          >
            {loading ? (
              <ActivityIndicator color={COLORS.surface} />
            ) : (
              <>
                <Icon name="plus" size={20} color={COLORS.surface} />
                <Text style={styles.submitButtonText}>{t.child.addChild}</Text>
              </>
            )}
          </TouchableOpacity>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  scrollContainer: {
    flexGrow: 1,
    padding: SPACING.lg,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: SPACING.xl,
  },
  cancelButton: {
    padding: SPACING.sm,
  },
  title: {
    fontSize: FONTS.sizes.xl,
    fontWeight: FONTS.weights.bold as any,
    color: COLORS.text,
  },
  placeholder: {
    width: 40,
  },
  form: {
    flex: 1,
  },
  inputGroup: {
    marginBottom: SPACING.lg,
  },
  label: {
    fontSize: FONTS.sizes.md,
    fontWeight: FONTS.weights.medium as any,
    color: COLORS.text,
    marginBottom: SPACING.sm,
  },
  input: {
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    padding: SPACING.md,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    backgroundColor: COLORS.surface,
  },
  inputError: {
    borderColor: COLORS.error,
  },
  errorText: {
    color: COLORS.error,
    fontSize: FONTS.sizes.sm,
    marginTop: SPACING.xs,
  },
  dateInputRow: {
    flexDirection: 'row',
    gap: SPACING.sm,
  },
  dateInputContainer: {
    flex: 1,
  },
  dateInputLabel: {
    fontSize: FONTS.sizes.sm,
    fontWeight: FONTS.weights.medium as any,
    color: COLORS.textSecondary,
    marginBottom: SPACING.xs,
  },
  dateInput: {
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    padding: SPACING.md,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    backgroundColor: COLORS.surface,
    textAlign: 'center',
  },
  ageDisplay: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: SPACING.sm,
    padding: SPACING.sm,
    backgroundColor: '#E8F5E9',
    borderRadius: 8,
    gap: SPACING.xs,
  },
  ageDisplayText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.success,
    fontWeight: FONTS.weights.medium as any,
  },
  radioGroup: {
    flexDirection: 'row',
    gap: SPACING.md,
  },
  radioButton: {
    flex: 1,
    padding: SPACING.md,
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    alignItems: 'center',
    backgroundColor: COLORS.surface,
  },
  radioButtonSelected: {
    borderColor: COLORS.primary,
    backgroundColor: COLORS.primary + '10',
  },
  radioText: {
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
  },
  radioTextSelected: {
    color: COLORS.primary,
    fontWeight: FONTS.weights.medium as any,
  },
  languageGroup: {
    flexDirection: 'row',
    gap: SPACING.sm,
  },
  languageButton: {
    flex: 1,
    padding: SPACING.sm,
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 6,
    alignItems: 'center',
    backgroundColor: COLORS.surface,
  },
  languageButtonSelected: {
    borderColor: COLORS.primary,
    backgroundColor: COLORS.primary + '10',
  },
  languageText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.text,
  },
  languageTextSelected: {
    color: COLORS.primary,
    fontWeight: FONTS.weights.medium as any,
  },
  ageInfo: {
    backgroundColor: COLORS.lightGray,
    padding: SPACING.md,
    borderRadius: 8,
    marginBottom: SPACING.lg,
  },
  ageInfoTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: FONTS.weights.medium as any,
    color: COLORS.text,
    marginBottom: SPACING.sm,
  },
  ageInfoSubtitle: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginBottom: SPACING.sm,
  },
  gamesList: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: SPACING.sm,
  },
  gameItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.surface,
    paddingHorizontal: SPACING.sm,
    paddingVertical: SPACING.xs,
    borderRadius: 4,
    gap: SPACING.xs,
  },
  gameText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.text,
    fontWeight: FONTS.weights.medium as any,
  },
  submitButton: {
    backgroundColor: COLORS.primary,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    padding: SPACING.md,
    borderRadius: 8,
    gap: SPACING.sm,
  },
  submitButtonDisabled: {
    backgroundColor: COLORS.disabled,
  },
  submitButtonText: {
    color: COLORS.surface,
    fontSize: FONTS.sizes.md,
    fontWeight: FONTS.weights.medium as any,
  },
});

export default ChildRegistrationScreen;

