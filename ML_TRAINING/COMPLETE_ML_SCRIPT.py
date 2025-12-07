# ============================================================
# 🧠 SenseAI ASD Screening - Complete ML Training Script
# ============================================================
# Copy this entire script into Google Colab and run cell by cell
# 
# HOW TO USE IN GOOGLE COLAB:
# 1. Go to https://colab.research.google.com
# 2. Sign in with Google account
# 3. File → New Notebook
# 4. Copy each section below into separate cells
# 5. Run cells in order (Shift + Enter)
# ============================================================

# ====================== CELL 1: SETUP ======================
# Install required packages
!pip install pandas numpy scikit-learn xgboost mord matplotlib seaborn joblib -q

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler, LabelEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.metrics import classification_report, confusion_matrix, accuracy_score, roc_auc_score
import xgboost as xgb
import joblib
import warnings
warnings.filterwarnings('ignore')

print("✅ Setup complete!")

# ====================== CELL 2: UPLOAD DATA ======================
# Upload your CSV file
from google.colab import files
print("📤 Select your merged_complete_dataset.csv file:")
uploaded = files.upload()
print(f"✅ Uploaded: {list(uploaded.keys())}")

# ====================== CELL 3: LOAD DATA ======================
# Load the dataset
df = pd.read_csv('merged_complete_dataset.csv')

print("=" * 60)
print("📊 DATASET SUMMARY")
print("=" * 60)
print(f"Total Samples: {len(df)}")
print(f"Features: {len(df.columns)}")
print(f"\nColumns: {list(df.columns)}")
print(f"\nASD Distribution:")
print(df['asd_label'].value_counts())
print(f"\nFirst 5 rows:")
display(df.head())

# ====================== CELL 4: PREPARE FEATURES ======================
# Define features based on your dataset columns
# Adjust these based on your actual column names!

# Numeric features for ML
feature_columns = [
    'age_months',
    'completion_time_sec', 
    'total_score_or_trials',
    'accuracy_overall',
    'primary_asd_marker_1',
    'primary_asd_marker_2', 
    'primary_asd_marker_3',
    'attention_level',
    'engagement_level',
    'frustration_tolerance',
    'instruction_following',
    'overall_behavior',
    'enhanced_risk_score'
]

# Filter to only existing columns
available_features = [col for col in feature_columns if col in df.columns]
print(f"✅ Using {len(available_features)} features: {available_features}")

# Prepare X and y
X = df[available_features].fillna(0)  # Handle missing values
y_binary = df['asd_label']  # Binary: 0=Control, 1=ASD
y_severity = df['severity_label']  # Severity: 0,1,2,3

print(f"\n📊 Feature Matrix Shape: {X.shape}")
print(f"🏷️ Binary Labels: {y_binary.value_counts().to_dict()}")

# ====================== CELL 5: SPLIT DATA ======================
# Split into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y_binary, 
    test_size=0.2, 
    random_state=42, 
    stratify=y_binary
)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

print(f"✅ Data Split Complete!")
print(f"   Training: {len(X_train)} samples")
print(f"   Testing: {len(X_test)} samples")

# ====================== CELL 6: TRAIN MODELS ======================
# Train multiple models for comparison

models = {
    'Logistic Regression': LogisticRegression(max_iter=1000, random_state=42),
    'Random Forest': RandomForestClassifier(n_estimators=100, random_state=42),
    'XGBoost': xgb.XGBClassifier(n_estimators=100, random_state=42, use_label_encoder=False, eval_metric='logloss'),
    'SVM': SVC(kernel='rbf', probability=True, random_state=42),
    'Gradient Boosting': GradientBoostingClassifier(n_estimators=100, random_state=42)
}

results = {}
trained_models = {}

print("🚀 TRAINING MODELS...")
print("=" * 60)

for name, model in models.items():
    # Train
    model.fit(X_train_scaled, y_train)
    trained_models[name] = model
    
    # Predict
    y_pred = model.predict(X_test_scaled)
    y_prob = model.predict_proba(X_test_scaled)[:, 1] if hasattr(model, 'predict_proba') else None
    
    # Calculate metrics
    accuracy = accuracy_score(y_test, y_pred)
    auc = roc_auc_score(y_test, y_prob) if y_prob is not None else 0
    
    results[name] = {
        'accuracy': accuracy,
        'auc': auc,
        'predictions': y_pred
    }
    
    print(f"\n✅ {name}:")
    print(f"   Accuracy: {accuracy:.2%}")
    print(f"   AUC-ROC: {auc:.3f}")

