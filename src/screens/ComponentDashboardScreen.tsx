/**
 * Component Dashboard Screen
 * Shows all 4 assessment components
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  Dimensions,
  StatusBar,
} from 'react-native';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';
import { COMPONENTS, COLORS, FONTS, SPACING, SHADOWS } from '../constants';
import LinearGradient from 'react-native-linear-gradient';

const { width } = Dimensions.get('window');
const CARD_WIDTH = (width - SPACING.lg * 3) / 2;

interface ComponentDashboardScreenProps {
  navigation: any;
}

const ComponentDashboardScreen: React.FC<ComponentDashboardScreenProps> = ({ navigation }) => {
  
  const handleComponentPress = (componentKey: string) => {
    // Navigate to specific component dashboard
    navigation.navigate('CognitiveDashboard', { componentKey });
  };

  const renderComponentCard = (key: string, index: number) => {
    const component = COMPONENTS[key as keyof typeof COMPONENTS];
    
    return (
      <TouchableOpacity
        key={key}
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
          <View style={styles.iconContainer}>
            <Icon name={component.icon} size={40} color="#FFF" />
          </View>
          
          <Text style={styles.componentName} numberOfLines={2}>
            {component.name}
          </Text>
          
          <Text style={styles.componentDescription} numberOfLines={2}>
            {component.description}
          </Text>
          
          <View style={styles.arrowContainer}>
            <Icon name="arrow-right-circle" size={24} color="#FFF" />
          </View>
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
          <Text style={styles.headerTitle}>Assessment Components</Text>
          <Text style={styles.headerSubtitle}>
            Select a component to begin assessment
          </Text>
        </View>
      </LinearGradient>

      {/* Component Cards */}
      <ScrollView
        style={styles.content}
        contentContainerStyle={styles.contentContainer}
        showsVerticalScrollIndicator={false}
      >
        <View style={styles.cardsGrid}>
          {Object.keys(COMPONENTS).map((key, index) => 
            renderComponentCard(key, index)
          )}
        </View>

        {/* Info Section */}
        <View style={styles.infoSection}>
          <View style={styles.infoCard}>
            <Icon name="information" size={24} color={COLORS.info} />
            <Text style={styles.infoText}>
              Each component assesses different aspects of child development.
              Choose the component based on clinical requirements.
            </Text>
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
    marginTop: SPACING.sm,
  },
  headerTitle: {
    fontSize: 28,
    fontWeight: '800',
    color: '#FFF',
    marginBottom: SPACING.xs,
  },
  headerSubtitle: {
    fontSize: FONTS.sizes.md,
    color: 'rgba(255,255,255,0.9)',
  },
  content: {
    flex: 1,
  },
  contentContainer: {
    padding: SPACING.lg,
  },
  cardsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginBottom: SPACING.xl,
  },
  componentCard: {
    width: CARD_WIDTH,
    height: 220,
    marginBottom: SPACING.lg,
    borderRadius: 20,
    overflow: 'hidden',
    ...SHADOWS.large,
  },
  cardGradient: {
    flex: 1,
    padding: SPACING.lg,
    justifyContent: 'space-between',
  },
  iconContainer: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(255,255,255,0.2)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  componentName: {
    fontSize: FONTS.sizes.lg,
    fontWeight: '700',
    color: '#FFF',
    marginTop: SPACING.md,
  },
  componentDescription: {
    fontSize: FONTS.sizes.sm,
    color: 'rgba(255,255,255,0.9)',
    lineHeight: 18,
  },
  arrowContainer: {
    alignSelf: 'flex-end',
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
  infoText: {
    flex: 1,
    fontSize: FONTS.sizes.sm,
    color: COLORS.textSecondary,
    marginLeft: SPACING.md,
    lineHeight: 20,
  },
});

export default ComponentDashboardScreen;

