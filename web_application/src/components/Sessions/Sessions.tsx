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
} from '@mui/material'
import { useNavigate } from 'react-router-dom'
import { Visibility } from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { sessionsApi } from '../../services/api'
import { format } from 'date-fns'

const Sessions = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [sessions, setSessions] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadSessions()
  }, [])

  const loadSessions = async () => {
    try {
      const response = await sessionsApi.getAll()
      setSessions(response.data.sessions || [])
    } catch (error) {
      console.error('Error loading sessions:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredSessions = sessions.filter((session) =>
    session.session_type?.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
        {t('sessions')}
      </Typography>

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
                  <TableCell>{session.session_type}</TableCell>
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

export default Sessions


