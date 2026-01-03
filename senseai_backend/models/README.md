# ML Models Directory

Place your trained ML model files here:

## Required Files

1. **asd_detection_model.pkl** - Trained scikit-learn model
2. **feature_scaler.pkl** - Feature scaler (StandardScaler)
3. **feature_names.json** - List of feature names in order (optional but recommended)

## How to Get These Files

1. Train your model using `ML_TRAINING/Complete_ASD_ML_Training.ipynb`
2. After training, the notebook will save:
   - `asd_detection_model.pkl`
   - `feature_scaler.pkl`
3. Create `feature_names.json` with your feature names in the same order as training

## Example feature_names.json

```json
[
  "age_months",
  "completion_time_sec",
  "accuracy_overall",
  "primary_asd_marker_1",
  "primary_asd_marker_2",
  "primary_asd_marker_3",
  "attention_level",
  "engagement_level",
  "enhanced_risk_score"
]
```

## Model Update

When you retrain with new data:
1. Replace the `.pkl` files with new trained models
2. Update `feature_names.json` if features changed
3. Restart backend server
4. No app update needed!

## Testing

Test the model is loaded correctly:
```bash
cd senseai_backend
python ml_scripts/predict.py '{"features": {"age_months": 70, "accuracy_overall": 55.0}, "age_group": "5-6", "session_type": "color_shape"}'
```







