const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const axios = require('axios');

// Create uploads directory if it doesn't exist
const uploadsDir = path.join(__dirname, '../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadsDir);
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, 'video-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024 // 100MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /mp4|avi|mov|mkv/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (extname && mimetype) {
      return cb(null, true);
    } else {
      cb(new Error('Only video files are allowed (mp4, avi, mov, mkv)'));
    }
  }
});

// Upload video endpoint
router.post('/upload', upload.single('video'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No video file uploaded'
      });
    }

    console.log(`📹 Video uploaded: ${req.file.filename}`);
    console.log(`📊 Size: ${(req.file.size / 1024 / 1024).toFixed(2)} MB`);

    // Send video to ML service for detection
    const mlServiceUrl = process.env.ML_SERVICE_URL || 'http://localhost:5000/api/v1';
    const videoPath = req.file.path;

    console.log(`🤖 Sending to ML service: ${mlServiceUrl}/detect`);

    // Create form data for ML service
    const FormData = require('form-data');
    const formData = new FormData();
    formData.append('video', fs.createReadStream(videoPath));

    try {
      const mlResponse = await axios.post(`${mlServiceUrl}/detect`, formData, {
        headers: {
          ...formData.getHeaders()
        },
        maxContentLength: Infinity,
        maxBodyLength: Infinity,
        timeout: 300000 // 5 minutes timeout
      });

      console.log('✅ ML service response received');

      // Return combined response
      res.json({
        success: true,
        message: 'Video processed successfully',
        video: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          uploadedAt: new Date().toISOString()
        },
        detection: mlResponse.data
      });

    } catch (mlError) {
      console.error('❌ ML service error:', mlError.message);
      
      // Return error but keep video info
      res.status(500).json({
        success: false,
        message: 'Video uploaded but detection failed',
        error: mlError.response?.data?.error || mlError.message,
        video: {
          filename: req.file.filename,
          originalName: req.file.originalname,
          size: req.file.size,
          uploadedAt: new Date().toISOString()
        }
      });
    }

  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({
      success: false,
      message: 'Video upload failed',
      error: error.message
    });
  }
});

// Get video list endpoint
router.get('/list', (req, res) => {
  try {
    const files = fs.readdirSync(uploadsDir);
    const videos = files
      .filter(file => /\.(mp4|avi|mov|mkv)$/i.test(file))
      .map(file => {
        const stats = fs.statSync(path.join(uploadsDir, file));
        return {
          filename: file,
          size: stats.size,
          uploadedAt: stats.birthtime
        };
      });

    res.json({
      success: true,
      count: videos.length,
      videos
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to list videos',
      error: error.message
    });
  }
});

// Delete video endpoint
router.delete('/:filename', (req, res) => {
  try {
    const filename = req.params.filename;
    const filePath = path.join(uploadsDir, filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({
        success: false,
        message: 'Video not found'
      });
    }

    fs.unlinkSync(filePath);

    res.json({
      success: true,
      message: 'Video deleted successfully'
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Failed to delete video',
      error: error.message
    });
  }
});

module.exports = router;

