# 🧪 Pilot Study Plan: Clinical-Based Autism Screening System

## 📋 **Pilot Study Overview**

### **Study Title**
*"Feasibility and Usability Testing of a Tablet-Based Cognitive Flexibility Assessment Tool for Early Autism Screening in Clinical Settings"*

### **Study Duration**
- **Development Phase**: 2-3 months
- **Pilot Testing**: 1 month
- **Data Analysis**: 2 weeks
- **Total**: 4-5 months

---

## 🎯 **Pilot Objectives**

### **Primary Objectives**
1. **Validate Clinical Feasibility**: Confirm the tablet app works smoothly in hospital environment
2. **Test Child Engagement**: Ensure 2-6 year olds can understand and complete tasks
3. **Verify Data Quality**: Confirm reaction time and behavioral data collection is accurate
4. **Assess Doctor Usability**: Test if clinicians find the system easy to use

### **Secondary Objectives**
1. **Preliminary ML Validation**: Test if collected data shows patterns between ASD and neurotypical children
2. **Cultural Adaptation**: Validate Sinhala/Tamil/English language support
3. **Technical Performance**: Ensure app runs reliably on tablets

---

## 👥 **Participant Groups**

| Group | Description | Sample Size | Age Range | Recruitment |
|-------|-------------|-------------|-----------|-------------|
| **ASD Group** | Children with confirmed ASD diagnosis (DSM-5/ADOS) | 8-10 | 2-6 years | Lady Ridgeway Hospital |
| **Control Group** | Neurotypical children (no developmental concerns) | 8-10 | 2-6 years | Hospital staff families |
| **Clinicians** | Doctors/therapists using the system | 3-5 | N/A | Lady Ridgeway Hospital |

**Total Participants**: 19-25

---

## 🧩 **Pilot Study Design**

### **Phase 1: System Development (Months 1-2)**
- Build React Native tablet app with 2 games:
  - **Go/No-Go Game** (ages 2-3)
  - **Rule Switching Game** (ages 4-6)
- Create basic web dashboard for doctors
- Implement data logging system
- Add multilingual support (Sinhala/Tamil/English)

### **Phase 2: Internal Testing (Month 2-3)**
- Test with 3-5 adult volunteers
- Test with 2-3 older children (7-8 years)
- Debug technical issues
- Validate data collection accuracy

### **Phase 3: Clinical Pilot (Month 3-4)**
- Deploy at Lady Ridgeway Hospital
- Collect data from 16-20 children
- Gather clinician feedback
- Monitor system performance

### **Phase 4: Analysis (Month 4-5)**
- Analyze collected data
- Test preliminary ML models
- Prepare pilot study report
- Plan full-scale study

---

## 📊 **Data Collection Plan**

### **Behavioral Data (Per Child)**
```json
{
  "child_id": "P001",
  "age": 4,
  "gender": "M",
  "diagnosis": "ASD",
  "session_date": "2024-03-15",
  "game_type": "rule_switching",
  "trials": [
    {
      "trial_number": 1,
      "stimulus": "red_circle",
      "rule": "color",
      "response": "red",
      "reaction_time": 1200,
      "correct": true,
      "timestamp": "2024-03-15T10:30:15Z"
    }
  ],
  "summary": {
    "total_trials": 20,
    "accuracy": 0.75,
    "mean_reaction_time": 1350,
    "switch_cost": 200,
    "errors": 5
  }
}
```

### **Clinician Feedback Data**
- Usability rating (1-5 scale)
- Child engagement level
- Technical issues encountered
- Suggestions for improvement
- Clinical relevance assessment

---

## 🔬 **Preliminary ML Analysis**

### **Features to Extract**
1. **Reaction Time Metrics**
   - Mean reaction time
   - Reaction time variability
   - Switch cost (RT after rule change - RT before)

2. **Accuracy Metrics**
   - Overall accuracy
   - Pre-switch accuracy
   - Post-switch accuracy
   - Recovery trials needed

3. **Error Analysis**
   - Perseverative errors
   - Inhibition errors
   - Error patterns

### **Baseline Models to Test**
- Logistic Regression
- Random Forest
- Support Vector Machine
- Simple Neural Network

