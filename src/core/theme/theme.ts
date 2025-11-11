/**
 * Complete Theme System
 * Combines colors, typography, and spacing into a unified theme
 */

import { colors, darkColors } from './colors';
import { typography, fontFamilies, fontSizes, fontWeights, lineHeights } from './typography';
import { spacing, borderRadius, borderWidth, shadows, componentSpacing } from './spacing';

export const theme = {
  colors,
  typography,
  fontFamilies,
  fontSizes,
  fontWeights,
  lineHeights,
  spacing,
  borderRadius,
  borderWidth,
  shadows,
  componentSpacing,

  // Animation durations (in milliseconds)
  animation: {
    fast: 150,
    normal: 300,
    slow: 500,
  },

  // Breakpoints (for responsive design)
  breakpoints: {
    phone: 0,
    tablet: 768,
    desktop: 1024,
  },

  // Z-index layers
  zIndex: {
    hide: -1,
    base: 0,
    raised: 10,
    dropdown: 100,
    sticky: 200,
    fixed: 300,
    overlay: 400,
    modal: 500,
    popover: 600,
    tooltip: 700,
    notification: 800,
    max: 999,
  },

  // Opacity levels
  opacity: {
    disabled: 0.4,
    hover: 0.8,
    active: 0.9,
    inactive: 0.6,
  },

  // Screen dimensions (tablet optimized)
  screen: {
    minTouchTarget: 44,  // Minimum touch target size (iOS HIG)
    iconSize: {
      small: 20,
      medium: 24,
      large: 32,
      xlarge: 48,
    },
  },
} as const;

// Dark theme (for future implementation)
export const darkTheme = {
  ...theme,
  colors: darkColors,
} as const;

export type Theme = typeof theme;
export default theme;



