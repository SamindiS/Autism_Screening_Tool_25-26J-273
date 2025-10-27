/**
 * Autism Screening App - Simple Version
 * This is a simplified version for initial testing
 * 
 * @format
 */

import React from 'react';
import { StatusBar, useColorScheme, View, StyleSheet, Text } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';

function App() {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <SafeAreaProvider>
      <StatusBar 
        barStyle={isDarkMode ? 'light-content' : 'dark-content'} 
        backgroundColor="#2E86AB"
      />
      <View style={styles.container}>
        <Text style={styles.title}>🧠 Autism Screening App</Text>
        <Text style={styles.subtitle}>Clinical Assessment System</Text>
        <Text style={styles.description}>
          Cognitive Flexibility & Rule-Switching Component
        </Text>
        <Text style={styles.status}>
          ✅ Core system ready for development
        </Text>
      </View>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F5F5F5',
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#2E86AB',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 18,
    color: '#A23B72',
    marginBottom: 20,
    textAlign: 'center',
  },
  description: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
    textAlign: 'center',
    lineHeight: 24,
  },
  status: {
    fontSize: 16,
    color: '#4CAF50',
    fontWeight: '600',
    textAlign: 'center',
  },
});

export default App;









