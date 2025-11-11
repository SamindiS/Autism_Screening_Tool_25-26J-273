/**
 * Joi Validation Schemas for API Requests
 */

import Joi from 'joi';

// Session data validation schema
export const sessionSchema = Joi.object({
  session_id: Joi.string().required(),
  clinic_id: Joi.string().required(),
  clinician_id: Joi.string().required(),
  child: Joi.object({
    child_id: Joi.string().required(),
    name: Joi.string().optional(),
    age_years: Joi.number().min(2).max(6).required(),
    gender: Joi.string().valid('male', 'female').required(),
    language: Joi.string().valid('en', 'si', 'ta').required(),
    dateOfBirth: Joi.string().optional(),
  }).required(),
  assessment_type: Joi.string().valid('ai_bot', 'frog_jump', 'color_shape').required(),
  timestamp_start: Joi.string().isoDate().required(),
  timestamp_end: Joi.string().isoDate().optional(),
  device_id: Joi.string().optional(),
  
  // Game data (optional, only for game-based assessments)
  game_data: Joi.object({
    total_trials: Joi.number().integer().min(0).optional(),
    correct_responses: Joi.number().integer().min(0).optional(),
    incorrect_responses: Joi.number().integer().min(0).optional(),
    mean_rt_ms: Joi.number().min(0).optional(),
    switch_cost_ms: Joi.number().optional(),
    inhibition_errors: Joi.number().integer().min(0).optional(),
    accuracy_percent: Joi.number().min(0).max(100).optional(),
    recovery_trials: Joi.number().integer().min(0).optional(),
    trials: Joi.array().items(Joi.object()).optional(),
  }).optional(),
  
  // Questionnaire data (optional, for AI Bot)
  questionnaire_data: Joi.object().optional(),
  
  // Clinical reflection data (optional)
  clinical_reflection: Joi.object().optional(),
  
  // Computed summary
  computed_summary: Joi.object().optional(),
});

// Child registration validation schema
export const childSchema = Joi.object({
  name: Joi.string().required(),
  dateOfBirth: Joi.string().required(),
  age: Joi.number().min(2).max(6).required(),
  gender: Joi.string().valid('male', 'female').required(),
  language: Joi.string().valid('en', 'si', 'ta').required(),
  hospitalId: Joi.string().required(),
  hospitalName: Joi.string().optional(),
});

// Clinician registration validation schema
export const clinicianSchema = Joi.object({
  username: Joi.string().min(3).max(50).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  fullName: Joi.string().required(),
  clinicId: Joi.string().required(),
  hospitalName: Joi.string().optional(),
  role: Joi.string().valid('doctor', 'admin').default('doctor'),
});

// Login validation schema
export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

// ML prediction request schema
export const mlPredictSchema = Joi.object({
  sessionId: Joi.string().required(),
  features: Joi.object().required(),
});

// Validation middleware
export const validate = (schema: Joi.ObjectSchema) => {
  return (req: any, res: any, next: any) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const errors = error.details.map((detail) => detail.message);
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors,
      });
    }

    req.body = value;
    next();
  };
};






