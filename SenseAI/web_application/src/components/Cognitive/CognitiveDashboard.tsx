import { useEffect, useMemo, useState } from 'react'
import {
  Box,
  Paper,
  Typography,
  Grid,
  Card,
  CardContent,
  CardActionArea,
  CircularProgress,
  TextField,
  Chip,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
} from '@mui/material'
import { Psychology, Person, Visibility } from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { childrenApi, sessionsApi } from '../../services/api'
import { format } from 'date-fns'

const CognitiveDashboard = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [children, setChildren] = useState<any[]>([])
  const [sessions, setSessions] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)

  const stats = useMemo(() => {
    const normalizeType = (v: unknown) =>
      String(v || '')
        .toLowerCase()
        .replace(/-/g, '_')
        .replace(/^dccs_/, '')

    const cognitiveTypes = new Set(['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment'])
    const cognitiveSessions = sessions.filter((s: any) => cognitiveTypes.has(normalizeType(s?.session_type)))

    const byType = cognitiveSessions.reduce(
      (acc: Record<string, number>, s: any) => {
        const st = normalizeType(s?.session_type)
        acc[st] = (acc[st] || 0) + 1
        return acc
      },
      {}
    )

    const sessionsWithRisk = cognitiveSessions.filter((s: any) => s?.risk_score != null)
    const avgRiskScore =
      sessionsWithRisk.length > 0
        ? sessionsWithRisk.reduce((sum: number, s: any) => sum + (Number(s.risk_score) || 0), 0) /
          sessionsWithRisk.length
        : 0

    const highRisk = cognitiveSessions.filter((s: any) => (s?.risk_level || '').toLowerCase() === 'high').length
    const moderateRisk = cognitiveSessions.filter((s: any) => (s?.risk_level || '').toLowerCase() === 'moderate').length
    const lowRisk = cognitiveSessions.filter((s: any) => (s?.risk_level || '').toLowerCase() === 'low').length

    return {
      totalChildren: children.length,
      totalSessions: cognitiveSessions.length,
      colorShapeCount: byType.color_shape || 0,
      frogJumpCount: byType.frog_jump || 0,
      aiBotCount: byType.ai_doctor_bot || 0,
      manualCount: byType.manual_assessment || 0,
      highRisk,
      moderateRisk,
      lowRisk,
      avgRiskScore,
    }
  }, [children, sessions])

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    try {
      const [childrenRes, sessionsRes] = await Promise.all([
        childrenApi.getAll(),
        sessionsApi.getAll(),
      ])

      const allChildren = childrenRes.data.children || []
      const allSessions = sessionsRes.data.sessions || []

      const normalizeType = (v: unknown) =>
        String(v || '')
          .toLowerCase()
          .replace(/-/g, '_')
          .replace(/^dccs_/, '')
      const cognitiveTypes = new Set(['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment'])

      const cognitiveSessions = allSessions.filter((s: any) => cognitiveTypes.has(normalizeType(s?.session_type)))
      const childIdsWithCognitive = new Set(cognitiveSessions.map((s: any) => String(s.child_id)))
      const childrenWithCognitive = allChildren.filter((c: any) => childIdsWithCognitive.has(String(c.id)))

      setChildren(childrenWithCognitive)
      setSessions(cognitiveSessions)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredChildren = children.filter((child) =>
    child.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    child.child_code?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const getChildSessions = (childId: string | number) => {
    return sessions.filter((s) => String(s.child_id) === String(childId))
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

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      <Box display="flex" alignItems="center" gap={2} mb={3}>
        <Psychology sx={{ fontSize: 40, color: '#2563EB' }} />
        <Typography variant="h4">{t('cognitive_flexibility')} {t('dashboard')}</Typography>
      </Box>

      {/* Statistics Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('total_children')}
              </Typography>
              <Typography variant="h4">{stats.totalChildren}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('total_sessions')}
              </Typography>
              <Typography variant="h4">{stats.totalSessions}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('color_shape_game')}
              </Typography>
              <Typography variant="h4" color="primary">{stats.colorShapeCount}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('frog_jump_game')}
              </Typography>
              <Typography variant="h4" sx={{ color: '#7C3AED' }}>{stats.frogJumpCount}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('ai_questionnaire')}
              </Typography>
              <Typography variant="h4" sx={{ color: '#0EA5E9' }}>{stats.aiBotCount}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('manual_assessment')}
              </Typography>
              <Typography variant="h4" sx={{ color: '#059669' }}>{stats.manualCount}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'error.main' }}>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('high_risk')}
              </Typography>
              <Typography variant="h4" color="error.main">{stats.highRisk}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'primary.main' }}>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('avg_risk_score')}
              </Typography>
              <Typography variant="h4" color="primary.main">
                {Number.isFinite(stats.avgRiskScore) ? stats.avgRiskScore.toFixed(1) : '0.0'}
              </Typography>
              <Typography variant="body2" color="text.secondary">
                {stats.moderateRisk} {t('moderate_risk')} • {stats.lowRisk} {t('low_risk')}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Search */}
      <TextField
        fullWidth
        label={t('search_children')}
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        sx={{ mb: 3 }}
      />

      {/* Children Cards */}
      <Grid container spacing={3}>
        {filteredChildren.length === 0 ? (
          <Grid item xs={12}>
            <Paper sx={{ p: 4, textAlign: 'center' }}>
              <Typography>{t('no_data')}</Typography>
            </Paper>
          </Grid>
        ) : (
          filteredChildren.map((child) => {
            const childSessions = getChildSessions(child.id)
            return (
              <Grid item xs={12} md={6} lg={4} key={child.id}>
                <Card>
                  <CardActionArea onClick={() => navigate(`/children/${child.id}`)}>
                    <CardContent>
                      <Box display="flex" alignItems="center" gap={2} mb={2}>
                        <Person sx={{ fontSize: 40, color: 'primary.main' }} />
                        <Box flex={1}>
                          <Typography variant="h6">{child.name}</Typography>
                          <Typography variant="body2" color="text.secondary">
                            {child.child_code || '-'}
                          </Typography>
                        </Box>
                      </Box>
                      
                      <Box display="flex" gap={1} mb={2} flexWrap="wrap">
                        {/* Primary Highlight: Latest Assessment Result */}
                        {childSessions.length > 0 ? (
                          (() => {
                            const sortedSessions = [...childSessions].sort((a, b) => 
                              new Date(b.created_at || 0).getTime() - new Date(a.created_at || 0).getTime()
                            );
                            
                            const latestWithRisk = sortedSessions.find(s => s.risk_level || s.ml_prediction?.risk_level);
                            const completedSession = sortedSessions.find(s => s.end_time || s.status === 'completed');
                            
                            if (latestWithRisk) {
                              const risk = latestWithRisk.risk_level || latestWithRisk.ml_prediction?.risk_level;
                              return (
                                <Chip
                                  label={`${t('result')}: ${t(risk)}`}
                                  size="small"
                                  color={
                                    risk === 'high' ? 'error' : 
                                    risk === 'moderate' ? 'warning' : 'success'
                                  }
                                  sx={{ fontWeight: 'bold' }}
                                />
                              );
                            }
                            
                            if (completedSession) {
                              return <Chip label={t('processing')} size="small" variant="outlined" color="warning" />;
                            }
                            
                            return <Chip label={t('pending_result')} size="small" variant="outlined" />;
                          })()
                        ) : (
                          <Chip label={t('no_sessions')} size="small" variant="outlined" />
                        )}

                        {/* Secondary Info: Registration Group */}
                        <Chip
                          label={t(child.group || 'typically_developing')}
                          size="small"
                          variant="outlined"
                          sx={{ opacity: 0.8 }}
                        />

                        {child.age && (
                          <Chip
                            label={`${child.age.toFixed(1)} ${t('years')}`}
                            size="small"
                            variant="outlined"
                          />
                        )}
                      </Box>

                      <Typography variant="body2" color="text.secondary">
                        {childSessions.length} {t('cognitive')} {t('sessions')}
                      </Typography>
                    </CardContent>
                  </CardActionArea>
                </Card>
              </Grid>
            )
          })
        )}
      </Grid>

      {/* Recent Sessions Table */}
      <Box sx={{ mt: 4 }}>
        <Typography variant="h6" gutterBottom>
          {t('recent_sessions')}
        </Typography>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('child')}</TableCell>
                <TableCell>{t('session_type')}</TableCell>
                <TableCell>{t('risk_level')}</TableCell>
                <TableCell>{t('date')}</TableCell>
                <TableCell>{t('actions')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {sessions.slice(0, 10).map((session) => {
                const child = children.find((c) => c.id === session.child_id)
                return (
                  <TableRow key={session.id}>
                    <TableCell>{child?.name || session.child_id}</TableCell>
                    <TableCell>{getSessionTypeLabel(session.session_type)}</TableCell>
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
                )
              })}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
    </Box>
  )
}

export default CognitiveDashboard