# Best model
best_model_name = max(results, key=lambda x: results[x]['accuracy'])
print(f"\n🏆 BEST MODEL: {best_model_name} ({results[best_model_name]['accuracy']:.2%})")

# ====================== CELL 7: VISUALIZE RESULTS ======================
# Model comparison chart
fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Accuracy comparison
ax1 = axes[0]
model_names = list(results.keys())
accuracies = [results[m]['accuracy'] for m in model_names]
colors = ['#3498db', '#2ecc71', '#e74c3c', '#9b59b6', '#f39c12']
bars = ax1.bar(model_names, accuracies, color=colors)
ax1.set_ylabel('Accuracy')
ax1.set_title('🎯 Model Accuracy Comparison', fontweight='bold')
ax1.set_ylim([0.5, 1.05])
ax1.tick_params(axis='x', rotation=45)
for bar, acc in zip(bars, accuracies):
    ax1.text(bar.get_x() + bar.get_width()/2, acc + 0.02, f'{acc:.1%}', ha='center', fontweight='bold')

# AUC comparison
ax2 = axes[1]
aucs = [results[m]['auc'] for m in model_names]
bars2 = ax2.bar(model_names, aucs, color=colors)
ax2.set_ylabel('AUC-ROC')
ax2.set_title('📈 Model AUC-ROC Comparison', fontweight='bold')
ax2.set_ylim([0.5, 1.05])
ax2.tick_params(axis='x', rotation=45)
for bar, auc in zip(bars2, aucs):
    ax2.text(bar.get_x() + bar.get_width()/2, auc + 0.02, f'{auc:.3f}', ha='center', fontweight='bold')

plt.tight_layout()
plt.show()

# ====================== CELL 8: FEATURE IMPORTANCE ======================
# Get feature importance from Random Forest
rf_model = trained_models['Random Forest']
importance_df = pd.DataFrame({
    'Feature': available_features,
    'Importance': rf_model.feature_importances_
}).sort_values('Importance', ascending=True)

plt.figure(figsize=(10, 6))
plt.barh(importance_df['Feature'], importance_df['Importance'], color='#3498db')
plt.xlabel('Importance Score')
plt.title('📊 Feature Importance for ASD Detection', fontweight='bold')
plt.tight_layout()
plt.show()

print("\n🎯 TOP 5 MOST IMPORTANT FEATURES:")
for i, row in importance_df.tail(5).iloc[::-1].iterrows():
    print(f"   • {row['Feature']}: {row['Importance']:.4f}")

# ====================== CELL 9: CONFUSION MATRIX ======================
# Show confusion matrix for best model
from sklearn.metrics import ConfusionMatrixDisplay

best_model = trained_models[best_model_name]
y_pred_best = results[best_model_name]['predictions']

fig, ax = plt.subplots(figsize=(8, 6))
ConfusionMatrixDisplay.from_predictions(
    y_test, y_pred_best,
    display_labels=['Control', 'ASD'],
    cmap='Blues',
    ax=ax
)
ax.set_title(f'🔍 Confusion Matrix - {best_model_name}', fontweight='bold')
plt.show()

# Classification report
print(f"\n📋 CLASSIFICATION REPORT ({best_model_name}):")
print(classification_report(y_test, y_pred_best, target_names=['Control', 'ASD']))

# ====================== CELL 10: SEVERITY CLASSIFICATION ======================
# Train model for severity levels (only ASD children)
print("=" * 60)
print("📊 SEVERITY CLASSIFICATION (ASD Children Only)")
print("=" * 60)

# Filter ASD children only
asd_df = df[df['asd_label'] == 1].copy()
print(f"ASD samples for severity prediction: {len(asd_df)}")

if len(asd_df) >= 10:  # Need enough samples
    X_sev = asd_df[available_features].fillna(0)
    y_sev = asd_df['severity_label']
    
    # Split
    X_train_s, X_test_s, y_train_s, y_test_s = train_test_split(
        X_sev, y_sev, test_size=0.3, random_state=42
    )
    
    # Scale
    X_train_s_scaled = scaler.fit_transform(X_train_s)
    X_test_s_scaled = scaler.transform(X_test_s)
    
    # Train Random Forest for severity
    rf_severity = RandomForestClassifier(n_estimators=100, random_state=42)
    rf_severity.fit(X_train_s_scaled, y_train_s)
    
    y_pred_sev = rf_severity.predict(X_test_s_scaled)
    sev_accuracy = accuracy_score(y_test_s, y_pred_sev)
    
    print(f"\n✅ Severity Classification Accuracy: {sev_accuracy:.2%}")
    print("\nClassification Report:")
    print(classification_report(y_test_s, y_pred_sev, 
                               target_names=['TD', 'Level 1', 'Level 2', 'Level 3'][:len(np.unique(y_sev))]))
