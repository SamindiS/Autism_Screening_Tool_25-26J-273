# 🧪 **Comprehensive Testing Guide** - Multilingual Autism Screening App

## 🎯 **Your Mission:** Test Everything!

---

## 🚀 **Step 1: Run the App**

```bash
npx react-native run-android
```

Wait for the app to build and launch on your device/emulator.

---

## 📋 **Step 2: Complete Testing Checklist**

### **🔐 LoginScreen Testing (5 min)**

1. **Initial Load:**
   - [ ] Language selector visible in top-right corner
   - [ ] Shows current language flag (🇬🇧 by default)

2. **Language Switching:**
   - [ ] Click language selector
   - [ ] Modal opens with 3 options
   - [ ] Select "සිංහල (Sinhala)"
   - [ ] All text changes to Sinhala immediately:
     - "Login" → "ඇතුළු වන්න"
     - "Email Address" → "විද්‍යුත් තැපැල් ලිපිනය"
     - "Password" → "මුරපදය"
   - [ ] Select "தமிழ் (Tamil)"
   - [ ] All text changes to Tamil immediately
   - [ ] Select "English"
   - [ ] All text back to English

3. **Login Functionality:**
   - [ ] Try logging in with test credentials:
     - Email: `doctor@clinic.com`
     - Password: `password`
   - [ ] Check error messages appear in selected language
   - [ ] Successfully login

---

### **🏠 MainDashboard Testing (5 min)**

1. **Initial View:**
   - [ ] Language selector visible in header
   - [ ] Welcome message in current language
   - [ ] All dashboard cards visible

2. **Language Persistence:**
   - [ ] Language is same as selected on Login screen
   - [ ] Selector still works

3. **UI Elements:**
   - [ ] Switch to Sinhala
   - [ ] Check "Welcome back" text changes
   - [ ] Click logout
   - [ ] Logout dialog appears in Sinhala
   - [ ] Cancel logout

4. **Navigation:**
   - [ ] Click "Cognitive Flexibility" card
   - [ ] Navigate to Cognitive Dashboard

---

### **🧠 CognitiveDashboard Testing (10 min)**

1. **Empty State:**
   - [ ] "No Children Registered" message in current language
   - [ ] "Add New Child" button in current language

2. **Add Child:**
   - [ ] Click "Add New Child"
   - [ ] Form opens

---

### **👶 ChildRegistration Testing (10 min)**

1. **Form Labels (English):**
   - [ ] All labels visible: "Child's Name", "Age", "Gender", "Language"
   - [ ] Placeholder text in English

2. **Switch to Sinhala:**
   - [ ] Form labels change to Sinhala
   - [ ] Gender options: "පිරිමි" (Male), "ගැහැණු" (Female)
   - [ ] Language options: "ඉංග්‍රීසි", "සිංහල", "දෙමළ"

3. **Switch to Tamil:**
   - [ ] Form labels change to Tamil
   - [ ] Gender options change to Tamil

4. **Validation (in current language):**
   - [ ] Try submitting empty form
   - [ ] Error messages appear in current language
   - [ ] Fill out form:
     - Name: "Test Child"
     - Age: 4
     - Gender: Male
     - Language: Sinhala
   - [ ] Submit
   - [ ] Success message appears in current language with child's name

5. **Return to Cognitive Dashboard:**
   - [ ] Child now appears in list
   - [ ] Age group info in current language

---

### **🤖 AIDoctorBot Testing (15 min)**

1. **Start Assessment:**
   - [ ] Click "Start Assessment" for child age 2-3
   - [ ] AI Doctor Bot screen opens

2. **Questions (Switch languages throughout):**
   - [ ] Question 1 appears in current language
   - [ ] Switch to Sinhala mid-questionnaire
   - [ ] Question text updates immediately
   - [ ] Answer options in Sinhala
   - [ ] Answer question
   - [ ] Switch to Tamil
   - [ ] Question 2 in Tamil
   - [ ] Answer options in Tamil
   - [ ] Progress text in Tamil: "பதில் 2 இல் 10"

3. **Complete Questionnaire:**
   - [ ] Answer all 10 questions
   - [ ] Check each question displays correctly in all languages
   - [ ] Verify categories translate
   - [ ] Check "Back" button translates

4. **Results:**
   - [ ] Results screen appears
   - [ ] All labels in current language

---

### **🐸 FrogJumpGame Testing (10 min)**

1. **Start Game:**
   - [ ] From Cognitive Dashboard, start assessment for child age 3-5
   - [ ] Frog Jump game loads

2. **Instructions Screen (English):**
   - [ ] Title visible
   - [ ] Instructions in English
   - [ ] "🔊 Hear Instructions" button
   - [ ] "Start Game" button

3. **Change Language:**
   - [ ] Go back to main app
   - [ ] Change language to Sinhala
   - [ ] Navigate back to game
   - [ ] Game instructions in Sinhala
   - [ ] Buttons in Sinhala:
     - "🔊 උපදෙස් අසන්න"
     - "ක්‍රීඩාව අරඹන්න"

4. **Play Game:**
   - [ ] Start game
   - [ ] "Back" button (← ආපසු)
   - [ ] Score label in Sinhala
   - [ ] Practice feedback in Sinhala
   - [ ] Play through game

