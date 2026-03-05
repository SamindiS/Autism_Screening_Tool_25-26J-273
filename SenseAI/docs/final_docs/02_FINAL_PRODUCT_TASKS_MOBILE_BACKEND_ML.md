# Final Product Tasks (After Data Collection)

## Purpose
This document is a detailed checklist for converting the current system (pilot + development mode) into a final, clinic-ready product where:
- A **new/random child** can be assessed end-to-end,
- The system **automatically selects the correct assessment** based on age/session type,
- The system returns a **final screening risk level** (Low / Moderate / High) with clinically defensible logic,
- Admin panel supports operational needs (hospital/clinician management).

---

## 1) Product Definition (what “final version” means)

### 1.1 Core user journey (tablet)
1. Start app
2. Consent + disclaimers
3. Create child profile (minimal fields)
4. App selects assessment (age group)
5. Run assessment session (questionnaire or game)
6. Collect clinician reflection (optional but recommended)
7. Submit session for risk estimation
8. Show result (risk level + explanation)
9. Generate report (PDF/summary) and store locally
10. Sync to backend/server when online (optional)

### 1.2 Non-functional requirements
- Offline-first: app works without internet
- Fast predictions: <1–2 seconds for risk output
- Data privacy: no identifiers in public logs
- Reliability: prevent crashes, prevent duplicate sessions, handle partial sessions
- Versioning: record app version + model version per prediction

---

## 2) Mobile App (Flutter) – Finalization tasks

### 2.1 Remove pilot-only flows
If your pilot version contains separate logins, debug routes, or developer-only pages:
- Remove unused role selection screens.
- Remove “test clinician accounts” and hard-coded tokens.
- Remove debug toggles that change scoring behavior.
- Remove screens that allow arbitrary session type selection (keep only age-driven routing in final mode).

Deliverable:
- A single “Start Screening” entry flow.

### 2.2 Final “random child screening” mode (kiosk vs clinician)
Choose **one** of these patterns:

**Option A: Kiosk mode (no login)**
- Use a device-registered mode where the tablet belongs to one hospital/clinic.
- On app start: show consent + “Start New Child”.
- Admin panel controls device registration and data sync permissions.

**Option B: Clinician login (recommended if hospitals need accountability)**
- Clinician logs in (PIN/password).
- Clinician starts session for a new child.
- All sessions are attributed to clinician ID (audit trail).

Deliverable:
- A final authentication and session ownership policy.

### 2.3 Child profile data model (minimal, safe)
Recommended minimal fields:
- `child_id` (generated, unique)
- `age_months` (or DOB locally converted to age months; avoid storing DOB if not required)
- `sex` (optional)
- `language` (English/Sinhala/Tamil)
- `guardian_consent` (boolean + timestamp)
- `site_id` (hospital/clinic branch, optional)

Data quality:
- Age must be validated (e.g., 24–83 months if your system is 2–6.9 years).
- Block missing age. Risk routing depends on age.

### 2.4 Assessment routing (age-specific)
Implement a single routing function:
- If 24–42 months → Questionnaire (2–3.5)
- If 42–66 months → Frog Jump (3.5–5.5)
- If 66–83 months → Color-Shape (5.5–6.9)

Deliverable:
- One routing function used everywhere (UI selection, backend payload, ML engine).

### 2.5 Data capture consistency and schema lock
Freeze your feature schema after data collection:
- For each session type, define the final set of features and units.
- Ensure that every session writes data in that schema even if values are missing.

Deliverables:
- A data dictionary per session type.
- Migration scripts if you have old pilot fields.

### 2.6 Offline storage, sync, and conflict policy
Define:
- Local database tables: `children`, `sessions`, `predictions`, `sync_queue`
- Sync triggers: on Wi-Fi, on manual “sync now”, on schedule
- Conflict policy: never overwrite clinician-entered values without warning

Deliverables:
- Sync strategy document + implementation.

