Age-Specific Model Training Notebooks
=====================================

This folder contains Jupyter notebooks for training age-specific ASD screening models.

- `Age_2_3_5_Questionnaire_Training.ipynb`: Training pipeline for age 2–3.5 (months) using parental questionnaires, online datasets, and hospital data.

Each notebook is designed to:
- Load and merge online datasets with your collected (hospital/system) data
- Filter records to the relevant age range
- Explore the data with tables, charts, and summary statistics
- Preprocess features (cleaning, scaling, outlier handling)
- Train and evaluate ML models (e.g., Logistic Regression, Random Forest)
- Report metrics focused on sensitivity/recall for ASD vs non-ASD