### **Expected Outcomes**
- **Proof of concept**: Can we distinguish ASD vs Control groups?
- **Feature importance**: Which metrics are most predictive?
- **Model performance**: What accuracy can we achieve with small dataset?

---

## 📋 **Ethics and Consent**

### **Required Approvals**
1. **SLIIT Ethics Review Committee (ERC)**
2. **Lady Ridgeway Hospital ERC**
3. **Parental/Guardian Consent Forms**

### **Consent Form Components**
- Clear explanation of the study purpose
- Description of tasks (5-minute tablet games)
- Data collection methods (behavioral data only)
- Privacy and confidentiality measures
- Right to withdraw at any time
- Contact information for questions

### **Data Privacy Measures**
- Anonymous child IDs only
- No video/audio recording
- Encrypted data storage
- Access restricted to research team
- Data retention policy (2 years)

---

## 📈 **Success Criteria**

### **Technical Success**
- ✅ App runs without crashes on tablets
- ✅ Data logging accuracy >95%
- ✅ Session completion rate >80%
- ✅ Doctor usability rating >4/5

### **Clinical Success**
- ✅ Children complete tasks without distress
- ✅ Tasks are age-appropriate and engaging
- ✅ Doctors find system clinically useful
- ✅ Data shows preliminary patterns

### **Research Success**
- ✅ Sufficient data quality for ML analysis
- ✅ Preliminary model shows some predictive power
- ✅ Ready for full-scale study design

---

## 📊 **Pilot Study Timeline**

| Week | Activities | Deliverables |
|------|------------|--------------|
| 1-4 | App development | Functional prototype |
| 5-6 | Internal testing | Debugged app |
| 7-8 | Ethics approval | ERC approval letters |
| 9-12 | Clinical pilot | Pilot dataset |
| 13-14 | Data analysis | Pilot study report |
| 15-16 | Report writing | Publication draft |

---

## 💰 **Resource Requirements**

### **Technical Resources**
- 2-3 Android tablets (for testing)
- Development server/cloud storage
- Software licenses (if needed)

### **Human Resources**
- 1-2 developers (you + team member)
- 1-2 clinical supervisors
- 1 data analyst

### **Estimated Costs**
- Tablets: $300-500
- Cloud storage: $50-100/month
- Travel to hospital: $100-200
- **Total**: $500-1000

---

## 📝 **Expected Deliverables**

### **Technical Deliverables**
1. **Functional React Native App**
   - 2 working games
   - Data logging system
   - Multilingual support
   - Doctor dashboard

2. **Pilot Dataset**
   - 16-20 children's behavioral data
   - Clinician feedback data
   - Technical performance logs

3. **Preliminary ML Models**
   - Baseline classifiers
   - Feature importance analysis
   - Performance metrics

### **Research Deliverables**
1. **Pilot Study Report**
   - Methodology and results
   - Technical performance analysis
   - Clinical feasibility assessment
   - Recommendations for full study

2. **Conference Paper/Poster**
   - Present pilot findings
   - Demonstrate system capabilities
   - Build research network

---

## 🚀 **Next Steps**

### **Immediate Actions (Next 2 weeks)**
1. **Submit ERC Application** to SLIIT and Lady Ridgeway Hospital
2. **Finalize App Development** - complete the 2 games
3. **Prepare Consent Forms** and information sheets
4. **Set up Data Storage** system

### **Month 1-2**
1. **Complete App Development**
2. **Internal Testing** with volunteers
3. **Ethics Approval** process
4. **Hospital Coordination** setup

### **Month 3-4**
1. **Clinical Pilot** data collection
2. **Real-time Monitoring** and debugging
3. **Clinician Feedback** collection

### **Month 4-5**
1. **Data Analysis** and ML testing
2. **Report Writing**
3. **Full Study Planning**

---

## 🎯 **Success Metrics Summary**

| Metric | Target | Measurement |
|--------|--------|-------------|
| **App Stability** | >95% uptime | Technical logs |
| **Child Engagement** | >80% completion rate | Session data |
| **Doctor Usability** | >4/5 rating | Feedback forms |
| **Data Quality** | >95% accuracy | Validation checks |
| **ML Performance** | >60% accuracy | Model testing |

---

**This pilot study will provide the foundation for your full-scale research project and demonstrate the clinical viability of your innovative autism screening system! 🎉**