5. **Results:**
   - [ ] Results screen in Sinhala
   - [ ] "Game Over!" → "ක්‍රීඩාව අවසන්!"
   - [ ] Accuracy label in Sinhala
   - [ ] "Finish" button in Sinhala

6. **Test Tamil:**
   - [ ] Repeat with Tamil language
   - [ ] Verify all game text in Tamil

---

### **🔷 RuleSwitchGame Testing (10 min)**

1. **Start Game:**
   - [ ] Start assessment for child age 5-6
   - [ ] Rule Switch game loads

2. **Instructions Screen (English):**
   - [ ] Instructions visible
   - [ ] "Start Game" button

3. **Change Language:**
   - [ ] Test with Sinhala
   - [ ] Instructions change: "පළමුව, වර්ණය අනුව වර්ග කරන්න!"
   - [ ] Button: "ක්‍රීඩාව අරඹන්න"

4. **Play Game:**
   - [ ] Start game
   - [ ] "Sort by COLOR!" in Sinhala
   - [ ] Score/Time labels in Sinhala
   - [ ] Rule switch message in Sinhala
   - [ ] "Sort by SHAPE!" in Sinhala
   - [ ] Complete game

5. **Results:**
   - [ ] Results screen in Sinhala
   - [ ] All labels translated

6. **Test Tamil:**
   - [ ] Repeat with Tamil
   - [ ] Verify all text in Tamil

---

### **💾 Persistence Testing (5 min)**

1. **Close App Completely:**
   - [ ] Close app (don't just background it)

2. **Reopen App:**
   - [ ] App opens
   - [ ] Language selector shows last selected language
   - [ ] All text in last selected language

3. **Navigate Through App:**
   - [ ] All screens remember language
   - [ ] No reset to English

---

### **📱 UI/UX Testing (10 min)**

1. **Text Overflow:**
   - [ ] Switch to Sinhala (longest text)
   - [ ] Check all buttons fit text
   - [ ] No cut-off text
   - [ ] No overlapping elements

2. **Button Tap Targets:**
   - [ ] All buttons easily tappable
   - [ ] No buttons too small
   - [ ] Language selector easy to tap

3. **Modal Functionality:**
   - [ ] Language selector modal opens smoothly
   - [ ] Can close by tapping outside
   - [ ] Selection works correctly

4. **Font Rendering:**
   - [ ] Sinhala characters display correctly (no □ boxes)
   - [ ] Tamil characters display correctly
   - [ ] All text readable

---

## 🐛 **Bug Reporting Template**

If you find issues, report them like this:

```
🐛 **Bug Title:** [Short description]

**Screen:** [Which screen]
**Language:** [EN/SI/TA]
**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected:** [What should happen]
**Actual:** [What actually happened]

**Screenshot:** [If possible]
```

---

## ✅ **Success Criteria**

### **Minimum Requirements:**
- [ ] All 3 languages work on all screens
- [ ] Language persists after app restart
- [ ] No crashes when switching languages
- [ ] No UI breaks with different languages
- [ ] All buttons remain clickable

### **Nice to Have:**
- [ ] Smooth language transitions
- [ ] No performance issues
- [ ] Fonts render beautifully
- [ ] Text fits nicely in all languages

---

## 🎯 **Test Results Summary**

After testing, fill this out:

### **LoginScreen:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **MainDashboard:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **CognitiveDashboard:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **ChildRegistration:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **AIDoctorBot:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **FrogJumpGame:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **RuleSwitchGame:**
- English: ✅ / ❌
- Sinhala: ✅ / ❌
- Tamil: ✅ / ❌
- Issues: _______________

### **Persistence:**
- Works: ✅ / ❌
- Issues: _______________

### **Overall:**
- **Total Tests Passed:** _____ / 21
- **Critical Issues:** _____
- **Minor Issues:** _____
- **Ready for Production:** ✅ / ❌

---

## 🚀 **After Testing**

### **If Everything Works:** ✅
```
Great! Report: "All tests passed! Ready for next phase."
```

### **If Issues Found:** 🐛
```
Report each issue using the bug template above.
I'll fix them immediately!
```

---

## 💡 **Quick Tips**

1. **Test methodically** - Don't rush
2. **Switch languages frequently** - Test transitions
3. **Try edge cases** - Empty forms, long names, etc.
4. **Check UI on different screen sizes** - If possible
5. **Note even small issues** - They're easy to fix now

---

## 🎓 **What You're Testing**

This isn't just language translation - you're testing:
- ✅ Translation accuracy
- ✅ UI layout integrity
- ✅ State management
- ✅ Persistence mechanism
- ✅ WebView communication
- ✅ User experience
- ✅ Performance
- ✅ Error handling

**This is comprehensive testing of a production-ready feature!** 🌟

---

## ⏱️ **Estimated Time**

- **Quick Test:** 15-20 minutes (basic functionality)
- **Thorough Test:** 60-80 minutes (comprehensive)
- **With Bug Reporting:** +15 minutes

---

**Good luck with testing!** 🧪🚀

**Remember:** Every bug you find now is one less bug in production! 🐛➡️✅

