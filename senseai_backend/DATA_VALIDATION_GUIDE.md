 # Data Validation, Integrity, and Recovery Guide

## Overview

This system now includes comprehensive data validation, integrity checking, and recovery tools to ensure data quality and system reliability.

---

## 🔍 Enhanced Data Validation

### What It Does

Beyond basic Joi schema validation, the enhanced validation service checks:

1. **Business Rules**
   - Age appropriateness for assessments
   - Data consistency (e.g., age calculations)
   - Relationship validation (e.g., child exists before session)

2. **Data Ranges**
   - Valid timestamps
   - Reasonable reaction times
   - Appropriate risk scores

3. **Completeness**
   - Required fields for specific session types
   - Missing critical data

### Usage

#### Validate Child Data
```javascript
POST /api/validation/child
Body: {
  "childData": {
    "name": "John Doe",
    "date_of_birth": 1234567890000,
    "gender": "male",
    "language": "en",
    // ... other fields
  },
  "isUpdate": false
}

Response: {
  "success": true,
  "valid": true,
  "errors": [],
  "warnings": ["Child age (1.5 years) is below minimum screening age"]
}
```

#### Validate Session Data
```javascript
POST /api/validation/session
Body: {
  "sessionData": {
    "child_id": "child123",
    "session_type": "frog_jump",
    "start_time": 1234567890000,
    // ... other fields
  },
  "isUpdate": false
}
```

#### Validate Trial Data
```javascript
POST /api/validation/trial
Body: {
  "trialData": {
    "session_id": "session123",
    "trial_number": 1,
    "reaction_time": 500,
    // ... other fields
  }
}
```

---

## 🔒 Data Integrity Checks

### What It Checks

1. **Orphaned Records**
   - Sessions without valid children
   - Trials without valid sessions
   - Children with invalid clinician references

2. **Data Consistency**
   - Timestamp validity
   - Risk score/level consistency
   - Age calculation accuracy

3. **Missing Required Data**
   - Required fields for children
   - Required fields for sessions

### Usage

#### Run All Integrity Checks
```javascript
GET /api/integrity/check

Response: {
  "success": true,
  "timestamp": 1234567890000,
  "checks": {
    "orphanedSessions": [...],
    "orphanedTrials": [...],
    "invalidClinicianReferences": [...],
    "dataConsistency": [...],
    "missingData": [...]
  },
  "summary": {
    "total": 5,
    "critical": 0,
    "high": 2,
    "medium": 2,
    "low": 1
  }
}
```

#### Check Specific Issues
```javascript
// Orphaned sessions
GET /api/integrity/orphaned-sessions

// Orphaned trials
GET /api/integrity/orphaned-trials

// Data consistency
GET /api/integrity/consistency
```

### Issue Severity Levels

- **Critical**: System errors that prevent checks from running
- **High**: Data integrity issues that need immediate attention
- **Medium**: Data quality issues that should be addressed
- **Low**: Minor inconsistencies or warnings

---

## 💾 Data Recovery & Backup

### Features

1. **Automatic Backups**
   - Created before major operations (create, update, delete)
   - Timestamped backup files
   - JSON format for easy inspection

2. **Manual Backups**
   - Create backups on demand
   - Named backups for specific operations

3. **Restore Capabilities**
   - Restore from any backup
   - Dry-run mode to preview changes
   - Selective collection restoration

4. **Backup Management**
   - List all backups
   - Delete old backups
   - Rollback to most recent backup

### Usage

#### Create Backup
```javascript
POST /api/backup/create
Body: {
  "backupName": "before-major-update" // optional
}

Response: {
  "success": true,
  "backupId": "backup-2024-01-15T10-30-00",
  "backupPath": "/path/to/backup.json",
  "stats": {
    "children": 50,
    "sessions": 200,
    "trials": 5000,
    "clinicians": 5
  },
  "timestamp": 1234567890000
}
```

#### List Backups
```javascript
GET /api/backup/list

Response: {
  "success": true,
  "backups": [
    {
      "backupId": "backup-2024-01-15T10-30-00",
      "timestamp": 1234567890000,
      "stats": {...},
      "size": 1024000
    }
  ],
  "count": 5
}
```

#### Restore Backup
```javascript
POST /api/backup/restore
Body: {
  "backupId": "backup-2024-01-15T10-30-00",
  "dryRun": false, // Set to true to preview
  "collections": ["children", "sessions"] // Optional: specific collections
}

Response: {
  "success": true,
  "restoredCount": 250,
  "stats": {...}
}
```

