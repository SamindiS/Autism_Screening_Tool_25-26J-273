"""
Main prediction logic with age-specific model routing.

This module is the core inference engine. It is responsible for orchestrating 
the entire prediction pipeline when a request is received from the client.

Workflow:
1. Extracts age information to determine the correct age band (e.g., 2-3.5, 3.5-5.5).
2. Dynamically routes to the appropriate model and scaler loaded via `age_specific_loader`.
   If the specific model isn't available, falls back to the legacy unified model.
3. Validates and prepares the incoming feature dictionary against expected `feature_names`.
4. Scales the raw features using the cached `StandardScaler`.
5. Executes the inference to get absolute prediction and probabilistic confidence.
6. Maps the output probability to Risk Thresholds (LOW, MODERATE, HIGH).
7. Invokes `_build_explanations` to compute feature contributions (SHAP-like linear weighting)
   for clinical transparency.
"""

import numpy as np
from app.ml.age_specific_loader import load_age_specific_model
from app.ml.model_loader import load_models, load_v3_models  # Updated with v3 loader
from app.ml.preprocessing import normalize_features, prepare_features
from app.core.config import RISK_THRESHOLDS, get_age_group
from app.core.logger import logger
from app.schemas.request import PredictionRequest
from app.schemas.response import PredictionResponse, ExplanationItem

# --- Multi-lingual Explanation Dictionary ---
EXPLANATION_TEXT = {
    "en": {
        "low_eye_contact": "Reduced eye contact was observed during the assessment.",
        "poor_imitation": "Social imitation skills are below the expected developmental level.",
        "difficulty_with_change": "Child showed difficulty adapting to changes in routine or tasks.",
        "low_joint_attention": "Reduced joint attention (sharing focus with others) was observed.",
        "low_name_response": "Reduced responsiveness to their name being called.",
        "sensory_sensitivity": "Signs of sensory sensitivity or unusual reactions were noted.",
        "peer_play_delay": "Social interaction and peer play skills are still developing.",
        "low_risk_positive": "Good social interaction and rule switching skills were observed."
    },
    "si": {
        "low_eye_contact": "පරීක්ෂණයේදී ඇස් සම්බන්ධතාවය (eye contact) අඩු බව නිරීක්ෂණය විය.",
        "poor_imitation": "සමාජීය අනුකරණ හැකියාව බලාපොරොත්තු වන මට්ටමට වඩා අඩුය.",
        "difficulty_with_change": "දෛනික රටාවේ හෝ කාර්යයන්හි වෙනස්වීම් වලට අනුගත වීමට දරුවා අපහසුවක් පෙන්වීය.",
        "low_joint_attention": "අන් අය සමඟ අවධානය බෙදාගැනීමේ (joint attention) හැකියාව අඩු බව පෙනේ.",
        "low_name_response": "නම කතා කළ විට දක්වන ප්‍රතිචාරය අඩු මට්ටමක පවතී.",
        "sensory_sensitivity": "ඉන්ද්‍රිය සංවේදීතාවයේ හෝ අසාමාන්‍ය ප්‍රතික්‍රියාවල ලක්ෂණ දක්නට ලැබුණි.",
        "peer_play_delay": "සමාජීය අන්තර්ක්‍රියා සහ සම වයසේ දරුවන් සමඟ සෙල්ලම් කිරීමේ හැකියාව තවමත් වර්ධනය වෙමින් පවතී.",
        "low_risk_positive": "හොඳ සමාජීය අන්තර්ක්‍රියා සහ නීති වෙනස් කිරීමට අනුගත වීමේ හැකියාව නිරීක්ෂණය විය."
    },
    "ta": {
        "low_eye_contact": "மதிப்பீட்டின் போது கண் தொடர்பு குறைவாக இருப்பது அவதானிக்கப்பட்டது.",
        "poor_imitation": "சமூகப் பின்பற்றுதல் திறன்கள் எதிர்பார்க்கப்படும் வளர்ச்சி நிலைக்குக் குறைவாக உள்ளன.",
        "difficulty_with_change": "வழக்கமான நடைமுறைகள் அல்லது பணிகளில் ஏற்படும் மாற்றங்களுக்குத் தலைகொடுப்பதில் குழந்தை சிரமத்தை வெளிப்படுத்தியது.",
        "low_joint_attention": "மற்றவர்களுடன் கவனத்தைப் பகிர்ந்து கொள்ளும் திறன் குறைவாக இருப்பது அவதானிக்கப்பட்டது.",
        "low_name_response": "பெயர் சொல்லி அழைக்கும்போது எதிர்வினை குறைவாக உள்ளது.",
        "sensory_sensitivity": "புலன் உணர்வு உணர்திறன் அல்லது அசாதாரண எதிர்வினைகளின் அறிகுறிகள் காணப்பட்டன.",
        "peer_play_delay": "சமூக தொடர்பு மற்றும் சக நண்பர்களுடன் விளையாடும் திறன்கள் இன்னும் வளர்ச்சியடைந்து வருகின்றன.",
        "low_risk_positive": "நல்ல சமூக தொடர்பு மற்றும் விதிமுறை மாற்றங்களுக்கு ஏற்ப மாறும் திறன்கள் அவதானிக்கப்பட்டன."
    }
}


