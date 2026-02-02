# Test Suite Documentation

## 📋 Overview

This directory contains comprehensive tests for the SenseAI ASD Screening Tool pilot project.

## 📁 Test Structure

```
test/
├── unit/                    # Unit tests for individual components
│   ├── services/           # Service layer tests
│   │   ├── api_service_test.dart
│   │   ├── storage_service_test.dart
│   │   ├── csv_export_test.dart
│   │   └── offline_sync_test.dart
│   └── models/             # Data model tests
│       └── child_test.dart
├── widget/                  # Widget tests for UI components
│   └── cognitive_dashboard_test.dart
├── integration/             # Integration tests for full flows
│   └── app_flow_test.dart
└── widget_test.dart         # Basic app launch test
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

### Run Tests with Coverage
```bash
flutter test --coverage
```

### View Coverage Report
```bash
# After running with coverage
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in browser
```

## 📊 Test Coverage Goals

- **Target**: 70%+ code coverage
- **Critical Services**: 80%+ coverage
- **UI Components**: 60%+ coverage

## ✅ Test Categories

### 1. Unit Tests
- **Purpose**: Test individual functions and classes in isolation
- **Location**: `test/unit/`
- **Examples**:
  - API service methods
  - Storage service operations
  - Data model serialization
  - Utility functions

### 2. Widget Tests
- **Purpose**: Test UI components and user interactions
- **Location**: `test/widget/`
- **Examples**:
  - Screen rendering
  - Button clicks
  - Form validation
  - Navigation flows

### 3. Integration Tests
- **Purpose**: Test complete user flows end-to-end
- **Location**: `test/integration/`
- **Examples**:
  - Complete assessment flow
  - Data synchronization
  - CSV export workflow
  - Offline to online transition

## 🧪 Test Scenarios Covered

### Data Collection
- ✅ Child profile creation
- ✅ Session creation
- ✅ Trial data recording
- ✅ Data validation

### Data Management
- ✅ Local storage (SQLite)
- ✅ Cloud synchronization
- ✅ Offline queue management
- ✅ Data export (CSV)

### User Flows
- ✅ Dashboard navigation
- ✅ Assessment completion
- ✅ Results display
- ✅ Data export

### Error Handling
- ✅ Network failures
- ✅ Invalid data
- ✅ Missing fields
- ✅ Edge cases

## 📝 Writing New Tests

### Unit Test Template
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceName', () {
    setUp(() {
      // Setup before each test
    });

    test('should do something', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

### Widget Test Template
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('should display widget', (WidgetTester tester) async {
    await tester.pumpWidget(MyWidget());
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

## 🔧 Test Dependencies

- `flutter_test` - Core testing framework
- `mockito` - Mocking HTTP and other dependencies
- `mocktail` - Alternative mocking library
- `sqflite_common_ffi` - SQLite testing support

## 📈 Coverage Reports

After running tests with coverage:
1. Generate HTML report: `genhtml coverage/lcov.info -o coverage/html`
2. Open `coverage/html/index.html` in browser
3. Review coverage by file and function

## 🎯 Testing Best Practices

1. **Test One Thing**: Each test should verify one behavior
2. **Use Descriptive Names**: Test names should describe what they test
3. **Arrange-Act-Assert**: Structure tests clearly
4. **Mock External Dependencies**: Don't rely on network/database in unit tests
5. **Test Edge Cases**: Include boundary conditions and error cases
6. **Keep Tests Fast**: Unit tests should run quickly
7. **Maintain Tests**: Update tests when code changes

## 🚨 Known Limitations

- Some tests require actual backend (marked for future mocking)
- Integration tests need real device/emulator
- Some UI tests may be flaky (need stabilization)

---

*Last Updated: 2024*




