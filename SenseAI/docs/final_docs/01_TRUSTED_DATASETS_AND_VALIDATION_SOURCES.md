# Trusted Datasets, Norms, and Validation Sources (ASD Screening System)

## 1) What you are asking for (clarified)
You want **trusted sources** for:
- A “trained dataset” you can use to **test** your system.
- Clinically defensible references (standards, norms, tools) for **risk-level decisions**.

Important clinical reality:
- Public datasets rarely match your exact **game telemetry** (Frog Jump / Go-NoGo, Color-Shape / DCCS) and your questionnaire schema.
- The most defensible “test dataset” for your system is a **held-out set** from your own collection, ideally with **gold-standard labels** or clinician-confirmed labels.

This document explains what is realistically available, what is trusted, and how to build an examiner-safe evaluation dataset.

---

## 2) Trusted sources you can cite (clinical standards)

### 2.1 Screening tools (toddler / early childhood)
- **M-CHAT-R/F** (Modified Checklist for Autism in Toddlers, Revised with Follow-Up)
  - Use for: questionnaire content framing, domain rationale, screening discussion.
  - Use carefully: you cannot claim you “used M-CHAT” unless you reproduced it exactly and have licensing/permission where applicable. You *can* say “M-CHAT-R/F inspired structure” if your items are adapted.

### 2.2 Diagnostic and assessment references (ground-truth sources)
These are not “datasets”, but they are **trusted label standards**:
- **ADOS-2** (Autism Diagnostic Observation Schedule, Second Edition)
- **ADI-R** (Autism Diagnostic Interview–Revised)
- **CARS-2** (Childhood Autism Rating Scale, Second Edition)

Use for:
- Labeling your research dataset (“ASD” vs “Typically developing”) using clinically recognized criteria.
- Justifying that your model is validated against a recognized reference standard.

### 2.3 Executive function tasks aligned with your games
Your two games map to widely used neuropsychological constructs:
- **Go/No-Go** → inhibitory control, impulsivity, sustained attention
- **DCCS (Dimensional Change Card Sort)** → cognitive flexibility / set shifting, perseveration

You should cite:
- Peer-reviewed normative studies and cognitive development literature for Go/No-Go and DCCS.
- Where available: standardized toolkits (e.g., NIH Toolbox cognition battery) and related papers for age norms and interpretation.

---

## 3) Trusted public datasets (what exists, what doesn’t)

### 3.1 Why you likely won’t find “ready-to-use” datasets for your exact app telemetry
Your telemetry features are app-specific:
- Trial-level taps, omissions, commission errors, reaction time variability, switch cost, perseveration metrics, completion time, etc.
Most public ASD datasets are:
- imaging (MRI/EEG), genetics, clinical text, questionnaires, or wearable sensors
and not your custom game measures.

So: you can use public datasets mainly for **background comparisons** and literature review—not as plug-in evaluation sets for your exact API features.

### 3.2 Repositories that are high-quality but require access approval
These can be “trusted sources” but are not instant downloads:
- **NIMH Data Archive (NDA / NDAR)**: large clinical research datasets (access controlled).
- **SFARI Base**: research datasets (access controlled).

Use for:
- Literature comparison and “future expansion” statements.
- Not for direct testing unless you redesign your feature extraction to match their data.

### 3.3 Common open ASD datasets (usually not feature-compatible)
- **ABIDE I/II**: mostly MRI (useful for research background, not your games).

---

## 4) The most defensible “test dataset” for your system (recommended)

### 4.1 Build your own “Trusted Test Set” from your collected data
You will create:
- **Training set** (for model fitting)
- **Validation set** (for tuning thresholds and calibration)
- **Hold-out test set** (for final reported performance)

Minimum requirements:
- **Child-level split**: the same child must never appear in both train and test (to avoid leakage).
- Ideally **site-level split** (if multiple hospitals): train on Hospital A, test on Hospital B for real generalization.

### 4.2 Label quality tiers (what examiners accept)
You can define your label tier in the paper:
- **Tier A (best):** ADOS-2 / ADI-R / CARS-2 confirmed labels
- **Tier B:** clinician diagnosis recorded in hospital charts
- **Tier C:** validated screening threshold labels (e.g., standardized questionnaire threshold) — acceptable for screening research but weaker than Tier A/B

### 4.3 What makes the dataset “trusted”
You will be trusted if you document:
- Inclusion/exclusion criteria
- Data collection setting (clinic, supervision level)
- Device model and configuration
- Quality checks (missing data thresholds, invalid sessions)
- Consent and anonymization
- Label source tier (A/B/C)
- Train/validation/test split strategy

---

## 5) What you can ship in GitHub vs what should not be public

### 5.1 You should NOT publish (privacy/ethics)
- Any real child identifiable data: names, phone numbers, exact birthdates, hospital identifiers if sensitive, clinician notes.
- Raw session logs if they contain identifiers.

### 5.2 You can publish (safe, reproducible)
- **Schema** (column names + definitions) without real data
- **Synthetic demo dataset** clearly labeled as synthetic
- **Model training notebooks** and preprocessing code
- **Evaluation pipeline code** that runs with demo data
- **Model cards** describing intended use and limitations

---

## 6) Practical recommendation: what to do now

### 6.1 During data collection
- Keep a separate folder/repo (private) for raw data.
- Export to a standardized schema (one CSV per age group OR one unified table with `session_type`).
- Maintain a data dictionary (column descriptions, units, valid ranges).

### 6.2 After data collection (to create your trusted test set)
- Freeze a “Test Set v1”:
  - Select 20–30% children as hold-out (or Hospital B).
  - Do not touch it until final results.
- Train using the rest, tune only on validation.
- Report results only on the frozen holdout.

---

## 7) Citations guidance (how to write it in your report)
Recommended phrasing (safe and examiner-friendly):
> “The system is a screening support tool (not a diagnostic instrument). Labels were obtained using clinician-confirmed diagnosis and/or standardized assessment references where available. Risk stratification follows age-normalized deviation rules aligned with established developmental assessment practice.”

---

## 8) If you want, I can tailor the exact evaluation plan
To finalize an examiner-safe plan, decide:
- Label tier (A/B/C)
- Single-site vs multi-site test design
- Minimum sample size per age group
- Required metrics (sensitivity, specificity, ROC-AUC, calibration)