#### Rollback (Restore Most Recent)
```javascript
POST /api/backup/rollback

Response: {
  "success": true,
  "restoredCount": 250,
  "stats": {...}
}
```

#### Delete Backup
```javascript
DELETE /api/backup/:backupId

Response: {
  "success": true,
  "message": "Backup backup-2024-01-15T10-30-00 deleted successfully"
}
```

---

## 🔄 Automatic Integration

### Pre-Operation Backups

The system automatically creates backups before:
- Creating new children
- Creating new sessions
- Major data modifications

These backups are stored in `senseai_backend/backups/` with names like:
- `pre-create-child-1234567890000.json`
- `pre-create-session-1234567890000.json`

### Enhanced Validation in Routes

All create/update operations now include:
1. Joi schema validation (existing)
2. Enhanced business rule validation (new)
3. Pre-operation backup (new)
4. Validation warnings logged (new)

---

## 📊 Data Quality Dashboard

### Running Integrity Checks

You can run integrity checks:
1. **Manually**: Via API endpoints
2. **Scheduled**: Set up cron job or scheduled task
3. **On Demand**: From admin portal (future feature)

### Recommended Schedule

- **Daily**: Quick integrity check
- **Weekly**: Full integrity check
- **Before Major Operations**: Always run checks
- **After Data Migration**: Run full check

---

## 🛠️ Troubleshooting

### Common Issues

#### 1. Validation Errors
**Problem**: Enhanced validation fails even though Joi validation passes

**Solution**: 
- Check the `errors` array in response
- Review business rules (age ranges, relationships)
- Fix data inconsistencies

#### 2. Integrity Check Finds Issues
**Problem**: Integrity check reports orphaned records

**Solution**:
1. Review the issues list
2. Determine if data should be deleted or fixed
3. Create backup before fixing
4. Restore relationships or delete orphaned records

#### 3. Backup Fails
**Problem**: Backup creation fails

**Solution**:
- Check disk space
- Verify write permissions in `backups/` directory
- Check Firebase connection

#### 4. Restore Fails
**Problem**: Restore operation fails

**Solution**:
- Verify backup file exists and is valid JSON
- Check Firebase connection
- Try dry-run first to preview changes
- Ensure sufficient Firebase quota

---

## 📝 Best Practices

1. **Regular Backups**
   - Create backups before major operations
   - Keep backups for at least 30 days
   - Store backups in multiple locations

2. **Regular Integrity Checks**
   - Run daily quick checks
   - Run weekly full checks
   - Address high/critical issues immediately

3. **Validation**
   - Always validate data before saving
   - Review warnings even if validation passes
   - Fix data quality issues proactively

4. **Recovery Planning**
   - Test restore procedures regularly
   - Document recovery procedures
   - Keep backup files organized

---

## 🔐 Security Notes

- Backup files contain sensitive data
- Store backups securely
- Encrypt backups if storing off-site
- Limit access to backup files
- Regularly delete old backups

---

## 📚 API Reference Summary

### Validation Endpoints
- `POST /api/validation/child` - Validate child data
- `POST /api/validation/session` - Validate session data
- `POST /api/validation/trial` - Validate trial data

### Integrity Endpoints
- `GET /api/integrity/check` - Run all checks
- `GET /api/integrity/orphaned-sessions` - Check orphaned sessions
- `GET /api/integrity/orphaned-trials` - Check orphaned trials
- `GET /api/integrity/consistency` - Check data consistency

### Backup Endpoints
- `POST /api/backup/create` - Create backup
- `GET /api/backup/list` - List backups
- `POST /api/backup/restore` - Restore backup
- `POST /api/backup/rollback` - Rollback to latest
- `DELETE /api/backup/:backupId` - Delete backup

---

## 🚀 Next Steps

1. **Test the System**
   - Run integrity checks
   - Create test backups
   - Test restore procedures

2. **Integrate with Admin Portal**
   - Add integrity check dashboard
   - Add backup management UI
   - Show validation warnings

3. **Schedule Automated Checks**
   - Set up daily integrity checks
   - Schedule weekly backups
   - Monitor data quality metrics

---

**Your system now has enterprise-grade data validation, integrity checking, and recovery capabilities!** 🎉


