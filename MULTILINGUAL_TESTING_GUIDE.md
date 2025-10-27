# 🧪 Multilingual Testing Guide - Phase 1

## Date: October 26, 2025

---

## ✅ What's Been Implemented (Phase 1)

### **Completed Components:**
1. ✅ **Translation System** (`src/i18n/translations.ts`)
2. ✅ **Language Context** (`src/context/LanguageContext.tsx`)
3. ✅ **Language Selector** (`src/components/LanguageSelector.tsx`)
4. ✅ **App Integration** (LanguageProvider in `App.tsx`)
5. ✅ **LoginScreen** - Fully translated
6. ✅ **MainDashboardScreen** - Key elements translated

### **Languages Available:**
- 🇬🇧 **English** (en)
- 🇱🇰 **සිංහල Sinhala** (si)
- 🇱🇰 **தமிழ் Tamil** (ta)

---

## 🚀 How to Run & Test

### **Step 1: Build and Run the App**

```bash
# If Metro bundler is still running, just reload:
# Press 'R' twice in Metro terminal
# OR shake device and tap "Reload"

# If you need to rebuild:
npx react-native run-android
```

---

## 🧪 Testing Checklist

### **Test 1: Language Selector Visibility** ⭐

**LoginScreen:**
1. ✅ Open the app
2. ✅ Look at **top-right corner**
3. ✅ You should see language button with flag: 🇬🇧 English ▼

**Expected Result:** Language selector is visible and accessible

---

### **Test 2: Language Switching** 🔄

**On LoginScreen:**

1. **Click the language selector** (top-right)
2. **Modal opens** with 3 options:
   - 🇬🇧 English / English
   - 🇱🇰 සිංහල / Sinhala
   - 🇱🇰 தமிழ் / Tamil

3. **Select සිංහල (Sinhala)**
4. **Verify changes:**
   - ✅ "Login" → "ඇතුළු වන්න"
   - ✅ "Email Address" → "විද්‍යුත් තැපැල් ලිපිනය"
   - ✅ "Password" → "මුරපදය"
   - ✅ "Forgot your password?" → "මුරපදය අමතක වුණාද?"
   - ✅ "Sign In to Dashboard" → "පුරන්න"
   - ✅ "Don't have an account?" → "ගිණුමක් නැද්ද?"
   - ✅ "Create Account" → "ගිණුමක් සාදන්න"

5. **Change to தமிழ் (Tamil)**
6. **Verify changes:**
   - ✅ "Login" → "உள்நுழை"
   - ✅ "Email Address" → "மின்னஞ்சல் முகவரி"
   - ✅ "Password" → "கடவுச்சொல்"
   - ✅ "Forgot your password?" → "கடவுச்சொல்லை மறந்துவிட்டீர்களா?"
   - ✅ "Sign In" → "உள்நுழை"

7. **Change back to English**
8. **Verify all text returns to English**

**Expected Result:** All visible text changes instantly when language is switched

---

### **Test 3: Language Persistence** 💾

1. **Select Sinhala language**
2. **Login** using demo credentials:
   - Email: `doctor@clinic.com`
   - Password: `password`
3. **Close the app completely** (swipe away from recent apps)
4. **Reopen the app**
5. **Check language selector** - should still show සිංහල

**Expected Result:** Language preference persists across app restarts

---

### **Test 4: MainDashboard Translation** 📊

**After logging in:**

1. **Check header:**
   - English: "Welcome back, [Name]"
   - Sinhala: "ආයුබෝවන්, [Name]"
   - Tamil: "வரவேற்கிறோம், [Name]"

2. **Click notification bell icon:**
   - English: "Assessment Reminder"
   - Sinhala: "තක්සේරු මතක් කිරීම"
   - Tamil: "மதிப்பீட்டு நினைவூட்டல்"

