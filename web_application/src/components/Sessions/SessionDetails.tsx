import { useEffect, useState } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import {
  Box,
  Paper,
  Typography,
  Button,
  Grid,
  Chip,
  CircularProgress,
} from '@mui/material'
import { ArrowBack } from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { sessionsApi } from '../../services/api'
import { format } from 'date-fns'

const SessionDetails = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const { t } = useTranslation()
  const [session, setSession] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (id) {
      loadSession()
    }
  }, [id])

  const loadSession = async () => {
    try {
      const response = await sessionsApi.getById(id!)
      setSession(response.data.session)
    } catch (error) {
      console.error('Error loading session:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  if (!session) {
    return <Typography>{t('no_data')}</Typography>
  }

  return (
    <Box>
      <Button startIcon={<ArrowBack />} onClick={() => navigate('/sessions')} sx={{ mb: 2 }}>
        {t('back')}
      </Button>

      <Typography variant="h4" gutterBottom>
        {t('session_details')}
      </Typography>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              Session Information
            </Typography>
            <Typography variant="body1" gutterBottom>
              Type: {session.session_type}
            </Typography>
            <Typography variant="body1" gutterBottom>
              Child ID: {session.child_id}
            </Typography>
            <Typography variant="body1" gutterBottom>
              Age Group: {session.age_group || '-'}
            </Typography>
            <Typography variant="body1" gutterBottom>
              Start Time:{' '}
              {session.start_time
                ? format(new Date(session.start_time), 'yyyy-MM-dd HH:mm:ss')
                : '-'}
            </Typography>
            <Typography variant="body1" gutterBottom>
              End Time:{' '}
              {session.end_time
                ? format(new Date(session.end_time), 'yyyy-MM-dd HH:mm:ss')
                : '-'}
            </Typography>
            {session.risk_level && (
              <Box sx={{ mt: 2 }}>
                <Typography variant="body1" gutterBottom>
                  {t('risk_level')}:{' '}
                  <Chip
                    label={t(session.risk_level)}
                    color={
                      session.risk_level === 'high'
                        ? 'error'
                        : session.risk_level === 'moderate'
                        ? 'warning'
                        : 'success'
                    }
                  />
                </Typography>
              </Box>
            )}
            {session.risk_score !== null && session.risk_score !== undefined && (
              <Typography variant="body1" gutterBottom>
                Risk Score: {session.risk_score}
              </Typography>
            )}
          </Paper>
        </Grid>

        {session.game_results && (
          <Grid item xs={12} md={6}>
            <Paper sx={{ p: 3 }}>
              <Typography variant="h6" gutterBottom>
                Game Results
              </Typography>
              <pre style={{ whiteSpace: 'pre-wrap', fontSize: '12px' }}>
                {JSON.stringify(session.game_results, null, 2)}
              </pre>
            </Paper>
          </Grid>
        )}
      </Grid>
    </Box>
  )
}

export default SessionDetails

