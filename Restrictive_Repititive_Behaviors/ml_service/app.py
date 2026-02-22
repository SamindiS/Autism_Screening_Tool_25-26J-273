import os
os.environ['TF_USE_LEGACY_KERAS'] = '1'  # Use tf-keras instead of keras 3.x
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'  # Suppress TensorFlow warnings
os.environ['CUDA_VISIBLE_DEVICES'] = '-1'  # Force CPU to prevent GPU memory issues

from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
import uuid
from datetime import datetime
import traceback
import logging
import sys

from config import Config
from utils.inference import RRBInference
from utils.video_validator import VideoValidator

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Load configuration
app.config.from_object(Config)
Config.init_app(app)

# Initialize inference engine (lazy loading)
inference_engine = None
video_validator = VideoValidator()

def get_inference_engine():
    """Get or initialize inference engine"""
    global inference_engine

    if inference_engine is None:
        model_path = Config.MODEL_PATH
        label_encoder_path = Config.LABEL_ENCODER_PATH

        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model not found at {model_path}")

        if not os.path.exists(label_encoder_path):
            raise FileNotFoundError(f"Label encoder not found at {label_encoder_path}")

        inference_engine = RRBInference(
            model_path=model_path,
            label_encoder_path=label_encoder_path,
            sequence_length=Config.SEQUENCE_LENGTH,
            img_size=Config.IMG_SIZE,
            confidence_threshold=Config.CONFIDENCE_THRESHOLD,
            min_duration=Config.MIN_DETECTION_DURATION
        )

    return inference_engine

