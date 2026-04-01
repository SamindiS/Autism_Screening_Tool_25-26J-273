# Future Features and Product Roadmap (ASD Screening System)

## Purpose
This document proposes high-impact, clinically safe, and technically realistic features for the final stage and future releases.
It is designed to be used as:
- “Future work” section in the research paper,
- roadmap for product finalization,
- viva defense support (“what next and why”).

---

## 1) Clinical safety + interpretability (highest priority)

### 1.1 Explainable screening output (“Why this risk level?”)
Add a clinician-friendly explanation that avoids black-box language:
- Domain-level contributions:
  - Social domain (questionnaire)
  - Inhibition control (Frog Jump)
  - Cognitive flexibility + perseveration (Color-Shape)
  - Behavioral regulation (clinician reflection)

Output example (safe):
- “Risk increased due to low No-Go accuracy and high commission errors, consistent with inhibitory control difficulty.”

### 1.2 Uncertainty handling and “needs review”
Add:
- a confidence indicator
- a “needs clinician review” flag if:
  - too many missing features
  - session quality flagged
  - model probability is near boundary

### 1.3 Model calibration monitoring
Add:
- calibration plots on validation set
- periodic check using new collected data (drift monitoring)

---

## 2) Data quality and anti-cheating / reliability checks

### 2.1 Session quality scoring
Compute a session quality score using rules like:
- too short completion time
- repeated random tapping patterns
- impossible values
- missing too many trials

Use quality score to:
- block prediction (ask to redo)
- downgrade confidence

### 2.2 Device and environment checks
- low battery warnings during sessions
- performance warnings if device lag affects reaction time measurement

---

## 3) Longitudinal child tracking (clinically meaningful)

### 3.1 Progress over time
Allow multiple sessions per child:
- show trends in key measures (e.g., inhibitory control index)
- show risk trend
- allow clinician notes across visits

### 3.2 Follow-up scheduling
If moderate/high risk:
- prompt for referral
- schedule re-screening

---

## 4) Reporting and documentation improvements

### 4.1 PDF report enhancements
Include:
- child anonymized id
- session type
- risk level
- domain summary (bullets)
- disclaimer (“screening tool”)
- clinician signature line (optional)

### 4.2 Export packs for research
Generate anonymized datasets automatically:
- remove identifiers
- include model/rules versions
- include quality flags

---

## 5) Admin panel expansions (operational maturity)

### 5.1 Full hospital operations
- hospital/ward/unit structure
- device registry and monitoring
- clinician training content

### 5.2 Governance
Add:
- export logs
- threshold change logs
- model update logs

---

## 6) ML/AI future extensions (only if clinically justified)

### 6.1 Personalization within safe limits
- Use age-bin norms and site norms (carefully)
- Avoid “over-personalization” that hides clinical signals

### 6.2 Additional modalities (future)
If ethics and budget allow:
- eye gaze / attention via camera (privacy-sensitive)
- voice prosody (privacy-sensitive)
- wearable motion (optional)

These should be “future work”, not required for final submission.

---

## 7) Internationalization and accessibility
- Sinhala/Tamil clinical terminology review
- accessibility mode (large UI, simplified flow)
- caregiver mode vs clinician mode

---

## 8) Deployment maturity
- automatic updates
- crash reporting (privacy-safe)
- performance monitoring
- automated backup and restore

---

## 9) Roadmap suggestion (phased)

### Phase 1: Final submission ready
- final user flow
- hospital + clinician management
- stable ML engine inference
- reproducible evaluation
- reports/export

### Phase 2: Reliability and quality
- session quality scoring
- audit logs everywhere
- device monitoring

### Phase 3: Clinical maturity
- longitudinal tracking
- follow-up scheduling
- periodic calibration checks

### Phase 4: Research extensions
- multi-site generalization studies
- additional modalities (optional)

