import React, { useRef, useState } from 'react';
import {
  View,
  StyleSheet,
  Alert,
  ActivityIndicator,
  Text,
  TouchableOpacity,
} from 'react-native';
import { WebView } from 'react-native-webview';
import { useLanguage } from '../context/LanguageContext';

interface GameWebViewProps {
  gameType: 'frog_jump' | 'day_night' | 'color_shape' | 'rule_switch';
  onComplete?: (results: any) => void;
  onGameComplete?: (results: any) => void;
  onBack?: () => void;
  onGoBack?: () => void;
  child?: any;
  childData?: any;
}

const GameWebView: React.FC<GameWebViewProps> = ({
  gameType,
  onComplete,
  onGameComplete,
  onBack,
  onGoBack,
  child,
  childData,
}) => {
  // Use whichever prop was provided
  const handleComplete = onComplete || onGameComplete;
  const handleBack = onBack || onGoBack;
  const childInfo = child || childData;
  const { language } = useLanguage();
  const webViewRef = useRef<WebView>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  const getGameUrl = () => {
    const baseUrl = 'file:///android_asset/';
    switch (gameType) {
      case 'frog_jump':
        return `${baseUrl}games/index.html?type=frog_jump`;
      case 'day_night':
        return `${baseUrl}games/day-night.html`;
      case 'color_shape':
        return `${baseUrl}games/color-shape.html`;
      case 'rule_switch':
        return `${baseUrl}games/rule-switch.html`;
      default:
        return `${baseUrl}games/index.html`;
    }
  };

  const handleMessage = (event: any) => {
    try {
      const data = JSON.parse(event.nativeEvent.data);
      console.log('WebView message received:', data);
      
      switch (data.type) {
        case 'game_complete':
          console.log('Game completed with results:', data.results);
          if (handleComplete) {
            handleComplete(data.results);
          }
          break;
        case 'go_back':
          console.log('Go back requested');
          if (handleBack) {
            handleBack();
          }
          break;
        default:
          console.log('Unknown message type:', data.type);
      }
    } catch (error) {
      console.error('Error parsing WebView message:', error);
    }
  };

  const handleLoadEnd = () => {
    setLoading(false);
    setError(false);
    
    // Send child data and language to WebView for age-based configuration
    if (webViewRef.current && childInfo) {
      setTimeout(() => {
        const message = JSON.stringify({
          type: 'childData',
          language: language, // Send current language
          child: {
            age: childInfo.age || 4,
            name: childInfo.name || 'Child',
            id: childInfo.id
          }
        });
        console.log('Sending child data to WebView:', message);
        webViewRef.current?.postMessage(message);
      }, 500); // Small delay to ensure WebView is ready
    }
  };

  const handleError = () => {
    setLoading(false);
    setError(true);
  };

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorTitle}>Game Loading Error</Text>
        <Text style={styles.errorText}>
          Unable to load the game. Please try again.
        </Text>
        <TouchableOpacity style={styles.retryButton} onPress={() => setError(false)}>
          <Text style={styles.retryButtonText}>Retry</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.backButton} onPress={() => handleBack && handleBack()}>
          <Text style={styles.backButtonText}>Go Back</Text>
        </TouchableOpacity>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      {loading && (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#2E86AB" />
          <Text style={styles.loadingText}>Loading Game...</Text>
        </View>
      )}
      
      <WebView
        ref={webViewRef}
        source={{ uri: getGameUrl() }}
        style={styles.webView}
        onMessage={handleMessage}
        onLoadEnd={handleLoadEnd}
        onError={handleError}
        javaScriptEnabled={true}
        domStorageEnabled={true}
        startInLoadingState={true}
        scalesPageToFit={true}
        allowsInlineMediaPlayback={true}
        mediaPlaybackRequiresUserAction={false}
        allowsFullscreenVideo={true}
        mixedContentMode="compatibility"
        onShouldStartLoadWithRequest={(request) => {
          // Allow navigation within the game
          return true;
        }}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#87CEEB',
  },
  webView: {
    flex: 1,
  },
  loadingContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    backgroundColor: '#87CEEB',
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 1000,
  },
  loadingText: {
    marginTop: 20,
    fontSize: 18,
    color: '#2E86AB',
    fontWeight: 'bold',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#87CEEB',
    padding: 20,
  },
  errorTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#FF6B6B',
    marginBottom: 10,
  },
  errorText: {
    fontSize: 16,
    color: '#333',
    textAlign: 'center',
    marginBottom: 30,
  },
  retryButton: {
    backgroundColor: '#4CAF50',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 25,
    marginBottom: 15,
  },
  retryButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
  backButton: {
    backgroundColor: '#FF6B6B',
    paddingHorizontal: 30,
    paddingVertical: 15,
    borderRadius: 25,
  },
  backButtonText: {
    color: 'white',
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default GameWebView;
