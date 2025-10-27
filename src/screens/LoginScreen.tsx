import React, { useState, useRef, useEffect } from 'react';
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
  Animated,
  Dimensions,
  StatusBar,
  ActivityIndicator,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import { COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import LinearGradient from 'react-native-linear-gradient';
import LanguageSelector from '../components/LanguageSelector';

const { width, height } = Dimensions.get('window');

interface LoginScreenProps {
  onNavigateToRegister?: () => void;
  onAuthSuccess?: () => void;
}

const LoginScreen: React.FC<LoginScreenProps> = ({ onNavigateToRegister, onAuthSuccess }) => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [isFocused, setIsFocused] = useState({ email: false, password: false });
  const { login, loading, error, clearError } = useAuth();
  const { t } = useLanguage();

  // Animation refs
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideAnim = useRef(new Animated.Value(30)).current;
  const logoScale = useRef(new Animated.Value(0.8)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;
  const inputFocusAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    // Entrance animations
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 800,
        useNativeDriver: true,
      }),
      Animated.spring(slideAnim, {
        toValue: 0,
        tension: 50,
        friction: 8,
        useNativeDriver: true,
      }),
      Animated.spring(logoScale, {
        toValue: 1,
        tension: 60,
        friction: 7,
        useNativeDriver: true,
      }),
    ]).start();
  }, []);

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      Alert.alert(t.errors.invalidInput, t.errors.required);
      return;
    }

    if (!isValidEmail(email)) {
      Alert.alert(t.errors.invalidInput, t.errors.emailInvalid);
      return;
    }

    try {
      clearError();
      
      // Button press animation
      Animated.sequence([
        Animated.timing(buttonScale, {
          toValue: 0.95,
          duration: 100,
          useNativeDriver: true,
        }),
        Animated.timing(buttonScale, {
          toValue: 1,
          duration: 100,
          useNativeDriver: true,
        }),
      ]).start();

      await login(email.trim(), password);
      onAuthSuccess?.();
    } catch (error) {
      // Error shake animation
      Animated.sequence([
        Animated.timing(inputFocusAnim, { toValue: 10, duration: 50, useNativeDriver: true }),
        Animated.timing(inputFocusAnim, { toValue: -10, duration: 50, useNativeDriver: true }),
        Animated.timing(inputFocusAnim, { toValue: 10, duration: 50, useNativeDriver: true }),
        Animated.timing(inputFocusAnim, { toValue: 0, duration: 50, useNativeDriver: true }),
      ]).start();
    }
  };

  const isValidEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const handleFocus = (field: 'email' | 'password') => {
    setIsFocused(prev => ({ ...prev, [field]: true }));
  };

  const handleBlur = (field: 'email' | 'password') => {
    setIsFocused(prev => ({ ...prev, [field]: false }));
  };

  const handleQuickFill = (demoEmail: string, demoPassword: string) => {
    setEmail(demoEmail);
    setPassword(demoPassword);
    clearError();
  };

  const AnimatedLinearGradient = Animated.createAnimatedComponent(LinearGradient);

  return (
    <KeyboardAvoidingView 
      style={styles.container} 
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      enabled={Platform.OS === 'ios'}
    >
      <StatusBar barStyle="light-content" backgroundColor={COLORS.primary} />
      
      <LinearGradient
        colors={['#6366F1', '#8B5CF6', '#A855F7']}
        style={styles.background}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      />

      {/* Language Selector */}
      <View style={styles.languageSelector}>
        <LanguageSelector />
      </View>

      <ScrollView 
        contentContainerStyle={styles.scrollContainer}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
        nestedScrollEnabled={true}
      >
        <Animated.View
          style={[
            styles.header,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          <Animated.View 
            style={[
              styles.logoContainer,
              { transform: [{ scale: logoScale }] }
            ]}
          >
            <View style={styles.logoBackground}>
              <Icon name="brain" size={48} color="#FFF" />
            </View>
            <Text style={styles.logoText}>SenseAI</Text>
            <Text style={styles.logoSubtext}>Clinical Early Autism Screening Platform</Text>
          </Animated.View>
        </Animated.View>

        <Animated.View
          style={[
            styles.formContainer,
            {
              opacity: fadeAnim,
              transform: [{ translateY: slideAnim }],
            },
          ]}
        >
          <View style={styles.formHeader}>
            <Text style={styles.title}>{t.auth.login}</Text>
            <Text style={styles.subtitle}>{t.dashboard.mainTitle}</Text>
          </View>

          {/* Email Input */}
          <View style={styles.inputWrapper}>
            <Text style={styles.label}>
              <Icon name="email-outline" size={16} color={COLORS.textSecondary} /> 
              {' '}{t.auth.email}
            </Text>
            <TextInput
              style={[
                styles.inputWithContainer,
                isFocused.email && styles.inputContainerFocused,
                error && styles.inputContainerError
              ]}
              value={email}
              onChangeText={setEmail}
              placeholder={t.auth.email}
              placeholderTextColor={COLORS.textSecondary + '80'}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
              textContentType="emailAddress"
              importantForAutofill="no"
              underlineColorAndroid="transparent"
              returnKeyType="next"
              onFocus={() => handleFocus('email')}
              onBlur={() => handleBlur('email')}
              editable={!loading}
            />
          </View>

          {/* Password Input */}
          <View style={styles.inputWrapper}>
            <Text style={styles.label}>
              <Icon name="lock-outline" size={16} color={COLORS.textSecondary} /> 
              {' '}{t.auth.password}
            </Text>
            <View style={styles.passwordWrapper}>
              <TextInput
                style={[
                  styles.passwordInputSimple,
                  isFocused.password && styles.inputContainerFocused,
                  error && styles.inputContainerError
                ]}
                value={password}
                onChangeText={setPassword}
                placeholder={t.auth.password}
                placeholderTextColor={COLORS.textSecondary + '80'}
                secureTextEntry={!showPassword}
                autoCapitalize="none"
                autoCorrect={false}
                textContentType="password"
                importantForAutofill="no"
                keyboardType="default"
                underlineColorAndroid="transparent"
                returnKeyType="done"
                onFocus={() => handleFocus('password')}
                onBlur={() => handleBlur('password')}
                editable={!loading}
              />
              <TouchableOpacity
                style={styles.eyeButtonAbsolute}
                onPress={() => setShowPassword(!showPassword)}
                disabled={loading}
              >
                <Icon 
                  name={showPassword ? 'eye-off' : 'eye'} 
                  size={20} 
                  color={COLORS.textSecondary} 
                />
              </TouchableOpacity>
            </View>
          </View>

          {/* Error Message */}
          {error && (
            <Animated.View 
              style={[
                styles.errorContainer,
                { transform: [{ translateX: inputFocusAnim }] }
              ]}
            >
              <Icon name="alert-circle" size={20} color={COLORS.error} />
              <Text style={styles.errorText}>{error}</Text>
            </Animated.View>
          )}

          {/* Forgot Password */}
          <TouchableOpacity style={styles.forgotPassword}>
            <Text style={styles.forgotPasswordText}>{t.auth.forgotPassword}</Text>
          </TouchableOpacity>

          {/* Login Button */}
          <Animated.View style={{ transform: [{ scale: buttonScale }] }}>
            <TouchableOpacity
              style={[styles.loginButton, loading && styles.loginButtonDisabled]}
              onPress={handleLogin}
              disabled={loading}
            >
              <LinearGradient
                colors={['#6366F1', '#8B5CF6']}
                style={styles.loginButtonGradient}
                start={{ x: 0, y: 0 }}
                end={{ x: 1, y: 0 }}
              >
                {loading ? (
                  <ActivityIndicator size="small" color="#FFF" />
                ) : (
                  <Icon name="login" size={20} color="#FFF" />
                )}
                <Text style={styles.loginButtonText}>
                  {loading ? t.loading : t.auth.loginButton}
                </Text>
              </LinearGradient>
            </TouchableOpacity>
          </Animated.View>

          {/* Demo Credentials */}
          <View style={styles.demoSection}>
            <Text style={styles.demoTitle}>Quick Access Demo Accounts</Text>
            
            <View style={styles.demoButtons}>
              <TouchableOpacity
                style={styles.demoButton}
                onPress={() => handleQuickFill('doctor@clinic.com', 'password')}
                disabled={loading}
              >
                <Icon name="stethoscope" size={16} color={COLORS.primary} />
                <Text style={styles.demoButtonText}>Clinical Doctor</Text>
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.demoButton}
                onPress={() => handleQuickFill('researcher@institute.edu', 'password')}
                disabled={loading}
              >
                <Icon name="microscope" size={16} color={COLORS.primary} />
                <Text style={styles.demoButtonText}>Researcher</Text>
              </TouchableOpacity>
            </View>
          </View>

          {/* Register Link */}
          <View style={styles.registerContainer}>
            <Text style={styles.registerText}>{t.auth.dontHaveAccount} </Text>
            <TouchableOpacity onPress={onNavigateToRegister} disabled={loading}>
              <Text style={styles.registerLink}>{t.auth.registerButton}</Text>
            </TouchableOpacity>
          </View>
        </Animated.View>

        {/* Security Footer */}
        <Animated.View
          style={[
            styles.footer,
            {
              opacity: fadeAnim,
            },
          ]}
        >
          <View style={styles.securityBadge}>
            <Icon name="shield-check" size={16} color={COLORS.success} />
            <Text style={styles.securityText}>HIPAA Compliant • Encrypted • Secure</Text>
          </View>
          <Text style={styles.footerText}>
            NeuroAssess Clinical System v2.1.4
          </Text>
        </Animated.View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  background: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: height * 0.4,
  },
  languageSelector: {
    position: 'absolute',
    top: Platform.OS === 'ios' ? 50 : 20,
    right: 20,
    zIndex: 1000,
  },
  scrollContainer: {
    flexGrow: 1,
    paddingHorizontal: SPACING.lg,
    paddingTop: Platform.OS === 'ios' ? 60 : 40,
  },
  header: {
    alignItems: 'center',
    marginBottom: SPACING.xxl,
  },
  logoContainer: {
    alignItems: 'center',
  },
  logoBackground: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.md,
    borderWidth: 2,
    borderColor: 'rgba(255,255,255,0.3)',
  },
  logoText: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFF',
    marginBottom: SPACING.xs,
    letterSpacing: -0.5,
  },
  logoSubtext: {
    fontSize: FONTS.sizes.md,
    color: 'rgba(255,255,255,0.8)',
    textAlign: 'center',
    fontWeight: '500',
  },
  formContainer: {
    backgroundColor: COLORS.surface,
    borderRadius: 24,
    padding: SPACING.xl,
    marginBottom: SPACING.xl,
    ...SHADOWS.large,
  },
  formHeader: {
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: COLORS.text,
    textAlign: 'center',
    marginBottom: SPACING.xs,
    letterSpacing: -0.5,
  },
  subtitle: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
  inputWrapper: {
    marginBottom: SPACING.lg,
  },
  label: {
    fontSize: FONTS.sizes.sm,
    fontWeight: '600',
    color: COLORS.text,
    marginBottom: SPACING.sm,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 12,
    backgroundColor: COLORS.background,
    paddingHorizontal: SPACING.md,
    minHeight: 50,
  },
  inputContainerFocused: {
    borderColor: COLORS.primary,
    backgroundColor: COLORS.surface,
    ...SHADOWS.small,
  },
  inputContainerError: {
    borderColor: COLORS.error,
  },
  input: {
    flex: 1,
    paddingVertical: SPACING.md,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    fontWeight: '500',
    minHeight: 45,
    outlineStyle: 'none',
  },
  inputWithContainer: {
    width: '100%',
    paddingVertical: SPACING.md,
    paddingHorizontal: SPACING.md,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    fontWeight: '500',
    minHeight: 50,
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 12,
    backgroundColor: COLORS.background,
    outlineStyle: 'none',
  },
  passwordInput: {
    flex: 1,
    paddingVertical: SPACING.md,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    fontWeight: '500',
    minHeight: 45,
    outlineStyle: 'none',
  },
  passwordWrapper: {
    position: 'relative',
    width: '100%',
  },
  passwordInputSimple: {
    width: '100%',
    paddingVertical: SPACING.md,
    paddingHorizontal: SPACING.md,
    paddingRight: 50,
    fontSize: FONTS.sizes.md,
    color: COLORS.text,
    fontWeight: '500',
    minHeight: 50,
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 12,
    backgroundColor: COLORS.background,
    outlineStyle: 'none',
  },
  eyeButtonAbsolute: {
    position: 'absolute',
    right: SPACING.md,
    top: '50%',
    transform: [{ translateY: -10 }],
    padding: SPACING.xs,
  },
  passwordActions: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  passwordAction: {
    padding: SPACING.xs,
    marginLeft: SPACING.xs,
  },
  clearButton: {
    padding: SPACING.xs,
  },
  errorContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.error + '10',
    padding: SPACING.md,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.error,
    marginBottom: SPACING.md,
  },
  errorText: {
    color: COLORS.error,
    fontSize: FONTS.sizes.sm,
    fontWeight: '500',
    marginLeft: SPACING.sm,
    flex: 1,
  },
  forgotPassword: {
    alignSelf: 'flex-end',
    marginBottom: SPACING.xl,
  },
  forgotPasswordText: {
    color: COLORS.primary,
    fontSize: FONTS.sizes.sm,
    fontWeight: '600',
  },
  loginButton: {
    borderRadius: 16,
    overflow: 'hidden',
    marginBottom: SPACING.lg,
    ...SHADOWS.medium,
  },
  loginButtonGradient: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: SPACING.lg,
    paddingHorizontal: SPACING.xl,
  },
  loginButtonDisabled: {
    opacity: 0.7,
  },
  loginButtonText: {
    color: '#FFF',
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    marginLeft: SPACING.sm,
  },
  demoSection: {
    backgroundColor: COLORS.background,
    padding: SPACING.lg,
    borderRadius: 16,
    marginBottom: SPACING.lg,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  demoTitle: {
    fontSize: FONTS.sizes.sm,
    fontWeight: '700',
    color: COLORS.text,
    marginBottom: SPACING.md,
    textAlign: 'center',
  },
  demoButtons: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: SPACING.md,
  },
  demoButton: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: COLORS.surface,
    paddingVertical: SPACING.sm,
    paddingHorizontal: SPACING.md,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: COLORS.border,
    ...SHADOWS.small,
  },
  demoButtonText: {
    color: COLORS.primary,
    fontSize: FONTS.sizes.sm,
    fontWeight: '600',
    marginLeft: SPACING.xs,
  },
  registerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  registerText: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
  },
  registerLink: {
    fontSize: FONTS.sizes.md,
    color: COLORS.primary,
    fontWeight: '700',
  },
  footer: {
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  securityBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: COLORS.success + '15',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 20,
    marginBottom: SPACING.md,
  },
  securityText: {
    color: COLORS.success,
    fontSize: FONTS.sizes.xs,
    fontWeight: '700',
    marginLeft: SPACING.xs,
    letterSpacing: 0.5,
  },
  footerText: {
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
});

export default LoginScreen;