def _build_explanations(
    model: any,
    feature_names: list,
    features_scaled: np.ndarray,
    features_dict: dict,
    top_k: int = 6,
) -> list | None:
    """
    Build a simple explanation list for linear models (e.g. LogisticRegression).
    Uses signed contribution ~= coef_i * x_i (on scaled features).
    """
    try:
        coefs = getattr(model, "coef_", None)
        if coefs is None or len(coefs) == 0:
            return None

        coef_vec = np.array(coefs[0], dtype=float)
        x = np.array(features_scaled[0], dtype=float)
        n = min(len(coef_vec), len(x), len(feature_names))
        if n <= 0:
            return None

        contrib = coef_vec[:n] * x[:n]
        # Rank by absolute contribution
        idx_sorted = np.argsort(np.abs(contrib))[::-1][:top_k]

        explanations = []
        for i in idx_sorted:
            fname = str(feature_names[i])
            val = features_dict.get(fname, 0)
            try:
                val_f = float(val) if val is not None else 0.0
            except Exception:
                val_f = 0.0
            c = float(contrib[i])
            explanations.append(
                {
                    "feature": fname,
                    "value": val_f,
                    "contribution": round(c, 4),
                    "direction": "increases_risk" if c >= 0 else "decreases_risk",
                }
            )

        return explanations
    except Exception as e:
        logger.warning(f"Could not build explanations: {e}")
        return None

def _engineer_features_v3(X_dict):
    """
    Apply v3 specific feature engineering (matching the notebook logic).
    """
    eng = {}
    
    # Standard numerical values
    for k, v in X_dict.items():
        if isinstance(v, (int, float)):
            eng[k] = float(v)
        else:
            # Handle categorical or missing
            try:
                eng[k] = float(v)
            except:
                eng[k] = 0.0

    # Engineered features (Exact formulas from v3 Research)
    eng['social_attention_idx'] = (
        eng.get('q9_joint_attention', 0) + 
        eng.get('q4_eye_contact', 0) + 
        eng.get('q1_name_response', 0)
    ) / 3

    eng['imitation_comm_score'] = (
        eng.get('q7_imitation', 0) + 
        eng.get('q10_communication', 0) + 
        eng.get('q5_pointing', 0)
    ) / 3

    eng['rigidity_index'] = (
        eng.get('q2_routine_change', 0) + 
        eng.get('q3_toy_switching', 0)
    ) / 2

    eng['behavioral_regulation'] = (
        eng.get('attention_level', 0) + 
        eng.get('engagement_level', 0) +
        eng.get('frustration_tolerance', 0) + 
        eng.get('instruction_following', 0)
    ) / 4

    q_sum = sum(eng.get(f'q{i}', 0) for i in range(1, 11))
    # Fallback to provided total if available
    eng['total_q_score'] = X_dict.get('total_q_score', q_sum)
    
    eng['failed_x_sensory'] = eng.get('failed_items_rate', 0) * eng.get('q6_sensory_reaction', 0)
    
    comp_time = eng.get('completion_time_sec', 300)
    eng['processing_efficiency'] = eng['total_q_score'] / (comp_time / 60 + 1)
    
    eng['critical_fail_per_age'] = eng.get('critical_items_failed', 0) / (eng.get('age_months', 24) + 1)
    
    eng['social_comm_combined'] = (
        eng.get('q1_name_response', 0) + 
        eng.get('q4_eye_contact', 0) +
        eng.get('q7_imitation', 0) + 
        eng.get('q10_communication', 0)
    ) / 4
    
    return eng

