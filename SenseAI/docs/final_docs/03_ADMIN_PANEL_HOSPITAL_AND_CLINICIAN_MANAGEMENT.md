# Admin Panel – Hospital, Clinician, Device, and Operations Modules (Final Version)

## Purpose
This document defines what the admin panel should contain in the final deployment so hospitals can:
- manage sites and clinicians,
- monitor devices/tablets,
- view and export sessions and risk outputs,
- maintain auditability and data integrity.

The goal is a complete, defendable “production features” list, suitable for your implementation plan and research paper.

---

## 1) Core entities (data model)

### 1.1 Hospital
Fields (recommended):
- `hospital_id` (unique)
- `name`
- `address` (optional)
- `district/province` (optional)
- `contact_phone/email` (optional)
- `status` (active/inactive)
- `created_at`, `updated_at`

### 1.2 Branch / Unit / Ward (optional but useful)
If you deploy to multiple departments:
- `unit_id`
- `hospital_id` (FK)
- `unit_name` (e.g., Pediatric OPD, Neurodevelopment clinic)
- `status`

### 1.3 Clinician
Fields:
- `clinician_id`
- `hospital_id` / `unit_id`
- `full_name` (or pseudonymous display name if needed)
- `role` (Admin / Supervisor / Clinician / DataManager)
- `phone/email` (optional)
- `status` (active/inactive)
- `last_login_at`
- `created_at`, `updated_at`

Authentication choices:
- PIN-based login (clinic-friendly)
- password-based login (more standard)

### 1.4 Device / Tablet
Fields:
- `device_id`
- `hospital_id` / `unit_id`
- `device_name` (e.g., Tablet-01)
- `platform` (Android)
- `app_version`
- `last_sync_at`
- `status` (active/lost/disabled)

### 1.5 Child (privacy-safe)
Strongly recommended:
- Store a generated `child_id` and age in months.
- Avoid storing identifying fields in admin panel unless required by ethics.

### 1.6 Session / Assessment
Fields:
- `session_id`
- `child_id`
- `session_type` (questionnaire / frog_jump / color_shape)
- `age_months`
- `hospital_id`, `unit_id`, `device_id`, `clinician_id`
- timestamps: start/end
- completion status (complete/incomplete)
- raw features (stored carefully)

### 1.7 Prediction / Result
Fields:
- `prediction_id`
- `session_id`
- `risk_level` (Low/Moderate/High)
- `ml_probability` (optional)
- `clinical_rules_flags` (json)
- `model_version`, `rules_version`, `features_version`
- `created_at`

---

## 2) Role-based access control (RBAC)

### 2.1 Roles and permissions (recommended)
- **Admin**
  - manage hospitals, units, clinicians, devices
  - full exports
  - threshold/version configuration (if allowed)
- **Supervisor**
  - view dashboards
  - manage clinicians within their hospital/unit
  - export anonymized data
- **Clinician**
  - view sessions they created
  - view results and generate reports
  - cannot export raw data (optional policy)
- **Data Manager**
  - exports and analytics only (no clinician management)

Deliverable:
- A permissions matrix table in your documentation.

---

## 3) Admin panel modules (screens/features)

### 3.1 Authentication & accounts
- login/logout
- reset password / reset PIN (admin flow)
- enforce password policies if applicable
- session timeout

### 3.2 Hospital management module
- Create hospital
- Edit hospital
- Disable hospital (soft delete)
- View hospital details
- Assign units/branches

### 3.3 Clinician management module
- Create clinician account
- Assign role and hospital/unit
- Activate/deactivate clinician
- View clinician activity (sessions run, last login)
- Reset credentials

### 3.4 Device management module
- Register device (tablet enrollment)
- Assign device to hospital/unit
- Show device health:
  - last sync time
  - app version
  - storage warnings (optional)
- Disable device (lost/stolen)

### 3.5 Session dashboard
Filters:
- date range
- hospital/unit
- session type (age group)
- clinician
- device

Views:
- list/table view with export
- session detail view with:
  - key features summary
  - prediction summary
  - clinician reflection
  - audit fields

### 3.6 Results dashboard (risk analytics)
Charts:
- risk distribution by hospital/unit
- risk distribution by age group
- trend over time

Clinical caution:
- clearly label results as “screening risk”, not diagnosis.

### 3.7 Data quality module (high-value)
Detect:
- missing key fields
- impossible values (negative times, accuracy > 100)
- extremely short sessions (random tapping)
- repeated sessions unusually frequent

Actions:
- flag sessions
- mark for review

### 3.8 Data export module
Exports:
- anonymized CSV export (default)
- full export (restricted to Admin only)
- per age group exports
- export logs (who exported, when)

### 3.9 Model & rules version module (optional but excellent for viva)
Display:
- current model version per age group
- model training date
- rules thresholds version
- “last updated” history

If you allow updating models:
- upload new model pack
- validate required files present
- rollback to previous version

---

## 4) Backend support required (APIs)
Your backend should provide endpoints for:
- hospitals CRUD
- units CRUD (optional)
- clinicians CRUD + credential reset
- device register/assign/disable
- sessions list + detail
- predictions list + detail
- exports (async job recommended if large)
- audit logs

---

## 5) Audit & integrity requirements
Minimum recommended:
- Every create/update action logs:
  - actor id (clinician/admin)
  - timestamp
  - entity type and id
  - changed fields (optional)

This is important for:
- “Maintaining integrity of specifications” section in your paper
- Hospital accountability

---

## 6) Recommended UI/UX behaviors
- Search and filters on all list pages
- Clear status badges (active/inactive)
- Confirm dialogs for destructive actions
- Export warnings: “Do not share identifiable data”

---

## 7) Future extensions (admin panel)
- Multi-hospital tenancy (super-admin)
- Training module for clinicians (guidelines, videos)
- A/B thresholds by hospital (careful; requires governance)

