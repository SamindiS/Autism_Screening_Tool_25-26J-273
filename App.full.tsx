/**
 * Autism Screening App - Clinical Assessment System
 * Cognitive Flexibility & Rule-Switching Component
 * 
 * @format
 */

import React, { useEffect } from 'react';
import { StatusBar, useColorScheme, View, StyleSheet } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

// Context Providers
import { AuthProvider, useAuth } from './src/context/AuthContext';
import { AppProvider } from './src/context/AppContext';

// Services
import { storageService } from './src/services/storage';

// Screens
import LoginScreen from './src/screens/LoginScreen';
import MainDashboardScreen from './src/screens/MainDashboardScreen';
import AgeSelectionScreen from './src/screens/AgeSelectionScreen';
import GameScreen from './src/screens/GameScreen';
import ResultScreen from './src/screens/ResultScreen';

// Types
import { COLORS } from './src/constants';

const Stack = createStackNavigator();

function AppContent() {
  const { isAuthenticated, loading } = useAuth();

  useEffect(() => {
    // Initialize storage service
    storageService.initialize().catch(console.error);
  }, []);

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <StatusBar barStyle="light-content" backgroundColor={COLORS.primary} />
        {/* TODO: Add loading spinner */}
      </View>
    );
  }

  return (
    <NavigationContainer>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          cardStyle: { backgroundColor: COLORS.background },
        }}
      >
        {isAuthenticated ? (
          // Authenticated screens
          <>
            <Stack.Screen 
              name="MainDashboard" 
              component={MainDashboardScreen} 
            />
            <Stack.Screen 
              name="AgeSelection" 
              component={AgeSelectionScreen}
              options={{
                presentation: 'card',
                gestureEnabled: true,
              }}
            />
            <Stack.Screen 
              name="GameScreen" 
              component={GameScreen}
              options={{
                presentation: 'fullScreenModal',
                gestureEnabled: false,
              }}
            />
            <Stack.Screen 
              name="ResultScreen" 
              component={ResultScreen}
              options={{
                presentation: 'card',
                gestureEnabled: true,
              }}
            />
          </>
        ) : (
          // Unauthenticated screens
          <Stack.Screen 
            name="Login" 
            component={LoginScreen}
            options={{
              gestureEnabled: false,
            }}
          />
        )}
      </Stack.Navigator>
    </NavigationContainer>
  );
}

function App() {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <GestureHandlerRootView style={styles.container}>
      <SafeAreaProvider>
        <StatusBar 
          barStyle={isDarkMode ? 'light-content' : 'dark-content'} 
          backgroundColor={COLORS.primary}
        />
        <AuthProvider>
          <AppProvider>
            <AppContent />
          </AppProvider>
        </AuthProvider>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  loadingContainer: {
    flex: 1,
    backgroundColor: COLORS.primary,
    justifyContent: 'center',
    alignItems: 'center',
  },
});

export default App;
