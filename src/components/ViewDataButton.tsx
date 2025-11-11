/**
 * Quick button to view all stored clinician data in console
 * Add this to any screen to see the data
 */

import React from 'react';
import { TouchableOpacity, Text, StyleSheet, Alert } from 'react-native';
import { apiService } from '../services/api';

interface ViewDataButtonProps {
  style?: any;
}

const ViewDataButton: React.FC<ViewDataButtonProps> = ({ style }) => {
  const handleViewData = async () => {
    try {
      console.log('\n🔍 Fetching all clinician data...\n');
      
      // Get the data
      const data = await apiService.getAllActivityLogs();
      
      // Print to console
      await apiService.printDataToConsole();
      
      // Show alert with summary
      Alert.alert(
        '✅ Data Logged to Console',
        `Total Logins: ${data.logins.length}\n` +
        `Total Registrations: ${data.registrations.length}\n\n` +
        `Check the console for full JSON data!`,
        [{ text: 'OK' }]
      );
    } catch (error) {
      console.error('Error viewing data:', error);
      Alert.alert('Error', 'Failed to retrieve data');
    }
  };

  return (
    <TouchableOpacity
      style={[styles.button, style]}
      onPress={handleViewData}
    >
      <Text style={styles.buttonText}>📊 View Data in Console</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  button: {
    backgroundColor: '#667eea',
    padding: 15,
    borderRadius: 10,
    alignItems: 'center',
    marginVertical: 10,
  },
  buttonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
});

export default ViewDataButton;







