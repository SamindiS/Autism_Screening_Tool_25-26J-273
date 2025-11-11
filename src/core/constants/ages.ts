/**
 * Age Group Constants
 * Age ranges and corresponding game assignments
 */

export const AGE_GROUPS = {
  GROUP_2_3: '2-3',
  GROUP_4_5: '4-5',
  GROUP_5_6: '5-6',
} as const;

export type AgeGroup = typeof AGE_GROUPS[keyof typeof AGE_GROUPS];

// Age range definitions
export const AGE_RANGES = {
  [AGE_GROUPS.GROUP_2_3]: { min: 2, max: 3, label: '2-3 years' },
  [AGE_GROUPS.GROUP_4_5]: { min: 4, max: 5, label: '4-5 years' },
  [AGE_GROUPS.GROUP_5_6]: { min: 5, max: 6, label: '5-6 years' },
} as const;

// Get age group from age
export const getAgeGroup = (age: number): AgeGroup => {
  if (age >= 2 && age <= 3) return AGE_GROUPS.GROUP_2_3;
  if (age >= 4 && age <= 5) return AGE_GROUPS.GROUP_4_5;
  if (age >= 5 && age <= 6) return AGE_GROUPS.GROUP_5_6;
  
  // Default to 2-3 for out of range
  return AGE_GROUPS.GROUP_2_3;
};

// Validate age
export const isValidAge = (age: number): boolean => {
  return age >= 2 && age <= 6;
};