else:
    print("⚠️ Not enough ASD samples for severity classification")

# ====================== CELL 11: SAVE MODELS ======================
# Save trained models
print("=" * 60)
print("💾 SAVING MODELS")
print("=" * 60)

# Save best model
joblib.dump(trained_models[best_model_name], 'asd_detection_model.pkl')
joblib.dump(scaler, 'feature_scaler.pkl')

print(f"✅ Saved: asd_detection_model.pkl ({best_model_name})")
print(f"✅ Saved: feature_scaler.pkl")

# Download to your computer
from google.colab import files
files.download('asd_detection_model.pkl')
files.download('feature_scaler.pkl')

print("\n📥 Models downloaded to your computer!")

# ====================== CELL 12: PREDICT NEW CHILD ======================
# Example: Make prediction for a new child
print("=" * 60)
print("🔮 PREDICT NEW CHILD")
print("=" * 60)

# Example child data (adjust values as needed)
new_child = {
    'age_months': 70,
    'completion_time_sec': 280,
    'total_score_or_trials': 28,
    'accuracy_overall': 55.0,
    'primary_asd_marker_1': 6,      # perseverative_errors
    'primary_asd_marker_2': 50.0,   # perseverative_rate
    'primary_asd_marker_3': 450,    # switch_cost_ms
    'attention_level': 2,
    'engagement_level': 2,
    'frustration_tolerance': 2,
    'instruction_following': 2,
    'overall_behavior': 2,
    'enhanced_risk_score': 35.0
}

# Only use features that exist
new_child_filtered = {k: v for k, v in new_child.items() if k in available_features}
new_child_df = pd.DataFrame([new_child_filtered])

# Scale and predict
new_child_scaled = scaler.transform(new_child_df)
prediction = trained_models[best_model_name].predict(new_child_scaled)
probability = trained_models[best_model_name].predict_proba(new_child_scaled)

print("\n📋 Input Features:")
for k, v in new_child_filtered.items():
    print(f"   {k}: {v}")

print("\n" + "=" * 40)
print("🔮 PREDICTION RESULT")
print("=" * 40)
print(f"   Diagnosis: {'🔴 ASD RISK' if prediction[0] == 1 else '🟢 No ASD Concern'}")
print(f"   Confidence: {max(probability[0]):.1%}")
print(f"   ASD Probability: {probability[0][1]:.1%}")
print(f"   Control Probability: {probability[0][0]:.1%}")

# ====================== CELL 13: CROSS VALIDATION ======================
# Perform 5-fold cross validation
print("=" * 60)
print("📊 CROSS VALIDATION (5-Fold)")
print("=" * 60)

cv_scores = cross_val_score(
    trained_models[best_model_name], 
    scaler.fit_transform(X), 
    y_binary, 
    cv=5, 
    scoring='accuracy'
)

print(f"\n{best_model_name} Cross-Validation:")
print(f"   Mean Accuracy: {cv_scores.mean():.2%}")
print(f"   Std Deviation: {cv_scores.std():.2%}")
print(f"   Individual Folds: {[f'{s:.2%}' for s in cv_scores]}")

# ====================== SUMMARY ======================
print("\n" + "=" * 60)
print("🎉 TRAINING COMPLETE!")
print("=" * 60)
print(f"""
📊 Summary:
   • Dataset: {len(df)} samples ({sum(df['asd_label']==1)} ASD, {sum(df['asd_label']==0)} Control)
   • Features: {len(available_features)}
   • Best Model: {best_model_name}
   • Accuracy: {results[best_model_name]['accuracy']:.2%}
   • AUC-ROC: {results[best_model_name]['auc']:.3f}

📁 Saved Files:
   • asd_detection_model.pkl (trained model)
   • feature_scaler.pkl (data scaler)

🚀 Next Steps:
   1. Collect more data (target: 100+ ASD, 150+ Control)
   2. Fine-tune hyperparameters
   3. Deploy model to your Flutter app via API
""")




