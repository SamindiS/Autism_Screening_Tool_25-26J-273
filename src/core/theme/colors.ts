/**
 * Color System for Clinical Autism Screening App
 * Professional, accessible, child-friendly palette
 */

export const colors = {
  // Primary Colors - Clinical Blue (Trust, Professional)
  primary: {
    50: '#E3F2FD',
    100: '#BBDEFB',
    200: '#90CAF9',
    300: '#64B5F6',
    400: '#42A5F5',
    500: '#2196F3',  // Main primary
    600: '#1E88E5',
    700: '#1976D2',
    800: '#1565C0',
    900: '#0D47A1',
  },

  // Secondary Colors - Soft Purple (Calm, Supportive)
  secondary: {
    50: '#F3E5F5',
    100: '#E1BEE7',
    200: '#CE93D8',
    300: '#BA68C8',
    400: '#AB47BC',
    500: '#9C27B0',  // Main secondary
    600: '#8E24AA',
    700: '#7B1FA2',
    800: '#6A1B9A',
    900: '#4A148C',
  },

  // Success - Green (Correct, Positive)
  success: {
    50: '#E8F5E9',
    100: '#C8E6C9',
    200: '#A5D6A7',
    300: '#81C784',
    400: '#66BB6A',
    500: '#4CAF50',  // Main success
    600: '#43A047',
    700: '#388E3C',
    800: '#2E7D32',
    900: '#1B5E20',
  },

  // Warning - Orange (Caution, Attention)
  warning: {
    50: '#FFF3E0',
    100: '#FFE0B2',
    200: '#FFCC80',
    300: '#FFB74D',
    400: '#FFA726',
    500: '#FF9800',  // Main warning
    600: '#FB8C00',
    700: '#F57C00',
    800: '#EF6C00',
    900: '#E65100',
  },

  // Error - Red (Incorrect, Alert)
  error: {
    50: '#FFEBEE',
    100: '#FFCDD2',
    200: '#EF9A9A',
    300: '#E57373',
    400: '#EF5350',
    500: '#F44336',  // Main error
    600: '#E53935',
    700: '#D32F2F',
    800: '#C62828',
    900: '#B71C1C',
  },

  // Neutral/Gray - UI Elements
  gray: {
    50: '#FAFAFA',
    100: '#F5F5F5',
    200: '#EEEEEE',
    300: '#E0E0E0',
    400: '#BDBDBD',
    500: '#9E9E9E',
    600: '#757575',
    700: '#616161',
    800: '#424242',
    900: '#212121',
  },

  // Special Colors for Games
  game: {
    sun: '#FFD54F',      // Day/Sun (yellow)
    moon: '#7986CB',     // Night/Moon (blue)
    star: '#FFEB3B',     // Stars
    frog: '#66BB6A',     // Frog (green)
    lily: '#81C784',     // Lily pad
    water: '#64B5F6',    // Water
    red: '#EF5350',      // Red shape
    blue: '#42A5F5',     // Blue shape
    yellow: '#FFEE58',   // Yellow shape
    green: '#66BB6A',    // Green shape
  },

  // Semantic Colors
  text: {
    primary: '#212121',      // Main text
    secondary: '#757575',    // Secondary text
    disabled: '#BDBDBD',     // Disabled text
    hint: '#9E9E9E',         // Hint text
    inverse: '#FFFFFF',      // Text on dark background
  },

  background: {
    default: '#FAFAFA',      // Default background
    paper: '#FFFFFF',        // Card/paper background
    elevated: '#FFFFFF',     // Elevated elements
    disabled: '#F5F5F5',     // Disabled background
  },

  border: {
    light: '#EEEEEE',
    default: '#E0E0E0',
    dark: '#BDBDBD',
  },

  // Risk Level Colors (for assessment results)
  risk: {
    low: '#4CAF50',          // Green - Low risk
    moderate: '#FF9800',     // Orange - Moderate risk
    high: '#F44336',         // Red - High risk
  },

  // Overlay
  overlay: {
    light: 'rgba(0, 0, 0, 0.1)',
    medium: 'rgba(0, 0, 0, 0.3)',
    dark: 'rgba(0, 0, 0, 0.7)',
  },

  // Status Colors
  status: {
    online: '#4CAF50',
    offline: '#9E9E9E',
    pending: '#FF9800',
    active: '#2196F3',
  },
} as const;

export type Colors = typeof colors;
export type ColorKey = keyof typeof colors;

// Dark mode colors (future implementation)
export const darkColors = {
  ...colors,
  background: {
    default: '#121212',
    paper: '#1E1E1E',
    elevated: '#2C2C2C',
    disabled: '#1A1A1A',
  },
  text: {
    primary: '#FFFFFF',
    secondary: '#B0B0B0',
    disabled: '#6E6E6E',
    hint: '#8E8E8E',
    inverse: '#212121',
  },
};



