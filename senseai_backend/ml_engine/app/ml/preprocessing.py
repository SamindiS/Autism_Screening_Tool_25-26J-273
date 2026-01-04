"""
Feature preprocessing and age normalization
"""

from typing import Dict, Any, Optional
import numpy as np

def get_age_band(age_months: int) -> str:
    """
    Convert age in months to age band
    
    Args:
        age_months: Age in months
        
    Returns:
        Age band string (e.g., '24-36', '36-48', '48-60', '60-72')
    """
    if age_months < 36:
        return "24-36"
    elif age_months < 48:
        return "36-48"
    elif age_months < 60:
        return "48-60"
    elif age_months < 72:
        return "60-72"
    else:
        return "72+"  # Fallback

def calculate_zscore(
    value: float,
    age_months: int,
    feature_name: str,
    age_norms: Optional[Dict[str, Any]]
) -> float:
    """
    Calculate Z-score for a feature using age-normalized control group norms
    
    Args:
        value: Raw feature value
        age_months: Child's age in months
        feature_name: Name of the feature
        age_norms: Dictionary with control group norms by age band
        
    Returns:
        Z-score (normalized value)
    """
    if age_norms is None:
        return value  # No normalization available, return raw value
    
    # Get age band
    age_band = get_age_band(age_months)
    
    # Try to get stats for this age band
    if age_band in age_norms and feature_name in age_norms[age_band]:
        stats = age_norms[age_band][feature_name]
        mean_val = stats.get('mean', 0)
        std_val = stats.get('std', 1)
        if std_val > 0:
            return (value - mean_val) / std_val
    
    # Fallback to overall stats
    if 'overall' in age_norms and feature_name in age_norms['overall']:
        stats = age_norms['overall'][feature_name]
        mean_val = stats.get('mean', 0)
        std_val = stats.get('std', 1)
        if std_val > 0:
            return (value - mean_val) / std_val
    
    return value  # No normalization available

def normalize_features(
    features_dict: Dict[str, Any],
    age_months: int,
    age_norms: Optional[Dict[str, Any]]
) -> Dict[str, Any]:
    """
    Normalize features by calculating Z-scores for features that need it
    
    Features ending in '_zscore' need to be calculated from raw features
    
    Args:
        features_dict: Dictionary of raw feature values
        age_months: Child's age in months
        age_norms: Age normalization norms (optional)
        
    Returns:
        Dictionary with both raw and normalized (Z-score) features
    """
    normalized = features_dict.copy()
    
    if age_norms is None:
        # No age norms available, return features as-is
        return normalized
    
    # Features that need age normalization (create Z-scores)
    features_to_normalize = [
        'post_switch_accuracy',
        'perseverative_error_rate_post_switch',
        'switch_cost_ms',
        'avg_rt_pre_switch_ms',
        'avg_rt_post_switch_correct_ms',
        'accuracy_drop_percent',
        'nogo_accuracy',
        'commission_error_rate',
        'rt_variability',
        'avg_rt_go_ms',
    ]
    
    # Calculate Z-scores for features that need normalization
    for feature in features_to_normalize:
        if feature in features_dict:
            raw_value = features_dict[feature]
            if raw_value is not None:
                try:
                    zscore = calculate_zscore(float(raw_value), age_months, feature, age_norms)
                    normalized[f'{feature}_zscore'] = zscore
                except (ValueError, TypeError):
                    # Skip if value can't be converted to float
                    normalized[f'{feature}_zscore'] = 0.0
    
    return normalized

def prepare_features(
    features_dict: Dict[str, Any],
    feature_names: list,
    expected_n_features: int
) -> np.ndarray:
    """
    Prepare feature vector in correct order for model
    
    Args:
        features_dict: Dictionary of feature values
        feature_names: List of feature names in training order
        expected_n_features: Number of features model expects
        
    Returns:
        Numpy array of features in correct order
    """
    # Adjust feature_names to match model expectations
    if len(feature_names) != expected_n_features:
        # Use only first N features that match model
        feature_names = feature_names[:expected_n_features]
    
    # Extract features in correct order
    feature_vector = []
    for feature_name in feature_names:
        if feature_name in features_dict:
            value = features_dict[feature_name]
        else:
            value = 0  # Missing feature, use default
        
        # Handle None values
        if value is None:
            value = 0
        
        try:
            feature_vector.append(float(value))
        except (ValueError, TypeError):
            feature_vector.append(0.0)
    
    # Verify we have the right number
    if len(feature_vector) != expected_n_features:
        raise ValueError(
            f"Feature count mismatch: Expected {expected_n_features} features, "
            f"but got {len(feature_vector)}"
        )
    
    return np.array(feature_vector).reshape(1, -1)

