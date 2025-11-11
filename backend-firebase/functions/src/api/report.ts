/**
 * Report Generation API
 * Handles PDF report creation and storage
 */

import express from 'express';
import * as admin from 'firebase-admin';
import PDFDocument from 'pdfkit';
import { Storage } from '@google-cloud/storage';
import { asyncHandler } from '../middleware/errorHandler';
import { verifyToken, verifyOwnership } from '../middleware/auth';
import { validate, reportSchema } from '../utils/validation';
import { logger } from '../utils/logger';
import { SUCCESS_MESSAGES, ERROR_MESSAGES } from '../config/constants';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';

export const router = express.Router();

// All routes require authentication
router.use(verifyToken);

// Initialize Google Cloud Storage
const storage = new Storage();
const bucketName = process.env.FIREBASE_STORAGE_BUCKET || '';

/**
 * POST /report/generate
 * Generate PDF report for an assessment
 */
router.post(
  '/generate',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    // Validate request
    const validatedData = validate(reportSchema)(req.body);

    const { userId, childId, assessmentId, language, includeGraphs, includeRecommendations } =
      validatedData;

    logger.info('Generating report', { userId, childId, assessmentId });

    // Get child data
    const childDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .get();

    if (!childDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Child not found',
      });
    }

    // Get assessment data
    const assessmentDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(assessmentId)
      .get();

    if (!assessmentDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Assessment not found',
      });
    }

    const childData = childDoc.data();
    const assessmentData = assessmentDoc.data();

    // Generate PDF
    const fileName = `report_${childId}_${assessmentId}_${Date.now()}.pdf`;
    const tempFilePath = path.join(os.tmpdir(), fileName);

    await generatePDF(tempFilePath, childData, assessmentData, {
      includeGraphs,
      includeRecommendations,
      language,
    });

    // Upload to Firebase Storage
    const bucket = storage.bucket(bucketName);
    const destination = `reports/${userId}/${childId}/${fileName}`;

    await bucket.upload(tempFilePath, {
      destination,
      metadata: {
        contentType: 'application/pdf',
        metadata: {
          childId,
          assessmentId,
          userId,
          generatedAt: new Date().toISOString(),
        },
      },
    });

    // Generate signed URL (valid for 7 days)
    const file = bucket.file(destination);
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: Date.now() + 7 * 24 * 60 * 60 * 1000, // 7 days
    });

    // Clean up temp file
    fs.unlinkSync(tempFilePath);

    // Save report reference to Firestore
    await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(assessmentId)
      .update({
        report: {
          fileName,
          url,
          generatedAt: admin.firestore.FieldValue.serverTimestamp(),
          language,
        },
      });

    logger.info('Report generated successfully', {
      userId,
      childId,
      assessmentId,
      fileName,
    });

    res.json({
      message: SUCCESS_MESSAGES.REPORT_GENERATED,
      report: {
        fileName,
        url,
        generatedAt: new Date().toISOString(),
      },
    });
  })
);

/**
 * GET /report/:userId/:childId/:assessmentId
 * Get existing report for an assessment
 */
router.get(
  '/:userId/:childId/:assessmentId',
  verifyOwnership,
  asyncHandler(async (req, res) => {
    const { userId, childId, assessmentId } = req.params;

    logger.info('Fetching report', { userId, childId, assessmentId });

    // Get assessment with report info
    const assessmentDoc = await admin
      .firestore()
      .collection('users')
      .doc(userId)
      .collection('children')
      .doc(childId)
      .collection('assessments')
      .doc(assessmentId)
      .get();

    if (!assessmentDoc.exists) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Assessment not found',
      });
    }

    const assessmentData = assessmentDoc.data();

    if (!assessmentData?.report) {
      return res.status(404).json({
        error: ERROR_MESSAGES.NOT_FOUND,
        message: 'Report not generated yet',
      });
    }

    res.json({
      report: assessmentData.report,
    });
  })
);

/**
 * Generate PDF document
 */
