/**
 * Children Routes - Handle child profile data
 */

import express, { Request, Response } from 'express';
import { db } from '../config/firebase';
import { childSchema, validate } from '../utils/validation';
import logger from '../utils/logger';

const router = express.Router();

/**
 * POST /api/children
 * Create a new child profile
 */
router.post('/', validate(childSchema), async (req: Request, res: Response) => {
  try {
    const childData = req.body;
    logger.info(`📥 Creating child profile: ${childData.name}`);

    // Generate child ID if not provided
    const childId = `child_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

    const childDoc = {
      ...childData,
      id: childId,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      testCompleted: false,
    };

    // Save to Firestore
    const docRef = db
      .collection('clinics')
      .doc(childData.hospitalId)
      .collection('children')
      .doc(childId);

    await docRef.set(childDoc);

    logger.info(`✅ Child profile created: ${childId}`);

    res.status(201).json({
      success: true,
      message: 'Child profile created successfully',
      data: {
        childId,
        ...childDoc,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error creating child: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error creating child profile',
      error: error.message,
    });
  }
});

/**
 * GET /api/children
 * Get all children for a clinic
 */
router.get('/', async (req: Request, res: Response) => {
  try {
    const { clinicId } = req.query;

    if (!clinicId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId is required',
      });
    }

    const querySnapshot = await db
      .collection('clinics')
      .doc(clinicId as string)
      .collection('children')
      .orderBy('createdAt', 'desc')
      .get();

    const children = querySnapshot.docs.map(doc => ({
      ...doc.data(),
      id: doc.id,
    }));

    res.json({
      success: true,
      data: {
        children,
        count: children.length,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error fetching children: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching children',
      error: error.message,
    });
  }
});

/**
 * GET /api/children/:childId
 * Get a specific child
 */
router.get('/:childId', async (req: Request, res: Response) => {
  try {
    const { childId } = req.params;
    const { clinicId } = req.query;

    if (!clinicId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId is required',
      });
    }

    const docRef = db
      .collection('clinics')
      .doc(clinicId as string)
      .collection('children')
      .doc(childId);

    const doc = await docRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Child not found',
      });
    }

    res.json({
      success: true,
      data: {
        ...doc.data(),
        id: doc.id,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error fetching child: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error fetching child',
      error: error.message,
    });
  }
});

/**
 * PUT /api/children/:childId
 * Update a child profile
 */
router.put('/:childId', async (req: Request, res: Response) => {
  try {
    const { childId } = req.params;
    const { clinicId, ...updateData } = req.body;

    if (!clinicId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId is required',
      });
    }

    const docRef = db
      .collection('clinics')
      .doc(clinicId)
      .collection('children')
      .doc(childId);

    // Check if child exists
    const doc = await docRef.get();
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Child not found',
      });
    }

    // Update the document
    await docRef.update({
      ...updateData,
      updatedAt: new Date().toISOString(),
    });

    logger.info(`✅ Child updated: ${childId}`);

    res.json({
      success: true,
      message: 'Child profile updated successfully',
      data: {
        childId,
        ...updateData,
      },
    });

  } catch (error: any) {
    logger.error(`❌ Error updating child: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error updating child profile',
      error: error.message,
    });
  }
});

/**
 * DELETE /api/children/:childId
 * Delete a child profile
 */
router.delete('/:childId', async (req: Request, res: Response) => {
  try {
    const { childId } = req.params;
    const { clinicId } = req.query;

    if (!clinicId) {
      return res.status(400).json({
        success: false,
        message: 'clinicId is required',
      });
    }

    const docRef = db
      .collection('clinics')
      .doc(clinicId as string)
      .collection('children')
      .doc(childId);

    // Check if child exists
    const doc = await docRef.get();
    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        message: 'Child not found',
      });
    }

    // Delete the document
    await docRef.delete();

    logger.info(`✅ Child deleted: ${childId}`);

    res.json({
      success: true,
      message: 'Child profile deleted successfully',
    });

  } catch (error: any) {
    logger.error(`❌ Error deleting child: ${error.message}`);
    res.status(500).json({
      success: false,
      message: 'Error deleting child profile',
      error: error.message,
    });
  }
});

export default router;