def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in Config.ALLOWED_EXTENSIONS

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'RRB Detection ML Service',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/v1/detect', methods=['POST'])
def detect_rrb():
    """
    Main RRB detection endpoint

    Expected: multipart/form-data with 'video' file
    Returns: JSON with detection results
    """
    upload_path = None
    repaired_path = None

    try:
        # Check if video file is present
        if 'video' not in request.files:
            return jsonify({
                'success': False,
                'error': 'No video file provided'
            }), 400

        file = request.files['video']

        # Check if file is selected
        if file.filename == '':
            return jsonify({
                'success': False,
                'error': 'No file selected'
            }), 400

        # Check file extension
        if not allowed_file(file.filename):
            return jsonify({
                'success': False,
                'error': f'Invalid file type. Allowed types: {Config.ALLOWED_EXTENSIONS}'
            }), 400

        # Save uploaded file
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        upload_path = os.path.join(Config.UPLOAD_FOLDER, unique_filename)
        file.save(upload_path)

        file_size_bytes = os.path.getsize(upload_path)
        file_size_mb = file_size_bytes / (1024 * 1024)
        logger.info(f"Video uploaded: {filename} ({file_size_mb:.2f} MB)")

        # Check file size limit (100MB max to prevent memory issues)
        MAX_FILE_SIZE_MB = 100
        if file_size_mb > MAX_FILE_SIZE_MB:
            if os.path.exists(upload_path):
                os.remove(upload_path)
            return jsonify({
                'success': False,
                'error': f'Video file too large ({file_size_mb:.1f}MB). Maximum size is {MAX_FILE_SIZE_MB}MB.',
                'details': 'Please use a shorter video or reduce the video quality/resolution.'
            }), 400

        # Validate video
        is_valid, error_msg, video_info = video_validator.validate_video(upload_path)

        if not is_valid:
            logger.warning(f"Video validation failed: {error_msg}")

            # Attempt to repair video
            logger.info("Attempting to repair video...")
            repair_success, repair_msg, repaired_path = video_validator.repair_video(upload_path)

            if repair_success and repaired_path:
                logger.info(f"Video repaired successfully: {repair_msg}")
                # Use repaired video for processing
                processing_path = repaired_path
            else:
                # Clean up and return error
                if os.path.exists(upload_path):
                    os.remove(upload_path)

                return jsonify({
                    'success': False,
                    'error': f'Video validation failed: {error_msg}',
                    'details': 'The video file appears to be corrupted or in an unsupported format. Please try re-encoding the video to MP4 (H.264) format.',
                    'repair_attempted': True,
                    'repair_result': repair_msg
                }), 400
        else:
            logger.info(f"Video validated successfully: {video_info}")
            processing_path = upload_path

        # Get inference engine
        try:
            engine = get_inference_engine()
        except Exception as e:
            logger.error(f"Failed to initialize inference engine: {str(e)}")
            if upload_path and os.path.exists(upload_path):
                os.remove(upload_path)
            if repaired_path and os.path.exists(repaired_path):
                os.remove(repaired_path)
            return jsonify({
                'success': False,
                'error': 'Failed to initialize ML model',
                'details': str(e)
            }), 500

        # Perform detection with comprehensive error handling
        logger.info("Starting RRB detection...")
        try:
            result = engine.detect_rrb(processing_path)

            # Check if detection returned an error
            if 'error' in result and result.get('detected') == False:
                logger.error(f"Detection failed: {result.get('error')}")
                raise ValueError(result.get('error'))

            logger.info("Detection completed successfully")

        except MemoryError as e:
            logger.error(f"Out of memory during detection: {str(e)}")
            if upload_path and os.path.exists(upload_path):
                os.remove(upload_path)
            if repaired_path and os.path.exists(repaired_path):
                os.remove(repaired_path)
            return jsonify({
                'success': False,
                'error': 'Video too large to process',
                'details': 'The video requires too much memory. Please use a shorter or lower resolution video.'
            }), 413

        except Exception as e:
            logger.error(f"Error during detection: {str(e)}", exc_info=True)
            if upload_path and os.path.exists(upload_path):
                os.remove(upload_path)
            if repaired_path and os.path.exists(repaired_path):
                os.remove(repaired_path)
            return jsonify({
                'success': False,
                'error': f'Detection failed: {str(e)}',
                'details': 'An error occurred while analyzing the video. Please try a different video or contact support.',
                'traceback': traceback.format_exc() if Config.DEBUG else None
            }), 500

        # Clean up uploaded files
        if upload_path and os.path.exists(upload_path):
            os.remove(upload_path)
        if repaired_path and os.path.exists(repaired_path):
            os.remove(repaired_path)

        # Format response
        response = {
            'success': True,
            'timestamp': datetime.now().isoformat(),
            'filename': filename,
            'detection': {
                'detected': result['detected'],
                'primary_behavior': result['primary_behavior'],
                'confidence': result['confidence'],
                'behaviors': result['behaviors']
            },
            'metadata': {
                'video_duration': result['video_info'].get('duration', 0),
                'video_fps': result['video_info'].get('fps', 0),
                'sequences_analyzed': result.get('total_sequences_analyzed', 0),
                'sequences_with_detections': result.get('sequences_with_detections', 0)
            }
        }

        return jsonify(response), 200

    except Exception as e:
        logger.error(f"Error during detection: {str(e)}", exc_info=True)

        # Clean up files if they exist
        if upload_path and os.path.exists(upload_path):
            os.remove(upload_path)
        if repaired_path and os.path.exists(repaired_path):
            os.remove(repaired_path)

        return jsonify({
            'success': False,
            'error': str(e),
            'details': 'An error occurred while processing the video. Please ensure the video is in a supported format (MP4, AVI, MOV, MKV).',
            'traceback': traceback.format_exc() if Config.DEBUG else None
        }), 500

