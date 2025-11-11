import React, { useState } from 'react';
import { View, StyleSheet } from 'react-native';
import LoginScreen from '../screens/LoginScreen';
import RegistrationScreen from '../screens/RegistrationScreen';

type AuthScreen = 'login' | 'register';

interface AuthFlowProps {
  onAuthSuccess: () => void;
}

const AuthFlow: React.FC<AuthFlowProps> = ({ onAuthSuccess }) => {
  const [currentScreen, setCurrentScreen] = useState<AuthScreen>('login');

  const handleNavigateToRegister = () => {
    setCurrentScreen('register');
  };

  const handleNavigateToLogin = () => {
    setCurrentScreen('login');
  };

  const handleAuthSuccess = () => {
    onAuthSuccess();
  };

  return (
    <View style={styles.container}>
      {currentScreen === 'login' ? (
        <LoginScreen 
          onNavigateToRegister={handleNavigateToRegister}
          onAuthSuccess={handleAuthSuccess}
        />
      ) : (
        <RegistrationScreen 
          onNavigateToLogin={handleNavigateToLogin}
          onAuthSuccess={handleAuthSuccess}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default AuthFlow;

