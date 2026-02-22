# Complete System Overview and Component Details – SenseAI ASD Screening System (25-26J-273)

## 1. High-Level Vision and Problem the Project Solves

### 1.1 Core problem
- **Late ASD identification** and delayed intervention.
- **Limited specialists** and long waiting times in clinics.
- **Subjective and inconsistent screening** practices.
- **Language and accessibility barriers** in existing tools.

### 1.2 Project vision
SenseAI is a **tablet-based, age-stratified ASD screening support system** for children aged **2–6.9 years**, combining:
- **Age-appropriate cognitive/behavioral assessments** (games + questionnaires),
- **Hybrid machine learning + clinical rules** to estimate **screening risk** (Low/Moderate/High),
- **Offline-first mobile app** for clinic tablets,
- **Backend + web admin portal** for data, hospital, and clinician management.

It is designed as a **screening support tool**, not a diagnostic test.

---

## 2. System Architecture (All Parts Together)

### 2.1 Three-tier architecture
- **Tier 1 – Frontend (Tablet / Mobile App in Flutter)**
  - Collects data via questionnaire and games.
  - Stores locally for offline use.
  - Sends sessions and feature data to backend.

- **Tier 2 – Backend (Node.js + Express + SQLite/Firebase + REST APIs)**
  - Validates and stores data.
  - Orchestrates calls to ML engine.
  - Serves APIs for mobile app and web admin panel.

- **Tier 3 – ML Engine (Python FastAPI Microservice)**
  - Loads age-specific models and preprocessing pipelines.
  - Receives cleaned feature payloads.
  - Returns risk estimation and explanation fields.

### 2.2 Web Admin Portal (React + TypeScript)
- Runs in browser for administrators and supervisors.
- Manages hospitals, clinicians, devices, sessions, and exports.

### 2.3 Data flow (simplified)
1. Clinician starts a session on the **Flutter app**.
2. Child plays game or caregiver answers questionnaire.
3. App records raw events → aggregates features → sends to **Node backend**.
4. Backend validates and forwards to **FastAPI ML engine**.
5. ML engine selects correct **age-specific model**, preprocesses, predicts, and applies **clinical rules**.
6. Backend stores prediction + metadata and sends result back to **app**.
7. Admin portal uses backend APIs to view analytics, manage hospitals/clinicians, and export data.

---

## 3. Frontend – Flutter Mobile/Tablet App

### 3.1 Purpose
- Provide a **simple, guided, clinician-friendly** interface to:
  - register / select a child,
  - run appropriate age-specific assessment,
  - collect clinician reflection,
  - present risk-level output in a safe, understandable way.

### 3.2 Key components
- `lib/`:
  - **Screens**: child profile, age selection, game launch screens, result screens.
  - **Services**: e.g., `api_service.dart` to talk to backend.
  - **Models**: Dart classes mapping to child/session/prediction entities.
  - **Localization**: ARB files + generated localizations for Sinhala/Tamil/English.

### 3.3 How it works (flow)
1. **Child registration / selection**
   - Clinician enters minimal data (age, language, optional identifiers).
   - App calculates `age_months` and determines age group.

2. **Assessment routing**
   - Age 2–3.5 years → Questionnaire (AI Doctor Bot).
   - Age 3.5–5.5 years → Frog Jump (Go/No-Go task).
   - Age 5.5–6.9 years → Color-Shape (DCCS-style task).

3. **Data capture**
   - For Questionnaire: stores item responses, domain scores, completion time, behavioral ratings.
   - For Frog Jump: logs Go/No-Go trials, reaction times, correct/incorrect responses, omissions, commissions.
   - For Color-Shape: logs pre-switch, post-switch, and mixed trials, reaction times, perseverative errors.

4. **Local persistence**
   - Uses local SQLite (via `sqflite`) to save sessions.
   - Supports offline-first operation and later sync.

5. **APIs**
   - Uses `api_service.dart` to:
     - send session data to backend,
     - trigger prediction,
     - fetch prediction results.

6. **Result display**
   - Shows risk level (Low/Moderate/High) and key domains.
   - Displays disclaimers and suggested next steps.

### 3.4 How it solves problems
- Reduces data entry complexity for clinicians (guided flow).
- Ensures correct task is used for age (reducing invalid assessments).
- Allows use in clinics with unstable internet (offline-first).
- Presents interpretations in simple, clinician-friendly language.

---

## 4. Assessment Components (Games + Questionnaire)

### 4.1 Age 2–3.5: Questionnaire (AI Doctor Bot)

**Purpose:**
- Capture early social communication and behavior signals via a parent/caregiver questionnaire inspired by M-CHAT-R/F principles and clinical practice.

