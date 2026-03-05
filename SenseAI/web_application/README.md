# SenseAI Admin Portal

Web-based admin dashboard for managing clinical data, viewing reports, and exporting research data.

## Project Structure

```
web_application/
├── src/
│   ├── components/      # React components
│   │   ├── Auth/        # Authentication components
│   │   ├── Dashboard/   # Dashboard components
│   │   ├── Children/    # Child management
│   │   ├── Sessions/    # Assessment management
│   │   ├── Export/      # Data export
│   │   ├── Settings/    # Settings
│   │   └── Layout/      # Layout components
│   ├── services/        # API services
│   ├── locales/         # Translation files
│   ├── App.tsx          # Main app component
│   └── main.tsx         # Entry point
├── public/              # Static assets
├── package.json
├── tsconfig.json
└── vite.config.ts
```

## Getting Started

### Prerequisites

- Node.js 18+ and npm
- Backend server running on port 3000 (from `senseai_backend` folder)

### Installation

```bash
cd web_application
npm install
```

### Development

```bash
npm run dev
```

The app will run on `http://localhost:5173`

### Build for Production

```bash
npm run build
```

The built files will be in the `dist` folder.

### Preview Production Build

```bash
npm run preview
```

## Features

- ✅ Dashboard with statistics and charts
- ✅ Child management (view, edit, delete)
- ✅ Assessment management
- ✅ Data export (CSV, PDF)
- ✅ Multi-language support (English, Sinhala, Tamil)
- ✅ Search and filters
- ✅ Responsive design

## Configuration

1. Copy `.env.example` to `.env`
2. Update `VITE_API_URL` if your backend runs on a different port or host

## Languages Supported

- English (en)
- Sinhala (si) - සිංහල
- Tamil (ta) - தமிழ்

## Login

Use the same PIN that you use in the mobile app to login.

## Notes

- This is a separate project from the mobile app
- It connects to the same backend API (`senseai_backend`)
- The mobile app and web app can run simultaneously without conflicts
