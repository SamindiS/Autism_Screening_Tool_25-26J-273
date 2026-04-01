# Quick Start: Using New Localization System

> 📚 **For complete documentation, see [LOCALIZATION_COMPLETE_GUIDE.md](./LOCALIZATION_COMPLETE_GUIDE.md)**

## ✅ System is Ready!

Your app now uses Flutter's official `.arb` localization system. No more hardcoding!

### System Overview
- **3 Languages**: English (en), Sinhala (si), Tamil (ta)
- **346 Translation Keys** in English
- **Auto-detection** of device language
- **Persistent preferences** via SharedPreferences
- **Automatic font switching** (IskoolaPota for Sinhala, Bamini for Tamil)

---

## 🚀 How to Use

### 1. Import the Generated Localizations:
```dart
import 'l10n/app_localizations.dart';
```

### 2. Use in Your Widgets:

#### Simple Text:
```dart
Text(AppLocalizations.of(context)!.appName)
```

#### In Buttons:
```dart
ElevatedButton(
  child: Text(AppLocalizations.of(context)!.login),
  onPressed: () {},
)
```

#### With Placeholders:
```dart
// ARB: "aiQuestion1": "Does {childName} respond when you call their name?"
Text(AppLocalizations.of(context)!.aiQuestion1(childName: 'John'))
```

#### In AppBar:
```dart
AppBar(
  title: Text(AppLocalizations.of(context)!.dashboard),
)
```

#### Form Validation:
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.nameRequired;
    }
    return null;
  },
)
```

---

## 🎯 Key Conversion Table

| Old JSON Key | New ARB Key | Usage |
|-------------|-------------|-------|
| `app_name` | `appName` | `AppLocalizations.of(context)!.appName` |
| `login` | `login` | `AppLocalizations.of(context)!.login` |
| `ai_question_1` | `aiQuestion1` | `AppLocalizations.of(context)!.aiQuestion1(childName: name)` |
| `child_name` | `childName` | `AppLocalizations.of(context)!.childName` |
| `dashboard` | `dashboard` | `AppLocalizations.of(context)!.dashboard` |
| `save` | `save` | `AppLocalizations.of(context)!.save` |
| `cancel` | `cancel` | `AppLocalizations.of(context)!.cancel` |

**Note**: All keys use camelCase in ARB files (e.g., `appName` instead of `app_name`)

---

## ⚙️ Language Settings

### Access Settings
**Path:** Dashboard → Settings icon (⚙️) in top-right corner

### Features:
- ✅ **Auto-detect device language** (default: ON)
  - Automatically uses device language on first launch
  - Updates when device language changes (if enabled)
- ✅ **Manual language selection**
  - Choose from: English, සිංහල (Sinhala), தமிழ் (Tamil)
  - Visual indicators show current selection
- ✅ **Instant language switching**
  - Changes apply immediately without app restart
  - All screens update automatically
- ✅ **Persistent storage**
  - Preference saved to SharedPreferences
  - Restored on app restart

### Quick Language Switcher
The `LanguageSelector` widget provides a popup menu in app bars:
```dart
AppBar(
  actions: [
    LanguageSelector(), // Quick language switcher
  ],
)
```

---

## 📝 Adding New Translations

### Step-by-Step Process:

#### 1. Add to English ARB (`lib/l10n/app_en.arb`):
```json
{
  "@@locale": "en",
  "myNewKey": "My New Text",
  "myKeyWithPlaceholder": "Hello {name}!",
  "@myKeyWithPlaceholder": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  }
}
```

#### 2. Add to Sinhala ARB (`lib/l10n/app_si.arb`):
```json
{
  "@@locale": "si",
  "myNewKey": "මගේ නව පෙළ",
  "myKeyWithPlaceholder": "හෙලෝ {name}!"
}
```

#### 3. Add to Tamil ARB (`lib/l10n/app_ta.arb`):
```json
{
  "@@locale": "ta",
  "myNewKey": "எனது புதிய உரை",
  "myKeyWithPlaceholder": "வணக்கம் {name}!"
}
```

#### 4. Generate Code:
```bash
flutter gen-l10n
```

#### 5. Use in Code:
```dart
// Simple key
AppLocalizations.of(context)!.myNewKey