**Key data collected:**
- Responses to critical items (e.g., joint attention, response to name, pretend play).
- Derived scores:
  - `total_score`
  - `critical_items_failed`
  - `critical_items_fail_rate`
  - social responsiveness-like indices
  - clinician behavioral ratings (attention, engagement, instruction-following, etc.).

**How it helps:**
- Appropriate for toddlers who cannot complete complex games.
- Provides a quick, low-burden screening using caregiver knowledge.
- Aligns with international practice (questionnaire-based early screening).

### 4.2 Age 3.5–5.5: Frog Jump Game (Go/No-Go)

**Purpose:**
- Assess **inhibitory control**, impulsivity, and sustained attention.
- A child presses or refrains from pressing based on “Go” and “No-Go” stimuli (e.g., frogs jumping).

**Key features (Frog Jump):**
- `nogo_accuracy`
- `commission_errors`, `commission_error_rate`
- `go_accuracy`, `overall_accuracy`
- `omission_errors`, `omission_error_rate`
- `avg_rt_go_ms`, `rt_variability`, `late_responses`
- clinician ratings (attention, engagement, frustration tolerance, overall behavior).

**How it helps:**
- Executive function (especially inhibition) is often atypical in ASD.
- Provides objective, trial-based metrics instead of only subjective observation.
- Helps differentiate between attentional and inhibitory issues.

### 4.3 Age 5.5–6.9: Color-Shape Game (DCCS)

**Purpose:**
- Assess **cognitive flexibility** and **perseveration**, inspired by the Dimensional Change Card Sort (DCCS) task.
- Child sorts based on color in one phase, then switches to shape (or vice versa).

**Key features (Color-Shape):**
- `pre_switch_accuracy`, `post_switch_accuracy`, `mixed_block_accuracy`
- `switch_cost_ms` (reaction time difference between pre/post-switch)
- `accuracy_drop_percent`
- `total_perseverative_errors`
- `perseverative_error_rate_post_switch`
- `number_of_consecutive_perseverations`
- `total_rule_switch_errors`
- `avg_rt_pre_switch_ms`, `avg_rt_post_switch_correct_ms`, `avg_reaction_time_ms`
- behavioral ratings (engagement, frustration, instruction following).

**How it helps:**
- Cognitive flexibility and perseveration differences are highly relevant for ASD.
- DCCS is well-known and clinically grounded, which helps examiners trust the design.

---

## 5. Backend – Node.js Server

### 5.1 Purpose
- Act as the **middle layer** between mobile app, ML engine, and admin portal:
  - Validate input data,
  - Manage sessions, children, and predictions,
  - Forward feature data to ML engine,
  - Provide APIs for admin analytics and exports.

### 5.2 Key responsibilities
- **API endpoints** for:
  - child registration,
  - session creation and updates,
  - prediction requests (`/predict`),
  - admin functions (clinician/hospital/device management),
  - data export.
- **Validation** (e.g., using Joi schemas) to ensure ranges and required fields.
- **Persistence** (local SQLite / Firebase sync).
- **ML orchestration**:
  - call FastAPI ML engine with standardized payloads,
  - handle engine health checks,
  - retry or display appropriate messages if ML engine unavailable.

### 5.3 How it solves problems
- Enforces consistent data structure before ML inference.
- Decouples mobile app from direct ML logic (better maintainability and security).
- Supports multi-tenant hospital deployments and admin management.

---

## 6. ML Engine – FastAPI Service (Python)

### 6.1 Purpose
- Provide a **production-ready ML microservice** that:
  - loads age-specific models,
  - preprocesses input safely,
  - applies hybrid ML + clinical rules,
  - returns structured risk outputs.

### 6.2 Age-specific models
- **2–3.5 years:** Questionnaire-based model
- **3.5–5.5 years:** Frog Jump model
- **5.5–6.9 years:** Color-Shape model

Each model has:
- a saved classifier (primarily logistic regression, RF for comparison),
- a scaler (RobustScaler),
- a feature list JSON,
- a metadata JSON (model version, training date, performance, etc.).

### 6.3 Preprocessing pipeline (per model)
- Missing value handling (median or rule-based filling).
- Outlier handling (winsorization at 1.5×IQR).
- Age normalization (z-scores or age-bin normalization).
- Composite indices (behavioral, inhibition, flexibility indices).
- Scaling with RobustScaler.
- Feature ordering using saved feature list.

### 6.4 Hybrid risk decision
1. **Model inference**: probability of ASD (or “at-risk”).
2. **Clinical rules**: based on normative-like deviation and composite indices, map into:
   - Low Risk
   - Moderate Risk
   - High Risk
