/**
 * Authentication Service
 */

import { auth, db } from '../config/firebase';
import { AppError } from '../middleware/errorHandler';
import { HTTP_STATUS, USER_ROLES } from '../config/constants';
import logger from '../utils/logger';

export class AuthService {
  /**
   * Register a new user
   */
  async registerUser(data: {
    email: string;
    password: string;
    fullName: string;
    role?: string;
    clinicId?: string;
  }) {
    try {
      // Create Firebase Auth user
      const userRecord = await auth.createUser({
        email: data.email,
        password: data.password,
        displayName: data.fullName,
      });

      // Set custom claims for role
      await auth.setCustomUserClaims(userRecord.uid, {
        role: data.role || USER_ROLES.CLINICIAN,
      });

      // Create user document in Firestore
      await db.collection('users').doc(userRecord.uid).set({
        uid: userRecord.uid,
        email: data.email,
        fullName: data.fullName,
        role: data.role || USER_ROLES.CLINICIAN,
        clinicId: data.clinicId || null,
        isActive: true,
        isVerified: false,
        twoFactorEnabled: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
      });

      logger.info(`User registered: ${userRecord.uid}`);

      return {
        uid: userRecord.uid,
        email: data.email,
        fullName: data.fullName,
        role: data.role || USER_ROLES.CLINICIAN,
      };
    } catch (error: any) {
      logger.error('User registration failed', error);
      if (error.code === 'auth/email-already-exists') {
        throw new AppError('Email already in use', HTTP_STATUS.CONFLICT);
      }
      throw new AppError('Registration failed', HTTP_STATUS.INTERNAL_ERROR);
    }
  }

  /**
   * Get user profile
   */
  async getUserProfile(uid: string) {
    try {
      const userDoc = await db.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw new AppError('User not found', HTTP_STATUS.NOT_FOUND);
      }

      return userDoc.data();
    } catch (error) {
      logger.error(`Failed to get user profile: ${uid}`, error);
      throw error;
    }
  }

  /**
   * Update user profile
   */
  async updateUserProfile(uid: string, updates: any) {
    try {
      await db
        .collection('users')
        .doc(uid)
        .update({
          ...updates,
          updatedAt: new Date().toISOString(),
        });

      logger.info(`User profile updated: ${uid}`);
      return { success: true };
    } catch (error) {
      logger.error(`Failed to update user profile: ${uid}`, error);
      throw new AppError('Profile update failed', HTTP_STATUS.INTERNAL_ERROR);
    }
  }

  /**
   * Delete user account
   */
  async deleteUser(uid: string) {
    try {
      // Delete from Auth
      await auth.deleteUser(uid);

      // Delete user document
      await db.collection('users').doc(uid).delete();

      logger.info(`User deleted: ${uid}`);
      return { success: true };
    } catch (error) {
      logger.error(`Failed to delete user: ${uid}`, error);
      throw new AppError('User deletion failed', HTTP_STATUS.INTERNAL_ERROR);
    }
  }

  /**
   * Send password reset email
   */
  async sendPasswordResetEmail(email: string) {
    try {
      const link = await auth.generatePasswordResetLink(email);
      logger.info(`Password reset link generated for: ${email}`);
      return { link };
    } catch (error) {
      logger.error(`Failed to generate password reset link: ${email}`, error);
      throw new AppError(
        'Password reset failed',
        HTTP_STATUS.INTERNAL_ERROR
      );
    }
  }

  /**
   * Verify email
   */
  async verifyEmail(uid: string) {
    try {
      await db.collection('users').doc(uid).update({
        isVerified: true,
        updatedAt: new Date().toISOString(),
      });

      logger.info(`Email verified for user: ${uid}`);
      return { success: true };
    } catch (error) {
      logger.error(`Email verification failed: ${uid}`, error);
      throw new AppError(
        'Email verification failed',
        HTTP_STATUS.INTERNAL_ERROR
      );
    }
  }
}

export default new AuthService();