// With placeholder
AppLocalizations.of(context)!.myKeyWithPlaceholder(name: 'John')
```

### ARB File Structure:
- **Template file**: `app_en.arb` (always add new keys here first)
- **Translation files**: `app_si.arb`, `app_ta.arb`
- **Locale metadata**: `"@@locale": "en"` (required in each file)
- **Placeholder metadata**: `"@keyName"` object defines placeholder types

---

## 📊 Translation Status

### Current Coverage:
- **English**: ✅ 100% (346/346 keys) - Complete
- **Sinhala**: ⚠️ ~75% (261/346 keys) - 85 keys missing
- **Tamil**: ⚠️ ~75% (261/346 keys) - 85 keys missing

### Missing Translations:
When a translation is missing in Sinhala or Tamil, the app automatically falls back to English. This ensures the app always works, even with incomplete translations.

### To Complete Translations:
1. Compare `app_en.arb` with `app_si.arb` and `app_ta.arb`
2. Identify missing keys
3. Add translations for missing keys
4. Run `flutter gen-l10n`
5. Test in all languages

---

## ⚠️ About the 78 Untranslated Messages Warning

### What It Means:
When you run `flutter gen-l10n`, you may see warnings like:
```
Warning: 78 messages are not translated in 'si'
Warning: 78 messages are not translated in 'ta'
```

**This is normal!** It means some keys exist in English but not in Sinhala/Tamil.

### Impact:
- ✅ App still works perfectly
- ✅ Missing translations show English text (fallback)
- ✅ No runtime errors

### To Fix:
1. Check which keys are missing (compare ARB files)
2. Add translations to `app_si.arb` and `app_ta.arb`
3. Run `flutter gen-l10n` again
4. Warnings will decrease as you add translations

---

## 🔄 Migration Status

### ✅ Completed:
- ✅ ARB files created (3 languages)
- ✅ Code generation configured (`l10n.yaml`)
- ✅ Language provider implemented (`LanguageProvider`)
- ✅ Settings screen created with UI
- ✅ Auto-detect functionality enabled
- ✅ Language switcher widget ready
- ✅ Font management integrated
- ✅ Persistent storage working
- ✅ Main app integration complete

### ⏳ In Progress:
- ⏳ Migrating screens to use `AppLocalizations.of(context)`
- ⏳ Completing missing Sinhala translations
- ⏳ Completing missing Tamil translations

### 📋 Next Steps:
1. Update remaining screens to use new localization system
2. Complete missing translations
3. Remove old JSON-based translation system
4. Test thoroughly in all languages

---

## 🏗️ Architecture Overview

### Core Components:

1. **ARB Files** (`lib/l10n/`)
   - Source files for translations
   - JSON format with Flutter-specific metadata

2. **Generated Files** (`lib/l10n/app_localizations*.dart`)
   - Auto-generated from ARB files
   - Type-safe getters for all keys
   - Do NOT edit manually

3. **Language Provider** (`lib/core/providers/language_provider.dart`)
   - Manages current locale state
   - Notifies listeners on change
   - Uses Provider pattern

4. **Language Preference Service** (`lib/core/services/language_preference_service.dart`)
   - Handles persistence (SharedPreferences)
   - Auto-detection logic
   - Device locale detection

5. **Settings Screen** (`lib/features/settings/settings_screen.dart`)
   - User interface for language selection
   - Auto-detect toggle
   - Visual language indicators

### Data Flow:
```
User selects language
    ↓
LanguageProvider.setLocale()
    ↓
LanguagePreferenceService.setLocale() (saves to SharedPreferences)
    ↓
LanguageProvider.notifyListeners()
    ↓
MaterialApp rebuilds with new locale
    ↓