def _get_clinical_rule_score(d):
    """
    Calculate clinical rule score (30% weight in v3 hybrid model).
    Based on key ASD markers specifically for age 2-3.5.
    """
    score = 0.0
    flags = []
    
    # Rule 1: Social Imitation (Critical for age 2-3)
    if d.get('q7_imitation', 5) <= 2:
        score += 0.25
        flags.append("low_imitation")
        
    # Rule 2: Name Response
    if d.get('q1_name_response', 5) <= 2:
        score += 0.25
        flags.append("low_name_response")
        
    # Rule 3: Joint Attention
    if d.get('joint_attention_score', 100) < 40 or d.get('q9_joint_attention', 5) <= 2:
        score += 0.25
        flags.append("low_joint_attention")
        
    # Rule 4: Critical Items Failure Threshold
    if d.get('critical_items_failed', 0) >= 3:
        score += 0.25
        flags.append("high_critical_failure")
        
    return min(score, 1.0), flags

def generate_v3_explanations(d, hybrid_score, lang="en"):
    """
    Generate human-readable explanations based on model findings.
    """
    keys = []
    
    if hybrid_score < 0.3:
        keys.append("low_risk_positive")
    else:
        # Identify top concerns for the "Why this result?" section
        if d.get('q4_eye_contact', 5) <= 2:
            keys.append("low_eye_contact")
        if d.get('q7_imitation', 5) <= 2:
            keys.append("poor_imitation")
        if d.get('q2_routine_change', 5) <= 2:
            keys.append("difficulty_with_change")
        if d.get('q9_joint_attention', 5) <= 2:
            keys.append("low_joint_attention")
        if d.get('q6_sensory_reaction', 5) <= 2:
            keys.append("sensory_sensitivity")

    # Map keys to localized text
    lang_dict = EXPLANATION_TEXT.get(lang, EXPLANATION_TEXT["en"])
    return [lang_dict.get(k, k) for k in keys[:3]] # Return top 3 explanations

def predict_asd_v3_hybrid(request: PredictionRequest) -> PredictionResponse:
    """
    v3 Hybrid Inference Engine for Age 2-3.5.
    70% ML Probability + 30% Clinical Rules.
    """
    # 1. Load v3 Ensemble
    (bin_model, sev_model, scaler, le_gender, le_lang, config) = load_v3_models()
    if bin_model is None:
        raise FileNotFoundError("v3 Cognitive Flexibility models could not be loaded.")
        
    # 2. Feature Engineering
    raw_features = request.features.copy()
    # Support both "en"/"si" and full labels if encoded
    eng_features = _engineer_features_v3(raw_features)
    
    # 3. Prepare for ML Model
    top_features = config.get("top_features", [])
    if not top_features:
        # Fallback to common top features if config missing
        top_features = ['total_q_score', 'social_comm_combined', 'social_attention_idx', 
                        'imitation_comm_score', 'critical_items_fail_rate']
    
    # Construct vector in correct order
    X_vec = np.array([eng_features.get(f, 0.0) for f in top_features]).reshape(1, -1)
    X_scaled = scaler.transform(X_vec)
    
    # 4. ML Prediction
    ml_prob_asd = float(bin_model.predict_proba(X_scaled)[0][1])
    
    # 5. Clinical Rules Component
    rule_score, rule_flags = _get_clinical_rule_score(raw_features)
    
    # 6. Hybrid Calculation
    ML_WEIGHT = config.get("ml_weight", 0.7)
    RULE_WEIGHT = config.get("rule_weight", 0.3)
    hybrid_score = (ML_WEIGHT * ml_prob_asd) + (RULE_WEIGHT * rule_score)
    
    # 7. Severity & Multi-class
    sev_probs = sev_model.predict_proba(X_scaled)[0]
    
    # Thresholding & Result Mapping
    if hybrid_score < 0.25:
        severity = "No ASD Risk (Typically Developing)"
        risk_level = "low"
        prediction = 0
    elif hybrid_score < 0.45:
        severity = "Low ASD Risk"
        risk_level = "low"
        prediction = 1
    elif hybrid_score < 0.70:
        severity = "Moderate ASD Risk"
        risk_level = "moderate"
        prediction = 1
    else:
        severity = "High ASD Risk"
        risk_level = "high"
        prediction = 1

    # 8. Localized Explanations (XAI)
    lang = raw_features.get('language', 'en')
    explanations = generate_v3_explanations(raw_features, hybrid_score, lang)
    
    return PredictionResponse(
        prediction=prediction,
        probability=[1-hybrid_score, hybrid_score],
        confidence=float(max(sev_probs)),
        risk_level=risk_level,
        risk_score=round(hybrid_score * 100, 1),
        asd_probability=round(ml_prob_asd, 3),
        model_age_group="2-3.5 (v3 Hybrid)",
        result_summary=f"Cognitive flexibility assessment: {severity}",
        severity=severity,
        hybrid_score=round(hybrid_score, 4),
        explanations=explanations
    )

