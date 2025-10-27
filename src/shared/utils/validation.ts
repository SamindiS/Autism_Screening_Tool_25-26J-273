/**
 * Validation Utilities
 * Form validation functions
 */

export const validation = {
  // Email validation
  isValidEmail: (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },

  // Password validation (minimum 8 characters)
  isValidPassword: (password: string): boolean => {
    return password.length >= 8;
  },

  // Password strength (returns score 0-4)
  getPasswordStrength: (password: string): number => {
    let strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
    if (/\d/.test(password)) strength++;
    if (/[^a-zA-Z0-9]/.test(password)) strength++;
    return Math.min(strength, 4);
  },

  // Age validation (2-6 years for this app)
  isValidAge: (age: number): boolean => {
    return age >= 2 && age <= 6;
  },

  // Name validation (non-empty, reasonable length)
  isValidName: (name: string): boolean => {
    return name.trim().length >= 2 && name.trim().length <= 100;
  },

  // Phone validation (basic)
  isValidPhone: (phone: string): boolean => {
    const phoneRegex = /^[+]?[(]?[0-9]{3}[)]?[-\s.]?[0-9]{3}[-\s.]?[0-9]{4,6}$/;
    return phoneRegex.test(phone);
  },

  // Required field validation
  isRequired: (value: any): boolean => {
    if (typeof value === 'string') {
      return value.trim().length > 0;
    }
    return value !== null && value !== undefined;
  },

  // Match validation (for password confirmation)
  matches: (value1: string, value2: string): boolean => {
    return value1 === value2;
  },

  // Minimum length validation
  minLength: (value: string, length: number): boolean => {
    return value.length >= length;
  },

  // Maximum length validation
  maxLength: (value: string, length: number): boolean => {
    return value.length <= length;
  },

  // Number range validation
  inRange: (value: number, min: number, max: number): boolean => {
    return value >= min && value <= max;
  },
};

// Validation error messages
export const validationMessages = {
  required: 'This field is required',
  email: 'Please enter a valid email address',
  password: 'Password must be at least 8 characters',
  passwordMatch: 'Passwords do not match',
  age: 'Age must be between 2 and 6 years',
  name: 'Please enter a valid name (2-100 characters)',
  phone: 'Please enter a valid phone number',
  minLength: (length: number) => `Must be at least ${length} characters`,
  maxLength: (length: number) => `Must not exceed ${length} characters`,
  range: (min: number, max: number) => `Must be between ${min} and ${max}`,
};

// Form validator function
export interface ValidationRule {
  validator: (value: any, formData?: any) => boolean;
  message: string;
}

export const validateField = (
  value: any,
  rules: ValidationRule[],
  formData?: any
): string | null => {
  for (const rule of rules) {
    if (!rule.validator(value, formData)) {
      return rule.message;
    }
  }
  return null;
};

// Common validation rules
export const commonRules = {
  required: (): ValidationRule => ({
    validator: validation.isRequired,
    message: validationMessages.required,
  }),
  email: (): ValidationRule => ({
    validator: validation.isValidEmail,
    message: validationMessages.email,
  }),
  password: (): ValidationRule => ({
    validator: validation.isValidPassword,
    message: validationMessages.password,
  }),
  age: (): ValidationRule => ({
    validator: validation.isValidAge,
    message: validationMessages.age,
  }),
  name: (): ValidationRule => ({
    validator: validation.isValidName,
    message: validationMessages.name,
  }),
  minLength: (length: number): ValidationRule => ({
    validator: (value) => validation.minLength(value, length),
    message: validationMessages.minLength(length),
  }),
  maxLength: (length: number): ValidationRule => ({
    validator: (value) => validation.maxLength(value, length),
    message: validationMessages.maxLength(length),
  }),
  matches: (field: string): ValidationRule => ({
    validator: (value, formData) => validation.matches(value, formData?.[field]),
    message: validationMessages.passwordMatch,
  }),
};