All widgets update automatically
```

---

## 💡 Pro Tips

### 1. Use IDE Autocomplete
Type `AppLocalizations.of(context).` and see all available keys with autocomplete. This helps discover existing translations.

### 2. Check Generated File
See `lib/l10n/app_localizations.dart` for all available getters. This is the source of truth for available keys.

### 3. Test All Languages
Always test your UI in:
- English (baseline)
- Sinhala (check font rendering, text length)
- Tamil (check font rendering, text length)

### 4. Fonts Work Automatically
Sinhala/Tamil fonts are applied automatically based on selected language:
- Sinhala → IskoolaPota font
- Tamil → Bamini font
- English → System default

### 5. Hot Restart After Changes
After running `flutter gen-l10n`, use **Hot Restart** (not Hot Reload) to see changes.

### 6. Keep ARB Files in Sync
When adding a new key:
1. Add to `app_en.arb` first (template)
2. Add to `app_si.arb` and `app_ta.arb`
3. Run `flutter gen-l10n`
4. Test in all languages

### 7. Use Descriptive Key Names
```dart
// ✅ Good
"assessmentResults": "Assessment Results"
"childNameLabel": "Child Name"

// ❌ Bad
"result": "Assessment Results"
"name": "Child Name"
```

### 8. Group Related Keys
Use prefixes for related translations:
- `aiQuestion1`, `aiQuestion2`, `aiQuestion3`
- `reflectionQuestionAttention`, `reflectionQuestionEngagement`
- `manualTask1Title`, `manualTask1Description`

### 9. Handle Null Safety
```dart
// ✅ Good - with null check
final l10n = AppLocalizations.of(context);
if (l10n != null) {
  Text(l10n.appName)
}

// ✅ Also good - with null assertion (if context guaranteed)
final l10n = AppLocalizations.of(context)!;
Text(l10n.appName)
```

### 10. Use Placeholders for Dynamic Content
```dart
// ✅ Good - uses placeholder
"greeting": "Hello {name}!"
// Usage: l10n.greeting(name: userName)

// ❌ Bad - manual concatenation
"greeting": "Hello!"
// Then: "${l10n.greeting} $userName"
```

---

## 🐛 Troubleshooting

### Issue: "AppLocalizations.of(context) returns null"
**Solution**: Ensure `MaterialApp` includes:
```dart
localizationsDelegates: AppLocalizations.localizationsDelegates,
supportedLocales: AppLocalizations.supportedLocales,
```

### Issue: Translations not updating
**Solution**: 
1. Run `flutter gen-l10n`
2. Hot restart (not hot reload)
3. Check ARB file syntax (valid JSON)

### Issue: Font not applying
**Solution**:
1. Check font file exists in `assets/fonts/`
2. Verify `pubspec.yaml` font configuration
3. Run `flutter pub get`
4. Hot restart app

### Issue: Language change not persisting
**Solution**: 
1. Check `SharedPreferences` permissions
2. Verify `LanguagePreferenceService.setLocale()` is called
3. Check auto-detect is not overriding manual selection

---

## 📚 Additional Resources

- **Complete Guide**: See [LOCALIZATION_COMPLETE_GUIDE.md](./LOCALIZATION_COMPLETE_GUIDE.md) for comprehensive documentation
- **Flutter Localization**: [Official Flutter Localization Docs](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
- **ARB Format**: [ARB File Format Specification](https://github.com/google/app-resource-bundle)

---

## 📈 Statistics

- **Total Translation Keys**: 346
- **Languages Supported**: 3 (English, Sinhala, Tamil)
- **Translation Coverage**: 
  - English: 100%
  - Sinhala: 75%
  - Tamil: 75%
- **Fonts Configured**: 2 (IskoolaPota, Bamini)
- **System Status**: ✅ Production Ready

---

**Last Updated**: Based on current codebase analysis  
**Quick Reference**: This file | **Full Documentation**: [LOCALIZATION_COMPLETE_GUIDE.md](./LOCALIZATION_COMPLETE_GUIDE.md)



