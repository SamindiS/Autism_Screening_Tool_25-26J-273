/**
 * Typography System
 * Professional, readable font styles for clinical application
 */

import { Platform, TextStyle } from 'react-native';

// Font families
export const fontFamilies = {
  regular: Platform.select({
    ios: 'System',
    android: 'Roboto',
    default: 'System',
  }),
  medium: Platform.select({
    ios: 'System',
    android: 'Roboto-Medium',
    default: 'System',
  }),
  bold: Platform.select({
    ios: 'System',
    android: 'Roboto-Bold',
    default: 'System',
  }),
  light: Platform.select({
    ios: 'System',
    android: 'Roboto-Light',
    default: 'System',
  }),
} as const;

// Font sizes
export const fontSizes = {
  xs: 12,
  sm: 14,
  base: 16,
  lg: 18,
  xl: 20,
  '2xl': 24,
  '3xl': 30,
  '4xl': 36,
  '5xl': 48,
  '6xl': 60,
} as const;

// Line heights
export const lineHeights = {
  tight: 1.2,
  normal: 1.5,
  relaxed: 1.75,
  loose: 2,
} as const;

// Font weights
export const fontWeights = {
  light: '300',
  normal: '400',
  medium: '500',
  semibold: '600',
  bold: '700',
  extrabold: '800',
} as const;

// Typography styles
export const typography = {
  // Headings
  h1: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['4xl'],
    lineHeight: fontSizes['4xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,

  h2: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['3xl'],
    lineHeight: fontSizes['3xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,

  h3: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['2xl'],
    lineHeight: fontSizes['2xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,

  h4: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.xl,
    lineHeight: fontSizes.xl * lineHeights.normal,
    fontWeight: fontWeights.semibold,
  } as TextStyle,

  h5: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.lg,
    lineHeight: fontSizes.lg * lineHeights.normal,
    fontWeight: fontWeights.semibold,
  } as TextStyle,

  h6: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.base,
    lineHeight: fontSizes.base * lineHeights.normal,
    fontWeight: fontWeights.semibold,
  } as TextStyle,

  // Body text
  body1: {
    fontFamily: fontFamilies.regular,
    fontSize: fontSizes.base,
    lineHeight: fontSizes.base * lineHeights.normal,
    fontWeight: fontWeights.normal,
  } as TextStyle,

  body2: {
    fontFamily: fontFamilies.regular,
    fontSize: fontSizes.sm,
    lineHeight: fontSizes.sm * lineHeights.normal,
    fontWeight: fontWeights.normal,
  } as TextStyle,

  // Subtitle
  subtitle1: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.base,
    lineHeight: fontSizes.base * lineHeights.normal,
    fontWeight: fontWeights.medium,
  } as TextStyle,

  subtitle2: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.sm,
    lineHeight: fontSizes.sm * lineHeights.normal,
    fontWeight: fontWeights.medium,
  } as TextStyle,

  // Caption
  caption: {
    fontFamily: fontFamilies.regular,
    fontSize: fontSizes.xs,
    lineHeight: fontSizes.xs * lineHeights.normal,
    fontWeight: fontWeights.normal,
  } as TextStyle,

  // Overline (small uppercase text)
  overline: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.xs,
    lineHeight: fontSizes.xs * lineHeights.normal,
    fontWeight: fontWeights.medium,
    textTransform: 'uppercase',
    letterSpacing: 1.5,
  } as TextStyle,

  // Button text
  button: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.base,
    lineHeight: fontSizes.base * lineHeights.tight,
    fontWeight: fontWeights.medium,
    textTransform: 'uppercase',
    letterSpacing: 1.25,
  } as TextStyle,

  // Game/child-friendly text (larger, clearer)
  gameTitle: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['3xl'],
    lineHeight: fontSizes['3xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,

  gameInstruction: {
    fontFamily: fontFamilies.medium,
    fontSize: fontSizes.xl,
    lineHeight: fontSizes.xl * lineHeights.relaxed,
    fontWeight: fontWeights.medium,
  } as TextStyle,

  // Large numbers (for scores, metrics)
  displayLarge: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['6xl'],
    lineHeight: fontSizes['6xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,

  displayMedium: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['5xl'],
    lineHeight: fontSizes['5xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,

  displaySmall: {
    fontFamily: fontFamilies.bold,
    fontSize: fontSizes['4xl'],
    lineHeight: fontSizes['4xl'] * lineHeights.tight,
    fontWeight: fontWeights.bold,
  } as TextStyle,
} as const;

export type Typography = typeof typography;
export type TypographyKey = keyof typeof typography;



