# System Architecture - Mobile App & Admin Portal

## Overview

The system consists of two separate applications that share the same backend:

1. **Mobile App (Flutter)** - For clinicians to assess children
2. **Admin Portal (React Web)** - For administrators to manage and view data

## User Roles

### 1. Clinicians (Mobile App Users)
- **Registration**: Clinicians register via the mobile app
- **Login**: Use 4-digit PIN (e.g., `1234`, `5678`)
- **Access**: Can only see their own data
- **Features**:
  - Register with name, hospital, and 4-digit PIN
  - Login with PIN
  - Add children
  - Conduct assessments
  - View their own assessment history

### 2. Administrator (Web Portal)
- **Login**: Fixed PIN `admin123`
- **Access**: Full system access
- **Features**:
  - View all clinicians (who registered via mobile app)
  - View all children
  - See which clinician examined which children
  - View complete assessment history for any child
  - Export data
  - Manage system-wide data

## Data Flow

```
Mobile App (Flutter)
    ↓
Clinician registers → Backend API → Firebase
    ↓
Clinician logs in → Backend API → Validates PIN
    ↓
Clinician adds child → Backend API → Stores with clinician_id
    ↓
Clinician conducts assessment → Backend API → Stores session data

Admin Portal (React)
    ↓
Admin logs in with admin123 → Backend API → Returns admin role
    ↓
Admin views clinicians → Backend API → Gets all clinicians from Firebase
    ↓
Admin views children → Backend API → Gets all children
    ↓
Admin views doctor-child relations → Backend API → Matches clinician_id
```

## Key Features

### Admin Portal Features

1. **Clinicians List** (`/doctors`)
   - Shows all clinicians who registered via mobile app
   - Filter by hospital (default: LRH)
   - View clinician profiles
   - See patient count per clinician

2. **Doctor-Child Relations** (`/admin/doctor-relations`)
   - Shows which clinician examined which children
   - Table view with all relationships
   - Filter and search capabilities

3. **Child Profiles** (`/children/:id`)
   - Complete assessment history (all components)
   - Shows "Examined By" (clinician name)
   - Table and Timeline views
   - Administrative information (admin only)

4. **Component Dashboards**
   - Cognitive Flexibility (`/cognitive`)
   - RRB (`/rrb`)
   - Auditory (`/auditory`)
   - Visual (`/visual`)

## Backend API

### Clinicians Endpoints
- `POST /api/clinicians/register` - Register new clinician (from mobile app)
- `POST /api/clinicians/login` - Login (supports admin123 and clinician PINs)
- `GET /api/clinicians` - Get all clinicians (admin only)
- `GET /api/clinicians/:id` - Get clinician by ID

### Children Endpoints
- `GET /api/children` - Get all children
- `GET /api/children/:id` - Get child by ID
- `GET /api/children/clinician/:clinicianId` - Get children by clinician

### Sessions Endpoints
- `GET /api/sessions` - Get all sessions
- `GET /api/sessions/child/:childId` - Get sessions by child

## Authentication

### Mobile App (Clinicians)
- Register: Name, Hospital, 4-digit PIN
- Login: 4-digit PIN
- PIN is hashed with bcrypt before storage

### Admin Portal
- Login: `admin123` (hardcoded, cannot be changed)
- Bypasses all validation
- Returns admin role immediately

## Important Notes

1. **Clinicians are mobile app users** - They register and use the Flutter app
2. **Admin is web portal user** - Uses React web app with admin123
3. **Same backend** - Both apps connect to the same Node.js/Firebase backend
4. **Data sharing** - Admin can see all data, clinicians see only their own
5. **clinician_id** - Links children to the clinician who added them

## Database Structure

### Clinicians Collection (Firebase)
```
{
  id: "auto-generated",
  name: "Dr. John Doe",
  hospital: "LRH",
  pin_hash: "bcrypt_hash",
  created_at: timestamp,
  updated_at: timestamp
}
```

### Children Collection (Firebase)
```
{
  id: "uuid",
  name: "Child Name",
  clinician_id: "clinician_id", // Links to clinician
  clinician_name: "Dr. John Doe", // For display
  ...
}
```

### Sessions Collection (Firebase)
```
{
  id: "uuid",
  child_id: "child_id",
  session_type: "color_shape" | "frog_jump" | ...
  ...
}
```


