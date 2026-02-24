// Compatibility re-export.
//
// Many parts of the app import `package:senseai/l10n/app_localizations.dart` or
// relative `../../l10n/app_localizations.dart`, but the actual implementation
// lives under `lib/core/localization/app_localizations.dart`.
//
// Keeping this small re-export avoids touching lots of files.

export '../core/localization/app_localizations.dart';

