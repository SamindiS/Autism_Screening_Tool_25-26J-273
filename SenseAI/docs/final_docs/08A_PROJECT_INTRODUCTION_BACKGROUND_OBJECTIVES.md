# Project Introduction, Background, and Objectives

**Project ID:** 25-26J-273  
**Project Title:** Designing a Culturally Adapted, Multi-Language, Tablet-Based Intelligent System for Early Detection of Autism Spectrum Disorder Risk in Children Aged 2-6.9 Years Using Age-Stratified Cognitive Assessments and Hybrid Clinical Machine Learning

---

## 1. Introduction

### 1.1. Background:

Autism Spectrum Disorder (ASD) is a neurodevelopmental condition characterized by persistent differences in social communication and interaction, along with restricted, repetitive patterns of behavior, interests, or activities. Early identification and intervention are critical, as research consistently demonstrates that children who receive early intervention services show significantly improved developmental outcomes, including better language skills, social functioning, and adaptive behaviors. However, the global healthcare landscape faces significant challenges in providing timely and accessible ASD screening, particularly in resource-limited settings.

In many regions, including Sri Lanka, healthcare systems struggle with:
- **Limited access to trained specialists**: Long waiting times (often 6-12 months) for developmental assessments
- **Geographic barriers**: Rural and remote clinics lack access to specialized screening tools
- **Language and cultural barriers**: Most validated screening tools are available only in English and may not be culturally appropriate
- **Subjective assessment methods**: Traditional screening relies heavily on clinician observation, which can be inconsistent and time-consuming
- **Age-inappropriate tools**: Existing screening instruments are not always designed for the critical early window (ages 2-6 years) when intervention is most effective

The rapid advancement of digital health technologies, mobile computing, and machine learning presents unprecedented opportunities to address these challenges. Tablet-based assessment systems can provide:
- **Objective, quantifiable metrics**: Game-based tasks capture precise behavioral and cognitive data (reaction times, accuracy, error patterns)
- **Standardized administration**: Reduces inter-clinician variability
- **Offline functionality**: Enables deployment in clinics without reliable internet connectivity
- **Multilingual support**: Can be adapted to local languages and cultural contexts
- **Scalable screening**: Can reach more children with fewer specialist hours

Educational and clinical research has demonstrated that executive function tasks—specifically inhibitory control (Go/No-Go tasks) and cognitive flexibility (Dimensional Change Card Sort, DCCS)—are sensitive markers of neurodevelopmental differences in children with ASD. These tasks can be adapted into engaging, age-appropriate games that children can complete on tablets, providing objective behavioral data that complements traditional screening approaches.

This study focuses on developing a comprehensive, culturally adapted, tablet-based ASD screening support system for children aged 2-6.9 years in Sri Lankan healthcare settings. The proposed system integrates:
- **Age-stratified assessments**: Different cognitive tasks appropriate for each developmental stage
- **Hybrid machine learning + clinical rules**: Combines predictive ML models with clinically interpretable risk stratification
- **Multi-language support**: English, Sinhala (සිංහල), and Tamil (தமிழ்)
- **Offline-first architecture**: Functions without internet connectivity
- **Production-ready deployment**: Flutter mobile app, Node.js backend, FastAPI ML engine, React admin portal

The system is designed as a **screening support tool** (not a diagnostic replacement), providing risk levels (Low/Moderate/High) to guide clinician decision-making and enable timely referral for comprehensive evaluation.

---

### 1.2. Research Problem:

Despite the availability of validated screening tools such as M-CHAT-R/F (Modified Checklist for Autism in Toddlers, Revised with Follow-Up), ADOS-2 (Autism Diagnostic Observation Schedule), and CARS-2 (Childhood Autism Rating Scale), most healthcare systems in resource-limited settings face critical barriers to early ASD detection:

**Problem 1: Limited Scalability of Traditional Screening**
- Manual screening of hundreds of children is impractical for overburdened healthcare systems
- Specialist-administered tools (e.g., ADOS-2) require extensive training and are time-intensive
- Self-report questionnaires (e.g., M-CHAT-R/F) rely on caregiver interpretation and may miss subtle behavioral patterns

**Problem 2: Lack of Age-Appropriate Objective Assessments**
- Most screening tools for ages 2-6 years rely primarily on questionnaires or observation
- Objective cognitive/executive function tasks are rarely integrated into early screening workflows
- Existing tablet-based tools are often single-age-group or lack ML-enhanced risk stratification

**Problem 3: Language and Cultural Barriers**
- Most validated tools are English-only, limiting accessibility in multilingual populations
- Cultural adaptations are often superficial (translation only) rather than deep (content adaptation)
- Local healthcare providers may lack familiarity with English-language screening protocols

**Problem 4: Internet Dependency**
- Many digital health tools require constant internet connectivity
- Rural clinics often have unreliable or no internet access
- Cloud-based systems create data privacy and security concerns in some settings

**Problem 5: Black-Box Machine Learning Models**
- Many ML-based screening tools provide predictions without clinical interpretation
- Clinicians cannot understand why a child received a certain risk level
- Pure ML probability thresholds lack clinical validity and may not align with established screening principles

