import i18n from 'i18next'
import { initReactI18next } from 'react-i18next'
import en from './locales/en'
import si from './locales/si'
import ta from './locales/ta'

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      si: { translation: si },
      ta: { translation: ta },
    },
    lng: localStorage.getItem('language') || 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
    },
  })

export default i18n








