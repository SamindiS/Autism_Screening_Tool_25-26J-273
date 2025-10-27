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
import { storageService } from '../services/storage';
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
    age: '',
    gender: 'male' as 'male' | 'female',
    language: 'en' as 'en' | 'si' | 'ta',
  });
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState<{[key: string]: string}>({});

  const validateForm = (): boolean => {
    const newErrors: {[key: string]: string} = {};

    if (!formData.name.trim()) {
      newErrors.name = t.errors.required;
    }

    if (!formData.age.trim()) {
      newErrors.age = t.errors.required;
    } else {
      const age = parseInt(formData.age);
      if (isNaN(age) || age < 2 || age > 6) {
        newErrors.age = t.errors.ageRange;
      }
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const getAgeGroup = (age: number): '2-3' | '4-5' | '5-6' => {
    if (age >= 2 && age <= 3) return '2-3';
    if (age >= 4 && age <= 5) return '4-5';
    return '5-6';
  };

  const getAvailableGames = (age: number): string[] => {
    const ageGroup = getAgeGroup(age);
    return AGE_GROUPS[ageGroup].games;
  };

  const handleSubmit = async () => {
    if (!validateForm()) return;

    setLoading(true);
    try {
      const age = parseInt(formData.age);
      const ageGroup = getAgeGroup(age);
      const availableGames = getAvailableGames(age);

      const child: Child = {
        id: `child_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        name: formData.name.trim(),
        age,
        gender: formData.gender,
        language: formData.language,
        testCompleted: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      await storageService.saveChild(child);

      Alert.alert(
        t.child.registrationSuccess,
        replacePlaceholders(t.child.registrationMessage, { name: child.name, age: age.toString() }),
        [
          {
            text: t.common.ok,
            onPress: () => {
              onChildAdded?.(child);
            },
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

  const age = parseInt(formData.age) || 0;
  const ageGroup = getAgeGroup(age);
  const availableGames = getAvailableGames(age);

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
            <Text style={styles.label}>{t.child.age} *</Text>
            <TextInput
              style={[styles.input, errors.age && styles.inputError]}
              value={formData.age}
              onChangeText={(text) => setFormData({ ...formData, age: text })}
              placeholder={`${t.child.age} (2-6)`}
              placeholderTextColor={COLORS.textSecondary}
              keyboardType="numeric"
              maxLength={1}
            />
            {errors.age && <Text style={styles.errorText}>{errors.age}</Text>}
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
                { value: 'en', label: t.common.english },
                { value: 'si', label: t.common.sinhala },
                { value: 'ta', label: t.common.tamil },
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

          {age > 0 && (
            <View style={styles.ageInfo}>
              <Text style={styles.ageInfoTitle}>{t.child.ageGroup}: {AGE_GROUPS[ageGroup].label}</Text>
              <Text style={styles.ageInfoSubtitle}>{t.games.availableGames}:</Text>
              <View style={styles.gamesList}>
                {availableGames.map((game, index) => (
                  <View key={index} style={styles.gameItem}>
                    <Icon name="gamepad-variant" size={16} color={AGE_GROUPS[ageGroup].color} />
                    <Text style={styles.gameText}>{game.replace('_', ' ').toUpperCase()}</Text>
                  </View>
                ))}
              </View>
            </View>
          )}

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
    fontWeight: FONTS.weights.bold,
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
    fontWeight: FONTS.weights.medium,
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
    fontWeight: FONTS.weights.medium,
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
    fontWeight: FONTS.weights.medium,
  },
  ageInfo: {
    backgroundColor: COLORS.lightGray,
    padding: SPACING.md,
    borderRadius: 8,
    marginBottom: SPACING.lg,
  },
  ageInfoTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: FONTS.weights.medium,
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
    fontWeight: FONTS.weights.medium,
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
    fontWeight: FONTS.weights.medium,
  },
});

export default ChildRegistrationScreen;