def validate_features(features_dict: dict, feature_names: list) -> None:
    """
    Validate that required features are present
    
    Args:
        features_dict: Dictionary of provided features
        feature_names: List of expected feature names
        
    Raises:
        ValueError: If critical features are missing
    """
    if feature_names is None:
        return  # Cannot validate without feature names
    
    # Check for missing features (warn but don't fail - missing features default to 0)
    missing = set(feature_names) - set(features_dict.keys())
    if missing:
        # Only warn about critical features (non-Z-score features)
        critical_missing = [f for f in missing if not f.endswith('_zscore')]
        if critical_missing:
            logger.warning(f"Missing features (will use 0): {critical_missing[:5]}...")  # Log first 5

def predict_asd(request: PredictionRequest) -> PredictionResponse:
    """
    Predict ASD risk from ML features using age-specific models
    
    Args:
        request: PredictionRequest with age_months and features
        
    Returns:
        PredictionResponse with risk score, level, and probabilities
    """
    logger.info(f"Prediction requested: age={request.age_months}, child_id={request.child_id or 'N/A'}")
    
    # Extract age_months
    age_months = request.age_months
    if age_months is None:
        age_months = request.features.get('age_months', 36)
    
    # Normalize age_months to int
    try:
        age_months = int(float(age_months))
    except (ValueError, TypeError):
        age_months = 36  # Default
    
    # Determine age group
    age_group = get_age_group(age_months)
    
    # EXCLUSIVE ROUTING: Check if this is the v3 target group (2-3.5 years)
    if age_group == "2-3.5":
        logger.info("Routing to v3 Cognitive Flexibility Hybrid Engine")
        return predict_asd_v3_hybrid(request)

    # Try to load age-specific model (Legacy Age-banded)
    try:
        model, scaler, feature_names, metadata = load_age_specific_model(age_months)
        logger.info(f"Using age-specific model for age group: {age_group}")
    except (FileNotFoundError, ValueError) as e:
        # Fallback to legacy model if age-specific model not found
        logger.warning(f"Age-specific model not found for {age_group}, trying legacy model: {e}")
        try:
            model, scaler, feature_names, age_norms = load_models()
            logger.info("Using legacy unified model")
        except FileNotFoundError:
            raise FileNotFoundError(
                f"No model available for age {age_months} months (age group: {age_group}). "
                f"Please ensure model files are in models/ directory. "
                f"Error: {str(e)}"
            )
    
    # Validate features
    validate_features(request.features, feature_names)
    
    # Prepare features (skip age normalization for age-specific models as they're already age-normalized)
    features_dict = request.features.copy()
    
    # Get expected number of features from scaler
    expected_n_features = scaler.n_features_in_
    
    # Prepare features in correct order
    if feature_names is None:
        raise ValueError(
            "feature_names.json not found. Cannot determine which features the model expects."
        )
    
    features = prepare_features(features_dict, feature_names, expected_n_features)
    logger.debug(f"Prepared {expected_n_features} features for prediction")
    
    # Scale features (using the same scaler from training)
    features_scaled = scaler.transform(features)
    
    # Predict
    prediction = model.predict(features_scaled)[0]
    probabilities = model.predict_proba(features_scaled)[0]
    
    # Calculate risk score and level
    asd_probability = float(probabilities[1])  # Probability of ASD
    control_probability = float(probabilities[0])  # Probability of Control
    risk_score = asd_probability * 100
    confidence = float(max(probabilities))
    
    # Determine risk level using thresholds
    if risk_score >= RISK_THRESHOLDS["HIGH"] * 100:
        risk_level = "high"
    elif risk_score >= RISK_THRESHOLDS["MODERATE"] * 100:
        risk_level = "moderate"
    else:
        risk_level = "low"
    
    logger.info(
        f"Prediction complete ({age_group or 'legacy'}): {risk_level.upper()} risk "
        f"(score={risk_score:.1f}%, prob={asd_probability:.3f})"
    )

    explanations = _build_explanations(
        model=model,
        feature_names=feature_names,
        features_scaled=features_scaled,
        features_dict=features_dict,
        top_k=6,
    )
    
    return PredictionResponse(
        prediction=int(prediction),
        probability=[control_probability, asd_probability],
        confidence=confidence,
        risk_level=risk_level,
        risk_score=round(risk_score, 1),
        asd_probability=round(asd_probability, 3),
        model_age_group=age_group,
        explanations=explanations,
    )