3. **Click logout icon:**
   - English: "Logout" / "Are you sure you want to logout?"
   - Sinhala: "ඉවත් වන්න" / "ඔබට ඉවත් වීමට අවශ්‍යද?"
   - Tamil: "வெளியேறு" / "நீங்கள் வெளியேற விரும்புகிறீர்களா?"

4. **Click "Coming Soon" assessment:**
   - English: "Coming Soon"
   - Sinhala: "ඉක්මනින් එනවා"
   - Tamil: "விரைவில் வருகிறது"

5. **Change language in dashboard:**
   - Language selector is in header
   - Click and switch languages
   - Verify all text updates

**Expected Result:** Dashboard updates dynamically when language changes

---

### **Test 5: Error Messages** ⚠️

**On LoginScreen:**

1. **Leave email and password empty**
2. **Click "Sign In"**
3. **Check error message:**
   - English: "Invalid input" / "This field is required"
   - Sinhala: "වැරදි ආදානය" / "මෙම ක්ෂේත්‍රය අවශ්‍යයි"
   - Tamil: "தவறான உள்ளீடு" / "இந்த புலம் தேவை"

4. **Enter invalid email** (e.g., "test")
5. **Click "Sign In"**
6. **Check error:**
   - English: "Invalid email address"
   - Sinhala: "වලංගු නොවන විද්‍යුත් තැපැල් ලිපිනය"
   - Tamil: "தவறான மின்னஞ்சல் முகவரி"

**Expected Result:** Error messages appear in selected language

---

## 🎨 Visual Testing

### **Language Selector Appearance:**

**Dropdown Button:**
```
┌─────────────────────┐
│ 🇱🇰 සිංහල     ▼  │
└─────────────────────┘
```

**Modal (when clicked):**
```
┌────────────────────────────────┐
│  Select Language            ✕  │
├────────────────────────────────┤
│ 🇬🇧 English                    │
│    English                     │
├────────────────────────────────┤
│ 🇱🇰 සිංහල               ✓    │
│    Sinhala                     │
├────────────────────────────────┤
│ 🇱🇰 தமிழ்                      │
│    Tamil                       │
└────────────────────────────────┘
```

---

## 📱 Device-Specific Testing

### **Test on Different Devices:**

