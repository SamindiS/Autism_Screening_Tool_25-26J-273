import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Animated,
  Dimensions,
  StatusBar,
  Image,
  Easing,
} from 'react-native';
import { COLORS, FONTS, SPACING } from '../constants';

const { width, height } = Dimensions.get('window');

interface SplashScreenProps {
  onFinish: () => void;
}

const SplashScreen: React.FC<SplashScreenProps> = ({ onFinish }) => {
  // Main animation values
  const fadeAnim = useRef(new Animated.Value(0)).current;
  const logoScale = useRef(new Animated.Value(0)).current;
  const logoRotate = useRef(new Animated.Value(0)).current;
  const textSlide = useRef(new Animated.Value(50)).current;
  const gradientAnim = useRef(new Animated.Value(0)).current;
  const particleAnim = useRef(new Animated.Value(0)).current;
  
  // Particle animations
  const particles = useRef(
    Array.from({ length: 12 }, () => ({
      scale: new Animated.Value(0),
      opacity: new Animated.Value(0),
      translateX: new Animated.Value(0),
      translateY: new Animated.Value(0),
    }))
  ).current;

  // Background gradient animation
  const backgroundInterpolate = gradientAnim.interpolate({
    inputRange: [0, 1],
    outputRange: ['#1E3A8A', '#6366F1'],
  });

  // Logo rotation interpolation
  const logoRotateInterpolate = logoRotate.interpolate({
    inputRange: [0, 1],
    outputRange: ['0deg', '360deg'],
  });

  useEffect(() => {
    const startAnimations = () => {
      // Background color transition
      Animated.timing(gradientAnim, {
        toValue: 1,
        duration: 2000,
        easing: Easing.bezier(0.4, 0, 0.2, 1),
        useNativeDriver: false,
      }).start();

      // Logo entrance with spring and rotation
      Animated.parallel([
        Animated.spring(logoScale, {
          toValue: 1,
          tension: 100,
          friction: 8,
          useNativeDriver: true,
        }),
        Animated.timing(logoRotate, {
          toValue: 1,
          duration: 3000,
          easing: Easing.elastic(1.2),
          useNativeDriver: true,
        }),
        Animated.timing(fadeAnim, {
          toValue: 1,
          duration: 1000,
          useNativeDriver: true,
        }),
      ]).start(() => {
        // Start particle animations after logo entrance
        animateParticles();
      });

      // Text slide up
      Animated.timing(textSlide, {
        toValue: 0,
        duration: 1200,
        easing: Easing.out(Easing.back(1.2)),
        useNativeDriver: true,
      }).start();
    };

    const animateParticles = () => {
      particles.forEach((particle, index) => {
        const angle = (index / particles.length) * Math.PI * 2;
        const distance = 120 + Math.random() * 80;
        
        Animated.sequence([
          Animated.delay(index * 100),
          Animated.parallel([
            Animated.spring(particle.scale, {
              toValue: 0.6 + Math.random() * 0.4,
              tension: 50,
              friction: 5,
              useNativeDriver: true,
            }),
            Animated.timing(particle.opacity, {
              toValue: 0.8,
              duration: 600,
              useNativeDriver: true,
            }),
            Animated.timing(particle.translateX, {
              toValue: Math.cos(angle) * distance,
              duration: 800,
              easing: Easing.out(Easing.back(1)),
              useNativeDriver: true,
            }),
            Animated.timing(particle.translateY, {
              toValue: Math.sin(angle) * distance,
              duration: 800,
              easing: Easing.out(Easing.back(1)),
              useNativeDriver: true,
            }),
          ]),
        ]).start();
      });

      // Start particle pulse animation
      Animated.timing(particleAnim, {
        toValue: 1,
        duration: 1500,
        useNativeDriver: true,
      }).start();
    };

    const exitAnimations = () => {
      // Particle exit
      particles.forEach((particle, index) => {
        Animated.sequence([
          Animated.delay(index * 50),
          Animated.parallel([
            Animated.timing(particle.opacity, {
              toValue: 0,
              duration: 300,
              useNativeDriver: true,
            }),
            Animated.timing(particle.scale, {
              toValue: 0,
              duration: 300,
              useNativeDriver: true,
            }),
          ]),
        ]).start();
      });

      // Main content exit
      Animated.parallel([
        Animated.timing(fadeAnim, {
          toValue: 0,
          duration: 600,
          useNativeDriver: true,
        }),
        Animated.timing(logoScale, {
          toValue: 1.2,
          duration: 600,
          useNativeDriver: true,
        }),
        Animated.timing(textSlide, {
          toValue: -50,
          duration: 600,
          useNativeDriver: true,
        }),
      ]).start(() => {
        onFinish();
      });
    };

    startAnimations();

    // Auto-finish after 4 seconds
    const timer = setTimeout(() => {
      exitAnimations();
    }, 4000);

    return () => {
      clearTimeout(timer);
    };
  }, [onFinish]);

  // Particle colors
  const particleColors = [
    '#60A5FA', '#3B82F6', '#2563EB', '#1D4ED8', '#6366F1', '#8B5CF6'
  ];

  return (
    <Animated.View 
      style={[
        styles.container,
        { backgroundColor: backgroundInterpolate }
      ]}
    >
      <StatusBar 
        barStyle="light-content" 
        backgroundColor="transparent" 
        translucent 
      />
      
      {/* Animated Background Elements */}
      <View style={styles.backgroundElements}>
        <View style={[styles.circle, styles.circle1]} />
        <View style={[styles.circle, styles.circle2]} />
        <View style={[styles.circle, styles.circle3]} />
      </View>

      {/* Floating Particles */}
      {particles.map((particle, index) => {
        const color = particleColors[index % particleColors.length];
        const pulse = particleAnim.interpolate({
          inputRange: [0, 0.5, 1],
          outputRange: [1, 1.2, 1],
        });

        return (
          <Animated.View
            key={index}
            style={[
              styles.particle,
              {
                backgroundColor: color,
                opacity: particle.opacity,
                transform: [
                  { scale: Animated.multiply(particle.scale, pulse) },
                  { translateX: particle.translateX },
                  { translateY: particle.translateY },
                ],
              },
            ]}
          />
        );
      })}

      <Animated.View
        style={[
          styles.content,
          {
            opacity: fadeAnim,
          },
        ]}
      >
        {/* Logo Container with Enhanced Effects */}
        <View style={styles.logoWrapper}>
          <Animated.View
            style={[
              styles.logoGlow,
              {
                opacity: fadeAnim,
                transform: [{ scale: logoScale }],
              },
            ]}
          />
          
          <Animated.View
            style={[
              styles.logoContainer,
              {
                transform: [
                  { scale: logoScale },
                  { rotate: logoRotateInterpolate },
                ],
              },
            ]}
          >
            <Image
              source={require('../assets/images/Logo.jpg')}
              style={styles.logoImage}
              resizeMode="contain"
            />
            
            {/* Logo Border Effect */}
            <Animated.View style={[styles.logoBorder, { opacity: fadeAnim }]} />
          </Animated.View>
        </View>

        {/* Text Content */}
        <Animated.View
          style={[
            styles.textContainer,
            {
              transform: [{ translateY: textSlide }],
            },
          ]}
        >
          <Text style={styles.appName}>SenseAI</Text>
          <Text style={styles.tagline}>
            Multi-Sensory Behavioral Autism Detection System
          </Text>
          
          {/* Enhanced Loading Indicator */}
          <Animated.View style={[styles.loadingContainer, { opacity: fadeAnim }]}>
            <View style={styles.loadingBar}>
              <Animated.View 
                style={[
                  styles.loadingProgress,
                  {
                    transform: [{
                      scaleX: particleAnim.interpolate({
                        inputRange: [0, 1],
                        outputRange: [0, 1],
                      })
                    }]
                  }
                ]} 
              />
            </View>
            <Text style={styles.loadingText}>Initializing Intelligence...</Text>
          </Animated.View>
        </Animated.View>

        {/* Version Info */}
        <Animated.View 
          style={[
            styles.versionContainer,
            { opacity: fadeAnim }
          ]}
        >
          <Text style={styles.versionText}>v1.0.0</Text>
          <Text style={styles.copyrightText}>© 2024 SenseAI Labs</Text>
        </Animated.View>
      </Animated.View>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    overflow: 'hidden',
  },
  backgroundElements: {
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
    width: 600,
    height: 600,
    top: -200,
    right: -200,
  },
  circle2: {
    width: 400,
    height: 400,
    bottom: -100,
    left: -100,
  },
  circle3: {
    width: 300,
    height: 300,
    top: '30%',
    left: '20%',
  },
  particle: {
    position: 'absolute',
    width: 12,
    height: 12,
    borderRadius: 6,
    backgroundColor: '#60A5FA',
  },
  content: {
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
    zIndex: 10,
  },
  logoWrapper: {
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: SPACING.xxl,
    position: 'relative',
  },
  logoGlow: {
    position: 'absolute',
    width: 240,
    height: 240,
    borderRadius: 120,
    backgroundColor: 'rgba(255, 255, 255, 0.1)',
    shadowColor: '#3B82F6',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 40,
    elevation: 20,
  },
  logoContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    position: 'relative',
  },
  logoImage: {
    width: 180,
    height: 180,
    borderRadius: 25,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 12,
    },
    shadowOpacity: 0.3,
    shadowRadius: 20,
    elevation: 16,
    borderWidth: 3,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  logoBorder: {
    position: 'absolute',
    width: 200,
    height: 200,
    borderRadius: 30,
    borderWidth: 2,
    borderColor: 'rgba(255, 255, 255, 0.2)',
  },
  textContainer: {
    alignItems: 'center',
    marginBottom: SPACING.xl,
  },
  appName: {
    fontSize: 48,
    fontWeight: '800',
    color: '#FFFFFF',
    marginBottom: SPACING.md,
    letterSpacing: -0.5,
    textShadowColor: 'rgba(0, 0, 0, 0.2)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 8,
    fontFamily: 'System', // Consider using a custom font like 'Inter-Black'
  },
  tagline: {
    fontSize: 16,
    color: 'rgba(255, 255, 255, 0.9)',
    textAlign: 'center',
    lineHeight: 22,
    paddingHorizontal: SPACING.xl,
    fontWeight: '500',
    letterSpacing: 0.3,
    maxWidth: 300,
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 4,
  },
  loadingContainer: {
    marginTop: SPACING.xl,
    alignItems: 'center',
  },
  loadingBar: {
    width: 200,
    height: 4,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 2,
    overflow: 'hidden',
    marginBottom: SPACING.md,
  },
  loadingProgress: {
    height: '100%',
    backgroundColor: '#FFFFFF',
    borderRadius: 2,
    transformOrigin: 'left',
  },
  loadingText: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.7)',
    fontWeight: '500',
    letterSpacing: 0.5,
  },
  versionContainer: {
    position: 'absolute',
    bottom: SPACING.xl,
    alignItems: 'center',
  },
  versionText: {
    fontSize: 12,
    color: 'rgba(255, 255, 255, 0.5)',
    marginBottom: 2,
  },
  copyrightText: {
    fontSize: 10,
    color: 'rgba(255, 255, 255, 0.4)',
  },
});

export default SplashScreen;