**Problem 6: Mobile Device Addiction Concerns**
- Smartphone-based screening may contribute to screen time concerns
- Tablet-based systems (dedicated clinic devices) reduce personal device dependency
- Controlled clinic environment ensures appropriate use

**Failure to address these problems leads to:**
- **Delayed identification**: Children miss critical early intervention windows (ages 2-4 years)
- **Increased healthcare costs**: Late diagnosis requires more intensive, longer-term interventions
- **Reduced intervention effectiveness**: Outcomes are significantly better when intervention begins early
- **Inequitable access**: Rural and low-resource settings are disproportionately affected
- **Clinician burnout**: Overwhelmed specialists cannot meet screening demand

**Therefore, the core research problem is:**

**The absence of a scalable, culturally adapted, offline-capable, age-stratified, tablet-based ASD screening support system that combines objective cognitive assessments with interpretable hybrid machine learning for early risk detection in children aged 2-6.9 years, suitable for deployment in resource-limited healthcare settings.**

---

### 1.3. Objectives:

| Objective Number | Objective Description | How It Addresses the Research Problem |
|-----------------|----------------------|--------------------------------------|
| **1** | Design and implement age-stratified cognitive assessments (questionnaire for 2-3.5 years, Go/No-Go game for 3.5-5.5 years, DCCS game for 5.5-6.9 years) | Addresses Problem 2: Provides age-appropriate objective tasks for each developmental stage |
| **2** | Develop culturally adapted, multilingual (English/Sinhala/Tamil) assessment interfaces and content | Addresses Problem 3: Removes language barriers and ensures cultural relevance |
| **3** | Build hybrid machine learning models (ML + clinical rules) for interpretable risk stratification (Low/Moderate/High) | Addresses Problem 5: Provides clinically interpretable outputs that clinicians can trust |
| **4** | Implement offline-first architecture enabling deployment in clinics without reliable internet | Addresses Problem 4: Ensures functionality in low-resource settings |
| **5** | Create tablet-based system (not smartphone) to prevent mobile addiction and ensure controlled clinic use | Addresses Problem 6: Reduces screen time concerns and ensures appropriate device usage |
| **6** | Validate system performance using clinically defensible evaluation metrics (sensitivity, specificity, ROC-AUC) | Ensures system meets screening tool standards and provides reliable risk estimates |
| **7** | Develop production-ready deployment architecture (Flutter app + Node.js backend + FastAPI ML engine + React admin portal) | Ensures system is scalable and maintainable for real-world healthcare deployment |

---

### 1.4. Research Questions:

1. **RQ1**: Can age-stratified cognitive assessments (questionnaire, Go/No-Go, DCCS) effectively capture behavioral patterns associated with ASD risk in children aged 2-6.9 years?

2. **RQ2**: Does a hybrid approach (ML probability + clinical rules) provide more reliable and interpretable risk stratification than pure ML-only or rules-only approaches?

3. **RQ3**: Can a tablet-based, offline-first system be successfully deployed in resource-limited healthcare settings without compromising screening accuracy?

4. **RQ4**: Does cultural adaptation and multilingual support improve accessibility and acceptance among local healthcare providers and families?

5. **RQ5**: How do age-normalized features and composite behavioral indices compare to raw features in predictive performance for ASD risk detection?

---

### 1.5. Scope and Limitations:

**Scope:**
- **Age Range**: Children aged 24-83 months (2-6.9 years)
- **Geographic Focus**: Sri Lankan healthcare settings (with potential applicability to similar contexts)
- **Assessment Types**: Three age-stratified assessments (questionnaire, Go/No-Go, DCCS)
- **Risk Levels**: Low, Moderate, High (screening support, not diagnostic)
- **Languages**: English, Sinhala, Tamil

**Limitations:**
- **Not a diagnostic tool**: System provides screening risk levels, not ASD diagnosis
- **Requires clinician interpretation**: Risk levels guide but do not replace clinical judgment
- **Sample size constraints**: Clinical datasets are typically small; results may need validation with larger samples
- **Cultural context**: Adaptations are specific to Sri Lankan context; may need re-adaptation for other regions
- **Device dependency**: Requires tablet device (may not be available in all settings)

---

### 1.6. Significance and Contribution:

**Clinical Significance:**
- Enables early identification of children at risk for ASD, facilitating timely referral for comprehensive evaluation
- Reduces burden on specialists by providing automated risk stratification
- Standardizes screening practices across different healthcare settings
- Provides objective metrics that complement clinical observation

**Technical Significance:**
- Demonstrates feasibility of hybrid ML + clinical rules approach for healthcare AI
- Validates age-stratified model architecture for developmental screening
- Establishes offline-first deployment pattern for low-resource settings
- Shows how cultural adaptation can be integrated into digital health tools

**Social Significance:**
- Improves access to screening in rural and remote areas
- Reduces language barriers through multilingual support
- Addresses healthcare inequity by providing scalable screening solution
- Supports early intervention, improving long-term outcomes for children with ASD

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Project:** 25-26J-273 - SenseAI ASD Screening System
