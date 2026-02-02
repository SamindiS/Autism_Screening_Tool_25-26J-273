# Testing Setup Instructions

## ✅ Test Suite Created

A comprehensive test suite has been created for the pilot project. Here's how to set it up and run it.

## 📋 Prerequisites

1. **Install Dependencies**
   ```bash
   flutter pub get
   ```

2. **Generate Mock Files** (if using mockito)
   ```bash
   flutter pub run build_runner build
   ```

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/unit/services/api_service_test.dart
```

### Run with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# Install lcov (if not installed)
# Windows: choco install lcov
# Mac: brew install lcov
# Linux: sudo apt-get install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
# Windows: start coverage/html/index.html
# Mac: open coverage/html/index.html
# Linux: xdg-open coverage/html/index.html
```

## 📁 Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── services/           # Service layer tests
│   ├── models/             # Data model tests
│   └── utils/              # Utility function tests
├── widget/                 # Widget tests
└── integration/           # Integration tests
```

## ⚠️ Known Issues & Fixes

### Issue 1: Missing sqflite_common_ffi
**Error**: `Target of URI doesn't exist: 'package:sqflite_common_ffi/sqflite_ffi.dart'`

**Fix**: Already added to `pubspec.yaml`. Run:
```bash
flutter pub get
```

### Issue 2: Mock Files Not Generated
**Error**: `Target of URI doesn't exist: 'api_service_test.mocks.dart'`

**Fix**: Run:
```bash
flutter pub run build_runner build
```

### Issue 3: Missing Age Parameter
**Error**: `The named parameter 'age' is required`

**Fix**: Already fixed in test files. All `saveChild` calls now include `age` parameter.

## 📊 Test Coverage Goals

- **Overall**: 70%+
- **Services**: 80%+
- **Models**: 90%+
- **UI**: 60%+

## 🎯 Next Steps

1. **Run Tests**: `flutter test`
2. **Fix Any Failures**: Update tests or code as needed
3. **Check Coverage**: `flutter test --coverage`
4. **Improve Coverage**: Add more tests for uncovered code
5. **Set Up CI/CD**: Add GitHub Actions to run tests automatically

## 📝 Test Files Created

### Unit Tests
- ✅ `test/unit/services/api_service_test.dart`
- ✅ `test/unit/services/storage_service_test.dart`
- ✅ `test/unit/services/csv_export_test.dart`
- ✅ `test/unit/services/offline_sync_test.dart`
- ✅ `test/unit/services/clinician_auth_test.dart`
- ✅ `test/unit/models/child_test.dart`
- ✅ `test/unit/utils/age_calculator_test.dart`
- ✅ `test/unit/services/session_type_normalization_test.dart`

### Widget Tests
- ✅ `test/widget/cognitive_dashboard_test.dart`
- ✅ `test/widget/game_screen_test.dart`

### Integration Tests
- ✅ `test/integration/app_flow_test.dart`
- ✅ `test/integration/data_sync_test.dart`
- ✅ `test/integration/csv_export_flow_test.dart`
- ✅ `test/integration/offline_functionality_test.dart`
- ✅ `test/integration/group_filter_test.dart`
- ✅ `test/integration/error_handling_test.dart`

## 💡 Tips

1. **Run tests frequently** during development
2. **Write tests before fixing bugs** to ensure they stay fixed
3. **Keep tests fast** - unit tests should run in seconds
4. **Mock external dependencies** - don't rely on network/database
5. **Test edge cases** - boundary conditions, null values, empty data

---

*Last Updated: 2024*  
*Status: Test Suite Ready - Run `flutter pub get` then `flutter test`*




