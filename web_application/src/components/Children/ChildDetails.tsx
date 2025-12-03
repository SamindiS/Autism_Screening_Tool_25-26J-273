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
  Accordion,
  AccordionSummary,
  AccordionDetails,
  Divider,
  Card,
  CardContent,
  Stack,
} from '@mui/material'
import {
  ArrowBack,
  Download,
  ExpandMore,
  History,
  Assessment,
  Person,
  CalendarToday,
  TrendingUp,
} from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { childrenApi, sessionsApi } from '../../services/api'
import { exportChildToPDF } from '../../services/export'
import { format } from 'date-fns'
import { isAdmin } from '../../services/auth'

const getComponentType = (sessionType: string): string => {
  const cognitiveTypes = ['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment']
  if (cognitiveTypes.includes(sessionType)) return 'Cognitive'
  if (sessionType === 'rrb') return 'RRB'
  if (sessionType === 'auditory') return 'Auditory'
  if (sessionType === 'visual') return 'Visual'
  return 'Other'
}

const getComponentColor = (component: string): 'default' | 'primary' | 'secondary' | 'error' | 'info' | 'success' | 'warning' => {
  switch (component) {
    case 'Cognitive': return 'primary'
    case 'RRB': return 'secondary'
    case 'Auditory': return 'info'
    case 'Visual': return 'success'
    default: return 'default'
  }
}

const formatSessionType = (type: string): string => {
  const typeMap: Record<string, string> = {
    'color_shape': 'Color-Shape Game',
    'frog_jump': 'Frog Jump Game',
    'ai_doctor_bot': 'AI Questionnaire',
    'manual_assessment': 'Manual Assessment',
    'rrb': 'RRB Assessment',
    'auditory': 'Auditory Assessment',
    'visual': 'Visual Assessment',
  }
  return typeMap[type] || type
}

