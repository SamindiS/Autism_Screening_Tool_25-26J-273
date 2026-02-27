## Cognitive Flexibility ASD Screening Tool – Final Project Roadmap

This file lists everything left to do to turn the current pilot into a clinically usable, advanced cognitive flexibility (ASD) screening tool. Tasks are ordered so you can follow them step by step.

---

## Phase 1 – Clean up clinical model & flows

1. **Finalize child model as clinical-only**
   - Remove any remaining “pilot”, “control group”, “study group”, and “preschool” wording from all screens and messages.
   - Ensure `Child` only exposes terminology that makes sense clinically:
     - Prior diagnosis status (existing vs new) should be represented clearly in model/DB and used only for display/analytics, not to change flows.
   - Confirm child fields: ID/code, name, DOB, age in months, gender, language, hospital/clinic, clinician ID, diagnosis/referral context.

2. **Lock down single clinical child form**
   - Verify `AddChildScreen` is the *only* entry point to create/edit a child.
   - Make Clinician ID required for all children.
   - Decide and standardize how you encode:
     - “Diagnosis before” vs “New diagnosis” in the data model (e.g. a `diagnosis_type` field or enum).
   - Make sure child list, detail, and dashboards render this diagnosis type consistently.

3. **Clarify age-based screening flow**
   - For each age band (2–3.5, 3.5–5.5, 5.5–6.9), define:
     - Which games/questionnaires are used.
     - Minimum number of trials or questions for a valid session.
   - In `AgeSelectScreen` and session start screens:
     - Only show relevant options based on child age.
     - Block starting the “wrong” session type for that age (with a clear message).

---

## Phase 2 – Session and assessment robustness

4. **Session lifecycle**
   - Define clear statuses for sessions: `in_progress`, `completed`, `aborted`.
   - Ensure:
     - A session is created on start and marked `in_progress`.
     - End time, metrics, and risk data are saved on completion.
     - Aborted sessions are saved with a flag and not sent to ML.

5. **Metrics completeness**
   - For each game and questionnaire:
     - List the metrics used by ML (e.g. accuracy, perseverative errors, switch cost, RT variability, questionnaire totals).
     - Verify they are:
       - Computed correctly in Flutter.
       - Saved in local DB / backend as part of the session `metrics` and/or `game_results` / `questionnaire_results`.
   - Add basic validation:
     - If critical metrics are missing or look invalid (e.g. 0 trials), block ML prediction and show a friendly error.

6. **Clinician summary on result screen**
   - Ensure the result screen shows, for the latest session:
     - Age group and session type.
     - Key metrics (e.g. accuracy, error rates, switch cost).
     - Risk score and level from ML (or clearly marked fallback).
   - Add a small, editable clinician note text box that saves to the session for later report inclusion.

---

## Phase 3 – ML engine quality & integration

7. **Feature mapping audit**
   - In the ML engine (`predictor.py` and `preprocessing.py`), list all `feature_names` the models expect.
   - On the backend and Flutter side:
     - Map each required feature to the exact field/path in the app.
     - Confirm no key feature is permanently 0, `null`, or missing across typical sessions.

8. **Risk thresholds & calibration**
   - Revisit `RISK_THRESHOLDS` using your training notebooks:
     - Confirm what probability / risk score corresponds to clinically meaningful concern.
     - Decide:
       - Threshold for “screen positive” vs “screen negative”.
       - Whether you want just `low / moderate / high` or also “borderline”.
   - Document these decisions in a short markdown doc (e.g. `ML_RISK_POLICY.md`) for future reference.

9. **Safety and error paths**
   - Make sure ML engine:
     - Returns clear error JSON if features are invalid (not HTTP 500 only).
     - Handles ages outside 24–83 months with a controlled message.
   - Ensure backend:
     - Logs ML errors with enough detail for debugging.
     - Falls back to a *conservative* rule-based result with clear labeling (`method: 'fallback'`) when needed.

---

## Phase 4 – Clinical PDF report (professional version)

10. **Report content design**
    - Specify the final structure of the report:
      - Cover page: child identifier, clinic, clinician, date.
      - Child info page: age, gender, diagnosis type, language.
      - Per-session pages: session type, date, key metrics, risk result.
      - Summary page: average risk, session history, clinician notes.
    - Decide on:
      - Which metrics are shown as numbers.
      - Which are highlighted visually (simple bars, colored text).

11. **Implement improved PDF layout**
    - Update `pdf_report_service.dart`:
      - Add a small metric table for each session (e.g. accuracy, perseverative errors, switch cost).
      - Color-code risk level text using consistent colors (green/orange/red).
      - Insert clinician’s note from the session (if available).
      - Include diagnosis type (diagnosis before vs new) and diagnosis/referral context.

12. **Explainability in reports**
    - Take top contributing features from ML explanations (if available) and:
      - Map them to simple clinical sentences, e.g.:
        - “High error rate after rule change suggests difficulty with cognitive flexibility.”
      - Show them in a short bullet list under “Factors influencing this screening result”.

---

## Phase 5 – Clinician experience & safety

13. **Clinician access control**
    - Ensure:
      - Only authenticated clinicians can add children, start sessions, and view/export reports.
      - Logout/login flows are clear and tested.
    - Display clinician name and hospital prominently in:
      - Dashboard header.
      - PDF reports.

14. **Audit trail and history**
    - For each child, store and display:
      - List of sessions (date, type, risk level).
      - List of reports generated (with timestamps and clinician).
    - Provide a simple “History” view on child detail screen with quick links to:
      - Session detail.
      - Report PDF.

15. **Clinical disclaimers**
    - Add a short, consistent disclaimer:
      - On result screen.
      - On the PDF report.
    - Example content:
      - “This tool provides a screening assessment of cognitive flexibility related to ASD. It is not a standalone diagnostic tool and must be interpreted by a qualified clinician.”

---

## Phase 6 – Stability, testing, and deployment

16. **Automated and manual testing**
    - Flutter:
      - Widget tests for child add form, result screen, and navigation flows.
    - Backend:
      - API tests for children/sessions and ML health/predict endpoints.
    - ML:
      - Unit tests with synthetic cases that should clearly produce low vs high risk.

17. **Performance checks**
    - Confirm:
      - ML engine loads models on startup without noticeable delay in the app.
      - Large local databases (many children/sessions) don’t slow down list screens.
      - Report generation time is acceptable on target devices.

18. **Packaging & deployment documentation**
    - Decide on initial deployment target(s):
      - Android APK for tablets/phones in clinics.
      - Optional web dashboard for clinicians.
    - Write a short `DEPLOYMENT.md`:
      - How to start backend and ML engine.
      - How to run the Flutter app in release mode.
      - Any environment variables or configs required (e.g. API URLs, ML engine URL).

---

## Phase 7 – Future enhancements (optional)

19. **Parent-facing summary (optional)**
    - A simplified, non-technical summary view or printable that explains:
      - What tasks the child did.
      - High-level outcome (without probabilities).
      - General recommendations for follow-up.

20. **Longitudinal tracking (optional)**
    - Charts over time for:
      - Accuracy.
      - Perseverative errors.
      - Risk score.
    - Helpful for monitoring progress across multiple visits.

