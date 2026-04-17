import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { ThemeProvider, createTheme, CssBaseline } from '@mui/material'
import { useTranslation } from 'react-i18next'
import Login from './components/Auth/Login'
import Dashboard from './components/Dashboard/Dashboard'
import Children from './components/Children/Children'
import ChildDetails from './components/Children/ChildDetails'
import Cognitive from './components/Cognitive/Cognitive'
import CognitiveDashboard from './components/Cognitive/CognitiveDashboard'
import RRBDashboard from './components/RRB/RRBDashboard'
import AuditoryDashboard from './components/Auditory/AuditoryDashboard'
import VisualDashboard from './components/Visual/VisualDashboard'
import Sessions from './components/Sessions/Sessions'
import SessionDetails from './components/Sessions/SessionDetails'
import Doctors from './components/Doctors/Doctors'
import DoctorDetails from './components/Doctors/DoctorDetails'
import DoctorChildRelations from './components/Admin/DoctorChildRelations'
import Export from './components/Export/Export'
import Settings from './components/Settings/Settings'
import Layout from './components/Layout/Layout'
import ProtectedRoute from './components/Auth/ProtectedRoute'
import { isAuthenticated } from './services/auth'

const theme = createTheme({
  palette: {
    primary: {
      main: '#667eea',
    },
    secondary: {
      main: '#764ba2',
    },
    background: {
      default: 'transparent', // Let CSS gradient shine through
      paper: 'transparent',
    },
  },
  typography: {
    fontFamily: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
    button: {
      textTransform: 'none',
      fontWeight: 600,
    },
  },
  components: {
    MuiPaper: {
      styleOverrides: {
        root: {
          backgroundImage: 'none',
          backgroundColor: 'rgba(255, 255, 255, 0.75)',
          backdropFilter: 'blur(16px)',
          borderRadius: '20px',
          border: '1px solid rgba(255, 255, 255, 0.6)',
          boxShadow: '0 8px 32px 0 rgba(31, 38, 135, 0.08)',
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: '12px',
          boxShadow: 'none',
          '&:hover': {
            boxShadow: '0 8px 24px rgba(102, 126, 234, 0.25)',
            transform: 'translateY(-2px)',
          },
          transition: 'transform 0.2s, box-shadow 0.2s',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          overflow: 'visible',
        },
      },
    },
  },
})

function App() {
  const { i18n } = useTranslation()

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router
        future={{
          v7_startTransition: true,
          v7_relativeSplatPath: true,
        }}
      >
        <Routes>
          <Route
            path="/login"
            element={
              isAuthenticated() ? <Navigate to="/dashboard" replace /> : <Login />
            }
          />
          <Route
            path="/"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="children" element={<Children />} />
            <Route path="children/:id" element={<ChildDetails />} />
            <Route path="cognitive" element={<CognitiveDashboard />} />
            <Route path="rrb" element={<RRBDashboard />} />
            <Route path="auditory" element={<AuditoryDashboard />} />
            <Route path="visual" element={<VisualDashboard />} />
            <Route path="sessions" element={<Sessions />} />
            <Route path="sessions/:id" element={<SessionDetails />} />
            <Route path="doctors" element={<Doctors />} />
            <Route path="doctors/:id" element={<DoctorDetails />} />
            <Route path="admin/doctor-relations" element={<DoctorChildRelations />} />
            <Route path="export" element={<Export />} />
            <Route path="settings" element={<Settings />} />
          </Route>
        </Routes>
      </Router>
    </ThemeProvider>
  )
}

export default App

