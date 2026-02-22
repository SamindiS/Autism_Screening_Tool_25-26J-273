# Localization Migration Guide

## ✅ Migration Complete: JSON → ARB System

Your app now uses Flutter's official `.arb` localization system instead of hardcoded JSON files.

## 📁 New Structure

```
lib/
├── l10n/
│   ├── app_en.arb      (English translations)
│   ├── app_si.arb      (Sinhala translations)
│   ├── app_ta.arb      (Tamil translations)
│   └── app_localizations.dart (Auto-generated)
```

## 🔄 How to Use

### Before (Old System):
```dart
import 'core/localization/app_localizations.dart';

Text(AppLocalizations.of(context)?.appName ?? 'SenseAI')
```

### After (New System):
```dart
import 'l10n/app_localizations.dart';

Text(AppLocalizations.of(context).appName)
```

## 🎯 Key Changes

1. **Import Path Changed:**
   - Old: `import 'core/localization/app_localizations.dart';`
   - New: `import 'l10n/app_localizations.dart';`

2. **No More Null Safety:**
   - Old: `AppLocalizations.of(context)?.appName ?? 'fallback'`
   - New: `AppLocalizations.of(context).appName` (always returns a string)

3. **CamelCase Keys:**
   - Old: `translate('app_name')`
   - New: `appName` (auto-generated getter)

4. **Placeholders:**
   - Old: `translate('ai_question_1').replaceAll('{childName}', name)`
   - New: `AppLocalizations.of(context).aiQuestion1(childName: name)`

## 📝 Example Usage

### Basic Text:
```dart
Text(AppLocalizations.of(context).welcome)
```

### With Placeholders:
```dart
Text(AppLocalizations.of(context).aiQuestion1(childName: 'John'))
```

### In Buttons:
```dart
ElevatedButton(
  onPressed: () {},
  child: Text(AppLocalizations.of(context).login),
)
```

## ⚙️ Language Settings

### Access Settings:
- Tap the **Settings icon** (⚙️) in the dashboard app bar
- Or navigate to `SettingsScreen` programmatically

### Features:
- ✅ Auto-detect device language (enabled by default)
- ✅ Manual language selection (English, Sinhala, Tamil)
- ✅ Language preference saved to SharedPreferences
- ✅ Instant language switching

## 🔧 Adding New Translations

1. **Add to `lib/l10n/app_en.arb`:**
```json
{
  "newKey": "New Translation",
  "@@locale": "en"
}
```

2. **Add to `lib/l10n/app_si.arb`:**
```json
{
  "newKey": "නව පරිවර්තනය",
  "@@locale": "si"
}
```

3. **Add to `lib/l10n/app_ta.arb`:**
```json
{
  "newKey": "புதிய மொழிபெயர்ப்பு",
  "@@locale": "ta"
}
```

4. **Run code generation:**
```bash
flutter gen-l10n
```

5. **Use in code:**
```dart
Text(AppLocalizations.of(context).newKey)
```

## 🚀 Auto-Detection

The app automatically detects your device language on first launch:
- Device set to Sinhala → App uses Sinhala
- Device set to Tamil → App uses Tamil
- Device set to other → App uses English

You can disable auto-detect in Settings to manually select a language.

## 📱 Settings Screen

Access via:
- Dashboard → Settings icon (⚙️) in app bar
- Or: `Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()))`

Features:
- Toggle auto-detect on/off
- Select language manually
- See current language
- Instant language change

## ⚠️ Migration Checklist

- [x] ARB files created (app_en.arb, app_si.arb, app_ta.arb)
- [x] Code generation enabled (pubspec.yaml)
- [x] Main.dart updated to use generated localizations
- [x] Language preference service created
- [x] Settings screen created
- [x] Auto-detect functionality added
- [ ] Update all screens to use new `AppLocalizations.of(context)`
- [ ] Remove old `core/localization/app_localizations.dart` (after migration)
- [ ] Remove old `core/services/localization_service.dart` (after migration)

## 🔍 Finding Translation Keys

All keys are converted from snake_case to camelCase:
- `app_name` → `appName`
- `ai_question_1` → `aiQuestion1`
- `child_name` → `childName`

Use autocomplete in your IDE to find available keys!

## 🎨 Font Support

Fonts are automatically applied based on language:
- Sinhala → IskoolaPota font
- Tamil → Bamini font
- English → System default

Configured in `main.dart` → `_getFontFamily()`.

## 📚 Next Steps

1. Update remaining screens to use `AppLocalizations.of(context)`
2. Test all three languages
3. Verify all translations appear correctly
4. Remove old localization files after migration complete






