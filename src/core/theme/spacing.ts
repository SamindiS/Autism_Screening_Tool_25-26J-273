/**
 * Spacing System
 * Consistent spacing scale for layouts, margins, and padding
 */

// Base spacing unit (4px)
const BASE_UNIT = 4;

export const spacing = {
  // Micro spacing
  0: 0,
  1: BASE_UNIT * 1,      // 4px
  2: BASE_UNIT * 2,      // 8px
  3: BASE_UNIT * 3,      // 12px
  4: BASE_UNIT * 4,      // 16px
  5: BASE_UNIT * 5,      // 20px
  6: BASE_UNIT * 6,      // 24px
  7: BASE_UNIT * 7,      // 28px
  8: BASE_UNIT * 8,      // 32px

  // Macro spacing
  10: BASE_UNIT * 10,    // 40px
  12: BASE_UNIT * 12,    // 48px
  16: BASE_UNIT * 16,    // 64px
  20: BASE_UNIT * 20,    // 80px
  24: BASE_UNIT * 24,    // 96px
  32: BASE_UNIT * 32,    // 128px

  // Semantic spacing (named)
  xs: BASE_UNIT * 1,     // 4px
  sm: BASE_UNIT * 2,     // 8px
  md: BASE_UNIT * 4,     // 16px
  lg: BASE_UNIT * 6,     // 24px
  xl: BASE_UNIT * 8,     // 32px
  '2xl': BASE_UNIT * 12, // 48px
  '3xl': BASE_UNIT * 16, // 64px
  '4xl': BASE_UNIT * 20, // 80px
} as const;

// Border radius
export const borderRadius = {
  none: 0,
  sm: 4,
  md: 8,
  lg: 12,
  xl: 16,
  '2xl': 24,
  '3xl': 32,
  full: 9999,
} as const;

// Border width
export const borderWidth = {
  none: 0,
  thin: 1,
  medium: 2,
  thick: 4,
} as const;

// Shadow elevations (for cards, modals, etc.)
export const shadows = {
  none: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0,
    shadowRadius: 0,
    elevation: 0,
  },
  sm: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.18,
    shadowRadius: 1.0,
    elevation: 1,
  },
  md: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.22,
    shadowRadius: 2.22,
    elevation: 3,
  },
  lg: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 4.65,
    elevation: 8,
  },
  xl: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.44,
    shadowRadius: 10.32,
    elevation: 16,
  },
} as const;

// Component-specific spacing
export const componentSpacing = {
  // Screen padding (optimized for tablets)
  screenPaddingHorizontal: spacing.lg,  // 24px
  screenPaddingVertical: spacing.lg,    // 24px

  // Card spacing
  cardPadding: spacing.md,               // 16px
  cardMargin: spacing.md,                // 16px
  cardGap: spacing.md,                   // 16px

  // Input fields
  inputPaddingHorizontal: spacing.md,    // 16px
  inputPaddingVertical: spacing.sm,      // 12px
  inputMarginBottom: spacing.md,         // 16px

  // Buttons
  buttonPaddingHorizontal: spacing.lg,   // 24px
  buttonPaddingVertical: spacing.md,     // 16px
  buttonMarginTop: spacing.lg,           // 24px

  // Lists
  listItemPadding: spacing.md,           // 16px
  listItemGap: spacing.sm,               // 8px

  // Game elements (larger for child interaction)
  gamePadding: spacing.xl,               // 32px
  gameButtonSize: 120,                   // 120px
  gameElementGap: spacing.lg,            // 24px
} as const;

export type Spacing = typeof spacing;
export type SpacingKey = keyof typeof spacing;
export type BorderRadius = typeof borderRadius;
export type BorderRadiusKey = keyof typeof borderRadius;
export type Shadow = typeof shadows;
export type ShadowKey = keyof typeof shadows;



