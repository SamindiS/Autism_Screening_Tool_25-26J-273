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
  const type = sessionType.toLowerCase()
  const cognitiveTypes = ['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment', 'dccs', 'flexibility']
  if (cognitiveTypes.some(t => type.includes(t))) return 'Cognitive'
  if (type.includes('rrb')) return 'RRB'
  if (type.includes('auditory')) return 'Auditory'
  if (type.includes('visual')) return 'Visual'
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
    'dccs_color_shape': 'DCCS Color-Shape',
    'dccs-color-shape': 'DCCS Color-Shape',
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

  const { alpha } = require('@mui/material/styles');
  const Avatar = require('@mui/material/Avatar').default;

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

      <Typography variant="h4" gutterBottom fontWeight="bold">
        {t('child_details')}
      </Typography>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={7}>
          <Paper sx={{ p: 3, height: '100%', borderRadius: 2 }}>
            <Box display="flex" alignItems="center" gap={2} mb={3}>
              <Avatar sx={{ width: 64, height: 64, bgcolor: 'primary.main' }}>
                <Person sx={{ fontSize: 40 }} />
              </Avatar>
              <Box>
                <Typography variant="h5" fontWeight="bold">
                  {child.name}
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  {child.child_code || t('no_code')} • {t(child.gender)}
                </Typography>
              </Box>
            </Box>

            <Divider sx={{ mb: 2 }} />

            <Grid container spacing={2}>
              <Grid item xs={6} sm={4}>
                <Typography variant="caption" color="text.secondary">{t('age')}</Typography>
                <Typography variant="body1" fontWeight="medium">
                  {child.age ? `${child.age.toFixed(1)} ${t('years')}` : '-'}
                </Typography>
              </Grid>
              <Grid item xs={6} sm={4}>
                <Typography variant="caption" color="text.secondary">{t('group')}</Typography>
                <Box>
                  <Chip
                    label={t(child.group || 'typically_developing')}
                    size="small"
                    color={child.group === 'asd' ? 'error' : 'success'}
                  />
                </Box>
              </Grid>
              <Grid item xs={6} sm={4}>
                <Typography variant="caption" color="text.secondary">{t('language')}</Typography>
                <Typography variant="body1" fontWeight="medium">{t(child.language || 'english')}</Typography>
              </Grid>
              <Grid item xs={6} sm={4}>
                <Typography variant="caption" color="text.secondary">{t('hospital')}</Typography>
                <Typography variant="body1" fontWeight="medium">{child.hospital_id || child.diagnosis_source || '-'}</Typography>
              </Grid>
              <Grid item xs={6} sm={4}>
                <Typography variant="caption" color="text.secondary">{t('registered')}</Typography>
                <Typography variant="body1" fontWeight="medium">
                  {child.created_at ? format(new Date(child.created_at), 'yyyy-MM-dd') : '-'}
                </Typography>
              </Grid>
              {child.clinician_name && (
                <Grid item xs={12} sm={4}>
                  <Typography variant="caption" color="text.secondary">{t('examined_by')}</Typography>
                  <Typography variant="body1" fontWeight="medium">{child.clinician_name}</Typography>
                </Grid>
              )}
            </Grid>
          </Paper>
        </Grid>

        <Grid item xs={12} md={5}>
          <Card sx={{ height: '100%', bgcolor: alpha('#2563EB', 0.03), borderRadius: 2 }}>
            <CardContent>
              <Typography variant="h6" gutterBottom fontWeight="bold">
                {t('diagnostic_summary')}
              </Typography>
              <Stack spacing={2} sx={{ mt: 2 }}>
                <Box display="flex" justifyContent="space-between">
                  <Typography variant="body2">{t('overall_risk')}</Typography>
                  <Chip 
                    label={t(sessions.some(s => s.risk_level === 'high') ? 'high' : 
                           sessions.some(s => s.risk_level === 'moderate') ? 'moderate' : 'low')}
                    size="small"
                    color={sessions.some(s => s.risk_level === 'high') ? 'error' : 
                           sessions.some(s => s.risk_level === 'moderate') ? 'warning' : 'success'}
                    sx={{ fontWeight: 'bold' }}
                  />
                </Box>
                <Box display="flex" justifyContent="space-between">
                  <Typography variant="body2">{t('avg_score')}</Typography>
                  <Typography variant="body2" fontWeight="bold">
                    {(sessions.reduce((sum, s) => sum + (s.risk_score || 0), 0) / (sessions.length || 1)).toFixed(1)}%
                  </Typography>
                </Box>
                <Divider />
                <Typography variant="caption" color="text.secondary" fontWeight="bold">
                  {t('initial_clinical_notes')}
                </Typography>
                <Typography variant="body2">
                  {child.external_diagnosis ? `${t('initial_diagnosis')}: ${t(child.external_diagnosis)}` : t('no_clinical_notes')}
                </Typography>
              </Stack>
            </CardContent>
          </Card>
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
                          <Card variant="outlined" sx={{ mb: 1 }}>
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
                                  <Chip
                                    label={t(session.risk_level || session.ml_prediction?.risk_level || 'pending')}
                                    size="small"
                                    color={
                                      (session.risk_level || session.ml_prediction?.risk_level) === 'high' ? 'error' : 
                                      (session.risk_level || session.ml_prediction?.risk_level) === 'moderate' ? 'warning' : 
                                      (session.risk_level || session.ml_prediction?.risk_level) === 'low' ? 'success' : 'default'
                                    }
                                  />
                                </Stack>
                              </Box>
                              
                              <Grid container spacing={2}>
                                <Grid item xs={12} sm={4}>
                                  <Typography variant="caption" color="text.secondary">{t('risk_score')}</Typography>
                                  <Typography variant="body1" fontWeight="bold">
                                    {((session.risk_score || session.ml_prediction?.risk_score || 0)).toFixed(1)}%
                                  </Typography>
                                </Grid>
                                <Grid item xs={12} sm={8}>
                                  <Typography variant="caption" color="text.secondary">{t('result_summary')}</Typography>
                                  <Typography variant="body2" sx={{ fontStyle: 'italic' }}>
                                    {session.ml_prediction?.result_summary || session.result_summary || t('no_summary_available')}
                                  </Typography>
                                </Grid>
                              </Grid>

                              {session.ml_prediction?.explanations && (
                                <Box mt={2} p={1.5} sx={{ bgcolor: alpha('#000', 0.02), borderRadius: 1 }}>
                                  <Typography variant="caption" color="primary" fontWeight="bold" display="block" mb={0.5}>
                                    {t('clinical_explanations')}
                                  </Typography>
                                  <Stack spacing={0.5}>
                                    {Object.entries(session.ml_prediction.explanations).map(([key, val]: [string, any]) => (
                                      <Typography key={key} variant="caption" display="block">
                                        • <strong>{key.replace(/_/g, ' ')}:</strong> {val}
                                      </Typography>
                                    ))}
                                  </Stack>
                                </Box>
                              )}

                              <Box mt={2} display="flex" gap={1}>
                                <Button
                                  size="small"
                                  variant="contained"
                                  onClick={() => navigate(`/sessions/${session.id}`)}
                                >
                                  {t('view_full_report')}
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

