"""
Flask Backend Server for Video Analysis and Tap the Sound Game
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from werkzeug.utils import secure_filename
from datetime import datetime
import json

from services.video_analyzer import VideoAnalyzer
from services.tap_game_service import TapGameService
from services.benchmark_assessment_service import BenchmarkAssessmentService
from services.video_quality_validator import VideoQualityValidator

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app
benchmark_service = BenchmarkAssessmentService()
video_quality_validator = VideoQualityValidator()

# Configuration
UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = {'mp4', 'avi', 'mov', 'mkv', 'webm'}
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = MAX_FILE_SIZE

# Ensure upload directory exists
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Initialize services
video_analyzer = VideoAnalyzer()
tap_game_service = TapGameService()


def allowed_file(filename):
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'message': 'Backend server is running',
        'timestamp': datetime.now().isoformat()
    }), 200


@app.route('/api/validate-video', methods=['POST'])
def validate_video():
    """Pre-upload video quality validation: resolution, lighting, audio, face visibility, duration."""
    try:
        if 'video' not in request.files:
            return jsonify({'error': 'No video file provided', 'message': 'Please upload a video file'}), 400
        file = request.files['video']
        if file.filename == '':
            return jsonify({'error': 'No file selected', 'message': 'Please select a video file'}), 400
        if not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type', 'message': 'Only video files (mp4, avi, mov, mkv, webm) are allowed'}), 400
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_filename = f"validate_{timestamp}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(filepath)
        try:
            result = video_quality_validator.validate(filepath)
            return jsonify(result), 200
        finally:
            try:
                os.remove(filepath)
            except Exception:
                pass
    except Exception as e:
        return jsonify({'error': 'Validation failed', 'message': str(e), 'passed': False}), 500


@app.route('/api/analyze-video', methods=['POST'])
def analyze_video():
    """Analyze uploaded video for RTN (Response to Name) detection"""
    try:
        # Check if video file is present
        if 'video' not in request.files:
            return jsonify({
                'error': 'No video file provided',
                'message': 'Please upload a video file'
            }), 400
        
        file = request.files['video']
        
        if file.filename == '':
            return jsonify({
                'error': 'No file selected',
                'message': 'Please select a video file'
            }), 400
        
        if not allowed_file(file.filename):
            return jsonify({
                'error': 'Invalid file type',
                'message': 'Only video files (mp4, avi, mov, mkv, webm) are allowed'
            }), 400
        
        # Get additional parameters
        child_name = request.form.get('child_name', 'Unknown')
        child_id = request.form.get('child_id', '')  # Optional: for benchmark comparison
        analysis_type = request.form.get('analysis_type', 'full')
        
        # Save uploaded file
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_filename = f"{timestamp}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(filepath)
        
        # Analyze video
        result = video_analyzer.analyze(filepath, child_name, analysis_type)
        
        # Store ML prediction for benchmark comparison (M-CHAT vs AI)
        if child_id and result.get('ML_Prediction'):
            try:
                benchmark_service.save_ml_prediction(child_id, result)
            except Exception:
                pass
        
        # Clean up uploaded file (optional - you may want to keep it)
        # os.remove(filepath)
        
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Analysis failed',
            'message': str(e)
        }), 500


@app.route('/api/analyze-audio', methods=['POST'])
def analyze_audio():
    """Analyze uploaded audio file"""
    try:
        if 'audio' not in request.files:
            return jsonify({
                'error': 'No audio file provided',
                'message': 'Please upload an audio file'
            }), 400
        
        file = request.files['audio']
        
        if file.filename == '':
            return jsonify({
                'error': 'No file selected',
                'message': 'Please select an audio file'
            }), 400
        
        # Save and analyze audio
        filename = secure_filename(file.filename)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        unique_filename = f"{timestamp}_{filename}"
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], unique_filename)
        file.save(filepath)
        
        # TODO: Implement audio analysis
        result = {
            'status': 'success',
            'message': 'Audio analysis not yet implemented',
            'file': filename
        }
        
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Analysis failed',
            'message': str(e)
        }), 500


@app.route('/tap-game/start', methods=['POST'])
def start_tap_game():
    """Start a new Tap the Sound game session"""
    try:
        data = request.get_json() or {}
        child_id = data.get('child_id')
        child_name = data.get('child_name', 'Unknown')
        child_age = data.get('child_age', 3)
        
        if not child_id:
            return jsonify({
                'error': 'Missing child_id',
                'message': 'child_id is required'
            }), 400
        
        result = tap_game_service.start_session(child_id, child_name, child_age)
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Failed to start game',
            'message': str(e)
        }), 500


@app.route('/tap-game/response', methods=['POST'])
def record_tap_response():
    """Record a tap response in the game with comprehensive metrics for age 5-6"""
    try:
        data = request.get_json() or {}
        child_id = data.get('child_id')
        session_id = data.get('session_id')
        sound_type = data.get('sound_type')
        selected_image = data.get('selected_image')
        is_correct = data.get('is_correct', False)
        reaction_time_ms = data.get('reaction_time_ms', 0)
        
        # Age 5-6 specific metrics
        hesitation_time_ms = data.get('hesitation_time_ms')
        is_first_tap = data.get('is_first_tap', True)
        is_tap_change = data.get('is_tap_change', False)
        sound_was_playing_when_tapped = data.get('sound_was_playing_when_tapped', False)
        total_taps_in_round = data.get('total_taps_in_round', 1)
        tap_history = data.get('tap_history', [])
        sound_duration_ms = data.get('sound_duration_ms')
        sound_difficulty = data.get('sound_difficulty', 'medium')
        tapped_before_sound_finished = data.get('tapped_before_sound_finished', False)
        random_tapping_detected = data.get('random_tapping_detected', False)
        decision_confidence = data.get('decision_confidence', 'medium')
        hesitation_level = data.get('hesitation_level', 'medium')
        
        if not child_id or not sound_type or not selected_image:
            return jsonify({
                'error': 'Missing required fields',
                'message': 'child_id, sound_type, and selected_image are required'
            }), 400
        
        # Store comprehensive metrics
        result = {
            'status': 'success',
            'child_id': child_id,
            'session_id': session_id,
            'sound_type': sound_type,
            'selected_image': selected_image,
            'is_correct': is_correct,
            'reaction_time_ms': reaction_time_ms,
            
            # Age 5-6 Metrics
            'metrics': {
                # 1. Sound Discrimination Ability
                'sound_difficulty': sound_difficulty,
                'discrimination_score': 'high' if is_correct and sound_difficulty == 'hard' else 'medium',
                
                # 2. Reaction Time
                'reaction_time_ms': reaction_time_ms,
                'reaction_speed': 'fast' if reaction_time_ms < 2000 else 'medium' if reaction_time_ms < 5000 else 'slow',
                
                # 3. Accuracy Rate
                'is_correct': is_correct,
                'accuracy': 'correct' if is_correct else 'incorrect',
                
                # 4. Auditory Attention Span
                'tapped_before_sound_finished': tapped_before_sound_finished,
                'sound_was_playing_when_tapped': sound_was_playing_when_tapped,
                'random_tapping_detected': random_tapping_detected,
                'attention_span_score': 'good' if not tapped_before_sound_finished and not random_tapping_detected else 'needs_improvement',
                
                # 5. Decision-Making Ability
                'hesitation_time_ms': hesitation_time_ms or reaction_time_ms,
                'hesitation_level': hesitation_level,
                'is_first_tap': is_first_tap,
                'is_tap_change': is_tap_change,
                'total_taps_in_round': total_taps_in_round,
                'tap_history': tap_history,
                'decision_confidence': decision_confidence,
                'decision_making_score': 'confident' if is_first_tap and not is_tap_change else 'uncertain',
            },
            
            'timestamp': datetime.now().isoformat()
        }
        
        # Try to use service if available, otherwise just return the result
        try:
            service_result = tap_game_service.record_response(
                child_id=child_id,
                round_number=1,  # Default if not provided
                sound_id=sound_type,
                selected_image_id=selected_image,
                response_time=reaction_time_ms,
                is_correct=is_correct
            )
            result.update(service_result)
        except Exception as service_error:
            print(f'Service error (continuing anyway): {service_error}')
        
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Failed to record response',
            'message': str(e)
        }), 500


@app.route('/tap-game/result/<child_id>', methods=['GET'])
def get_tap_game_result(child_id):
    """Get game results for a child"""
    try:
        result = tap_game_service.get_results(child_id)
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            'error': 'Failed to get results',
            'message': str(e)
        }), 500


# ---------- Benchmark Assessment Integration ----------

@app.route('/api/benchmark/mchat/questions', methods=['GET'])
def get_mchat_questions():
    """Get M-CHAT-R/F 20 questions"""
    try:
        questions = benchmark_service.get_mchat_questions()
        return jsonify({'questions': questions}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/mchat/submit', methods=['POST'])
def submit_mchat():
    """Submit M-CHAT answers, get score, and save"""
    try:
        data = request.get_json() or {}
        child_id = data.get('child_id', 'unknown')
        child_name = data.get('child_name', '')
        child_age_months = data.get('child_age_months')
        answers = data.get('answers', [])
        if not answers:
            return jsonify({'error': 'answers required'}), 400
        score_result = benchmark_service.score_mchat(answers)
        record = benchmark_service.save_mchat(child_id, child_name, child_age_months, answers, score_result)
        return jsonify({'score': score_result, 'saved': record}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/mchat/history', methods=['GET'])
def get_mchat_history():
    """Get M-CHAT history; optional query ?child_id=..."""
    try:
        child_id = request.args.get('child_id')
        history = benchmark_service.get_mchat_history(child_id)
        return jsonify({'history': history}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/compare', methods=['GET'])
def get_benchmark_compare():
    """Compare M-CHAT with ML predictions for a child. Query: ?child_id=..."""
    try:
        child_id = request.args.get('child_id', '')
        if not child_id:
            return jsonify({'error': 'child_id required'}), 400
        result = benchmark_service.get_comparison(child_id)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/milestones', methods=['GET'])
def get_milestones():
    """Get CDC milestones for age. Query: ?age_months=..."""
    try:
        age_months = request.args.get('age_months', type=int)
        if age_months is None:
            return jsonify({'error': 'age_months required'}), 400
        result = benchmark_service.get_milestones(age_months)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/milestones/submit', methods=['POST'])
def submit_milestone_progress():
    """Submit milestone progress (achieved ids) for a child"""
    try:
        data = request.get_json() or {}
        child_id = data.get('child_id', 'unknown')
        child_name = data.get('child_name', '')
        age_months = data.get('age_months')
        achieved = data.get('achieved_ids', [])
        if age_months is None:
            return jsonify({'error': 'age_months required'}), 400
        result = benchmark_service.save_milestone_progress(child_id, child_name, age_months, achieved)
        return jsonify(result), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/milestones/history', methods=['GET'])
def get_milestone_history():
    """Get milestone progress history; optional ?child_id=..."""
    try:
        child_id = request.args.get('child_id')
        history = benchmark_service.get_milestone_history(child_id)
        return jsonify({'history': history}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/prq/schema', methods=['GET'])
def get_prq_schema():
    """Get PRQ sections and questions"""
    try:
        schema = benchmark_service.get_prq_schema()
        return jsonify(schema), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/prq/submit', methods=['POST'])
def submit_prq():
    """Submit PRQ answers"""
    try:
        data = request.get_json() or {}
        child_id = data.get('child_id', 'unknown')
        child_name = data.get('child_name', '')
        answers = data.get('answers', {})
        record = benchmark_service.save_prq(child_id, child_name, answers)
        return jsonify({'saved': record}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/benchmark/prq/history', methods=['GET'])
def get_prq_history():
    """Get PRQ history; optional ?child_id=..."""
    try:
        child_id = request.args.get('child_id')
        history = benchmark_service.get_prq_history(child_id)
        return jsonify({'history': history}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    print("Starting Flask backend server...")
    print("Server will run on http://localhost:5000")
    print("For Android emulator, use: http://10.0.2.2:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)
