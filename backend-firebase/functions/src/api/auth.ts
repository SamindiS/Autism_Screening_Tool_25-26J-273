/**
 * Authentication API Routes
 */

import express from 'express';
import * as admin from 'firebase-admin';
import { asyncHandler } from '../middleware/errorHandler';
import { validate, registerUserSchema, loginSchema } from '../utils/validation';
import { logger } from '../utils/logger';
import { SUCCESS_MESSAGES, ERROR_MESSAGES, CONSTANTS } from '../config/constants';

export const router = express.Router();

/**
 * POST /auth/register
 * Register a new user (doctor/admin)
 */
router.post(
  '/register',
  asyncHandler(async (req, res) => {
    // Validate request body
    const validatedData = validate(registerUserSchema)(req.body);

    const { email, password, name, role, clinic, phone } = validatedData;

    logger.info('Creating new user', { email, role });

    // Create user in Firebase Auth
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
      emailVerified: false,
    });

    // Set custom claims for role-based access
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      role: role || CONSTANTS.ROLES.DOCTOR,
    });

    // Create user profile in Firestore
    await admin
      .firestore()
      .collection('users')
      .doc(userRecord.uid)
      .set({
        uid: userRecord.uid,
        email,
        name,
        role: role || CONSTANTS.ROLES.DOCTOR,
        clinic: clinic || null,
        phone: phone || null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        active: true,
        emailVerified: false,
      });

    logger.info('User created successfully', {
      uid: userRecord.uid,
      email,
      role,
    });

    res.status(201).json({
      message: SUCCESS_MESSAGES.USER_CREATED,
      user: {
        uid: userRecord.uid,
        email,
        name,
        role,
      },
    });
  })
);

/**
 * POST /auth/login
 * Login user (handled by Firebase Client SDK, but this validates credentials)
 */
router.post(
  '/login',
  asyncHandler(async (req, res) => {
    // Validate request body
    const validatedData = validate(loginSchema)(req.body);

    const { email } = validatedData;

    // Get user by email
    const userRecord = await admin.auth().getUserByEmail(email);

    // Get user profile from Firestore
    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(userRecord.uid)
      .get();

    if (!userDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'User profile not found',
      });
    }

    const userData = userDoc.data();

    // Check if user is active
    if (!userData?.active) {
      return res.status(403).json({
        error: ERROR_MESSAGES.FORBIDDEN,
        message: 'User account is deactivated',
      });
    }

    logger.info('User login validated', { uid: userRecord.uid, email });

    res.json({
      message: 'Login validated successfully',
      user: {
        uid: userRecord.uid,
        email: userData?.email,
        name: userData?.name,
        role: userData?.role,
      },
    });
  })
);

/**
 * GET /auth/me
 * Get current user profile
 */
router.get(
  '/me',
  asyncHandler(async (req, res) => {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: ERROR_MESSAGES.UNAUTHORIZED,
        message: 'No token provided',
      });
    }

    const token = authHeader.split('Bearer ')[1];

    // Verify token
    const decodedToken = await admin.auth().verifyIdToken(token);

    // Get user profile
    const userDoc = await admin
      .firestore()
      .collection('users')
      .doc(decodedToken.uid)
      .get();

    if (!userDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'User profile not found',
      });
    }

    const userData = userDoc.data();

    res.json({
      user: {
        uid: decodedToken.uid,
        email: userData?.email,
        name: userData?.name,
        role: userData?.role,
        clinic: userData?.clinic,
        phone: userData?.phone,
        emailVerified: userData?.emailVerified,
        createdAt: userData?.createdAt,
      },
    });
  })
);

/**
 * PUT /auth/update-profile
 * Update user profile
 */
router.put(
  '/update-profile',
  asyncHandler(async (req, res) => {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        error: ERROR_MESSAGES.UNAUTHORIZED,
        message: 'No token provided',
      });
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);

    const { name, clinic, phone } = req.body;

    // Update Firestore profile
    await admin
      .firestore()
      .collection('users')
      .doc(decodedToken.uid)
      .update({
        ...(name && { name }),
        ...(clinic && { clinic }),
        ...(phone && { phone }),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    // Update Firebase Auth display name if provided
    if (name) {
      await admin.auth().updateUser(decodedToken.uid, {
        displayName: name,
      });
    }

    logger.info('User profile updated', { uid: decodedToken.uid });

    res.json({
      message: SUCCESS_MESSAGES.DATA_UPDATED,
      user: {
        uid: decodedToken.uid,
        name,
        clinic,
        phone,
      },
    });
  })
);

/**
 * POST /auth/send-verification-email
 * Send email verification (handled by Firebase Client SDK)
 */
router.post(
  '/send-verification-email',
  asyncHandler(async (req, res) => {
    const { uid } = req.body;

    // Generate email verification link
    const link = await admin.auth().generateEmailVerificationLink(req.body.email);

    logger.info('Email verification link generated', { uid });

    res.json({
      message: 'Email verification link generated',
      link, // In production, send this via email service
    });
  })
);

export default router;







