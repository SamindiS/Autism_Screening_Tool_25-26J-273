import { useEffect, useState } from 'react'
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TextField,
  Typography,
  CircularProgress,
  Chip,
  Button,
  Tabs,
  Tab,
} from '@mui/material'
import { Visibility } from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { sessionsApi } from '../../services/api'
import { format } from 'date-fns'

interface TabPanelProps {
  children?: React.ReactNode
  index: number
  value: number
}

function TabPanel(props: TabPanelProps) {
  const { children, value, index, ...other } = props

  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`cognitive-tabpanel-${index}`}
      aria-labelledby={`cognitive-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ p: 3 }}>{children}</Box>}
    </div>
  )
}

const Cognitive = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [sessions, setSessions] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)
  const [tabValue, setTabValue] = useState(0)

  // Filter sessions by cognitive flexibility games
  // Cognitive flexibility includes: DCCS (color_shape), Go/No-Go (frog_jump), and related assessments
  const cognitiveSessionTypes = ['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment']

  useEffect(() => {
    loadSessions()
  }, [])

  const loadSessions = async () => {
    try {
      const response = await sessionsApi.getAll()
      const allSessions = response.data.sessions || []
      // Filter only cognitive flexibility related sessions
      const cognitiveSessions = allSessions.filter((s: any) =>
        cognitiveSessionTypes.includes(s.session_type)
      )
      setSessions(cognitiveSessions)
    } catch (error) {
      console.error('Error loading sessions:', error)
    } finally {
      setLoading(false)
    }
  }

  const getSessionTypeLabel = (type: string) => {
    switch (type) {
      case 'color_shape':
        return t('color_shape_game')
      case 'frog_jump':
        return t('frog_jump_game')
      case 'ai_doctor_bot':
        return t('ai_questionnaire')
      case 'manual_assessment':
        return t('manual_assessment')
      default:
        return type
    }
  }

  const filteredSessions = sessions.filter((session) => {
    const matchesSearch =
      session.session_type?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      session.child_id?.toLowerCase().includes(searchTerm.toLowerCase())
    
    if (tabValue === 0) return matchesSearch // All
    if (tabValue === 1) return matchesSearch && session.session_type === 'color_shape'
    if (tabValue === 2) return matchesSearch && session.session_type === 'frog_jump'
    if (tabValue === 3) return matchesSearch && (session.session_type === 'ai_doctor_bot' || session.session_type === 'manual_assessment')
    
    return matchesSearch
  })

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {t('cognitive')}
      </Typography>

      <Paper sx={{ mb: 3 }}>
        <Tabs value={tabValue} onChange={(_, newValue) => setTabValue(newValue)}>
          <Tab label={t('all')} />
          <Tab label={t('color_shape_game')} />
          <Tab label={t('frog_jump_game')} />
          <Tab label={t('questionnaire')} />
        </Tabs>
      </Paper>

      <TextField
        fullWidth
        label={t('search')}
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        margin="normal"
        sx={{ mb: 2 }}
      />

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>{t('sessions')}</TableCell>
              <TableCell>Child ID</TableCell>
              <TableCell>{t('risk_level')}</TableCell>
              <TableCell>Risk Score</TableCell>
              <TableCell>Date</TableCell>
              <TableCell>{t('actions')}</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredSessions.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} align="center">
                  {t('no_data')}
                </TableCell>
              </TableRow>
            ) : (
              filteredSessions.map((session) => (
                <TableRow key={session.id} hover>
                  <TableCell>{getSessionTypeLabel(session.session_type)}</TableCell>
                  <TableCell>{session.child_id}</TableCell>
                  <TableCell>
                    {session.risk_level ? (
                      <Chip
                        label={t(session.risk_level)}
                        size="small"
                        color={
                          session.risk_level === 'high'
                            ? 'error'
                            : session.risk_level === 'moderate'
                            ? 'warning'
                            : 'success'
                        }
                      />
                    ) : (
                      '-'
                    )}
                  </TableCell>
                  <TableCell>
                    {session.risk_score !== null && session.risk_score !== undefined
                      ? session.risk_score
                      : '-'}
                  </TableCell>
                  <TableCell>
                    {session.created_at
                      ? format(new Date(session.created_at), 'yyyy-MM-dd HH:mm')
                      : '-'}
                  </TableCell>
                  <TableCell>
                    <Button
                      size="small"
                      startIcon={<Visibility />}
                      onClick={() => navigate(`/sessions/${session.id}`)}
                    >
                      {t('view')}
                    </Button>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  )
}

export default Cognitive
