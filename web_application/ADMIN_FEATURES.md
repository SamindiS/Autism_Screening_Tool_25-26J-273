# Admin Portal Features

## Admin Access

- **Admin PIN:** `admin123` (fixed, cannot be changed)
- **Admin Role:** Separate from doctors/clinicians
- **Admin Features:** Full access to all data, doctor management

## Features Implemented

### 1. **Admin Dashboard**
- Statistics overview
- Charts and visualizations
- Risk level distribution
- Group breakdown (ASD vs Control)

### 2. **Doctors Management** (Admin Only)
- View all doctors registered under LRH (Lady Ridgeway Hospital)
- Filter by hospital
- View doctor profiles
- See patient count per doctor
- Search doctors by name

### 3. **Cognitive Tab**
- Shows only cognitive flexibility related assessments:
  - Color-Shape Game (DCCS) - Primary cognitive flexibility test
  - Frog Jump Game (Go/No-Go) - Inhibitory control
  - AI Questionnaire - For ages 2-3.5
  - Manual Assessment - Clinician observations
- Filter by assessment type
- Separate from general sessions view

### 4. **Children Management**
- View all children
- Search and filter
- View child details
- Assessment history

### 5. **Sessions Management**
- View all assessment sessions
- Filter by type, date, risk level
- View detailed session results

### 6. **Data Export**
- CSV export for research
- PDF reports
- Date range filtering

## Language Support

- English (en)
- Sinhala (si) - සිංහල
- Tamil (ta) - தமிழ்

## Navigation Structure

### Admin Menu:
- Dashboard
- Doctors (Admin only)
- Children
- Cognitive (Cognitive Flexibility data)
- Sessions (All assessments)
- Export
- Settings

### Clinician Menu:
- Dashboard
- Children
- Cognitive
- Sessions
- Export
- Settings

## Backend Updates

### Admin Login
- PIN: `admin123` (hardcoded)
- Returns admin role and full access

### Multiple Clinicians Support
- Backend now supports multiple clinicians
- Each clinician has their own PIN (4 digits)
- Clinicians can be filtered by hospital
- Admin can view all clinicians

## Future Enhancements

- [ ] Hospital-based data filtering (when multiple hospitals added)
- [ ] Doctor registration from admin portal
- [ ] Advanced analytics for cognitive data
- [ ] Comparison charts (ASD vs Control groups)





