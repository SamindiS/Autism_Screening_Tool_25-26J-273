# Automatic ASD Child ID Generation

## ✅ Feature Implemented

ASD children now automatically get sequential IDs in the format **LRH-###** (e.g., LRH-001, LRH-002, LRH-003, etc.).

---

## 🎯 How It Works

### 1. **Automatic ID Generation**
- When you select **ASD Group** for a new child, the system automatically:
  - Queries all existing ASD children
  - Finds the highest LRH-### number
  - Generates the next sequential ID
  - Auto-fills the Child Code field

### 2. **ID Format**
- **Format**: `LRH-###` (3 digits, zero-padded)
- **Examples**: 
  - First child: `LRH-001`
  - Second child: `LRH-002`
  - 15th child: `LRH-015`
  - 100th child: `LRH-100`

### 3. **Field Behavior**
- **For ASD Children (New)**:
  - Child Code field is **read-only** (auto-generated)
  - Shows hint: "Auto-generated (e.g., LRH-001)"
  - Field has grey background to indicate it's auto-filled

- **For Control Group**:
  - Child Code field is **editable** (manual entry)
  - Shows hint: "e.g., PRE-112"
  - User enters their own ID format

- **For Editing Existing Children**:
  - Child Code field is **editable** (can modify if needed)

---

## 🔍 Technical Details

### ID Generation Logic

```dart
Future<void> _generateNextAsdId() async {
  // 1. Get all children from database
  final allChildren = await StorageService.getAllChildren();
  
  // 2. Filter only ASD children
  final asdChildren = allChildren.where((child) {
    final groupStr = child['study_group'] ?? child['group'] ?? 'typically_developing';
    return groupStr == 'asd';
  }).toList();
  
  // 3. Extract LRH-### pattern and find max number
  final lrhPattern = RegExp(r'^LRH-(\d+)$', caseSensitive: false);
  int maxNumber = 0;
  
  for (final child in asdChildren) {
    final childCode = (child['child_code'] ?? '').trim();
    final match = lrhPattern.firstMatch(childCode);
    if (match != null) {
      final number = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (number > maxNumber) {
        maxNumber = number;
      }
    }
  }
  
  // 4. Generate next ID
  final nextNumber = maxNumber + 1;
  final nextId = 'LRH-${nextNumber.toString().padLeft(3, '0')}';
  
  // 5. Auto-fill the field
  _childCodeCtrl.text = nextId;
}
```

### When ID is Generated

1. **On Screen Load** (if ASD group is default):
   - Called in `initState()` for new children

2. **When Group Changes to ASD**:
   - Called in `_onGroupChanged()` when user selects ASD group

3. **Validation**:
   - Validates that ASD child codes match `LRH-###` format
   - Shows error if format is incorrect

---

## 📱 User Experience

### Adding New ASD Child:

1. Open "Add Child" screen
2. Select **"ASD Group"**
3. **Child Code field automatically fills** with next sequential ID (e.g., `LRH-016`)
4. Field is **read-only** (grey background)
5. Continue filling other fields
6. Save child

### Adding Control Group Child:

1. Open "Add Child" screen
2. Select **"Control Group"**
3. **Child Code field is empty** and editable
4. Enter your own ID (e.g., `PRE-112`)
5. Continue filling other fields
6. Save child

---

## ✅ Benefits

1. **No Manual Counting**: System automatically finds the next number
2. **No Duplicates**: Sequential numbering prevents ID conflicts
3. **Consistent Format**: All ASD children follow `LRH-###` pattern
4. **User-Friendly**: Field is read-only, so users can't accidentally change it
5. **Works Offline**: Uses local database, so it works even when offline

---

## 🔧 Edge Cases Handled

1. **No Existing ASD Children**: Starts with `LRH-001`
2. **Non-Sequential IDs**: Finds the highest number, not just count
   - If you have LRH-001, LRH-003, LRH-005, next will be LRH-006
3. **Mixed Formats**: Only counts IDs matching `LRH-###` pattern
   - Ignores other formats (e.g., `PRE-001`, `ABC-123`)
4. **Case Insensitive**: Works with `lrh-001`, `LRH-001`, `Lrh-001`
5. **Offline Mode**: Uses local database, so it works without internet

---

## 📝 Notes

- **Control Group IDs**: Still manual entry (e.g., `PRE-112`)
- **Editing Existing Children**: Child Code field is editable (can modify if needed)
- **ID Format Validation**: Validates `LRH-###` format for ASD children
- **Database Query**: Queries both local and server data (if online)

---

## 🚀 Usage Example

**Scenario**: You have 15 ASD children (LRH-001 through LRH-015)

**Adding 16th ASD Child**:
1. Select "ASD Group"
2. System automatically generates: `LRH-016`
3. Field is read-only
4. Continue with other fields

**Result**: New child saved with ID `LRH-016`

---

**Feature is now live and ready to use!** 🎉

