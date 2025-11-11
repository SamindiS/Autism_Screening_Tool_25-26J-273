/**
 * Data Export Helper
 * Use this component to view and export clinician data from AsyncStorage
 */

import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
  Share,
  Clipboard,
} from 'react-native';
import { apiService } from '../services/api';

const DataExportHelper: React.FC = () => {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    try {
      const logs = await apiService.getAllActivityLogs();
      setData(logs);
      
      // Also print to console
      await apiService.printDataToConsole();
    } catch (error) {
      console.error('Error loading data:', error);
      Alert.alert('Error', 'Failed to load data');
    } finally {
      setLoading(false);
    }
  };

  const handleCopyJSON = async () => {
    try {
      const jsonString = await apiService.exportClinicianDataAsJSON();
      Clipboard.setString(jsonString);
      Alert.alert('Success', 'JSON data copied to clipboard!');
    } catch (error) {
      Alert.alert('Error', 'Failed to copy data');
    }
  };

  const handleShareJSON = async () => {
    try {
      const jsonString = await apiService.exportClinicianDataAsJSON();
      await Share.share({
        message: jsonString,
        title: 'Clinician Data Export',
      });
    } catch (error) {
      Alert.alert('Error', 'Failed to share data');
    }
  };

  const handleClearData = () => {
    Alert.alert(
      'Clear All Data?',
      'This will permanently delete all logged clinician data. Are you sure?',
      [
        { text: 'Cancel', style: 'cancel' },
        {
          text: 'Clear',
          style: 'destructive',
          onPress: async () => {
            await apiService.clearActivityLogs();
            setData({ allActivity: [], logins: [], registrations: [] });
            Alert.alert('Success', 'All data cleared');
          },
        },
      ]
    );
  };

  if (loading) {
    return (
      <View style={styles.container}>
        <Text style={styles.loadingText}>Loading data...</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>📊 Clinician Data Export</Text>
        <Text style={styles.subtitle}>
          View data in React Native DevTools AsyncStorage
        </Text>
      </View>

      <ScrollView style={styles.content}>
        {/* Statistics */}
        <View style={styles.statsContainer}>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{data?.allActivity?.length || 0}</Text>
            <Text style={styles.statLabel}>Total Activities</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{data?.logins?.length || 0}</Text>
            <Text style={styles.statLabel}>Logins</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statValue}>{data?.registrations?.length || 0}</Text>
            <Text style={styles.statLabel}>Registrations</Text>
          </View>
        </View>

        {/* Instructions */}
        <View style={styles.instructionsCard}>
          <Text style={styles.instructionsTitle}>📱 How to View in DevTools:</Text>
          <Text style={styles.instructionText}>
            1. Open React Native Debugger or Chrome DevTools{'\n'}
            2. Go to Application → Storage → AsyncStorage{'\n'}
            3. Look for these keys:{'\n'}
            {'\n'}
            • <Text style={styles.keyName}>CLINICIAN_ACTIVITY_LOG</Text> - All activity{'\n'}
            • <Text style={styles.keyName}>CLINICIAN_LOGINS</Text> - Login records{'\n'}
            • <Text style={styles.keyName}>CLINICIAN_REGISTRATIONS</Text> - Registration records
          </Text>
        </View>

        {/* Data Preview */}
        {data?.registrations && data.registrations.length > 0 && (
          <View style={styles.dataCard}>
            <Text style={styles.dataTitle}>Recent Registrations:</Text>
            {data.registrations.slice(-3).reverse().map((reg: any, index: number) => (
              <View key={index} style={styles.dataItem}>
                <Text style={styles.dataText}>👤 {reg.fullName}</Text>
                <Text style={styles.dataSubtext}>📧 {reg.email}</Text>
                <Text style={styles.dataSubtext}>🏥 Clinic: {reg.clinicId}</Text>
                <Text style={styles.dataSubtext}>⏰ {new Date(reg.registrationTime).toLocaleString()}</Text>
              </View>
            ))}
          </View>
        )}

        {data?.logins && data.logins.length > 0 && (
          <View style={styles.dataCard}>
            <Text style={styles.dataTitle}>Recent Logins:</Text>
            {data.logins.slice(-3).reverse().map((login: any, index: number) => (
              <View key={index} style={styles.dataItem}>
                <Text style={styles.dataText}>👤 {login.name}</Text>
                <Text style={styles.dataSubtext}>📧 {login.email}</Text>
                <Text style={styles.dataSubtext}>⏰ {new Date(login.loginTime).toLocaleString()}</Text>
              </View>
            ))}
          </View>
        )}

        {/* Console Output */}
        <View style={styles.consoleCard}>
          <Text style={styles.consoleTitle}>💻 Console Output</Text>
          <Text style={styles.consoleText}>
            Check your console for formatted JSON output!{'\n'}
            The data is also printed in the terminal.
          </Text>
        </View>
      </ScrollView>

      {/* Action Buttons */}
      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.button} onPress={loadData}>
          <Text style={styles.buttonText}>🔄 Refresh</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.buttonPrimary} onPress={handleCopyJSON}>
          <Text style={styles.buttonTextPrimary}>📋 Copy JSON</Text>
        </TouchableOpacity>
      </View>

      <View style={styles.buttonContainer}>
        <TouchableOpacity style={styles.button} onPress={handleShareJSON}>
          <Text style={styles.buttonText}>📤 Share JSON</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.buttonDanger} onPress={handleClearData}>
          <Text style={styles.buttonTextDanger}>🗑️ Clear Data</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: '#667eea',
    padding: 20,
    paddingTop: 50,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#fff',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 14,
    color: 'rgba(255,255,255,0.9)',
  },
  loadingText: {
    textAlign: 'center',
    marginTop: 50,
    fontSize: 16,
    color: '#666',
  },
  content: {
    flex: 1,
    padding: 15,
  },
  statsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 15,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    marginHorizontal: 5,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  statValue: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#667eea',
  },
  statLabel: {
    fontSize: 12,
    color: '#666',
    marginTop: 5,
  },
  instructionsCard: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 10,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  instructionsTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  instructionText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 22,
  },
  keyName: {
    fontFamily: 'monospace',
    backgroundColor: '#f0f0f0',
    padding: 2,
    fontWeight: 'bold',
    color: '#667eea',
  },
  dataCard: {
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    marginBottom: 15,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  dataTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 10,
  },
  dataItem: {
    borderLeftWidth: 3,
    borderLeftColor: '#667eea',
    paddingLeft: 10,
    marginBottom: 15,
  },
  dataText: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 3,
  },
  dataSubtext: {
    fontSize: 12,
    color: '#666',
    marginBottom: 2,
  },
  consoleCard: {
    backgroundColor: '#1e1e1e',
    padding: 20,
    borderRadius: 10,
    marginBottom: 15,
  },
  consoleTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#4ec9b0',
    marginBottom: 10,
  },
  consoleText: {
    fontSize: 13,
    color: '#d4d4d4',
    fontFamily: 'monospace',
    lineHeight: 20,
  },
  buttonContainer: {
    flexDirection: 'row',
    paddingHorizontal: 15,
    paddingVertical: 8,
    gap: 10,
  },
  button: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: '#ddd',
  },
  buttonPrimary: {
    flex: 1,
    backgroundColor: '#667eea',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonDanger: {
    flex: 1,
    backgroundColor: '#ff6b6b',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
  },
  buttonText: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
  },
  buttonTextPrimary: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
  },
  buttonTextDanger: {
    fontSize: 14,
    fontWeight: '600',
    color: '#fff',
  },
});

export default DataExportHelper;







