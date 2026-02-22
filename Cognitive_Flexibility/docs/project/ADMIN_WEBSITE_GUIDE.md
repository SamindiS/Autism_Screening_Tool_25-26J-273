# 🌐 Admin Website Development Guide
## SenseAI - Clinical Data Management Portal

**Purpose:** Web-based admin dashboard for managing clinical data, viewing reports, and exporting research data.

---

## 📋 Table of Contents

1. [Features Overview](#features-overview)
2. [Technology Stack Options](#technology-stack-options)
3. [Language Support](#language-support)
4. [Architecture Design](#architecture-design)
5. [Implementation Guide](#implementation-guide)
6. [Security Considerations](#security-considerations)
7. [UI/UX Recommendations](#uiux-recommendations)

---

## 🎯 Features Overview

### Core Features (Must Have)

#### 1. **Dashboard & Analytics** 📊
- **Statistics Overview**
  - Total children registered
  - Total assessments completed
  - ASD vs Control group breakdown
  - Risk level distribution (High/Moderate/Low)
  - Assessment completion rate
  - Recent activity timeline

- **Charts & Visualizations**
  - Age distribution chart
  - Gender distribution
  - Assessment type breakdown
  - Risk score distribution histogram
  - Completion rate over time
  - Clinician activity chart

#### 2. **Child Management** 👶
- **View All Children**
  - Table with search and filters
  - Columns: Name, Code, Age, Gender, Group, Risk Level, Last Assessment
  - Sortable columns
  - Pagination (50 per page)

- **Child Details View**
  - Full profile information
  - Assessment history
  - Game results summary
  - Risk assessment timeline
  - Download child report (PDF)

- **Child Operations**
  - Edit child information
  - Delete child (with confirmation)
  - Add new child (manual entry)
  - Export child data

#### 3. **Assessment Management** 📝
- **View All Sessions**
  - List of all assessments
  - Filter by: Child, Date, Type, Risk Level
  - Search functionality
  - Status indicators (Complete/Incomplete)

- **Session Details**
  - Full assessment results
  - Game performance metrics
  - ML features extracted
  - Clinician reflection notes
  - Risk score calculation
  - Download session report

#### 4. **Data Export** 📥
- **CSV Export**
  - Export all children data
  - Export assessment results
  - Export ML features for training
  - Custom date range selection
  - Anonymized export option

- **PDF Reports**
  - Individual child reports
  - Assessment summary reports
  - Research data summary
  - Batch report generation

#### 5. **User Management** 👥
- **Clinician Management**
  - View registered clinicians
  - Add/edit clinician profiles
  - Reset PIN
  - Activity logs

- **Admin Settings**
  - System configuration
  - Backup management
  - Data retention settings

#### 6. **Search & Filters** 🔍
- **Advanced Search**
  - Search by child name/code
  - Search by clinician
  - Search by date range
  - Search by risk level
  - Search by assessment type

- **Filters**
  - Age group filter
  - Gender filter
  - Group filter (ASD/Control)
  - Risk level filter
  - Date range filter

### Advanced Features (Nice to Have)

#### 7. **Analytics & Insights** 📈
- **Trend Analysis**
  - Risk score trends over time
  - Assessment completion trends
  - Performance metrics by age group
  - Comparison charts (ASD vs Control)

- **ML Model Insights**
  - Feature importance visualization
  - Prediction confidence scores
  - Model performance metrics

#### 8. **Notifications** 🔔
- **System Alerts**
  - New assessments completed
  - High-risk cases flagged
  - Data sync status
  - System errors

#### 9. **Audit Logs** 📋
- **Activity Tracking**
  - User login/logout
  - Data modifications
  - Export operations
  - System changes

---

## 🛠️ Technology Stack Options

### Option 1: Flutter Web (Recommended) ⭐

**Why:** You already use Flutter, so code can be shared!

**Pros:**
- ✅ Code reuse from mobile app
- ✅ Same codebase for mobile/web
- ✅ Consistent UI/UX
- ✅ Already familiar with Flutter
- ✅ Good performance

**Cons:**
- ⚠️ Larger bundle size
- ⚠️ Some web limitations

**Setup:**
```bash
# Enable web support
flutter config --enable-web

# Create web version
flutter create --platforms=web admin_portal
cd admin_portal

# Run
flutter run -d chrome
```

**Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.2
  provider: ^6.1.2
  fl_chart: ^0.69.0
  pdf: ^3.11.1
  csv: ^5.0.2
  intl: ^0.20.2
  shared_preferences: ^2.3.2
```

---

### Option 2: React + TypeScript

**Why:** Most popular, lots of libraries

**Pros:**
- ✅ Huge ecosystem
- ✅ Many UI libraries (Material-UI, Ant Design)
- ✅ Great for complex dashboards
- ✅ Excellent performance
- ✅ Large community

**Cons:**
- ⚠️ Different codebase from mobile
- ⚠️ Need to learn React

**Setup:**
```bash
# Create React app
npx create-react-app admin-portal --template typescript
cd admin-portal

# Install dependencies
npm install axios react-router-dom @mui/material @emotion/react @emotion/styled
npm install recharts date-fns csv-parse csv-stringify
```

**Tech Stack:**
- **Framework:** React 18 + TypeScript
- **UI Library:** Material-UI (MUI)
- **Charts:** Recharts
- **HTTP:** Axios
- **Routing:** React Router
- **State:** Context API or Redux

---

### Option 3: Vue.js + TypeScript

**Why:** Easy to learn, good for dashboards

**Pros:**
- ✅ Easy learning curve
- ✅ Great documentation
- ✅ Good performance
- ✅ Flexible

**Cons:**
- ⚠️ Smaller ecosystem than React
- ⚠️ Different codebase

**Setup:**
```bash
npm create vue@latest admin-portal
cd admin-portal
npm install
```

---

### Option 4: Next.js (React Framework)

**Why:** Best for production, SEO-friendly

**Pros:**
- ✅ Server-side rendering
- ✅ Great performance
- ✅ Built-in routing
- ✅ Production-ready

**Cons:**
- ⚠️ More complex setup
- ⚠️ Different codebase

---

## 🌍 Language Support

### Required Languages

Your admin website **MUST** support the same languages as your mobile app:

1. **English** (en) - Primary
2. **Sinhala** (si) - සිංහල
3. **Tamil** (ta) - தமிழ்

### Implementation Approaches

#### For Flutter Web:
```dart
// Use same localization system
import 'package:flutter_localizations/flutter_localizations.dart';

MaterialApp(
  localizationsDelegates: [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en', ''),
    Locale('si', ''),
    Locale('ta', ''),
  ],
)
```

#### For React:
```javascript
// Use i18next
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: require('./locales/en.json') },
      si: { translation: require('./locales/si.json') },
      ta: { translation: require('./locales/ta.json') },
    },
    lng: 'en',
    fallbackLng: 'en',
  });
```

#### Translation Files Structure:
```
locales/
├── en.json
│   {
│     "dashboard": "Dashboard",
│     "children": "Children",
│     "assessments": "Assessments",
│     "export": "Export Data",
│     "settings": "Settings"
│   }
├── si.json
│   {
│     "dashboard": "ප්‍රධාන පුවරුව",
│     "children": "ළමයි",
│     "assessments": "ඇගයීම්",
│     "export": "දත්ත අපනයනය",
│     "settings": "සැකසීම්"
│   }
└── ta.json
    {
      "dashboard": "முதன்மை பலகை",
      "children": "குழந்தைகள்",
      "assessments": "மதிப்பீடுகள்",
      "export": "தரவு ஏற்றுமதி",
      "settings": "அமைப்புகள்"
    }
```

---

## 🏗️ Architecture Design

### Recommended Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Admin Website                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐    ┌──────────────┐                  │
│  │   Frontend   │    │   API Layer  │                  │
│  │  (React/     │───►│   (Axios/    │                  │
│  │   Flutter)   │    │   HTTP)      │                  │
│  └──────────────┘    └──────┬───────┘                  │
│                              │                          │
│                              ▼                          │
│  ┌──────────────────────────────────────────┐         │
│  │      Existing Backend API                 │         │
│  │  (Node.js + Express + Firebase)            │         │
│  │                                            │         │
│  │  • /api/children                          │         │
│  │  • /api/sessions                          │         │
│  │  • /api/trials                            │         │
│  │  • /api/clinicians                        │         │
│  └──────────────────────────────────────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Component Structure (React Example)

```
src/
├── components/
│   ├── Dashboard/
│   │   ├── StatsCard.tsx
│   │   ├── Chart.tsx
│   │   └── RecentActivity.tsx
│   ├── Children/
│   │   ├── ChildrenTable.tsx
│   │   ├── ChildDetails.tsx
│   │   └── ChildForm.tsx
│   ├── Assessments/
│   │   ├── SessionsTable.tsx
│   │   └── SessionDetails.tsx
│   ├── Export/
│   │   ├── CSVExport.tsx
│   │   └── PDFExport.tsx
│   └── Common/
│       ├── Header.tsx
│       ├── Sidebar.tsx
│       ├── SearchBar.tsx
│       └── LanguageSelector.tsx
├── services/
│   ├── api.ts          # API calls
│   ├── export.ts       # Export functions
│   └── auth.ts         # Authentication
├── hooks/
│   ├── useChildren.ts
│   ├── useSessions.ts
│   └── useLanguage.ts
├── utils/
│   ├── formatters.ts
│   └── validators.ts
└── locales/
    ├── en.json
    ├── si.json
    └── ta.json
```

---

## 📝 Implementation Guide

### Step 1: Setup Project

#### For Flutter Web:
```bash
# Create new Flutter project
flutter create admin_portal
cd admin_portal

# Add dependencies
flutter pub add http provider fl_chart pdf csv intl shared_preferences

# Enable web
flutter config --enable-web

# Run
flutter run -d chrome
```

#### For React:
```bash
# Create React app
npx create-react-app admin-portal --template typescript
cd admin-portal

# Install dependencies
npm install axios react-router-dom @mui/material @emotion/react @emotion/styled
npm install recharts date-fns csv-parse csv-stringify jspdf
npm install react-i18next i18next
npm install @mui/icons-material

# Start
npm start
```

---

### Step 2: Create API Service

```typescript
// services/api.ts
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Children API
export const childrenApi = {
  getAll: () => api.get('/api/children'),
  getById: (id: string) => api.get(`/api/children/${id}`),
  create: (data: any) => api.post('/api/children', data),
  update: (id: string, data: any) => api.put(`/api/children/${id}`, data),
  delete: (id: string) => api.delete(`/api/children/${id}`),
  getByClinician: (clinicianId: string) => 
    api.get(`/api/children/clinician/${clinicianId}`),
};

// Sessions API
export const sessionsApi = {
  getAll: () => api.get('/api/sessions'),
  getById: (id: string) => api.get(`/api/sessions/${id}`),
  getByChild: (childId: string) => api.get(`/api/sessions/child/${childId}`),
  create: (data: any) => api.post('/api/sessions', data),
  update: (id: string, data: any) => api.put(`/api/sessions/${id}`, data),
  delete: (id: string) => api.delete(`/api/sessions/${id}`),
};

// Clinicians API
export const cliniciansApi = {
  login: (pin: string) => api.post('/api/clinicians/login', { pin }),
  getCurrent: () => api.get('/api/clinicians/me'),
  register: (data: any) => api.post('/api/clinicians/register', data),
};

export default api;
```

---

### Step 3: Create Dashboard Component

```typescript
// components/Dashboard/Dashboard.tsx
import React, { useEffect, useState } from 'react';
import { childrenApi, sessionsApi } from '../../services/api';
import StatsCard from './StatsCard';
import { useTranslation } from 'react-i18next';

const Dashboard: React.FC = () => {
  const { t } = useTranslation();
  const [stats, setStats] = useState({
    totalChildren: 0,
    totalSessions: 0,
    asdCount: 0,
    controlCount: 0,
    highRisk: 0,
    moderateRisk: 0,
    lowRisk: 0,
  });

  useEffect(() => {
    loadStats();
  }, []);

  const loadStats = async () => {
    try {
      const [childrenRes, sessionsRes] = await Promise.all([
        childrenApi.getAll(),
        sessionsApi.getAll(),
      ]);

      const children = childrenRes.data.children;
      const sessions = sessionsRes.data.sessions;

      const asdCount = children.filter((c: any) => c.group === 'asd').length;
      const controlCount = children.filter((c: any) => c.group === 'typically_developing').length;
      
      const highRisk = sessions.filter((s: any) => s.risk_level === 'high').length;
      const moderateRisk = sessions.filter((s: any) => s.risk_level === 'moderate').length;
      const lowRisk = sessions.filter((s: any) => s.risk_level === 'low').length;

      setStats({
        totalChildren: children.length,
        totalSessions: sessions.length,
        asdCount,
        controlCount,
        highRisk,
        moderateRisk,
        lowRisk,
      });
    } catch (error) {
      console.error('Error loading stats:', error);
    }
  };

  return (
    <div className="dashboard">
      <h1>{t('dashboard')}</h1>
      <div className="stats-grid">
        <StatsCard title={t('total_children')} value={stats.totalChildren} />
        <StatsCard title={t('total_assessments')} value={stats.totalSessions} />
        <StatsCard title={t('asd_group')} value={stats.asdCount} />
        <StatsCard title={t('control_group')} value={stats.controlCount} />
        <StatsCard title={t('high_risk')} value={stats.highRisk} color="error" />
        <StatsCard title={t('moderate_risk')} value={stats.moderateRisk} color="warning" />
        <StatsCard title={t('low_risk')} value={stats.lowRisk} color="success" />
      </div>
    </div>
  );
};

export default Dashboard;
```

---

### Step 4: Create Children Management

```typescript
// components/Children/ChildrenTable.tsx
import React, { useEffect, useState } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, TextField, Button } from '@mui/material';
import { childrenApi } from '../../services/api';
import { useTranslation } from 'react-i18next';

const ChildrenTable: React.FC = () => {
  const { t } = useTranslation();
  const [children, setChildren] = useState<any[]>([]);
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    loadChildren();
  }, []);

  const loadChildren = async () => {
    try {
      const response = await childrenApi.getAll();
      setChildren(response.data.children);
    } catch (error) {
      console.error('Error loading children:', error);
    }
  };

  const filteredChildren = children.filter((child) =>
    child.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
    child.child_code?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div>
      <TextField
        label={t('search')}
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        fullWidth
        margin="normal"
      />
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>{t('name')}</TableCell>
              <TableCell>{t('code')}</TableCell>
              <TableCell>{t('age')}</TableCell>
              <TableCell>{t('gender')}</TableCell>
              <TableCell>{t('group')}</TableCell>
              <TableCell>{t('risk_level')}</TableCell>
              <TableCell>{t('actions')}</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredChildren.map((child) => (
              <TableRow key={child.id}>
                <TableCell>{child.name}</TableCell>
                <TableCell>{child.child_code}</TableCell>
                <TableCell>{child.age?.toFixed(1)} {t('years')}</TableCell>
                <TableCell>{t(child.gender)}</TableCell>
                <TableCell>{t(child.group)}</TableCell>
                <TableCell>{child.risk_level || '-'}</TableCell>
                <TableCell>
                  <Button size="small" onClick={() => viewChild(child.id)}>
                    {t('view')}
                  </Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </div>
  );
};

export default ChildrenTable;
```

---

### Step 5: Create Export Service

```typescript
// services/export.ts
import { childrenApi, sessionsApi } from './api';
import { parse, stringify } from 'csv-stringify/sync';
import jsPDF from 'jspdf';

export const exportToCSV = async (type: 'children' | 'sessions' | 'all') => {
  let data: any[] = [];

  if (type === 'children' || type === 'all') {
    const response = await childrenApi.getAll();
    data = response.data.children.map((child: any) => ({
      id: child.id,
      name: child.name,
      code: child.child_code,
      age: child.age,
      gender: child.gender,
      group: child.group,
      asd_level: child.asd_level,
      created_at: new Date(child.created_at).toISOString(),
    }));
  }

  if (type === 'sessions' || type === 'all') {
    const response = await sessionsApi.getAll();
    const sessions = response.data.sessions.map((session: any) => ({
      session_id: session.id,
      child_id: session.child_id,
      session_type: session.session_type,
      risk_score: session.risk_score,
      risk_level: session.risk_level,
      created_at: new Date(session.created_at).toISOString(),
    }));
    data = type === 'all' ? [...data, ...sessions] : sessions;
  }

  const csv = stringify(data, { header: true });
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `senseai_export_${type}_${Date.now()}.csv`;
  a.click();
};

export const exportToPDF = async (childId: string) => {
  const [childRes, sessionsRes] = await Promise.all([
    childrenApi.getById(childId),
    sessionsApi.getByChild(childId),
  ]);

  const child = childRes.data.child;
  const sessions = sessionsRes.data.sessions;

  const doc = new jsPDF();
  
  // Add content
  doc.text(`Child Report: ${child.name}`, 10, 10);
  doc.text(`Code: ${child.child_code}`, 10, 20);
  doc.text(`Age: ${child.age} years`, 10, 30);
  doc.text(`Group: ${child.group}`, 10, 40);
  doc.text(`Total Assessments: ${sessions.length}`, 10, 50);

  // Add session details
  let y = 60;
  sessions.forEach((session: any) => {
    doc.text(`Session: ${session.session_type}`, 10, y);
    doc.text(`Risk Level: ${session.risk_level || 'N/A'}`, 10, y + 10);
    y += 20;
  });

  doc.save(`child_report_${child.child_code}.pdf`);
};
```

---

### Step 6: Add Language Support

```typescript
// i18n.ts
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import en from './locales/en.json';
import si from './locales/si.json';
import ta from './locales/ta.json';

i18n
  .use(initReactI18next)
  .init({
    resources: {
      en: { translation: en },
      si: { translation: si },
      ta: { translation: ta },
    },
    lng: localStorage.getItem('language') || 'en',
    fallbackLng: 'en',
    interpolation: {
      escapeValue: false,
    },
  });

export default i18n;
```

```typescript
// components/Common/LanguageSelector.tsx
import React from 'react';
import { Select, MenuItem, FormControl } from '@mui/material';
import { useTranslation } from 'react-i18next';

const LanguageSelector: React.FC = () => {
  const { i18n } = useTranslation();

  const handleChange = (event: any) => {
    const lang = event.target.value;
    i18n.changeLanguage(lang);
    localStorage.setItem('language', lang);
  };

  return (
    <FormControl>
      <Select value={i18n.language} onChange={handleChange}>
        <MenuItem value="en">English</MenuItem>
        <MenuItem value="si">සිංහල</MenuItem>
        <MenuItem value="ta">தமிழ்</MenuItem>
      </Select>
    </FormControl>
  );
};

export default LanguageSelector;
```

---

## 🔒 Security Considerations

### 1. **Authentication**
```typescript
// services/auth.ts
export const login = async (pin: string) => {
  const response = await cliniciansApi.login(pin);
  if (response.data.success) {
    localStorage.setItem('authToken', response.data.token);
    localStorage.setItem('clinician', JSON.stringify(response.data.clinician));
  }
  return response.data;
};

export const isAuthenticated = () => {
  return !!localStorage.getItem('authToken');
};

export const logout = () => {
  localStorage.removeItem('authToken');
  localStorage.removeItem('clinician');
};
```

### 2. **API Interceptor**
```typescript
// Add to api.ts
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

### 3. **Protected Routes**
```typescript
// components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom';
import { isAuthenticated } from '../services/auth';

const ProtectedRoute: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" />;
  }
  return <>{children}</>;
};
```

---

## 🎨 UI/UX Recommendations

### Design Principles

1. **Clean & Professional**
   - Use Material-UI or similar design system
   - Consistent color scheme
   - Clear typography

2. **Responsive Design**
   - Mobile-friendly
   - Tablet-optimized
   - Desktop-first

3. **Accessibility**
   - Keyboard navigation
   - Screen reader support
   - High contrast mode

4. **Performance**
   - Lazy loading
   - Pagination
   - Optimistic updates

### Recommended UI Library

**For React:** Material-UI (MUI)
```bash
npm install @mui/material @mui/icons-material @emotion/react @emotion/styled
```

**For Flutter:** Use Material Design widgets (built-in)

---

## 📦 Complete Feature Checklist

### Phase 1: Core Features (Week 1-2)
- [ ] Login/Authentication
- [ ] Dashboard with statistics
- [ ] Children list view
- [ ] Child details view
- [ ] Sessions list view
- [ ] Basic search and filters

### Phase 2: Management Features (Week 2-3)
- [ ] Edit child information
- [ ] Delete child (with confirmation)
- [ ] View session details
- [ ] Export to CSV
- [ ] Export to PDF

### Phase 3: Advanced Features (Week 3-4)
- [ ] Charts and visualizations
- [ ] Advanced filters
- [ ] Bulk operations
- [ ] User management
- [ ] Settings page

### Phase 4: Polish (Week 4-5)
- [ ] Language switching
- [ ] Responsive design
- [ ] Error handling
- [ ] Loading states
- [ ] Toast notifications

---

## 🚀 Quick Start Template

I can create a complete starter template for you. Would you like:

1. **React + TypeScript + Material-UI** template
2. **Flutter Web** template
3. **Next.js** template

Let me know which one you prefer, and I'll create the complete project structure!

---

## 📝 Summary

**Recommended Stack:**
- **Frontend:** React + TypeScript + Material-UI (or Flutter Web)
- **Backend:** Your existing Node.js API
- **Languages:** English, Sinhala, Tamil
- **Key Features:** Dashboard, Child Management, Data Export, Analytics

**Timeline:** 4-5 weeks for complete implementation

**Priority Features:**
1. Dashboard & Statistics
2. Child Management
3. Data Export (CSV/PDF)
4. Search & Filters
5. Language Support

---

*Last Updated: December 2024*

