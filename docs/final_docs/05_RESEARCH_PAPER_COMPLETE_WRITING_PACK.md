# Research Paper – Complete Writing Pack (Project 25-26J-273)

## How to use this document
This is a full writing guide and template. You can copy each section into your paper and replace bracketed placeholders.

It is aligned with your project:
- Age-stratified ASD screening (2–6.9 years)
- Questionnaire + Go/No-Go (Frog Jump) + DCCS (Color-Shape)
- Hybrid ML + clinical rules risk levels (Low/Moderate/High)
- Flutter + Node.js + FastAPI ML engine architecture

---

## Title (examples)
Choose one:
- **“SenseAI: An Offline-Capable, Age-Stratified Autism Screening Support System Using Executive-Function Games and Hybrid Clinical Machine Learning”**
- **“A Tablet-Based Early Autism Screening Support Tool for Ages 2–6: Age-Specific Models, Clinical Rules, and Deployable Architecture”**

---

## Abstract (template)
**Background:** Autism Spectrum Disorder (ASD) is often identified late, reducing access to early intervention. Many regions face limited specialist availability and language barriers in existing tools.  
**Objective:** This study presents a multilingual, offline-first tablet system for early ASD screening support for children aged 2–6.9 years using age-appropriate tasks and hybrid clinical machine learning.  
**Methods:** The system uses three age-stratified assessments: a caregiver questionnaire (2–3.5 years), a Go/No-Go inhibitory control game (3.5–5.5 years), and a DCCS-based cognitive flexibility game (5.5–6.9 years). For each age group, interpretable models (logistic regression; shallow random forest for comparison) were trained with robust preprocessing, outlier winsorization, age normalization, and child-level train/test splitting. Risk levels (Low/Moderate/High) were assigned using a hybrid approach combining ML probability with clinically interpretable deviation rules and composite indices.  
**Results:** [Insert performance metrics per age group: sensitivity, specificity, ROC-AUC, and calibration].  
**Conclusion:** The proposed system provides a deployable screening support workflow with clinically interpretable outputs, suitable for low-resource settings.  
**Keywords:** Autism screening, executive function, Go/No-Go, DCCS, clinical ML, mobile health, FastAPI, Flutter.

---

## I. Introduction (write-up)
### 1. Background
Autism Spectrum Disorder (ASD) is a neurodevelopmental condition characterized by differences in social communication and restricted or repetitive behaviors. Early identification is essential because early intervention is associated with improved developmental outcomes. However, many healthcare systems face constraints such as limited access to trained specialists, long waiting times, and inconsistent screening practices.

### 2. Problem context (local relevance)
In resource-limited clinical settings, screening tools may be unavailable in local languages, require specialized training, or rely heavily on subjective observation. Digital screening support tools can reduce burden by standardizing data capture, providing objective task metrics, and offering risk stratification for clinician review.

### 3. Gap / motivation
Existing screening approaches often:
- do not provide age-appropriate objective tasks for 2–6 years,
- lack offline functionality,
- do not integrate interpretable ML with clinically meaningful rules,
- are difficult to deploy across hospitals due to operational constraints.

### 4. Contribution
This project contributes:
- an age-stratified tablet-based screening workflow for 2–6.9 years,
- objective executive-function metrics via Go/No-Go and DCCS-inspired tasks,
- interpretable ML models combined with clinical rules for Low/Moderate/High risk,
- deployable architecture (Flutter app + Node backend + FastAPI ML engine),
- multilingual support suitable for real clinical environments.

---

## II. Ease of Use (requested section)
This section must show that the system is practical and usable in clinics.

### A. Workflow simplicity
Describe the user journey:
- minimal steps: start → consent → age entry → assessment → result
- automatic age-based routing to correct assessment
- automatic scoring and report generation

### B. Time efficiency
Provide approximate times:
- questionnaire: [X minutes]
- frog jump: [X minutes]
- color-shape: [X minutes]

### C. Offline-first design
Explain:
- all assessments run without internet
- results stored locally
- background sync to server when network available

### D. Multilingual and accessibility considerations
- English/Sinhala/Tamil labels and instructions
- large buttons and simple interactions for children
- caregiver-friendly questionnaire UI

### E. Error prevention
- input validation (age, missing fields)
- session resume support
- session quality checks (optional)

---

## III. System Architecture (recommended)
Describe the 3-tier architecture:
- Flutter tablet app for data capture and UI
- Node.js backend for validation, storage, and orchestration
- FastAPI ML engine for age-specific model inference

Include a diagram if allowed.

---

## IV. Maintaining the Integrity of the Specifications (requested section)
This section is where you prove engineering discipline.

### A. Requirements traceability
State that each requirement maps to a module:
- age group routing → routing service
- ML inference → FastAPI engine
- admin management → admin panel modules
- offline storage → local database