### 2.7 Results UX and “not diagnosis” messaging
Your final result page should include:
- Risk level: Low / Moderate / High
- A short explanation: “screening support output”
- Suggested next steps (clinical referral guidance)
- Option to export report (PDF)

Deliverable:
- Results UX that is safe and clinically phrased.

---

## 3) Backend (Node.js) – Finalization tasks

### 3.1 API contract stabilization
Create a stable server contract so Flutter never has to guess fields.

Recommended structure:
- `POST /api/sessions`
  - stores session data
  - returns session id
- `POST /api/predict`
  - accepts {child_id, age_months, session_type, features, clinician_reflection}
  - returns {risk_level, probability, rationale, model_version, rules_version}

Deliverables:
- Versioned API contract (OpenAPI/Swagger or written spec).

### 3.2 Validation and guardrails (server-side)
Implement:
- schema validation per session type (Joi)
- range checks (e.g., accuracy 0–100, times non-negative)
- reject impossible values; accept missing values but mark them

Deliverables:
- Server-side validation that prevents corrupt data and reduces ML garbage input.

### 3.3 Logging and privacy
Ensure logs never print:
- child name/guardian phone
- raw free-text clinician notes (unless encrypted or redacted)

Deliverable:
- Privacy-safe logging policy.

### 3.4 Audit trail
Store:
- who created/edited session
- when it happened
- what changed (optional)

Deliverable:
- audit tables + endpoints.

---

## 4) ML Engine (FastAPI) – Finalization tasks

### 4.1 Model registry and versioning
For each age group keep:
- model file (`.pkl`)
- scaler (`.pkl`)
- feature list (`.json`)
- metadata (`.json`)

Add:
- `model_version` and `rules_version`
- training date, dataset version, feature schema version

Deliverable:
- deterministic model loading with clear versions.

### 4.2 Inference pipeline must match training pipeline
The engine must replicate training preprocessing:
- missing value handling (median impute or rule-based)
- outlier handling (winsorization)
- scaling (RobustScaler)
- feature ordering using the saved feature list
- age-normalization if used (z-scores or bin-based)

Deliverable:
- strict, tested preprocessing parity between notebook and API.

### 4.3 Hybrid ML + clinical rules output
Output should not be ML-only.
Recommended decision stages:
- ML probability (risk tendency)
- clinical rules / deviation thresholds (risk level)
- final reconciled risk output

Deliverable:
- `risk_level` and `rationale` fields.

### 4.4 Health checks
Expose:
- `/health` status
- loaded model readiness per age group
- versions loaded

Deliverable:
- backend can reliably detect “ML engine ready”.

---

## 5) Data science: finalize datasets, training, and evaluation

### 5.1 Freeze datasets and create splits
Create:
- `train.csv`
- `val.csv`
- `test.csv` (holdout, frozen)

Child-level split mandatory.
If multi-hospital: keep one hospital as holdout if possible.

Deliverable:
- a documented dataset split.

### 5.2 Calibration and threshold tuning
For clinical acceptability:
- tune threshold boundaries on validation set only
- record and freeze thresholds with `rules_version`

Deliverables:
- calibration results + fixed thresholds.

### 5.3 Model cards (recommended)
Write one per age group:
- intended use
- limitations
- performance summary
- fairness considerations
- safety / disclaimers

Deliverable:
- `MODEL_CARD_*.md` files.

---

## 6) Security, compliance, and release readiness

### 6.1 Security baseline
- HTTPS for networked deployments
- authentication for admin panel and backend endpoints
- rotate secrets, no secrets in git

### 6.2 Data protection
- encryption at rest (if feasible) or OS-level encryption
- anonymize exports by default
- consent tracking

### 6.3 Release checklist (Android APK)
- update app version/build number
- run `flutter analyze` and fix errors
- run release build
- test on real tablet hardware

---

## 7) Final deliverables list (what you should submit)
Minimum final package:
- Final Flutter app (APK)
- Node backend deployable
- FastAPI ML engine deployable
- Documented model + rules per age group
- Admin panel with hospital/clinician management
- Research paper + appendices (dataset schema, evaluation protocol)