const ChildDetails = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const { t } = useTranslation()
  const [child, setChild] = useState<any>(null)
  const [sessions, setSessions] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [viewMode, setViewMode] = useState<'table' | 'timeline'>('table')
  const admin = isAdmin()

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
            {child.clinician_name && (
              <Typography variant="body1" gutterBottom>
                {t('examined_by')}: {child.clinician_name}
              </Typography>
            )}
          </Paper>
        </Grid>
      </Grid>

      {/* Assessment History Section */}
      <Box sx={{ mt: 4 }}>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
          <Box display="flex" alignItems="center" gap={2}>
            <History color="primary" />
            <Typography variant="h5" fontWeight="bold">
              {t('complete_assessment_history')}
            </Typography>
            <Chip label={`${sessions.length} ${t('sessions')}`} color="primary" />
          </Box>
          <Box display="flex" gap={1}>
            <Button
              variant={viewMode === 'table' ? 'contained' : 'outlined'}
              size="small"
              onClick={() => setViewMode('table')}
            >
              {t('table_view')}
            </Button>
            <Button
              variant={viewMode === 'timeline' ? 'contained' : 'outlined'}
              size="small"
              onClick={() => setViewMode('timeline')}
            >
              {t('timeline_view')}
            </Button>
          </Box>
        </Box>

        {/* Statistics Cards */}
        <Grid container spacing={2} sx={{ mb: 3 }}>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  {t('total_assessments')}
                </Typography>
                <Typography variant="h4" color="primary">
                  {sessions.length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  {t('high_risk')}
                </Typography>
                <Typography variant="h4" color="error">
                  {sessions.filter((s) => s.risk_level === 'high').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  {t('moderate_risk')}
                </Typography>
                <Typography variant="h4" sx={{ color: '#ed6c02' }}>
                  {sessions.filter((s) => s.risk_level === 'moderate').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
          <Grid item xs={12} sm={6} md={3}>
            <Card>
              <CardContent>
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  {t('low_risk')}
                </Typography>
                <Typography variant="h4" color="success">
                  {sessions.filter((s) => s.risk_level === 'low').length}
                </Typography>
              </CardContent>
            </Card>
          </Grid>
        </Grid>

        {/* View Mode: Table */}
        {viewMode === 'table' && (
          <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('session_type')}</TableCell>
                <TableCell>{t('component')}</TableCell>
                <TableCell>{t('risk_level')}</TableCell>
                <TableCell>{t('risk_score')}</TableCell>
                <TableCell>{t('date')}</TableCell>
                <TableCell>{t('actions')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {sessions.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={6} align="center">
                    {t('no_assessments')}
                  </TableCell>
                </TableRow>
              ) : (
                sessions.map((session) => {
                  const componentType = getComponentType(session.session_type)
                  return (
                    <TableRow key={session.id}>
                      <TableCell>
                        <Typography variant="body2" fontWeight="medium">
                          {formatSessionType(session.session_type)}
                        </Typography>
                      </TableCell>
                      <TableCell>
                        <Chip
                          label={componentType}
                          size="small"
                          color={getComponentColor(componentType)}
                        />
                      </TableCell>
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
                          ? session.risk_score.toFixed(1)
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
                          variant="outlined"
                          onClick={() => navigate(`/sessions/${session.id}`)}
                        >
                          {t('view_details')}
                        </Button>
                      </TableCell>
                    </TableRow>
                  )
                })
              )}
            </TableBody>
          </Table>
        </TableContainer>
        )}

        {/* View Mode: Timeline */}
        {viewMode === 'timeline' && (
          <Paper sx={{ p: 3 }}>
            {sessions.length === 0 ? (
              <Box textAlign="center" py={4}>
                <Typography color="text.secondary">{t('no_assessments')}</Typography>
              </Box>
            ) : (
              <Box>
                {sessions
                  .sort((a: any, b: any) => (b.created_at || 0) - (a.created_at || 0))
                  .map((session, index) => {
                    const componentType = getComponentType(session.session_type)
                    const isLast = index === sessions.length - 1
                    return (
                      <Box key={session.id} display="flex" mb={isLast ? 0 : 3}>
                        <Box display="flex" flexDirection="column" alignItems="center" mr={2}>
                          <Box
                            sx={{
                              width: 40,
                              height: 40,
                              borderRadius: '50%',
                              bgcolor:
                                session.risk_level === 'high'
                                  ? 'error.main'
                                  : session.risk_level === 'moderate'
                                  ? 'warning.main'
                                  : 'success.main',
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                              color: 'white',
                            }}
                          >
                            <Assessment fontSize="small" />
                          </Box>
                          {!isLast && (
                            <Box
                              sx={{
                                width: 2,
                                flex: 1,
                                bgcolor: 'divider',
                                mt: 1,
                                minHeight: 40,
                              }}
                            />
                          )}
                        </Box>
                        <Box flex={1}>
                          <Card>
                            <CardContent>
                              <Box display="flex" justifyContent="space-between" alignItems="start" mb={2}>
                                <Box>
                                  <Typography variant="h6" fontWeight="bold">
                                    {formatSessionType(session.session_type)}
                                  </Typography>
                                  <Typography variant="body2" color="text.secondary">
                                    {session.created_at
                                      ? format(new Date(session.created_at), 'MMMM dd, yyyy • HH:mm')
                                      : '-'}
                                  </Typography>
                                </Box>
                                <Stack direction="row" spacing={1}>
                                  <Chip
                                    label={componentType}
                                    size="small"
                                    color={getComponentColor(componentType)}
                                  />
                                  {session.risk_level && (
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
                                  )}
                                </Stack>
                              </Box>
                              <Grid container spacing={2}>
                                <Grid item xs={12} sm={6}>
                                  <Typography variant="body2" color="text.secondary">
                                    {t('risk_score')}:
                                  </Typography>
                                  <Typography variant="body1" fontWeight="medium">
                                    {session.risk_score !== null && session.risk_score !== undefined
                                      ? session.risk_score.toFixed(1)
                                      : '-'}
                                  </Typography>
                                </Grid>
                                <Grid item xs={12} sm={6}>
                                  <Typography variant="body2" color="text.secondary">
                                    {t('age_group')}:
                                  </Typography>
                                  <Typography variant="body1" fontWeight="medium">
                                    {session.age_group || '-'}
                                  </Typography>
                                </Grid>
                              </Grid>
                              <Box mt={2}>
                                <Button
                                  size="small"
                                  variant="outlined"
                                  onClick={() => navigate(`/sessions/${session.id}`)}
                                >
                                  {t('view_full_details')}
                                </Button>
                              </Box>
                            </CardContent>
                          </Card>
                        </Box>
                      </Box>
                    )
                  })}
              </Box>
            )}
          </Paper>
        )}
      </Box>

      {/* Additional Information for Admin */}
      {admin && child && (
        <Box sx={{ mt: 4 }}>
          <Accordion>
            <AccordionSummary expandIcon={<ExpandMore />}>
              <Typography variant="h6">{t('administrative_info')}</Typography>
            </AccordionSummary>
            <AccordionDetails>
              <Grid container spacing={2}>
                <Grid item xs={12} md={6}>
                  <Typography variant="body2" color="text.secondary">
                    {t('child_id')}
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {child.id}
                  </Typography>
                </Grid>
                <Grid item xs={12} md={6}>
                  <Typography variant="body2" color="text.secondary">
                    {t('created_at')}
                  </Typography>
                  <Typography variant="body1" fontWeight="medium">
                    {child.created_at
                      ? format(new Date(child.created_at), 'yyyy-MM-dd HH:mm:ss')
                      : '-'}
                  </Typography>
                </Grid>
                {child.clinician_id && (
                  <Grid item xs={12} md={6}>
                    <Typography variant="body2" color="text.secondary">
                      {t('clinician_id')}
                    </Typography>
                    <Typography variant="body1" fontWeight="medium">
                      {child.clinician_id}
                    </Typography>
                  </Grid>
                )}
                {child.hospital_id && (
                  <Grid item xs={12} md={6}>
                    <Typography variant="body2" color="text.secondary">
                      {t('hospital_id')}
                    </Typography>
                    <Typography variant="body1" fontWeight="medium">
                      {child.hospital_id}
                    </Typography>
                  </Grid>
                )}
              </Grid>
            </AccordionDetails>
          </Accordion>
        </Box>
      )}
    </Box>
  )
}

export default ChildDetails

