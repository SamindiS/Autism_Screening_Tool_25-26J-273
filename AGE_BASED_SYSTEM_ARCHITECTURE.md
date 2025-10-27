# 🏗️ Age-Based Autism Screening System Architecture

## Date: October 26, 2025

---

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Age-Based Assessment Flow](#age-based-assessment-flow)
3. [Component Architecture](#component-architecture)
4. [Game Configurations](#game-configurations)
5. [Navigation Flow](#navigation-flow)
6. [Data Flow](#data-flow)
7. [Clinical Rationale](#clinical-rationale)
8. [Implementation Details](#implementation-details)
9. [Testing Guidelines](#testing-guidelines)

---

## 🎯 System Overview

### **Hybrid Assessment Platform**
This system combines **AI-guided behavioral interviews** with **gamified cognitive assessments** to evaluate autism risk in children aged 2-6 years.

### **Key Innovation**
- **Ages 2-3**: Parent-guided AI questionnaire (no screen time for toddlers)
- **Ages 3-5**: Simple Go/No-Go game (response inhibition)
- **Ages 5-6**: Rule Switch game (cognitive flexibility - DCCS style)

### **Clinical Foundation**
Based on established developmental psychology protocols:
- Go/No-Go tasks (Wiebe et al., 2011)
- DCCS paradigm (Zelazo et al., 2013)
- Parental observation questionnaires (Baron-Cohen et al., 2000)

---

## 👶 Age-Based Assessment Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    Login → Main Dashboard                    │
│                  (Doctor/Clinician Interface)                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              Cognitive Flexibility Dashboard                 │
│              (Select/Register Child)                         │
└─────────────────────────────────────────────────────────────┘
                              │
                 ┌────────────┴────────────┐
                 │                         │
                 ▼                         ▼
        Check Child's Age          Age-Based Routing
                 │                         │
                 └────────────┬────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            │                 │                 │
            ▼                 ▼                 ▼
    ┌──────────────┐   ┌──────────────┐  ┌──────────────┐
    │  Age 2 - <3  │   │  Age 3 - <5  │  │  Age 5 - 6   │
    │              │   │              │  │              │
    │  🤖 AI Bot   │   │  🐸 Frog     │  │  🔷 Rule     │
    │  Questionnaire│   │  Jump Game  │  │  Switch Game │
    │              │   │              │  │              │
    │  Parent      │   │  Go/No-Go    │  │  DCCS Task   │
    │  Interview   │   │  Task        │  │              │
    └──────────────┘   └──────────────┘  └──────────────┘
            │                 │                 │
            └─────────────────┼─────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Results Screen  │
                    │                  │
                    │  - Risk Score    │
                    │  - Metrics       │
                    │  - Recommendations│
                    └──────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Main Dashboard  │
                    │  (Session Saved) │
                    └──────────────────┘
```

---

## 🧩 Component Architecture

### **1. Frontend Components (React Native)**

#### **A. Screens**
```
src/screens/
├── SplashScreen.tsx              # App startup
├── LoginScreen.tsx               # Clinician authentication
├── MainDashboardScreen.tsx       # Overview + Quick Actions
├── CognitiveDashboardScreen.tsx  # Child management + Assessment start
├── ChildRegistrationScreen.tsx   # Register new child
├── AIDoctorBotScreen.tsx         # AI questionnaire (Ages 2-3) ⭐ NEW
└── AgeSelectionScreen.tsx        # Game parameter configuration
```

#### **B. Components**
```
src/components/
├── GameWebView.tsx               # WebView wrapper for HTML5 games
├── AuthFlow.tsx                  # Authentication wrapper
└── [Other shared components]
```

#### **C. Services**
```
src/services/
├── storage.ts                    # AsyncStorage wrapper
├── authService.ts                # Authentication logic
└── dataService.ts                # Data management
```

---

### **2. Game Assets (HTML5)**

```
android/app/src/main/assets/games/
├── index.html          # Frog Jump Game (Ages 3-5) ⭐ ENHANCED
├── rule-switch.html    # Rule Switch Game (Ages 5-6) ⭐ NEW
└── sounds/
    └── frog-game.mp3   # Background music ⭐ NEW
```

#### **Enhanced Features**
✅ Age-based trial configuration (6-10 trials)  
✅ Practice trials with encouragement  
✅ Voice instructions (Web Speech API)  
✅ MP3 background music  
✅ Real-time performance tracking  

---

## 🎮 Game Configurations

### **Assessment Matrix**

| Age Range | Assessment Type | Name | Measures | Duration | Trials | Output Metrics |
|-----------|----------------|------|----------|----------|--------|----------------|
| **2 - <3** | Questionnaire | AI Doctor Bot | Social responsiveness, cognitive flexibility, joint attention, sensory processing | 5-7 min | 10 questions | Behavioral scores, category averages, risk score |
| **3 - <5** | Game | Frog Jump | Response inhibition, impulse control | 2-4 min | 6-10 trials | Accuracy, reaction time, error rate |
| **5 - 6** | Game | Rule Switch | Cognitive flexibility, task switching | 4-6 min | 20 trials | Switch cost, post-switch errors, accuracy |

---

### **Detailed Configuration**

#### **1. AI Doctor Bot (Ages 2-3)**

**Type**: React Native Component with AI-style interface  
**Method**: Parent-guided structured interview  

**Question Categories**:
1. Social Responsiveness (name response, eye contact)
2. Cognitive Flexibility (routine changes, toy switching)
3. Joint Attention (pointing, shared interest)
4. Social Communication (imitation, expression)
5. Sensory Processing (reactions to stimuli)

**Scoring**:
- Likert scale: 1-5 per question
- Total score: 0-50
- Risk calculation: Inverted percentage (low score = high risk)
- Category breakdowns for targeted interventions

**Output Example**:
```javascript
{
  totalScore: 35,
  percentageScore: 70,
  riskScore: 30,  // Low risk
  categoryScores: {
    "Social Responsiveness": 75,
    "Cognitive Flexibility": 60,
    "Joint Attention": 80
  },
  recommendations: [
    "Continue regular monitoring",
    "Focus on cognitive flexibility skills"
  ]
}
```

---

#### **2. Frog Jump Game (Ages 3-5)**

**Type**: HTML5 Go/No-Go Task  
**File**: `games/index.html`

**Age Configurations**:
```javascript
Age 3:
  - Trials: 6
  - Practice: 3
  - Display time: 3.5s (slower)

Age 4:
  - Trials: 8
  - Practice: 2
  - Display time: 2.5s

Age 5:
  - Trials: 10
  - Practice: 2
  - Display time: 2.0s (faster)
```

**Stimulus**: 70% "Go" (Frog 🐸), 30% "No-Go" (Turtle 🐢)

**Features**:
- ✅ **Practice Mode**: Explicit feedback + encouragement
- ✅ **Voice Instructions**: "Tap the happy animal!"
- ✅ **Background Music**: MP3 audio (30% volume)
- ✅ **Visual Feedback**: Confetti for correct, gentle guidance for wrong

**Metrics Captured**:
```javascript
{
  trials: [
    {
      trialNumber: 1,
      stimulus: 'happy',
      response: 'tap',
      reactionTime: 1250,
      correct: true,
      timestamp: "2025-10-26T..."
    },
    // ...
  ],
  accuracy: 85.0,
  avgReactionTime: 1420,
  errorRate: 15.0
}
```

---

#### **3. Rule Switch Game (Ages 5-6)**

**Type**: HTML5 DCCS-style Task  
**File**: `games/rule-switch.html`

**Game Structure**:
- **Phase 1 (Trials 1-10)**: Sort by COLOR
- **Phase 2 (Trials 11-20)**: Sort by SHAPE (rule switch at trial 11)

**Cards**: Blue Star ⭐, Blue Heart ♥️, Red Star ⭐, Red Heart ♥️

**Cognitive Load**:
1. **Pre-Switch**: Establish color sorting rule
2. **Switch Announcement**: "New rule: Match by SHAPE!"
3. **Post-Switch**: Measure adaptation speed

**Key Metrics**:
- **Switch Cost**: RT difference between pre-switch and post-switch trials
- **Post-Switch Errors**: Perseveration (using old rule)
- **Overall Accuracy**: Percentage correct across all trials

**Output Example**:
```javascript
{
  trials: 20,
  correctTrials: 17,
  accuracy: 85,
  avgReactionTime: 1820,
  switchCost: 450,  // 450ms slower after switch
  postSwitchErrors: 2
}
```

**Clinical Interpretation**:
- **High switch cost** (>500ms): Difficulty with cognitive flexibility
- **Post-switch errors**: Perseveration tendency
- **Low accuracy (<70%)**: Executive function concerns

---

## 🗺️ Navigation Flow

### **Screen State Management**

**App.tsx State**:
```typescript
const [currentScreen, setCurrentScreen] = useState<string>('splash');
const [previousScreen, setPreviousScreen] = useState<string | null>(null);
const [currentChild, setCurrentChild] = useState<Child | null>(null);
const [currentGameType, setCurrentGameType] = useState<GameType | null>(null);
const [currentGameResults, setCurrentGameResults] = useState<any>(null);
```

### **Navigation Transitions**

```
splash → login
login → mainDashboard
mainDashboard → cognitiveDashboard
cognitiveDashboard → {
  - childRegistration (add new child)
  - aiBot (age 2-<3)
  - ageSelection (age 3-6, then → game)
}
aiBot → results
game → results
results → mainDashboard
```

### **Age-Based Routing Logic**

**In `CognitiveDashboardScreen.tsx`**:
```typescript
const getRecommendedGame = (age: number) => {
  if (age >= 2 && age < 3) {
    return {
      type: 'questionnaire',
      name: 'AI Doctor Bot',
      route: 'AIDoctorBot',
    };
  } else if (age >= 3 && age < 5) {
    return {
      type: 'game',
      name: 'Frog Jump Game',
      gameType: 'frog_jump',
      route: 'FrogJumpGame',
    };
  } else if (age >= 5 && age <= 6) {
    return {
      type: 'game',
      name: 'Rule Switch Game',
      gameType: 'rule_switch',
      route: 'RuleSwitchGame',
    };
  }
  return { type: 'none', route: null };
};
```

**In `App.tsx`**:
```typescript
// Handle AI Bot navigation
if (screen === 'AIDoctorBot') {
  setCurrentChild(params.child);
  setPreviousScreen('cognitiveDashboard');
  setCurrentScreen('aiBot');
}

// Handle Game navigation
if (screen === 'AgeSelection') {
  setCurrentChild(params.childData);
  setCurrentGameType(params.gameType);  // 'frog_jump' or 'rule_switch'
  setCurrentScreen('ageSelection');
}
```

---

## 📊 Data Flow

### **1. Child Data → Assessment Configuration**

```
Child Age → getRecommendedGame() → Assessment Type
    │                 │                      │
    ▼                 ▼                      ▼
   3.5 yrs    Frog Jump (6-8 trials)    gameType='frog_jump'
```

### **2. WebView Communication**

**React Native → WebView** (Send child data):
```typescript
// In GameWebView.tsx
webViewRef.current?.postMessage(JSON.stringify({
  type: 'childData',
  child: { age: 4, name: 'Emma', id: '123' }
}));
```

**WebView → React Native** (Send results):
```javascript
// In game HTML
window.ReactNativeWebView.postMessage(JSON.stringify({
  type: 'game_complete',
  results: { accuracy: 85, avgReactionTime: 1420, ... }
}));
```

### **3. Results Processing**

```
Game Results → handleGameComplete() → Transform to PilotSession
                      │
                      ▼
             Store in AsyncStorage
                      │
                      ▼
             Display Results Screen
                      │
                      ▼
          Return to Main Dashboard
```

**Result Transformation**:
```typescript
const transformedResults = {
  id: Date.now().toString(),
  childId: child.id,
  gameType: 'frog_jump',
  summary: {
    accuracy: results.accuracy,
    averageReactionTime: results.avgReactionTime,
    riskScore: calculateRisk(results.accuracy),
    recommendations: generateRecommendations(results)
  },
  trials: results.trials
};
```

---

## 🧠 Clinical Rationale

### **Why Age-Based Differentiation?**

#### **Ages 2-3: Questionnaire Only**
**Reason**: 
- ❌ Limited sustained attention (<2 min)
- ❌ Poor comprehension of digital task rules
- ❌ Fine motor skills still developing
- ✅ Parents are reliable observers at this age

**Evidence**: Parental report shows 85% concordance with clinical observation in toddlers (Gray & Tonge, 2005).

---

#### **Ages 3-5: Simple Go/No-Go**
**Reason**:
- ✅ Can follow single-rule tasks ("tap frog, not turtle")
- ✅ Understand immediate feedback
- ✅ Response inhibition is measurable from age 3+
- ❌ Cannot reliably handle rule switching yet

**Evidence**: Go/No-Go tasks show developmental sensitivity from age 3 (Wiebe et al., 2011).

---

#### **Ages 5-6: Rule Switch (DCCS)**
**Reason**:
- ✅ Cognitive flexibility emerges around age 4-5
- ✅ Can understand "now the rule changed"
- ✅ Pre-switch vs post-switch comparison is valid
- ✅ Sustained attention for 20 trials (~5 min)

**Evidence**: DCCS is validated for ages 4-6 (Zelazo et al., 2013), shows autism discrimination (Ozonoff et al., 2004).

---

### **Metrics Aligned with Executive Function Research**

| Metric | Clinical Relevance | Autism Correlation |
|--------|-------------------|-------------------|
| **Response Inhibition** (Frog Jump) | Frontal lobe function | Impaired in ASD (Christ et al., 2007) |
| **Switch Cost** (Rule Switch) | Cognitive flexibility | Higher in ASD (Ozonoff & Jensen, 1999) |
| **Post-Switch Errors** | Perseveration | Increased in ASD (Hill, 2004) |
| **Joint Attention** (Questionnaire) | Social cognition | Core deficit in ASD (Mundy et al., 1986) |

---

## 🛠️ Implementation Details

### **File Structure**
```
AutismApp_update/
├── App.tsx                                    ⭐ UPDATED (navigation)
├── src/
│   ├── screens/
│   │   ├── MainDashboardScreen.tsx           ⭐ UPDATED
│   │   ├── CognitiveDashboardScreen.tsx      ⭐ UPDATED (age routing)
│   │   └── AIDoctorBotScreen.tsx             ⭐ NEW
│   ├── components/
│   │   └── GameWebView.tsx                   ⭐ UPDATED (child data, rule_switch)
│   └── constants/
│       └── index.ts                          (colors, age groups)
└── android/app/src/main/assets/
    ├── games/
    │   ├── index.html                        ⭐ ENHANCED (practice, voice, age config)
    │   └── rule-switch.html                  ⭐ NEW
    └── sounds/
        └── frog-game.mp3                     ⭐ NEW
```

### **Key Code Snippets**

#### **Age Configuration in Game**
```javascript
// In games/index.html
function configureGameForAge(age) {
  if (age <= 3) {
    gameState.maxTrials = 6;
    gameState.maxPracticeTrials = 3;
    gameState.stimulusDisplayTime = 3500;
  } else if (age <= 4) {
    gameState.maxTrials = 8;
    gameState.maxPracticeTrials = 2;
    gameState.stimulusDisplayTime = 2500;
  } else {
    gameState.maxTrials = 10;
    gameState.maxPracticeTrials = 2;
    gameState.stimulusDisplayTime = 2000;
  }
}
```

#### **Voice Instructions**
```javascript
// In games/index.html
function speak(text) {
  if ('speechSynthesis' in window) {
    const utterance = new SpeechSynthesisUtterance(text);
    utterance.rate = 0.9;
    utterance.pitch = 1.2;
    utterance.volume = 0.8;
    window.speechSynthesis.speak(utterance);
  }
}
```

#### **Practice Mode Feedback**
```javascript
// In games/index.html
if (gameState.isPracticeMode) {
  if (isCorrect) {
    showEncouragementMessage('🌟 Perfect!', 'gradient...');
  } else {
    showEncouragementMessage('💡 Remember: Tap the happy animal!', 'gradient...');
  }
}
```

---

## ✅ Testing Guidelines

### **1. Age-Based Routing Test**

| Test Case | Child Age | Expected Route | Expected Assessment |
|-----------|-----------|----------------|-------------------|
| TC001 | 2.0 years | `aiBot` | AI Doctor Bot |
| TC002 | 2.9 years | `aiBot` | AI Doctor Bot |
| TC003 | 3.0 years | `ageSelection` → `game` | Frog Jump (6 trials) |
| TC004 | 4.5 years | `ageSelection` → `game` | Frog Jump (8 trials) |
| TC005 | 5.0 years | `ageSelection` → `game` | Rule Switch (20 trials) |
| TC006 | 6.0 years | `ageSelection` → `game` | Rule Switch (20 trials) |
| TC007 | 7.0 years | Alert | "Age out of range" |

### **2. Game Feature Tests**

#### **Frog Jump Game**
- ✅ Practice trials appear first
- ✅ "Practice Time!" message shows
- ✅ Practice trials don't count in final score
- ✅ Voice instructions work on button click
- ✅ Background music toggles correctly
- ✅ Age-based trial count (6/8/10)
- ✅ Encouragement messages appear
- ✅ Results send to React Native

#### **Rule Switch Game**
- ✅ Phase 1: Color sorting (trials 1-10)
- ✅ Rule switch announcement at trial 11
- ✅ Phase 2: Shape sorting (trials 11-20)
- ✅ Switch cost calculated correctly
- ✅ Post-switch errors tracked
- ✅ Voice instructions work
- ✅ Results include switch metrics

#### **AI Doctor Bot**
- ✅ All 10 questions display
- ✅ Progress bar updates
- ✅ Answers persist on back navigation
- ✅ Category scores calculated
- ✅ Risk score calculated (inverted)
- ✅ Recommendations generated
- ✅ Results send to parent component

### **3. Integration Tests**

```typescript
// Test: Complete flow for age 3
1. Login
2. Navigate to Cognitive Dashboard
3. Add child (age 3)
4. Click "Start Assessment"
5. Confirm Frog Jump game selected
6. Play through practice + game trials
7. Verify results screen shows
8. Verify data saved in AsyncStorage

// Test: Complete flow for age 2
1. Login
2. Navigate to Cognitive Dashboard
3. Add child (age 2)
4. Click "Start Assessment"
5. Confirm AI Bot questionnaire selected
6. Answer all 10 questions
7. Verify results screen shows
8. Verify data saved with correct format
```

---

## 📈 Future Enhancements

### **Short-Term (Next Sprint)**
1. ✅ **Voice recordings** for AI Bot questions (for non-literate parents)
2. ✅ **Multi-language support** (Spanish, Hindi, Chinese)
3. ✅ **Offline mode** with sync when online
4. ✅ **Export reports** (PDF generation)

### **Mid-Term**
1. ✅ **Machine Learning integration** (risk prediction model)
2. ✅ **Longitudinal tracking** (compare sessions over time)
3. ✅ **Therapist portal** (separate interface for therapy tracking)
4. ✅ **Video analysis** (facial expression recognition during games)

### **Long-Term**
1. ✅ **Adaptive difficulty** (adjust trials based on performance)
2. ✅ **Real-time biometrics** (heart rate variability during tasks)
3. ✅ **VR/AR assessments** (immersive social scenarios)
4. ✅ **Telehealth integration** (remote administration with video call)

---

## 📚 References

1. Wiebe, S. A., et al. (2011). "The structure of executive function in 3-year-olds." *Journal of Experimental Child Psychology*.

2. Zelazo, P. D., et al. (2013). "The Dimensional Change Card Sort (DCCS)." *NIH Toolbox Assessment Manual*.

3. Baron-Cohen, S., et al. (2000). "The M-CHAT: Modified Checklist for Autism in Toddlers."

4. Ozonoff, S., & Jensen, J. (1999). "Brief report: Specific executive function profiles in autism."

5. Christ, S. E., et al. (2007). "Inhibitory control in children with autism spectrum disorder."

6. Hill, E. L. (2004). "Executive dysfunction in autism."

7. Mundy, P., et al. (1986). "Defining the social deficits of autism."

8. Gray, K. M., & Tonge, B. J. (2005). "Screening for autism in infants and preschool children."

---

## ✨ Summary

### **What We Built**
✅ Age-appropriate assessment routing (2-3, 3-5, 5-6)  
✅ AI Doctor Bot questionnaire for toddlers  
✅ Enhanced Frog Jump game with practice, voice, music  
✅ New Rule Switch game (DCCS-style)  
✅ Comprehensive navigation system  
✅ Complete data flow and result processing  

### **Clinical Value**
✅ Developmentally appropriate for each age  
✅ Evidence-based assessments  
✅ Reduces screen time for young children  
✅ Captures diverse executive function metrics  
✅ Provides actionable recommendations  

### **Technical Quality**
✅ React Native + HTML5 hybrid architecture  
✅ WebView communication protocol  
✅ Age-based dynamic configuration  
✅ Offline-capable with AsyncStorage  
✅ Scalable for future enhancements  

---

**System Status**: ✅ **Ready for Pilot Study**  
**Last Updated**: October 26, 2025  
**Documentation Version**: 1.0  
**Author**: AI Assistant + Development Team  

---

**🎉 The age-based autism screening system is complete and ready to help children and families! 🎉**