1. **Phone (5.5" screen)**
   - ✅ Language selector visible and clickable
   - ✅ Modal fits on screen
   - ✅ Text not cut off

2. **Tablet (10" screen)**
   - ✅ Layout looks good
   - ✅ Language selector properly positioned
   - ✅ Text readable at larger scale

3. **Different Android Versions:**
   - ✅ Android 10+
   - ✅ Android 11+
   - ✅ Android 12+

---

## 🐛 Known Issues to Check

### **Potential Issues:**

1. **Text Overflow:**
   - Sinhala/Tamil text may be longer than English
   - Check if buttons expand properly
   - Check if text wraps correctly

2. **Font Rendering:**
   - Sinhala characters: ආ, ඉ, එ, ඔ, ක, ග, ඩ
   - Tamil characters: அ, இ, உ, எ, ஒ, க, ச, ட
   - Should render clearly without boxes (□)

3. **Language Selector Position:**
   - Should not overlap with other UI elements
   - Should be accessible on all screen sizes

---

## ✅ Success Criteria

### **Phase 1 is successful if:**

1. ✅ Language selector appears on Login and Dashboard screens
2. ✅ Clicking selector opens modal with 3 languages
3. ✅ Selecting a language changes all visible text immediately
4. ✅ Language preference persists after app restart
5. ✅ No crashes when switching languages
6. ✅ Text renders correctly in all 3 languages (no □ boxes)
7. ✅ Error messages appear in selected language
8. ✅ Alerts/dialogs appear in selected language

---

## 📊 Test Results Template

**Copy and fill this out:**

```
TEST DATE: __________
TESTER: __________
DEVICE: __________
ANDROID VERSION: __________

=== RESULTS ===

✅ Test 1 (Language Selector Visibility): PASS / FAIL
✅ Test 2 (Language Switching): PASS / FAIL
✅ Test 3 (Language Persistence): PASS / FAIL
✅ Test 4 (MainDashboard Translation): PASS / FAIL
✅ Test 5 (Error Messages): PASS / FAIL

=== ISSUES FOUND ===
1. [Describe any issues]
2. [...]

=== SCREENSHOTS ===
- English: [Attach]
- Sinhala: [Attach]
- Tamil: [Attach]

=== RECOMMENDATIONS ===
[Any suggestions or improvements]
```

---

## 🎯 What to Look For

### **Good Signs:** ✅
- Text changes instantly when language is selected
- No English text remains when in Sinhala/Tamil
- Layout doesn't break with longer text
- Language selector is always visible
- Modal opens and closes smoothly
- App feels responsive

### **Bad Signs:** ❌
- Some text stays in English
- UI elements overlap
- Text cut off or truncated
- App crashes when switching languages
- Fonts don't render (show □ boxes)
- Language doesn't persist

---

## 🔧 Troubleshooting

### **Issue: Language selector not visible**
**Solution:**
1. Check if you rebuilt the app
2. Reload Metro bundler (R R)
3. Check console for errors

### **Issue: Text not changing**
**Solution:**
1. Check if `t.*` is being used in the component
2. Verify LanguageProvider wraps the component
3. Check console logs for translation key errors

### **Issue: Fonts showing boxes (□)**
**Solution:**
1. This is normal on some devices
2. Try different Android version/device
3. Update system fonts if possible

### **Issue: App crashes on language switch**
**Solution:**
1. Check console for error messages
2. Share error log for debugging
3. Try with fewer language switches

---

## 📞 Next Steps After Testing

### **If Everything Works:** ✅
1. ✅ Report "All tests passed!"
2. ✅ I'll continue with remaining screens:
   - CognitiveDashboardScreen
   - AIDoctorBotScreen  
   - ChildRegistrationScreen
   - HTML Games translation

### **If Issues Found:** 🐛
1. 🐛 Report specific issues with details
2. 🐛 Share screenshots if possible
3. 🐛 I'll fix issues before continuing

---

## 🎓 Quick Demo Script

**For showing to others:**

```
1. "Let me show you the multilingual feature"

2. [Open app on Login screen]
   "See the language selector here?"
   [Point to top-right]

3. [Click language selector]
   "We support 3 languages"
   [Show modal]

4. [Select Sinhala]
   "Watch all text change to Sinhala"
   [Wait for instant update]

5. [Select Tamil]
   "Now Tamil"
   [Text updates]

6. [Login]
   "The language persists after login"
   [Show dashboard in Tamil]

7. [Switch language in dashboard]
   "And can be changed anytime"
   [Show instant update]

8. "This will work throughout the app"
```

---

## 🌟 Summary

### **What You're Testing:**
- ✅ Language selector visibility and functionality
- ✅ Instant text translation (English → Sinhala → Tamil)
- ✅ Language persistence across sessions
- ✅ Error messages in all languages
- ✅ UI doesn't break with different text lengths

### **Currently Translated:**
- ✅ LoginScreen (100%)
- ✅ MainDashboardScreen (Key elements)
- ⏳ Other screens (Next phase)

### **Total Coverage:**
- **Phase 1:** ~20% of app (Login + Dashboard entry points)
- **Phase 2 (After testing):** Remaining 80% (Child mgmt, Assessments, Games)

---

## 🚀 Ready to Test!

**Your action items:**
1. ✅ Run the app: `npx react-native run-android`
2. ✅ Go through testing checklist
3. ✅ Report results (pass/fail for each test)
4. ✅ Share any issues or suggestions
5. ✅ Once confirmed working, I'll complete remaining screens!

**Good luck with testing!** 🎉

---

**Questions? Just ask!**
- How do I test X?
- I found an issue with Y
- Can you explain Z?
- Everything works! Continue!

**I'm ready to help!** 💪

