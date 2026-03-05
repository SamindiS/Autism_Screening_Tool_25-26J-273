# 🚀 Pilot to Production: Complete Transition Checklist

**Status:** 70% Research Complete → Production Ready  
**Goal:** Transform research/pilot version into a production-ready screening tool

---

## 📋 **1. REMOVE RESEARCH-SPECIFIC FEATURES**

### 1.1 Remove Study Group Selection
- [ ] **Remove from `add_child_screen.dart`**:
  - Remove study group selector (ASD vs Control Group)
  - Remove ASD level selection (Level 1/2/3)
  - Remove clinician ID input (only needed for ASD group in research)
  - Simplify child code generation (no LRH-### vs PRE-### distinction)
  
- [ ] **Update `child.dart` model**:
  - Remove `ChildGroup` enum (asd, typicallyDeveloping)
  - Remove `AsdLevel` enum
  - Remove `clinicianId` and `clinicianName` fields
  - Remove `isAsdGroup` and `isControlGroup` getters
  - Keep only essential fields: name, DOB, age, gender, language

- [ ] **Update database schema** (`storage_service.dart`):
  - Remove `study_group` column (or make it optional/hidden)
  - Remove `asd_level` column
  - Remove `clinician_id` and `clinician_name` columns
  - Create migration script for existing data

### 1.2 Remove Control Group Logic
- [ ] **Update `reflection_screen.dart`**:
  - Remove: `if (widget.child.isControlGroup) { return 'low' }`
  - All children should go through normal ML prediction
  
- [ ] **Update `reflection_screen_2_3.dart`**:
  - Remove control group special handling
  - Apply ML prediction to all children

- [ ] **Update `result_screen.dart`**:
  - Remove study group badge display
  - Remove control group specific messages
  - Remove "Control Group - Typically Developing" text
  - Show same risk assessment for all children

### 1.3 Update Dashboard & Lists
- [ ] **Update `dashboard_screen.dart`**:
  - Remove "ASD Group" and "Control Group" stat cards
  - Replace with general statistics (Total Children, Completed Assessments, etc.)
  
- [ ] **Update `child_list_screen.dart`**:
  - Remove study group filter (ASD/Control toggle)
  - Remove group badges from child cards
  
- [ ] **Update `cognitive_dashboard_screen.dart`**:
  - Remove study group grouping
  - Show all children in unified list

### 1.4 Update PDF Reports
- [ ] **Update `pdf_report_service.dart`**:
  - Remove "Study Group" from report
  - Remove ASD level display
  - Remove clinician ID/name
  - Keep only: Child info, assessment results, risk level, recommendations

---

## 🤖 **2. UPDATE ML MODEL & PREDICTIONS**

### 2.1 ML Engine Changes
- [ ] **Update ML model training**:
  - Train model on **general population** (not ASD vs Control distinction)
  - Model should predict: **ASD Risk** (Low/Moderate/High) for any child
  - Remove binary classification (ASD=1, Control=0)
  - Use **risk-based scoring** instead

- [ ] **Update `ml_engine/app/ml/predictor.py`**:
  - Remove control group special handling
  - All predictions should use same ML model
  - Risk levels: Low (<30%), Moderate (30-70%), High (>70%)

- [ ] **Update backend routes** (`ml_predictions_fastapi.js`):
  - Remove "ASD Risk" vs "Control" distinction
  - Return: `{ risk_level: 'low'|'moderate'|'high', probability: 0.45 }`

### 2.2 Age Normalization
- [ ] **Update age norms**:
  - Use **general population norms** (not control group norms)
  - If you have population data, use that
  - Otherwise, use age-matched typical development norms from literature

---

## 🎨 **3. UI/UX IMPROVEMENTS**

### 3.1 Simplify Child Registration
- [ ] **New child flow**:
  - Name, DOB, Gender, Language only
  - Auto-generate sequential ID (CHILD-001, CHILD-002, etc.)
  - No study group selection
  - No diagnosis source selection
  - No hospital/clinician assignment (unless needed for production)

### 3.2 Update Language & Labels
- [ ] **Remove research terminology**:
  - Remove "Pilot Mode" references
  - Remove "Study Group" labels
  - Remove "Control Group" mentions
  - Update to: "Child Profile", "Screening Assessment", "Risk Assessment"

- [ ] **Update localization files**:
  - `app_en.arb`, `app_si.arb`, `app_ta.arb`
  - Remove `pilotMode` key
  - Update all study group related strings

### 3.3 Professional Branding
- [ ] **Update app name**:
  - Change from "my_autism_app" to production name
  - Update package name: `com.example.my_autism_app` → `com.yourorg.senseai` (or similar)
  - Update app icon and splash screen

---

## 🔒 **4. DATA PRIVACY & SECURITY**

### 4.1 GDPR/Privacy Compliance
- [ ] **Add privacy policy**:
  - Create privacy policy screen
  - Explain data collection, storage, usage
  - Add consent checkbox during registration

- [ ] **Data encryption**:
  - Encrypt sensitive data in SQLite
  - Encrypt data in transit (HTTPS)
  - Secure Firebase rules

- [ ] **Data retention**:
  - Add data deletion policy
  - Allow users to delete their data
  - Add "Delete Account" functionality

### 4.2 User Authentication
- [ ] **Production auth system**:
  - Remove test accounts
  - Implement proper clinician registration
  - Add email verification
  - Add password reset
  - Add role-based access (Admin, Clinician, etc.)

---

## 📊 **5. REPORTING & ANALYTICS**

### 5.1 Clinical Reports
- [ ] **Professional PDF reports**:
  - Remove research-specific fields
  - Add professional header (clinic name, date, clinician)
  - Include: Child info, assessment scores, risk level, recommendations
  - Add disclaimer: "Screening tool, not diagnostic"

- [ ] **Export functionality**:
  - Export to CSV for clinic records
  - Export to PDF for sharing with parents
  - Add print functionality

### 5.2 Analytics Dashboard
- [ ] **Admin dashboard** (if needed):
  - Total screenings
  - Risk level distribution
  - Age group statistics
  - Completion rates
  - No study group analytics

---

## 🧪 **6. TESTING & VALIDATION**

### 6.1 Remove Test Data
- [ ] **Clean test data**:
  - Remove pilot study test children
  - Remove test accounts
  - Archive research data separately

### 6.2 Production Testing
- [ ] **End-to-end testing**:
  - Test child registration (no study group)
  - Test assessment flow
  - Test ML prediction
  - Test PDF generation
  - Test data sync

- [ ] **Performance testing**:
  - Test with 100+ children
  - Test offline functionality
  - Test sync performance

---

## 📱 **7. DEPLOYMENT PREPARATION**

### 7.1 App Store Preparation
- [ ] **Android**:
  - Update app name, description
  - Update screenshots (remove research UI)
  - Set up Google Play Console
  - Generate signed APK/AAB

- [ ] **iOS** (if applicable):
  - Update App Store listing
  - Generate signed IPA
  - Submit for review

### 7.2 Backend Deployment
- [ ] **Production environment**:
  - Set up production Firebase project
  - Deploy FastAPI ML engine to cloud (AWS/GCP/Azure)
  - Set up production database
  - Configure production API endpoints

- [ ] **Monitoring**:
  - Set up error tracking (Sentry, Firebase Crashlytics)
  - Set up analytics (Firebase Analytics)
  - Set up logging

---

## 📚 **8. DOCUMENTATION**

### 8.1 User Documentation
- [ ] **User manual**:
  - How to register children
  - How to run assessments
  - How to interpret results
  - How to generate reports

- [ ] **Clinician guide**:
  - Best practices
  - Interpretation guidelines
  - When to refer for diagnosis

### 8.2 Technical Documentation
- [ ] **Update README**:
  - Remove research/pilot references
  - Add production setup guide
  - Add deployment instructions

- [ ] **API documentation**:
  - Document ML prediction API
  - Document data sync API
  - Add authentication docs

---

## 🔄 **9. DATA MIGRATION**

### 9.1 Existing Data
- [ ] **Migration script**:
  - Convert existing children (remove study_group)
  - Archive research data separately
  - Update child codes if needed

- [ ] **Backup**:
  - Backup all pilot study data
  - Export to CSV/JSON for research records
  - Store separately from production data

---

## ✅ **10. FINAL CHECKLIST**

### Before Launch
- [ ] All research-specific UI removed
- [ ] ML model updated for general population
- [ ] All children get risk assessment (no control group bypass)
- [ ] Privacy policy added
- [ ] Test data cleaned
- [ ] Production environment configured
- [ ] Documentation updated
- [ ] App tested end-to-end
- [ ] App store listings ready
- [ ] Legal/compliance reviewed

---

## 🎯 **PRIORITY ORDER**

### **Phase 1: Core Changes (Week 1)**
1. Remove study group selection from UI
2. Remove control group logic from assessment
3. Update ML model to work without study groups
4. Update child model and database

### **Phase 2: UI Cleanup (Week 2)**
5. Remove research terminology
6. Update dashboard and lists
7. Update PDF reports
8. Update localization

### **Phase 3: Production Ready (Week 3-4)**
9. Add privacy policy
10. Set up production environment
11. Testing and validation
12. Documentation
13. Deployment

---

## 📝 **NOTES**

- **Keep research data separate**: Don't delete pilot data, archive it
- **ML model retraining**: May need to retrain model on general population data
- **Backward compatibility**: Consider if you need to support old data format
- **Gradual rollout**: Consider beta testing with select clinics first

---

**Last Updated:** 2025-01-XX  
**Status:** In Progress

