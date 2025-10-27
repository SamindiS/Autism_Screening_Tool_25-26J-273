import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Modal,
  Dimensions,
} from 'react-native';
import LinearGradient from 'react-native-linear-gradient';
import { useLanguage } from '../context/LanguageContext';
import { Language } from '../i18n/translations';

const { width } = Dimensions.get('window');

interface LanguageSelectorProps {
  showInline?: boolean;
}

const LanguageSelector: React.FC<LanguageSelectorProps> = ({ showInline = false }) => {
  const { language, setLanguage, t } = useLanguage();
  const [modalVisible, setModalVisible] = useState(false);

  const languages: { code: Language; name: string; nativeName: string; flag: string }[] = [
    { code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧' },
    { code: 'si', name: 'Sinhala', nativeName: 'සිංහල', flag: '🇱🇰' },
    { code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇱🇰' },
  ];

  const currentLanguage = languages.find((l) => l.code === language) || languages[0];

  const handleLanguageSelect = async (code: Language) => {
    await setLanguage(code);
    setModalVisible(false);
  };

  if (showInline) {
    return (
      <View style={styles.inlineContainer}>
        <Text style={styles.inlineLabel}>{t.settings.language}:</Text>
        {languages.map((lang) => (
          <TouchableOpacity
            key={lang.code}
            style={[
              styles.inlineButton,
              language === lang.code && styles.inlineButtonSelected,
            ]}
            onPress={() => handleLanguageSelect(lang.code)}
          >
            <Text style={styles.inlineFlag}>{lang.flag}</Text>
            <Text
              style={[
                styles.inlineButtonText,
                language === lang.code && styles.inlineButtonTextSelected,
              ]}
            >
              {lang.nativeName}
            </Text>
          </TouchableOpacity>
        ))}
      </View>
    );
  }

  return (
    <>
      <TouchableOpacity
        style={styles.button}
        onPress={() => setModalVisible(true)}
      >
        <Text style={styles.flag}>{currentLanguage.flag}</Text>
        <Text style={styles.buttonText}>{currentLanguage.nativeName}</Text>
        <Text style={styles.arrow}>▼</Text>
      </TouchableOpacity>

      <Modal
        visible={modalVisible}
        transparent
        animationType="fade"
        onRequestClose={() => setModalVisible(false)}
      >
        <TouchableOpacity
          style={styles.modalOverlay}
          activeOpacity={1}
          onPress={() => setModalVisible(false)}
        >
          <View style={styles.modalContent}>
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>{t.settings.selectLanguage}</Text>
              <TouchableOpacity onPress={() => setModalVisible(false)}>
                <Text style={styles.closeButton}>✕</Text>
              </TouchableOpacity>
            </View>

            {languages.map((lang) => (
              <TouchableOpacity
                key={lang.code}
                style={[
                  styles.languageOption,
                  language === lang.code && styles.languageOptionSelected,
                ]}
                onPress={() => handleLanguageSelect(lang.code)}
              >
                <View style={styles.languageInfo}>
                  <Text style={styles.languageFlag}>{lang.flag}</Text>
                  <View style={styles.languageNames}>
                    <Text style={styles.languageName}>{lang.nativeName}</Text>
                    <Text style={styles.languageEnglishName}>{lang.name}</Text>
                  </View>
                </View>
                {language === lang.code && (
                  <Text style={styles.checkmark}>✓</Text>
                )}
              </TouchableOpacity>
            ))}
          </View>
        </TouchableOpacity>
      </Modal>
    </>
  );
};

const styles = StyleSheet.create({
  button: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 15,
    paddingVertical: 10,
    borderRadius: 25,
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.3)',
  },
  flag: {
    fontSize: 24,
    marginRight: 8,
  },
  buttonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
    marginRight: 5,
  },
  arrow: {
    color: '#fff',
    fontSize: 12,
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 0, 0, 0.5)',
    justifyContent: 'center',
    alignItems: 'center',
  },
  modalContent: {
    width: width * 0.85,
    maxWidth: 400,
    backgroundColor: '#fff',
    borderRadius: 20,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 10,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
    paddingBottom: 15,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#333',
  },
  closeButton: {
    fontSize: 28,
    color: '#999',
    fontWeight: '300',
  },
  languageOption: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 15,
    borderRadius: 12,
    marginBottom: 10,
    backgroundColor: '#f8f9fa',
  },
  languageOptionSelected: {
    backgroundColor: '#e3f2fd',
    borderWidth: 2,
    borderColor: '#667eea',
  },
  languageInfo: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  languageFlag: {
    fontSize: 32,
    marginRight: 15,
  },
  languageNames: {
    flex: 1,
  },
  languageName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginBottom: 2,
  },
  languageEnglishName: {
    fontSize: 14,
    color: '#666',
  },
  checkmark: {
    fontSize: 24,
    color: '#667eea',
    fontWeight: 'bold',
  },
  inlineContainer: {
    marginVertical: 20,
  },
  inlineLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },
  inlineButton: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 15,
    borderRadius: 12,
    backgroundColor: '#f8f9fa',
    marginBottom: 10,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  inlineButtonSelected: {
    backgroundColor: '#e3f2fd',
    borderColor: '#667eea',
  },
  inlineFlag: {
    fontSize: 28,
    marginRight: 12,
  },
  inlineButtonText: {
    fontSize: 16,
    color: '#666',
    fontWeight: '500',
  },
  inlineButtonTextSelected: {
    color: '#667eea',
    fontWeight: '700',
  },
});

export default LanguageSelector;