3. **Combination logic** (example):
   - If ML and clinical rules both signal High → final High.
   - If ML moderate but clinical High → final High (clinical override).
   - If ML Low and clinical Low → final Low.
   - If disagreement → Moderate + “needs review” flag.

### 6.5 Health checks and integration
- `/health` endpoint indicates:
  - engine status (`OK`/`ERROR`),
  - model loaded status per age group.
- Node backend uses this to ensure readiness and inform the app/admin.

### 6.6 How it solves problems
- Ensures **interpretable**, medically-aligned risk output instead of black-box scores.
- Separates data science code from user interface and storage layers.
- Makes it easy to update models in future with minimal changes to the app.

---

## 7. Web Admin Portal – React/TypeScript

### 7.1 Purpose
- Provide hospital administrators and supervisors with:
  - visibility into app usage,
  - tools to manage clinicians and devices,
  - dashboards for session and risk statistics,
  - data export for research and quality monitoring.

### 7.2 Main modules (see also `03_ADMIN_PANEL_HOSPITAL_AND_CLINICIAN_MANAGEMENT.md`)
- **Authentication and roles** (admin, supervisor, clinician, data manager).
- **Hospital management** (create/edit/disable hospitals and units).
- **Clinician management** (accounts, roles, activation).
- **Device management** (tablets, versions, last sync).
- **Session & results dashboard** (filter by date, hospital, session type, risk).
- **Data quality and export** modules.

### 7.3 How it solves problems
- Allows scaling the system across multiple clinics/hospitals.
- Supports supervision and governance (who used the tool, how often, trends).
- Enables research exports without exposing identifiers.

---

## 8. Data and Evaluation Design

### 8.1 Data collection
- Real clinical sessions from participating hospitals/clinics.
- Three age groups, each with its own assessment modality.
- Clinician-confirmed labels or questionnaire-based risk labels (depending on available gold standard).

### 8.2 Dataset preparation
- Filter invalid/incomplete sessions beyond defined thresholds.
- Apply age and inclusion criteria (2–6.9 years).
- Create child-level split into **train / validation / test**.

### 8.3 Evaluation
- Use sensitivity, specificity, ROC-AUC as core metrics.
- Emphasize clinically important metrics (e.g., high sensitivity, acceptable specificity).
- Evaluate per age group separately.

---

## 9. How Each Part Contributes to Solving the Problem

### 9.1 Frontend app
- Makes standardized assessments feasible in busy clinics.
- Reduces reliance on unstructured clinician observation.
- Delivers results quickly at point-of-care.

### 9.2 Games and questionnaire
- Provide **age-appropriate**, evidence-grounded measures:
  - social signs (questionnaire),
  - inhibitory control (Frog Jump),
  - cognitive flexibility and perseveration (Color-Shape).

### 9.3 Backend + admin portal
- Enables multi-hospital deployments and supervision.
- Preserves data quality and governance.
- Allows secure reporting and monitoring over time.

### 9.4 ML engine
- Encodes clinically informed pattern recognition.
- Translates complex metrics into simple risk levels.
- Provides a consistent, explainable framework for screening support.

---

## 10. Overall Usefulness and Impact

### 10.1 Clinical usefulness
- Supports earlier identification of at-risk children in regular clinics.
- Standardizes assessments and reduces subjective variation.
- Provides structured output that can support referral decisions.

### 10.2 Operational usefulness
- Designed for **low-resource** and **offline** environments.
- Works on widely available Android tablets.
- Centralized admin web portal supports real-world management.

### 10.3 Research usefulness
- Produces structured, analyzable datasets.
- Allows ongoing improvement of models and thresholds.
- Supports future multi-site validation and comparative studies.

---

## 11. Relationship to Your Research Paper and Other Docs

- This file gives the **complete system-level description**.
- `01_TRUSTED_DATASETS_AND_VALIDATION_SOURCES.md` explains **datasets and validation sources**.
- `02_FINAL_PRODUCT_TASKS_MOBILE_BACKEND_ML.md` gives a **checklist** to finalize the product.
- `03_ADMIN_PANEL_HOSPITAL_AND_CLINICIAN_MANAGEMENT.md` details **admin/web features**.
- `04_FUTURE_FEATURES_AND_PRODUCT_ROADMAP.md` provides **future work and roadmap**.
- `05_RESEARCH_PAPER_COMPLETE_WRITING_PACK.md` gives a **full writing structure** for your paper.

Together, these documents cover **every part** of your project: frontend, backend, ML, web admin, games, datasets, evaluation, and research write-up.

