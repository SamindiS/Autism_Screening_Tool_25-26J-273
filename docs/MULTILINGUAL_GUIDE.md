# Multilingual Support Guide - SenseAI

## Overview

SenseAI supports **three languages**:
- **English** (en)
- **Sinhala** (si) - සිංහල
- **Tamil** (ta) - தமிழ்

## Architecture Decision: Frontend vs Backend

### ✅ **Frontend Approach (Current Implementation)**

**Why Frontend is Better for This App:**

1. **Offline Functionality** - Clinical apps need to work without internet
2. **Performance** - No network latency, instant language switching
3. **Standard Practice** - Flutter's built-in localization system
4. **User Experience** - Immediate response, no loading delays
5. **Data Privacy** - Translations stay on device

**Implementation:**
- JSON translation files stored in `assets/translations/`
- Loaded at app startup
- Cached in memory for fast access
- Works completely offline

### 🔄 **Backend API Approach (Optional Enhancement)**

**When Backend API Makes Sense:**

1. **Dynamic Content Updates** - If translations change frequently
2. **Centralized Management** - Single source of truth for all clinics
3. **A/B Testing** - Different translations for different regions
4. **Analytics** - Track which languages are used most

**Hybrid Approach (Best of Both):**
```dart
// Load default translations from assets (offline)
await LocalizationService.load(locale);

// Optionally sync with backend for updates
if (hasInternet) {
  final updates = await api.getTranslationUpdates(locale);
  LocalizationService.mergeTranslations(updates);
}
```

## File Structure

```
assets/
  translations/
    en.json      # English translations
    si.json      # Sinhala translations
    ta.json      # Tamil translations

lib/
  core/
    localization/
      app_localizations.dart    # Localization delegate
      l10n.dart                 # Supported locales
    services/
      localization_service.dart # Translation loader
    providers/
      language_provider.dart    # Language state management
  widgets/
    language_selector.dart     # Language switcher widget
```

## Usage Examples

### Method 1: Using AppLocalizations (Recommended)

```dart
import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.cognitiveFlexibility ?? 'Cognitive Flexibility'),
      ),
      body: Text(l10n?.welcome ?? 'Welcome'),
    );
  }
}
```

### Method 2: Using Extension (Quick Access)

```dart
import '../../core/services/localization_service.dart';

// In your widget
Text('welcome'.tr)  // Automatically translates
Text('add_child'.trWithFallback('Add Child'))  // With fallback
```

### Method 3: Direct Service Call

```dart
import '../../core/services/localization_service.dart';

Text(LocalizationService.translate('dashboard'))
```

## Adding New Translations

### Step 1: Add to English JSON
```json
// assets/translations/en.json
{
  "new_key": "New Translation"
}
```

### Step 2: Add to Sinhala JSON
```json
// assets/translations/si.json
{
  "new_key": "නව පරිවර්තනය"
}
```

### Step 3: Add to Tamil JSON
```json
// assets/translations/ta.json
{
  "new_key": "புதிய மொழிபெயர்ப்பு"
}
```

### Step 4: Use in Code
```dart
Text(l10n?.translate('new_key') ?? 'New Translation')
```

## Language Switching

### Using Language Selector Widget

```dart
import '../../widgets/language_selector.dart';

AppBar(
  actions: [
    const LanguageSelector(),  // Adds language switcher
  ],
)
```

### Programmatically

```dart
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';

final languageProvider = Provider.of<LanguageProvider>(context);
await languageProvider.setLocale(Locale('si'));  // Switch to Sinhala
```

## Font Support

The app automatically uses appropriate fonts:
- **English**: System default
- **Sinhala**: IskoolaPota font
- **Tamil**: Bamini font

Fonts are configured in `pubspec.yaml` and applied automatically in `main.dart`.

## Backend Integration (Future Enhancement)

If you want to add backend API support later:

### Express/Node.js API Endpoint

```javascript
// routes/translations.js
router.get('/translations/:locale', async (req, res) => {
  const { locale } = req.params;
  const translations = await TranslationModel.find({ locale });
  res.json(translations);
});
```

### Flutter Sync Service

```dart
// lib/core/services/translation_sync_service.dart
class TranslationSyncService {
  static Future<void> syncWithBackend(Locale locale) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/translations/${locale.languageCode}'),
      );
      final updates = json.decode(response.body);
      LocalizationService.mergeTranslations(updates);
    } catch (e) {
      // Fallback to local translations
      print('Sync failed, using local translations');
    }
  }
}
```

## Best Practices

1. **Always provide fallback** - Use `??` operator for null safety
2. **Use descriptive keys** - `child_name` not `cn`
3. **Keep translations consistent** - Same terminology across app
4. **Test all languages** - Ensure UI doesn't break with longer text
5. **Consider RTL** - If adding Arabic/Hebrew later

## Translation Keys Reference

Common keys available:
- `app_name`, `welcome`, `login`, `register`, `logout`
- `dashboard`, `cognitive_flexibility`, `rule_switching`
- `add_child`, `view_all`, `recent_children`
- `total_children`, `completed`, `pending`, `today`
- `statistics`, `quick_actions`, `search_children`
- And many more... (see `assets/translations/en.json`)

## Troubleshooting

### Translations not showing?
1. Check JSON files are in `assets/translations/`
2. Verify `pubspec.yaml` includes `assets/translations/`
3. Run `flutter pub get`
4. Restart app (hot reload may not pick up asset changes)

### Font not displaying correctly?
1. Ensure font files exist in `assets/fonts/`
2. Check font names match in `pubspec.yaml` and code
3. Verify font files are valid TTF files

### Language not persisting?
- Language preference is saved in SharedPreferences
- Check if `LanguageProvider` is properly initialized
- Verify `setLocale` is being called correctly

## Summary

✅ **Current Implementation**: Frontend-only, offline-first
✅ **Languages**: English, Sinhala, Tamil
✅ **Storage**: JSON files in assets
✅ **State Management**: Provider pattern
✅ **Future**: Can add backend sync if needed

This approach gives you the best user experience while keeping the option to enhance with backend API later if needed.

