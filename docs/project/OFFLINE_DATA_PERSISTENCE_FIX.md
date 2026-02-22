# Offline Data Persistence Fix

## 🔴 Problem

When adding data (e.g., ASD child details) in offline mode, closing the app, and reopening before connecting to the internet, the added data disappears.

## 🔍 Root Cause

The issue was in `getAllChildren()` method:

1. **When app reopens**, `getAllChildren()` tries to fetch from backend first
2. **If backend is unreachable**, it should fall back to local data
3. **BUT** - If the API call succeeds but returns empty data, or if there's a timeout issue, it calls `_replaceChildrenLocal()` which **DELETES all local children** and replaces them with server data
4. **Result**: Offline entries are lost!

## ✅ Solution

### Changes Made:

1. **Always load local data first** - Preserves offline entries immediately
2. **Check connectivity with timeout** - Quick health check before attempting sync
3. **Merge instead of replace** - Preserves offline entries when merging with server data
4. **Better error handling** - Always returns local data on any error

### Code Changes:

#### Before (Buggy):
```dart
static Future<List<Map<String, dynamic>>> getAllChildren() async {
  try {
    final children = await ApiService.getAllChildren();
    // ... format data
    await _replaceChildrenLocal(formatted); // ❌ DELETES local data!
    return formatted;
  } catch (_) {
    return await _getChildrenLocal();
  }
}
```

#### After (Fixed):
```dart
static Future<List<Map<String, dynamic>>> getAllChildren() async {
  // ✅ Always load local data first
  final localChildren = await _getChildrenLocal();
  
  try {
    // Quick health check with timeout
    final isOnline = await ApiService.healthCheck()
        .timeout(const Duration(seconds: 3), onTimeout: () => false);
    
    if (isOnline) {
      // Fetch from backend
      final children = await ApiService.getAllChildren()
          .timeout(const Duration(seconds: 10));
      // ✅ Merge instead of replace
      await _mergeChildrenLocal(formatted, localChildren);
      return await _getChildrenLocal();
    } else {
      // ✅ Offline - return local data
      return localChildren;
    }
  } catch (e) {
    // ✅ Any error - return local data
    return localChildren;
  }
}
```

### New Merge Function:

```dart
/// Merge remote and local children, preserving offline entries
static Future<void> _mergeChildrenLocal(
    List<Map<String, dynamic>> remoteChildren,
    List<Map<String, dynamic>> localChildren) async {
  // Identify offline entries (IDs starting with 'child_')
  final offlineChildren = localChildren.where((child) {
    final id = child['id'] as String;
    return id.startsWith('child_');
  }).toList();
  
  // Update/insert remote children
  for (final remoteChild in remoteChildren) {
    batch.insert('children', remoteChild,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
  
  // Preserve offline entries
  for (final offlineChild in offlineChildren) {
    batch.insert('children', offlineChild,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
```

## 🧪 Testing

### Test Scenario:
1. ✅ Turn off internet/WiFi
2. ✅ Add a child (ASD or Control)
3. ✅ Close the app completely
4. ✅ Reopen the app (still offline)
5. ✅ **Expected**: Child should still be visible ✅
6. ✅ Turn on internet
7. ✅ Data should sync to backend

### Verification:
- Offline entries have IDs starting with `child_` (from `_offlineId('child')`)
- These entries are preserved when merging with server data
- When online, offline entries sync to backend and get real IDs

## 📝 Key Points

1. **Offline-first approach**: Always load local data first
2. **Preserve offline entries**: Never delete local data when syncing
3. **Merge strategy**: Combine remote and local data intelligently
4. **Timeout protection**: Prevent long waits when offline
5. **Error resilience**: Always return local data on any error

## 🎯 Impact

- ✅ **Data persistence**: Offline entries are never lost
- ✅ **Better UX**: App works immediately even when offline
- ✅ **Reliable sync**: Data syncs when connection is restored
- ✅ **No data loss**: Critical for clinical data collection

---

*Last Updated: 2024*  
*Status: Fixed - Offline data now persists correctly*