async function generatePDF(
  filePath: string,
  childData: any,
  assessmentData: any,
  options: any
) {
  return new Promise<void>((resolve, reject) => {
    try {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });
      const stream = fs.createWriteStream(filePath);

      doc.pipe(stream);

      // Header
      doc
        .fontSize(24)
        .fillColor('#2E86AB')
        .text('SenseAI Autism Screening Report', { align: 'center' });

      doc.moveDown();

      // Child Information
      doc
        .fontSize(16)
        .fillColor('#000000')
        .text('Child Information', { underline: true });

      doc.moveDown(0.5);

      doc.fontSize(12);
      doc.text(`Name: ${childData?.name || 'N/A'}`);
      doc.text(`Age: ${childData?.age || 'N/A'} years`);
      doc.text(`Gender: ${childData?.gender === 'M' ? 'Male' : 'Female'}`);
      doc.text(
        `Date of Birth: ${
          childData?.dateOfBirth
            ? new Date(childData.dateOfBirth.toDate()).toLocaleDateString()
            : 'N/A'
        }`
      );

      doc.moveDown(1.5);

      // Assessment Information
      doc.fontSize(16).text('Assessment Information', { underline: true });

      doc.moveDown(0.5);

      doc.fontSize(12);
      doc.text(`Assessment Type: ${formatAssessmentType(assessmentData?.assessmentType)}`);
      doc.text(
        `Date: ${
          assessmentData?.createdAt
            ? new Date(assessmentData.createdAt.toDate()).toLocaleDateString()
            : 'N/A'
        }`
      );
      doc.text(`Duration: ${Math.round(assessmentData?.duration / 60)} minutes`);
      doc.text(`Language: ${formatLanguage(assessmentData?.language)}`);

      doc.moveDown(1.5);

      // Results
      doc.fontSize(16).text('Results', { underline: true });

      doc.moveDown(0.5);

      const gameResults = assessmentData?.gameResults;
      if (gameResults) {
        doc.fontSize(12);
        doc.text(`Total Trials: ${gameResults.totalTrials || 0}`);
        doc.text(`Correct Trials: ${gameResults.correctTrials || 0}`);
        doc.text(`Accuracy: ${gameResults.accuracy?.toFixed(1) || 0}%`);
        doc.text(`Average Reaction Time: ${gameResults.avgReactionTime || 0} ms`);
        if (gameResults.switchCost) {
          doc.text(`Switch Cost: ${gameResults.switchCost} ms`);
        }
      }

      doc.moveDown(1.5);

      // Risk Assessment
      doc.fontSize(16).text('Risk Assessment', { underline: true });

      doc.moveDown(0.5);

      doc.fontSize(12);
      doc.text(`Risk Score: ${assessmentData?.riskScore || 0}/100`);

      const riskLevel = assessmentData?.riskLevel || 'unknown';
      const riskColor =
        riskLevel === 'low' ? '#06D6A0' : riskLevel === 'moderate' ? '#FFD166' : '#EF476F';

      doc.fillColor(riskColor);
      doc.fontSize(14).text(`Risk Level: ${riskLevel.toUpperCase()}`, { bold: true });

      doc.fillColor('#000000');
      doc.moveDown(1.5);

      // Recommendations (if enabled)
      if (options.includeRecommendations) {
        doc.fontSize(16).text('Recommendations', { underline: true });

        doc.moveDown(0.5);

        doc.fontSize(12);
        const recommendations = generateRecommendations(assessmentData);
        recommendations.forEach((rec: string, index: number) => {
          doc.text(`${index + 1}. ${rec}`);
          doc.moveDown(0.3);
        });

        doc.moveDown(1);
      }

      // Clinician Notes
      if (assessmentData?.clinicianNotes) {
        doc.fontSize(16).text('Clinician Notes', { underline: true });

        doc.moveDown(0.5);

        doc.fontSize(12).text(assessmentData.clinicianNotes);

        doc.moveDown(1);
      }

      // Footer
      doc
        .fontSize(10)
        .fillColor('#999999')
        .text('Generated by SenseAI - Professional Autism Screening System', {
          align: 'center',
        });

      doc.text(`Report generated on ${new Date().toLocaleDateString()}`, {
        align: 'center',
      });

      doc.end();

      stream.on('finish', () => {
        resolve();
      });

      stream.on('error', (error) => {
        reject(error);
      });
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * Helper functions
 */
function formatAssessmentType(type: string): string {
  const types: { [key: string]: string } = {
    ai_bot: 'AI Doctor Bot Questionnaire',
    frog_jump: 'Frog Jump (Go/No-Go)',
    rule_switch: 'Rule Switch (DCCS)',
  };
  return types[type] || type;
}

function formatLanguage(lang: string): string {
  const languages: { [key: string]: string } = {
    en: 'English',
    si: 'Sinhala',
    ta: 'Tamil',
  };
  return languages[lang] || lang;
}

function generateRecommendations(assessmentData: any): string[] {
  const recommendations: string[] = [];
  const riskLevel = assessmentData?.riskLevel;
  const accuracy = assessmentData?.gameResults?.accuracy || 0;

  if (riskLevel === 'low') {
    recommendations.push('Continue regular developmental monitoring');
    recommendations.push('Maintain current cognitive stimulation activities');
    recommendations.push('Schedule follow-up assessment in 6 months');
  } else if (riskLevel === 'moderate') {
    recommendations.push('Consider comprehensive developmental assessment');
    recommendations.push('Implement cognitive flexibility exercises');
    recommendations.push('Schedule follow-up assessment in 3 months');
    recommendations.push('Monitor for changes in behavioral patterns');
  } else {
    recommendations.push('Refer for comprehensive clinical evaluation');
    recommendations.push('Consider early intervention programs');
    recommendations.push('Schedule follow-up assessment in 1 month');
    recommendations.push('Consult with developmental specialist');
  }

  if (accuracy < 60) {
    recommendations.push('Focus on task understanding and attention training');
  }

  return recommendations;
}

export default router;