@app.route('/api/v1/detect/enhanced', methods=['POST'])
def detect_rrb_enhanced():
    """
    Enhanced RRB detection with pose analysis

    Expected: multipart/form-data with 'video' file
    Returns: JSON with detection results including pose features
    """
    upload_path = None
    repaired_path = None

    try:
        # Check if video file is present
        if 'video' not in request.files:
            return jsonify({
                'success': False,
                'error': 'No video file provided'
            }), 400

        file = request.files['video']

        if file.filename == '' or not allowed_file(file.filename):
            return jsonify({
                'success': False,
                'error': 'Invalid file'
            }), 400

        # Save uploaded file
        filename = secure_filename(file.filename)
        unique_filename = f"{uuid.uuid4()}_{filename}"
        upload_path = os.path.join(Config.UPLOAD_FOLDER, unique_filename)
        file.save(upload_path)

        logger.info(f"Video uploaded for enhanced detection: {filename}")

        # Validate video
        is_valid, error_msg, video_info = video_validator.validate_video(upload_path)

        if not is_valid:
            logger.warning(f"Video validation failed: {error_msg}")

            # Attempt to repair video
            logger.info("Attempting to repair video...")
            repair_success, repair_msg, repaired_path = video_validator.repair_video(upload_path)

            if repair_success and repaired_path:
                logger.info(f"Video repaired successfully")
                processing_path = repaired_path
            else:
                if upload_path and os.path.exists(upload_path):
                    os.remove(upload_path)

                return jsonify({
                    'success': False,
                    'error': f'Video validation failed: {error_msg}',
                    'details': 'The video file appears to be corrupted or in an unsupported format.',
                    'repair_attempted': True,
                    'repair_result': repair_msg
                }), 400
        else:
            processing_path = upload_path

        # Get inference engine
        engine = get_inference_engine()

        # Perform enhanced detection
        logger.info("Starting enhanced RRB detection with pose analysis...")
        result = engine.detect_with_pose_analysis(processing_path)
        logger.info("Enhanced detection completed")

        # Clean up
        if upload_path and os.path.exists(upload_path):
            os.remove(upload_path)
        if repaired_path and os.path.exists(repaired_path):
            os.remove(repaired_path)

        # Format response
        response = {
            'success': True,
            'timestamp': datetime.now().isoformat(),
            'filename': filename,
            'detection': {
                'detected': result['detected'],
                'primary_behavior': result['primary_behavior'],
                'confidence': result['confidence'],
                'behaviors': result['behaviors']
            },
            'pose_analysis': result.get('pose_analysis', {}),
            'metadata': {
                'video_duration': result.get('video_info', {}).get('duration', 0),
                'video_fps': result.get('video_info', {}).get('fps', 0),
                'sequences_analyzed': result.get('total_sequences_analyzed', 0)
            }
        }

        return jsonify(response), 200

    except Exception as e:
        logger.error(f"Error during enhanced detection: {str(e)}", exc_info=True)

        if upload_path and os.path.exists(upload_path):
            os.remove(upload_path)
        if repaired_path and os.path.exists(repaired_path):
            os.remove(repaired_path)

        return jsonify({
            'success': False,
            'error': str(e),
            'details': 'An error occurred while processing the video.',
            'traceback': traceback.format_exc() if Config.DEBUG else None
        }), 500

@app.route('/api/v1/model/info', methods=['GET'])
def model_info():
    """Get model information"""
    try:
        engine = get_inference_engine()
        
        return jsonify({
            'success': True,
            'model_info': {
                'classes': engine.label_encoder.classes_.tolist(),
                'num_classes': len(engine.label_encoder.classes_),
                'sequence_length': engine.sequence_length,
                'image_size': engine.img_size,
                'confidence_threshold': engine.confidence_threshold,
                'min_duration': engine.min_duration
            }
        }), 200
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/v1/categories', methods=['GET'])
def get_categories():
    """Get list of RRB categories"""
    return jsonify({
        'success': True,
        'categories': Config.RRB_CATEGORIES,
        'descriptions': {
            'hand_flapping': 'Repetitive hand or arm movements',
            'head_banging': 'Repetitive head hitting or banging movements',
            'head_nodding': 'Repetitive head nodding movements',
            'spinning': 'Repetitive spinning or rotating movements',
            'atypical_hand_movements': 'Other atypical hand movements',
            'normal': 'No restricted or repetitive behaviors detected'
        }
    }), 200

@app.errorhandler(413)
def request_entity_too_large(error):
    """Handle file too large error"""
    return jsonify({
        'success': False,
        'error': 'File too large. Maximum size is 100MB'
    }), 413

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'success': False,
        'error': 'Endpoint not found'
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    return jsonify({
        'success': False,
        'error': 'Internal server error'
    }), 500

if __name__ == '__main__':
    print("=" * 80)
    print("RRB Detection ML Service")
    print("=" * 80)
    print(f"Starting server on port {Config.PORT}...")
    print(f"Debug mode: {Config.DEBUG}")
    print(f"Model path: {Config.MODEL_PATH}")
    print(f"Confidence threshold: {Config.CONFIDENCE_THRESHOLD}")
    print(f"Min detection duration: {Config.MIN_DETECTION_DURATION}s")
    print("=" * 80)
    
    app.run(
        host='0.0.0.0',
        port=Config.PORT,
        debug=Config.DEBUG
    )

