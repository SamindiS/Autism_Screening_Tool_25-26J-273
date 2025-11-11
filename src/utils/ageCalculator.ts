/**
 * Age Calculator Utility
 * Calculates precise age from date of birth to current date
 */

export interface AgeDetails {
  years: number;
  months: number;
  days: number;
  totalMonths: number;
  ageInYears: number; // Decimal representation (e.g., 5.5 years)
}

/**
 * Calculate exact age from date of birth to current date
 */
export const calculateAge = (dateOfBirth: string | Date): AgeDetails => {
  const birthDate = typeof dateOfBirth === 'string' ? new Date(dateOfBirth) : dateOfBirth;
  const today = new Date();
  
  let years = today.getFullYear() - birthDate.getFullYear();
  let months = today.getMonth() - birthDate.getMonth();
  let days = today.getDate() - birthDate.getDate();
  
  // Adjust for negative days
  if (days < 0) {
    months--;
    const lastMonth = new Date(today.getFullYear(), today.getMonth(), 0);
    days += lastMonth.getDate();
  }
  
  // Adjust for negative months
  if (months < 0) {
    years--;
    months += 12;
  }
  
  const totalMonths = years * 12 + months;
  
  // Calculate decimal age (e.g., 5 years 6 months = 5.5 years)
  const ageInYears = years + (months / 12) + (days / 365);
  
  return {
    years,
    months,
    days,
    totalMonths,
    ageInYears: parseFloat(ageInYears.toFixed(2)),
  };
};

/**
 * Get age group based on exact age
 */
export const getAgeGroup = (dateOfBirth: string | Date): '2-3' | '3-5' | '5-6' | 'out-of-range' => {
  const { ageInYears } = calculateAge(dateOfBirth);
  
  if (ageInYears >= 2 && ageInYears < 3.5) {
    return '2-3';
  } else if (ageInYears >= 3.5 && ageInYears < 5.5) {
    return '3-5';
  } else if (ageInYears >= 5.5 && ageInYears <= 6) {
    return '5-6';
  } else {
    return 'out-of-range';
  }
};

/**
 * Get appropriate assessment type based on exact age
 */
export const getAssessmentType = (dateOfBirth: string | Date): 'ai_bot' | 'frog_jump' | 'color_shape' | 'out_of_range' => {
  const ageGroup = getAgeGroup(dateOfBirth);
  
  switch (ageGroup) {
    case '2-3':
      return 'ai_bot';
    case '3-5':
      return 'frog_jump';
    case '5-6':
      return 'color_shape';
    default:
      return 'out_of_range';
  }
};

/**
 * Format age for display
 */
export const formatAge = (dateOfBirth: string | Date): string => {
  const { years, months, days } = calculateAge(dateOfBirth);
  
  if (years === 0) {
    if (months === 0) {
      return `${days} ${days === 1 ? 'day' : 'days'}`;
    }
    return `${months} ${months === 1 ? 'month' : 'months'}`;
  }
  
  if (months === 0) {
    return `${years} ${years === 1 ? 'year' : 'years'}`;
  }
  
  return `${years} ${years === 1 ? 'year' : 'years'} ${months} ${months === 1 ? 'month' : 'months'}`;
};

/**
 * Check if child is within valid assessment age range
 */
export const isValidAssessmentAge = (dateOfBirth: string | Date): boolean => {
  const { ageInYears } = calculateAge(dateOfBirth);
  return ageInYears >= 2 && ageInYears <= 6;
};

/**
 * Get age bracket description
 */
export const getAgeBracketDescription = (dateOfBirth: string | Date): string => {
  const ageGroup = getAgeGroup(dateOfBirth);
  const { ageInYears } = calculateAge(dateOfBirth);
  
  switch (ageGroup) {
    case '2-3':
      return `Age ${ageInYears} years - AI Doctor Bot Questionnaire`;
    case '3-5':
      return `Age ${ageInYears} years - Frog Jump Game (Go/No-Go)`;
    case '5-6':
      return `Age ${ageInYears} years - Color Shape Game (Rule Switch)`;
    default:
      return `Age ${ageInYears} years - Outside valid range (2-6 years)`;
  }
};

/**
 * Log age calculation details to console (for debugging/database)
 */
export const logAgeDetails = (child: { name: string; dateOfBirth: string }): void => {
  const ageDetails = calculateAge(child.dateOfBirth);
  const ageGroup = getAgeGroup(child.dateOfBirth);
  const assessmentType = getAssessmentType(child.dateOfBirth);
  
  console.log('\n');
  console.log('╔════════════════════════════════════════════════════════════╗');
  console.log('║                                                            ║');
  console.log('║           📅 AGE CALCULATION                              ║');
  console.log('║                                                            ║');
  console.log('╚════════════════════════════════════════════════════════════╝');
  console.log('\n👶 Child:', child.name);
  console.log('🎂 Date of Birth:', child.dateOfBirth);
  console.log('📅 Assessment Date:', new Date().toISOString().split('T')[0]);
  console.log('\n📊 Age Details:');
  console.log('   Exact Age:', ageDetails.ageInYears, 'years');
  console.log('   Years:', ageDetails.years);
  console.log('   Months:', ageDetails.months);
  console.log('   Days:', ageDetails.days);
  console.log('   Total Months:', ageDetails.totalMonths);
  console.log('\n🎯 Assessment Routing:');
  console.log('   Age Group:', ageGroup);
  console.log('   Assessment Type:', assessmentType.toUpperCase());
  console.log('\n════════════════════════════════════════════════════════════\n');
};







