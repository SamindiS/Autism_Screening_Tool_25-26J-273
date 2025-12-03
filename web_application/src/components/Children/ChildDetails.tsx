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
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
} from '@mui/material'
import { ArrowBack, Download } from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { childrenApi, sessionsApi } from '../../services/api'
import { exportChildToPDF } from '../../services/export'
import { format } from 'date-fns'

const ChildDetails = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const { t } = useTranslation()
  const [child, setChild] = useState<any>(null)
  const [sessions, setSessions] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (id) {
      loadData()
    }
  }, [id])

  const loadData = async () => {
    try {
      const [childRes, sessionsRes] = await Promise.all([
        childrenApi.getById(id!),
        sessionsApi.getByChild(id!),
      ])
      setChild(childRes.data.child)
      setSessions(sessionsRes.data.sessions || [])
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleExportPDF = async () => {
    if (id) {
      try {
        await exportChildToPDF(id)
      } catch (error) {
        console.error('Export error:', error)
        alert(t('error_occurred'))
      }
    }
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  if (!child) {
    return <Typography>{t('no_data')}</Typography>
  }

  return (
    <Box>
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Button startIcon={<ArrowBack />} onClick={() => navigate('/children')}>
          {t('back')}
        </Button>
        <Button startIcon={<Download />} variant="contained" onClick={handleExportPDF}>
          {t('export_pdf')}
        </Button>
      </Box>

      <Typography variant="h4" gutterBottom>
        {t('child_details')}
      </Typography>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              {t('name')}: {child.name}
            </Typography>
            <Typography variant="body1" gutterBottom>
              {t('code')}: {child.child_code || '-'}
            </Typography>
            <Typography variant="body1" gutterBottom>
              {t('age')}: {child.age ? `${child.age.toFixed(1)} ${t('years')}` : '-'}
            </Typography>
            <Typography variant="body1" gutterBottom>
              {t('gender')}: {t(child.gender)}
            </Typography>
            <Typography variant="body1" gutterBottom>
              {t('group')}:{' '}
              <Chip
                label={t(child.group || 'typically_developing')}
                size="small"
                color={child.group === 'asd' ? 'error' : 'success'}
              />
            </Typography>
            {child.asd_level && (
              <Typography variant="body1" gutterBottom>
                ASD Level: {child.asd_level}
              </Typography>
            )}
          </Paper>
        </Grid>
      </Grid>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" gutterBottom>
          {t('assessment_history')}
        </Typography>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('sessions')}</TableCell>
                <TableCell>{t('risk_level')}</TableCell>
                <TableCell>Date</TableCell>
                <TableCell>{t('actions')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {sessions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={4} align="center">
                    {t('no_data')}
                  </TableCell>
                </TableRow>
              ) : (
                sessions.map((session) => (
                  <TableRow key={session.id}>
                    <TableCell>{session.session_type}</TableCell>
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
                      {session.created_at
                        ? format(new Date(session.created_at), 'yyyy-MM-dd')
                        : '-'}
                    </TableCell>
                    <TableCell>
                      <Button
                        size="small"
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
    </Box>
  )
}

export default ChildDetails

