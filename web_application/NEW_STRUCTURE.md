# New Admin Portal Structure

## Overview

The admin portal has been restructured according to your requirements with a component-based approach and enhanced admin features.

## Main Dashboard

The main dashboard now displays **4 component buttons**:

1. **Cognitive Flexibility** → Navigates to `/cognitive`
2. **RRB (Restricted Repetitive Behaviors)** → Navigates to `/rrb`
3. **Auditory Checking** → Navigates to `/auditory`
4. **Visual Checking** → Navigates to `/visual`

Each button shows:
- Component icon
- Component name
- Total number of sessions for that component
- Click to navigate to component-specific dashboard

## Component Dashboards

### Cognitive Dashboard (`/cognitive`)

**Features:**
- Shows **only children who have cognitive assessments**
- Statistics cards:
  - Total children with cognitive assessments
  - Total cognitive sessions
  - Color-Shape Game count
  - Frog Jump Game count
- Children cards grid:
  - Each card shows child profile
  - Number of cognitive sessions
  - Click to view full child profile
- Recent sessions table:
  - Last 10 cognitive sessions
  - Shows child name, session type, risk level, date
  - Quick view button to session details

**Cognitive Session Types:**
- `color_shape` - Color-Shape Game (DCCS)
- `frog_jump` - Frog Jump Game (Go/No-Go)
- `ai_doctor_bot` - AI Questionnaire
- `manual_assessment` - Manual Assessment

### Other Component Dashboards

Currently using the same structure as Cognitive Dashboard. Can be customized later for:
- RRB Dashboard (`/rrb`)
- Auditory Dashboard (`/auditory`)
- Visual Dashboard (`/visual`)

## Child Profile (`/children/:id`)

**Shows ALL sessions for the child** (not filtered by component):

### Child Information Section:
- Name, Code, Age, Gender
- Study Group (ASD/Control)
- ASD Level (if applicable)
- **Examined By** (Doctor name - if available)

### All Assessments Table:
- **Session Type** - Full name of assessment
- **Component** - Color-coded chip (Cognitive, RRB, Auditory, Visual)
- **Risk Level** - Color-coded chip (High/Moderate/Low)
- **Risk Score** - Numerical score
- **Date** - When assessment was completed
- **Actions** - View details button

**Key Feature:** Shows ALL assessments regardless of component type, so you can see the complete assessment history for each child.

## Admin Features

### 1. Doctors Management (`/doctors`)

**Admin Only:**
- View all doctors registered under selected hospital (default: LRH)
- Filter by hospital
- Search by name
- View doctor profiles
- See patient count per doctor

### 2. Doctor-Child Relations (`/admin/doctor-relations`)

**Admin Only - NEW FEATURE:**

Shows which doctor examined which children:

**Table Columns:**
- Doctor Name
- Hospital
- Child Name
- Child Code
- Age
- Group (ASD/Control)
- Registered Date
- Actions (View child profile)

**Features:**
- Filter by hospital
- Search by doctor name, child name, or code
- Summary showing total examinations and number of doctors
- Direct link to child profile

**Use Case:** Admin can see:
- Which doctor examined which children
- How many children each doctor has examined
- Complete examination history

## Navigation Structure

### Admin Menu:
- Dashboard
- Children
- Cognitive
- Sessions
- **Doctors** (Admin only)
- **Doctor Relations** (Admin only)
- Export
- Settings

### Clinician Menu:
- Dashboard
- Children
- Cognitive
- Sessions
- Export
- Settings

## Data Flow

### Component-Based Filtering:
1. Main Dashboard → Click component button
2. Component Dashboard → Shows children with that component's assessments
3. Child Profile → Shows ALL assessments (all components)

### Admin Tracking:
1. When child is created → `clinician_id` is stored
2. Admin can view → Doctor-Child Relations page
3. Child profile shows → "Examined By" field

## Component Classification

Sessions are automatically classified into components:

- **Cognitive:** `color_shape`, `frog_jump`, `ai_doctor_bot`, `manual_assessment`
- **RRB:** `rrb`
- **Auditory:** `auditory`
- **Visual:** `visual`

## Future Enhancements

1. **RRB Dashboard:** Customize for RRB-specific data
2. **Auditory Dashboard:** Customize for auditory assessments
3. **Visual Dashboard:** Customize for visual assessments
4. **Component Comparison:** Compare performance across components
5. **Doctor Analytics:** Statistics per doctor (admin only)

## Key Improvements

✅ **Component-based navigation** - Easy access to each assessment type
✅ **Complete child history** - All assessments visible in one place
✅ **Admin oversight** - See doctor-child relationships
✅ **Better organization** - Component dashboards for focused views
✅ **Enhanced child profiles** - Shows component type for each assessment