### B. Data integrity
Explain how you ensure correctness:
- child-level splitting prevents leakage in evaluation
- schema locking: fixed feature lists for each model
- versioning: model/scaler/features metadata saved and logged

### C. Clinical integrity (critical)
State clearly:
- screening tool ≠ diagnosis
- hybrid ML + clinical rules reduces over-reliance on ML probability
- interpretable models enable clinician understanding
- clinical thresholds based on age-normalized deviations and composite indices

### D. Operational integrity
- audit logs (who did what and when)
- role-based access (admin/supervisor/clinician)
- device management (tablet registration)

### E. Security and privacy integrity
- consent tracking
- anonymized exports
- avoid storing identifiers when not required
- safe logging policy

---

## V. Methods (dataset, preprocessing, modeling)

### A. Data collection protocol
Describe:
- setting: hospital/clinic
- inclusion: children aged 2–6.9 years
- exclusion: incomplete sessions beyond threshold (optional)
- ethics/consent

### B. Feature engineering
Explain per age group:
- Questionnaire: social responsiveness proxies, critical item failures, behavioral ratings
- Frog Jump (Go/No-Go): No-Go accuracy, commission errors, RT variability, omission errors
- Color-Shape (DCCS): switch cost, post-switch accuracy, perseveration metrics

### C. Age normalization
Justify:
- performance changes with age
- normalize using age bins or z-scores:
  - within-bin mean and standard deviation

### D. Outlier handling
Use clinically reasonable approach:
- winsorization (cap at IQR bounds) rather than deleting data

### E. Data expansion (if used)
Explain multi-view expansion:
- one child contributes multiple domain-specific views
- child-level split prevents leakage

### F. Safe augmentation (if used)
Bootstrap resampling with small noise to preserve real distributions and avoid “synthetic children”.

### G. Modeling choice
Primary:
- Logistic regression for interpretability and stability with small clinical datasets
Secondary:
- shallow random forest for comparison and feature importance

### H. Risk stratification: hybrid ML + clinical rules
Explain:
1) ML gives probability / risk tendency  
2) clinical rules decide Low/Moderate/High using deviation thresholds and composite indices  
3) combine them to reduce false positives/negatives and preserve clinical trust

---

## VI. Equations (requested section)
Include only what you use.

### A. Logistic regression
\[
p(y=1 \mid x)=\sigma(w^T x+b)=\frac{1}{1+e^{-(w^T x+b)}}
\]

### B. Z-score (age normalization)
\[
z=\frac{x-\mu_{\text{age}}}{\sigma_{\text{age}}}
\]

### C. Composite clinical index (example)
\[
\text{CRI}=\alpha f_1+\beta f_2+\gamma f_3
\]

### D. Metrics (recommended)
Sensitivity (recall):
\[
\text{Sensitivity}=\frac{TP}{TP+FN}
\]
Specificity:
\[
\text{Specificity}=\frac{TN}{TN+FP}
\]
Precision:
\[
\text{Precision}=\frac{TP}{TP+FP}
\]
F1:
\[
F1=\frac{2\cdot \text{Precision}\cdot \text{Recall}}{\text{Precision}+\text{Recall}}
\]

---

## VII. Results (what to report)
For each age group, include:
- confusion matrix
- sensitivity and specificity (priority over accuracy)
- ROC-AUC (if sample size allows)
- risk-level distribution (Low/Moderate/High)
- example explanations for a few cases

Add:
- comparison: ML-only vs hybrid rules (even qualitative)  

---

## VIII. Discussion
Cover:
- clinical interpretability of key features
- stability of logistic regression in small datasets
- limitations: sample size, site bias, label quality tier
- safety: screening output not a diagnosis

---

## IX. Conclusion
Summarize:
- age-stratified screening workflow
- hybrid ML + rules for clinically meaningful risk levels
- deployable architecture
- future work roadmap

---

## Literature Review (how to structure it)
Create subsections:
1) ASD screening tools and early detection importance  
2) Executive function in ASD (inhibition and cognitive flexibility)  
3) Go/No-Go evidence and measures (commission errors, RT variability)  
4) DCCS evidence and measures (switch cost, perseveration)  
5) Clinical ML best practices (interpretability, calibration, risk stratification)  
6) Mobile health deployment (offline-first, multilingual, low-resource settings)

For each subsection:
- summarize 3–7 papers
- state what they did
- state limitations
- connect to your design choice

---

## Appendix suggestions (strong for viva)
- Data dictionary (columns, units, valid ranges)
- Model cards per age group
- API contract (request/response JSON)
- Consent and ethics statements
- Screenshots of UI flows
- Admin panel permission matrix

