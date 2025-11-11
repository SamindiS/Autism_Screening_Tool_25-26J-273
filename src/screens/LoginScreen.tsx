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
  Easing,
  SafeAreaView,
  Image,
} from 'react-native';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import { COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import LinearGradient from 'react-native-linear-gradient';
import LanguageSelector from '../components/LanguageSelector';

const CropLogo = require('../assets/images/CropLogo.jpg');

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

  // Advanced Animation refs
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const slideUpAnim = useRef(new Animated.Value(50)).current;
  const logoScale = useRef(new Animated.Value(0.8)).current;
  const buttonScale = useRef(new Animated.Value(1)).current;
  const inputFocusAnim = useRef(new Animated.Value(0)).current;
  const backgroundAnim = useRef(new Animated.Value(0)).current;
  const formSlideAnim = useRef(new Animated.Value(30)).current;

  // Particle animations
  const particles = useRef(
    Array.from({ length: 8 }, () => ({
      translateX: new Animated.Value(0),
      translateY: new Animated.Value(0),
      opacity: new Animated.Value(0),
      scale: new Animated.Value(0),
    }))
  ).current;

  useEffect(() => {
    startEntranceAnimations();
    startParticleAnimations();
  }, []);

  const startEntranceAnimations = () => {
    // Background gradient animation
    Animated.timing(backgroundAnim, {
      toValue: 1,
      duration: 2000,
      easing: Easing.bezier(0.4, 0, 0.2, 1),
      useNativeDriver: false,
    }).start();

    // Main content animations
    Animated.parallel([
      Animated.timing(fadeAnim, {
        toValue: 1,
        duration: 1000,
        useNativeDriver: true,
      }),
      Animated.spring(slideUpAnim, {
        toValue: 0,
        tension: 60,
        friction: 8,
        useNativeDriver: true,
      }),
      Animated.spring(logoScale, {
        toValue: 1,
        tension: 80,
        friction: 6,
        useNativeDriver: true,
      }),
      Animated.spring(formSlideAnim, {
        toValue: 0,
        tension: 70,
        friction: 7,
        useNativeDriver: true,
      }),
    ]).start();
  };

  const startParticleAnimations = () => {
    particles.forEach((particle, index) => {
      Animated.sequence([
        Animated.delay(index * 200),
        Animated.parallel([
          Animated.timing(particle.opacity, {
            toValue: 0.6,
            duration: 800,
            useNativeDriver: true,
          }),
          Animated.spring(particle.scale, {
            toValue: 1,
            tension: 40,
            friction: 5,
            useNativeDriver: true,
          }),
          Animated.timing(particle.translateY, {
            toValue: -Math.random() * 100 - 50,
            duration: 3000 + Math.random() * 2000,
            useNativeDriver: true,
          }),
          Animated.timing(particle.translateX, {
            toValue: (Math.random() - 0.5) * 100,
            duration: 2000 + Math.random() * 2000,
            useNativeDriver: true,
          }),
        ]),
      ]).start();
    });
  };

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) {
      showInputError(t.errors.required || 'All fields are required');
      return;
    }

    if (!isValidEmail(email)) {
      showInputError(t.errors.emailInvalid || 'Invalid email format');
      return;
    }

    try {
      clearError();
      
      // Enhanced button press animation
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
    } catch (error: any) {
      showInputError(error?.message || t.errors.loginFailed || 'Login failed');
    }
  };

  const showInputError = (message: string) => {
    Alert.alert(t.errors.invalidInput || 'Invalid Input', message);
    
    // Enhanced error shake animation
    Animated.sequence([
      Animated.timing(inputFocusAnim, { toValue: 8, duration: 60, useNativeDriver: true }),
      Animated.timing(inputFocusAnim, { toValue: -8, duration: 60, useNativeDriver: true }),
      Animated.timing(inputFocusAnim, { toValue: 6, duration: 60, useNativeDriver: true }),
      Animated.timing(inputFocusAnim, { toValue: -6, duration: 60, useNativeDriver: true }),
      Animated.timing(inputFocusAnim, { toValue: 0, duration: 60, useNativeDriver: true }),
    ]).start();
  };

  const isValidEmail = (email: string) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const handleFocus = (field: 'email' | 'password') => {
    setIsFocused(prev => ({ ...prev, [field]: true }));
    // Input focus animation
    Animated.timing(inputFocusAnim, {
      toValue: 1,
      duration: 200,
      useNativeDriver: true,
    }).start();
  };

  const handleBlur = (field: 'email' | 'password') => {
    setIsFocused(prev => ({ ...prev, [field]: false }));
    Animated.timing(inputFocusAnim, {
      toValue: 0,
      duration: 200,
      useNativeDriver: true,
    }).start();
  };

  const handleQuickFill = (demoEmail: string, demoPassword: string) => {
    setEmail(demoEmail);
    setPassword(demoPassword);
    clearError();
    
    // Quick fill animation
    Animated.sequence([
      Animated.timing(buttonScale, {
        toValue: 1.05,
        duration: 100,
        useNativeDriver: true,
      }),
      Animated.timing(buttonScale, {
        toValue: 1,
        duration: 100,
        useNativeDriver: true,
      }),
    ]).start();
  };

  // Background gradient interpolation
  const backgroundInterpolate = backgroundAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['#6366F1', '#8B5CF6'],
  });

  const AnimatedLinearGradient = Animated.createAnimatedComponent(LinearGradient);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="light-content" backgroundColor="#6366F1" translucent />
      
      {/* Animated Background */}
      <AnimatedLinearGradient
        colors={['#6366F1', '#8B5CF6', '#A855F7']}
        style={[
          styles.background,
          {
            backgroundColor: backgroundInterpolate,
          },
        ]}
        start={{ x: 0, y: 0 }}
        end={{ x: 1, y: 1 }}
      >
        {/* Floating Particles */}
        {particles.map((particle, index) => (
          <Animated.View
            key={index}
            style={[
              styles.particle,
              {
                opacity: particle.opacity,
                transform: [
                  { translateX: particle.translateX },
                  { translateY: particle.translateY },
                  { scale: particle.scale },
                ],
                left: `${(index * 12.5) % 100}%`,
                top: `${20 + (index * 10) % 60}%`,
              },
            ]}
          />
        ))}
        
        {/* Background Pattern */}
        <View style={styles.backgroundPattern}>
          <View style={[styles.circle, styles.circle1]} />
          <View style={[styles.circle, styles.circle2]} />
          <View style={[styles.circle, styles.circle3]} />
        </View>
      </AnimatedLinearGradient>

      {/* Language Selector */}
      <Animated.View 
        style={[
          styles.languageSelector,
          {
            opacity: fadeAnim,
            transform: [{ translateY: slideUpAnim }],
          },
        ]}
      >
        <LanguageSelector />
      </Animated.View>

      <KeyboardAvoidingView 
        style={styles.keyboardAvoid}
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      >
        <ScrollView 
          contentContainerStyle={styles.scrollContainer}
          showsVerticalScrollIndicator={false}
          keyboardShouldPersistTaps="handled"
        >
          {/* Header Section */}
          <Animated.View
            style={[
              styles.header,
              {
                opacity: fadeAnim,
                transform: [{ translateY: slideUpAnim }],
              },
            ]}
          >
            <Animated.View 
              style={[
                styles.logoContainer,
                { transform: [{ scale: logoScale }] }
              ]}
            >
              <View style={styles.logoWrapper}>
                <LinearGradient
                  colors={['rgba(255,255,255,0.2)', 'rgba(255,255,255,0.1)']}
                  style={styles.logoGlow}
                />
                <View style={styles.logoBackground}>
                  <Image 
                    source={CropLogo} 
                    style={styles.logoImage}
                    resizeMode="contain"
                  />
                  <View style={styles.logoPulse} />
                </View>
              </View>
              <Text style={styles.logoText}>SenseAI</Text>
              <Text style={styles.logoSubtext}>Clinical Autism Screening Platform</Text>
            </Animated.View>
          </Animated.View>

          {/* Form Section */}
          <Animated.View
            style={[
              styles.formContainer,
              {
                opacity: fadeAnim,
                transform: [{ translateY: formSlideAnim }],
              },
            ]}
          >
            {/* Form Header */}
            <View style={styles.formHeader}>
              <Text style={styles.welcomeText}>{t.auth?.welcomeBack || 'Welcome Back'}</Text>
              <Text style={styles.formTitle}>{t.auth?.clinicalAccess || 'Clinical Portal Access'}</Text>
              <View style={styles.formDivider} />
            </View>

            {/* Email Input */}
            <View style={styles.inputSection}>
              <View style={styles.inputLabelRow}>
                <Icon name="email-outline" size={18} color={COLORS.primary} />
                <Text style={styles.inputLabel}>{t.auth?.email || 'Professional Email'}</Text>
              </View>
              <View 
                style={[
                  styles.inputContainer,
                  isFocused.email && styles.inputContainerFocused,
                  error && styles.inputContainerError,
                ]}
              >
                <TextInput
                  style={styles.input}
                  value={email}
                  onChangeText={setEmail}
                  placeholder={t.auth?.emailPlaceholder || "your.name@healthcare.org"}
                  placeholderTextColor={COLORS.textSecondary + '80'}
                  keyboardType="email-address"
                  autoCapitalize="none"
                  autoCorrect={false}
                  textContentType="emailAddress"
                  underlineColorAndroid="transparent"
                  returnKeyType="next"
                  onFocus={() => handleFocus('email')}
                  onBlur={() => handleBlur('email')}
                  editable={true}
                />
                {email.length > 0 && (
                  <TouchableOpacity
                    style={styles.clearButton}
                    onPress={() => setEmail('')}
                    disabled={loading}
                  >
                    <Icon name="close-circle" size={20} color={COLORS.textSecondary} />
                  </TouchableOpacity>
                )}
              </View>
            </View>

            {/* Password Input */}
            <View style={styles.inputSection}>
              <View style={styles.inputLabelRow}>
                <Icon name="lock-outline" size={18} color={COLORS.primary} />
                <Text style={styles.inputLabel}>{t.auth?.password || 'Secure Password'}</Text>
              </View>
              <View 
                style={[
                  styles.inputContainer,
                  error && styles.inputContainerError,
                ]}
              >
                <TextInput
                  style={[styles.input, styles.passwordInput]}
                  value={password}
                  onChangeText={setPassword}
                  placeholder="••••••••••••"
                  placeholderTextColor={COLORS.textSecondary + '80'}
                  secureTextEntry={!showPassword}
                  autoCapitalize="none"
                  autoCorrect={false}
                  underlineColorAndroid="transparent"
                  returnKeyType="done"
                  editable={true}
                  onSubmitEditing={handleLogin}
                  blurOnSubmit={false}
                  selectTextOnFocus={false}
                />
                <View style={styles.passwordActions} pointerEvents="box-none">
                  {password.length > 0 && (
                    <TouchableOpacity
                      style={styles.passwordAction}
                      onPress={() => setPassword('')}
                      disabled={loading}
                    >
                      <Icon name="close-circle" size={20} color={COLORS.textSecondary} />
                    </TouchableOpacity>
                  )}
                  <TouchableOpacity
                    style={styles.passwordAction}
                    onPress={() => setShowPassword(!showPassword)}
                    disabled={loading}
                  >
                    <Icon 
                      name={showPassword ? 'eye-off-outline' : 'eye-outline'} 
                      size={20} 
                      color={COLORS.primary} 
                    />
                  </TouchableOpacity>
                </View>
              </View>
            </View>

            {/* Error Message */}
            {error && (
              <View style={styles.errorContainer}>
                <View style={styles.errorIcon}>
                  <Icon name="alert-rhombus" size={20} color="#FFF" />
                </View>
                <Text style={styles.errorText}>{error}</Text>
                <TouchableOpacity onPress={clearError}>
                  <Icon name="close" size={16} color="#FFF" />
                </TouchableOpacity>
              </View>
            )}

            {/* Action Buttons */}
            <View style={styles.actionsRow}>
              <TouchableOpacity style={styles.forgotPassword}>
                <Text style={styles.forgotPasswordText}>{t.auth?.forgotPassword || 'Recover Access'}</Text>
              </TouchableOpacity>
              
              <TouchableOpacity style={styles.rememberMe}>
                <View style={styles.checkbox}>
                  <Icon name="check" size={14} color="#FFF" />
                </View>
                <Text style={styles.rememberMeText}>{t.auth?.rememberMe || 'Remember Device'}</Text>
              </TouchableOpacity>
            </View>

            {/* Login Button */}
            <Animated.View style={{ transform: [{ scale: buttonScale }] }}>
              <TouchableOpacity
                style={[styles.loginButton, loading && styles.loginButtonDisabled]}
                onPress={handleLogin}
                disabled={loading}
                activeOpacity={0.9}
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
                    <Icon name="fingerprint" size={22} color="#FFF" />
                  )}
                  <Text style={styles.loginButtonText}>
                    {loading ? (t.auth?.authenticating || 'Authenticating...') : (t.auth?.login || 'Secure Login')}
                  </Text>
                  {!loading && <Icon name="chevron-right" size={20} color="#FFF" />}
                </LinearGradient>
              </TouchableOpacity>
            </Animated.View>

            {/* Demo Access Section */}
            <View style={styles.demoSection}>
              <View style={styles.demoHeader}>
                <Icon name="rocket-launch" size={18} color={COLORS.primary} />
                <Text style={styles.demoTitle}>{t.auth?.quickAccess || 'Quick Clinical Access'}</Text>
              </View>
              
              <View style={styles.demoGrid}>
                <TouchableOpacity
                  style={styles.demoCard}
                  onPress={() => handleQuickFill('clinician@hospital.org', 'Demo123!')}
                  disabled={loading}
                >
                  <LinearGradient
                    colors={['#F0F9FF', '#E0F2FE']}
                    style={styles.demoCardGradient}
                  >
                    <View style={[styles.demoIcon, { backgroundColor: '#0EA5E9' }]}>
                      <Icon name="stethoscope" size={20} color="#FFF" />
                    </View>
                    <Text style={styles.demoRole}>{t.auth?.clinician || 'Clinical Specialist'}</Text>
                    <Text style={styles.demoHospital}>{t.auth?.hospital || "Children's Hospital"}</Text>
                  </LinearGradient>
                </TouchableOpacity>

                <TouchableOpacity
                  style={styles.demoCard}
                  onPress={() => handleQuickFill('research@center.edu', 'Demo123!')}
                  disabled={loading}
                >
                  <LinearGradient
                    colors={['#F0FDF4', '#DCFCE7']}
                    style={styles.demoCardGradient}
                  >
                    <View style={[styles.demoIcon, { backgroundColor: '#16A34A' }]}>
                      <Icon name="microscope" size={20} color="#FFF" />
                    </View>
                    <Text style={styles.demoRole}>{t.auth?.researcher || 'Research Fellow'}</Text>
                    <Text style={styles.demoHospital}>{t.auth?.researchCenter || 'Autism Research Center'}</Text>
                  </LinearGradient>
                </TouchableOpacity>
              </View>
            </View>

            {/* Registration Link */}
            <View style={styles.registerContainer}>
              <Text style={styles.registerText}>{t.auth?.newUser || 'New to SenseAI?'} </Text>
              <TouchableOpacity onPress={onNavigateToRegister} disabled={loading}>
                <LinearGradient
                  colors={['#6366F1', '#8B5CF6']}
                  style={styles.registerButton}
                >
                  <Text style={styles.registerLink}>{t.auth?.requestAccess || 'Request Access'}</Text>
                  <Icon name="arrow-right" size={16} color="#FFF" />
                </LinearGradient>
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
            <View style={styles.securitySection}>
              <View style={styles.securityBadges}>
                <View style={styles.securityBadge}>
                  <Icon name="shield-check" size={14} color={COLORS.success} />
                  <Text style={styles.securityText}>HIPAA Compliant</Text>
                </View>
                <View style={styles.securityBadge}>
                  <Icon name="encryption" size={14} color={COLORS.success} />
                  <Text style={styles.securityText}>End-to-End Encrypted</Text>
                </View>
                <View style={styles.securityBadge}>
                  <Icon name="medical-bag" size={14} color={COLORS.success} />
                  <Text style={styles.securityText}>CLIA Certified</Text>
                </View>
              </View>
              
              <Text style={styles.footerText}>
                SenseAI Clinical System v2.4.1 • © 2024 SenseAI Labs
              </Text>
            </View>
          </Animated.View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  keyboardAvoid: {
    flex: 1,
  },
  background: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  backgroundPattern: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
  },
  circle: {
    position: 'absolute',
    borderRadius: 500,
    backgroundColor: 'rgba(255, 255, 255, 0.03)',
  },
  circle1: {
    width: 400,
    height: 400,
    top: -100,
    right: -100,
  },
  circle2: {
    width: 300,
    height: 300,
    bottom: -50,
    left: -50,
  },
  circle3: {
    width: 200,
    height: 200,
    top: '30%',
    left: '60%',
  },
  particle: {
    position: 'absolute',
    width: 6,
    height: 6,
    borderRadius: 3,
    backgroundColor: 'rgba(255, 255, 255, 0.4)',
  },
  languageSelector: {
    position: 'absolute',
    top: Platform.OS === 'ios' ? 60 : 30,
    right: 20,
    zIndex: 1000,
  },
  scrollContainer: {
    flexGrow: 1,
    paddingHorizontal: SPACING.lg,
    paddingTop: Platform.OS === 'ios' ? 100 : 80,
    paddingBottom: SPACING.xl,
  },
  header: {
    alignItems: 'center',
    marginBottom: SPACING.xxl,
  },
  logoContainer: {
    alignItems: 'center',
  },
  logoWrapper: {
    position: 'relative',
    marginBottom: SPACING.lg,
  },
  logoGlow: {
    position: 'absolute',
    width: 120,
    height: 120,
    borderRadius: 60,
    top: -20,
    left: -20,
  },
  logoBackground: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    justifyContent: 'center',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.3)',
    overflow: 'hidden',
  },
  logoImage: {
    width: 70,
    height: 70,
    borderRadius: 35,
  },
  logoPulse: {
    position: 'absolute',
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
  },
  logoText: {
    fontSize: 32,
    fontWeight: '800',
    color: '#FFF',
    marginBottom: SPACING.xs,
    letterSpacing: -0.5,
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 3,
  },
  logoSubtext: {
    fontSize: FONTS.sizes.md,
    color: 'rgba(255, 255, 255, 0.9)',
    textAlign: 'center',
    fontWeight: '500',
    letterSpacing: 0.5,
  },
  formContainer: {
    backgroundColor: COLORS.surface,
    borderRadius: 28,
    padding: SPACING.xl,
    marginBottom: SPACING.xl,
    ...SHADOWS.large,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  formHeader: {
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  welcomeText: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '600',
    color: COLORS.textSecondary,
    marginBottom: SPACING.xs,
  },
  formTitle: {
    fontSize: 24,
    fontWeight: '700',
    color: COLORS.text,
    textAlign: 'center',
    marginBottom: SPACING.md,
    letterSpacing: -0.5,
  },
  formDivider: {
    width: 60,
    height: 4,
    backgroundColor: COLORS.primary,
    borderRadius: 2,
    opacity: 0.6,
  },
  inputSection: {
    marginBottom: SPACING.lg,
  },
  inputLabelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: SPACING.sm,
  },
  inputLabel: {
    fontSize: FONTS.sizes.sm,
    fontWeight: '600',
    color: COLORS.text,
    marginLeft: SPACING.xs,
  },
  inputContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 16,
    backgroundColor: COLORS.background,
    paddingHorizontal: SPACING.md,
    height: 60,
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
    height: 50,
  },
  passwordInput: {
    paddingRight: 80, // More space for the action buttons
  },
  passwordActions: {
    position: 'absolute',
    right: 0,
    top: 0,
    bottom: 0,
    flexDirection: 'row',
    alignItems: 'center',
    paddingRight: SPACING.md,
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
    backgroundColor: COLORS.error,
    padding: SPACING.md,
    borderRadius: 12,
    marginBottom: SPACING.md,
  },
  errorIcon: {
    marginRight: SPACING.sm,
  },
  errorText: {
    color: '#FFF',
    fontSize: FONTS.sizes.sm,
    fontWeight: '500',
    flex: 1,
  },
  actionsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  forgotPassword: {
    padding: SPACING.xs,
  },
  forgotPasswordText: {
    color: COLORS.primary,
    fontSize: FONTS.sizes.sm,
    fontWeight: '600',
  },
  rememberMe: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  checkbox: {
    width: 18,
    height: 18,
    borderRadius: 4,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: SPACING.xs,
  },
  rememberMeText: {
    color: COLORS.textSecondary,
    fontSize: FONTS.sizes.sm,
    fontWeight: '500',
  },
  loginButton: {
    borderRadius: 20,
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
    marginHorizontal: SPACING.sm,
  },
  demoSection: {
    backgroundColor: COLORS.background,
    padding: SPACING.lg,
    borderRadius: 20,
    marginBottom: SPACING.lg,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  demoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING.md,
  },
  demoTitle: {
    fontSize: FONTS.sizes.md,
    fontWeight: '700',
    color: COLORS.text,
    marginLeft: SPACING.xs,
  },
  demoGrid: {
    flexDirection: 'row',
    gap: SPACING.md,
  },
  demoCard: {
    flex: 1,
    borderRadius: 16,
    overflow: 'hidden',
    ...SHADOWS.small,
  },
  demoCardGradient: {
    padding: SPACING.lg,
    alignItems: 'center',
  },
  demoIcon: {
    width: 48,
    height: 48,
    borderRadius: 24,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: SPACING.sm,
  },
  demoRole: {
    fontSize: FONTS.sizes.sm,
    fontWeight: '700',
    color: COLORS.text,
    textAlign: 'center',
    marginBottom: 2,
  },
  demoHospital: {
    fontSize: FONTS.sizes.xs,
    color: COLORS.textSecondary,
    textAlign: 'center',
  },
  registerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    flexWrap: 'wrap',
  },
  registerText: {
    fontSize: FONTS.sizes.md,
    color: COLORS.textSecondary,
    marginRight: SPACING.sm,
  },
  registerButton: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: SPACING.xs,
    paddingHorizontal: SPACING.md,
    borderRadius: 20,
  },
  registerLink: {
    fontSize: FONTS.sizes.md,
    color: '#FFF',
    fontWeight: '700',
    marginRight: SPACING.xs,
  },
  footer: {
    alignItems: 'center',
  },
  securitySection: {
    alignItems: 'center',
  },
  securityBadges: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: SPACING.md,
    marginBottom: SPACING.md,
  },
  securityBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(16, 185, 129, 0.1)',
    paddingHorizontal: SPACING.md,
    paddingVertical: SPACING.sm,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: 'rgba(16, 185, 129, 0.2)',
  },
  securityText: {
    color: COLORS.success,
    fontSize: FONTS.sizes.xs,
    fontWeight: '600',
    marginLeft: SPACING.xs,
    letterSpacing: 0.3,
  },
  footerText: {
    fontSize: FONTS.sizes.xs,
    color: 'rgba(255, 255, 255, 0.7)',
    textAlign: 'center',
  },
});

export default LoginScreen;
