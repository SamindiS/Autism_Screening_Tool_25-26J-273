import { useEffect, useState } from 'react'
import {
  Grid,
  Paper,
  Typography,
  Box,
  CircularProgress,
  Card,
  CardContent,
  Button,
  Chip,
  Divider,
  LinearProgress,
} from '@mui/material'
import {
  Psychology,
  Repeat,
  Hearing,
  Visibility,
  People,
  Assessment,
  TrendingUp,
  CalendarToday,
  PersonAdd,
  FileDownload,
  ArrowForward,
} from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { childrenApi, sessionsApi, cliniciansApi } from '../../services/api'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
} from 'recharts'
import { isAdmin } from '../../services/auth'

const Dashboard = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [stats, setStats] = useState({
    totalChildren: 0,
    totalSessions: 0,
    completedSessions: 0,
    pendingSessions: 0,
    todaySessions: 0,
    asdCount: 0,
    controlCount: 0,
    highRisk: 0,
    moderateRisk: 0,
    lowRisk: 0,
    totalDoctors: 0,
  })
  const [recentChildren, setRecentChildren] = useState<any[]>([])
  const [ageDistribution, setAgeDistribution] = useState<any[]>([])
  const [componentStats, setComponentStats] = useState({
    cognitive: 0,
    rrb: 0,
    auditory: 0,
    visual: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const [childrenRes, sessionsRes, doctorsRes] = await Promise.all([
        childrenApi.getAll(),
        sessionsApi.getAll(),
        isAdmin() ? cliniciansApi.getAll() : Promise.resolve({ data: { clinicians: [] } }),
      ])

      const children = childrenRes.data.children || []
      const sessions = sessionsRes.data.sessions || []
      const doctors = doctorsRes.data.clinicians || []

      // Basic stats
      const asdCount = children.filter((c: any) => c.group === 'asd').length
      const controlCount = children.filter((c: any) => c.group === 'typically_developing').length
      const completedSessions = sessions.filter((s: any) => s.end_time != null).length
      const pendingSessions = sessions.filter((s: any) => s.end_time == null).length

      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const todaySessions = sessions.filter((s: any) => {
        if (!s.created_at) return false
        const sessionDate = new Date(s.created_at)
        return sessionDate >= today
      }).length

      const highRisk = sessions.filter((s: any) => s.risk_level === 'high').length
      const moderateRisk = sessions.filter((s: any) => s.risk_level === 'moderate').length
      const lowRisk = sessions.filter((s: any) => s.risk_level === 'low').length

      // Component stats
      const cognitiveSessions = sessions.filter((s: any) =>
        ['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment'].includes(s.session_type)
      )
      const rrbSessions = sessions.filter((s: any) => s.session_type === 'rrb')
      const auditorySessions = sessions.filter((s: any) => s.session_type === 'auditory')
      const visualSessions = sessions.filter((s: any) => s.session_type === 'visual')

      // Age distribution
      const ageGroups = {
        '2-3 years': 0,
        '3-4 years': 0,
        '4-5 years': 0,
        '5-6 years': 0,
        '6+ years': 0,
      }
      children.forEach((c: any) => {
        const age = c.age || 0
        if (age >= 2 && age < 3) ageGroups['2-3 years']++
        else if (age >= 3 && age < 4) ageGroups['3-4 years']++
        else if (age >= 4 && age < 5) ageGroups['4-5 years']++
        else if (age >= 5 && age < 6) ageGroups['5-6 years']++
        else if (age >= 6) ageGroups['6+ years']++
      })
      setAgeDistribution(
        Object.entries(ageGroups).map(([name, value]) => ({ name, value }))
      )

      // Recent children (last 5)
      const sortedChildren = [...children].sort(
        (a: any, b: any) => (b.created_at || 0) - (a.created_at || 0)
      )
      setRecentChildren(sortedChildren.slice(0, 5))

      setStats({
        totalChildren: children.length,
        totalSessions: sessions.length,
        completedSessions,
        pendingSessions,
        todaySessions,
        asdCount,
        controlCount,
        highRisk,
        moderateRisk,
        lowRisk,
        totalDoctors: doctors.length,
      })

      setComponentStats({
        cognitive: cognitiveSessions.length,
        rrb: rrbSessions.length,
        auditory: auditorySessions.length,
        visual: visualSessions.length,
      })
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const groupData = [
    { name: t('asd_group'), value: stats.asdCount, color: '#dc004e' },
    { name: t('control_group'), value: stats.controlCount, color: '#2e7d32' },
  ]

  const riskData = [
    { name: t('high_risk'), value: stats.highRisk, color: '#d32f2f' },
    { name: t('moderate_risk'), value: stats.moderateRisk, color: '#ed6c02' },
    { name: t('low_risk'), value: stats.lowRisk, color: '#2e7d32' },
  ]

  const componentData = [
    { name: t('cognitive_flexibility'), value: componentStats.cognitive, color: '#2563EB' },
    { name: t('rrb'), value: componentStats.rrb, color: '#7C3AED' },
    { name: t('auditory_checking'), value: componentStats.auditory, color: '#0EA5E9' },
    { name: t('visual_checking'), value: componentStats.visual, color: '#059669' },
  ]

  const completionRate =
    stats.totalSessions > 0
      ? ((stats.completedSessions / stats.totalSessions) * 100).toFixed(1)
      : '0'

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box>
      {/* Header */}
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box>
          <Typography variant="h4" fontWeight="bold" gutterBottom>
            {t('dashboard')}
          </Typography>
          <Typography variant="body2" color="text.secondary">
            {new Date().toLocaleDateString('en-US', {
              weekday: 'long',
              year: 'numeric',
              month: 'long',
              day: 'numeric',
            })}
          </Typography>
        </Box>
        <Box display="flex" gap={2}>
          <Button
            variant="contained"
            startIcon={<PersonAdd />}
            onClick={() => navigate('/children')}
          >
            {t('add_child')}
          </Button>
          <Button
            variant="outlined"
            startIcon={<FileDownload />}
            onClick={() => navigate('/export')}
          >
            {t('export')}
          </Button>
        </Box>
      </Box>

      {/* Key Metrics */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ height: '100%', background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)' }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" color="rgba(255,255,255,0.8)" gutterBottom>
                    {t('total_children')}
                  </Typography>
                  <Typography variant="h3" color="white" fontWeight="bold">
                    {stats.totalChildren}
                  </Typography>
                </Box>
                <People sx={{ fontSize: 48, color: 'rgba(255,255,255,0.3)' }} />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ height: '100%', background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)' }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" color="rgba(255,255,255,0.8)" gutterBottom>
                    {t('total_assessments')}
                  </Typography>
                  <Typography variant="h3" color="white" fontWeight="bold">
                    {stats.totalSessions}
                  </Typography>
                  <Typography variant="caption" color="rgba(255,255,255,0.7)" sx={{ mt: 0.5 }}>
                    {stats.completedSessions} {t('completed')}
                  </Typography>
                </Box>
                <Assessment sx={{ fontSize: 48, color: 'rgba(255,255,255,0.3)' }} />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ height: '100%', background: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)' }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" color="rgba(255,255,255,0.8)" gutterBottom>
                    {t('today')}
                  </Typography>
                  <Typography variant="h3" color="white" fontWeight="bold">
                    {stats.todaySessions}
                  </Typography>
                  <Typography variant="caption" color="rgba(255,255,255,0.7)" sx={{ mt: 0.5 }}>
                    {t('assessments_today')}
                  </Typography>
                </Box>
                <CalendarToday sx={{ fontSize: 48, color: 'rgba(255,255,255,0.3)' }} />
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ height: '100%', background: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)' }}>
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="center">
                <Box>
                  <Typography variant="body2" color="rgba(255,255,255,0.8)" gutterBottom>
                    {t('completion_rate')}
                  </Typography>
                  <Typography variant="h3" color="white" fontWeight="bold">
                    {completionRate}%
                  </Typography>
                  <LinearProgress
                    variant="determinate"
                    value={parseFloat(completionRate)}
                    sx={{
                      mt: 1,
                      height: 6,
                      borderRadius: 3,
                      bgcolor: 'rgba(255,255,255,0.2)',
                      '& .MuiLinearProgress-bar': {
                        bgcolor: 'white',
                      },
                    }}
                  />
                </Box>
                <TrendingUp sx={{ fontSize: 48, color: 'rgba(255,255,255,0.3)' }} />
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Study Progress */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('study_progress')}
            </Typography>
            <Box sx={{ mt: 2 }}>
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2">{t('asd_group')}</Typography>
                <Typography variant="body2" fontWeight="bold">
                  {stats.asdCount} / 90
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={(stats.asdCount / 90) * 100}
                sx={{ height: 10, borderRadius: 5, mb: 2 }}
                color="error"
              />
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2">{t('control_group')}</Typography>
                <Typography variant="body2" fontWeight="bold">
                  {stats.controlCount} / 90
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={(stats.controlCount / 90) * 100}
                sx={{ height: 10, borderRadius: 5 }}
                color="success"
              />
            </Box>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('risk_distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={riskData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Bar dataKey="value" fill="#1976d2" radius={[8, 8, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
      </Grid>

      {/* Assessment Components */}
      <Paper sx={{ p: 3, mb: 3 }}>
        <Typography variant="h6" fontWeight="bold" gutterBottom>
          {t('assessment_components')}
        </Typography>
        <Grid container spacing={2} sx={{ mt: 1 }}>
          {componentData.map((component) => (
            <Grid item xs={12} sm={6} md={3} key={component.name}>
              <Card
                sx={{
                  cursor: 'pointer',
                  transition: 'all 0.3s',
                  '&:hover': {
                    transform: 'translateY(-4px)',
                    boxShadow: 4,
                  },
                }}
                onClick={() => {
                  if (component.name === t('cognitive_flexibility')) navigate('/cognitive')
                  else if (component.name === t('rrb')) navigate('/rrb')
                  else if (component.name === t('auditory_checking')) navigate('/auditory')
                  else if (component.name === t('visual_checking')) navigate('/visual')
                }}
              >
                <CardContent>
                  <Box display="flex" alignItems="center" gap={2}>
                    <Box
                      sx={{
                        width: 56,
                        height: 56,
                        borderRadius: 2,
                        bgcolor: `${component.color}15`,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      {component.name === t('cognitive_flexibility') && (
                        <Psychology sx={{ fontSize: 32, color: component.color }} />
                      )}
                      {component.name === t('rrb') && (
                        <Repeat sx={{ fontSize: 32, color: component.color }} />
                      )}
                      {component.name === t('auditory_checking') && (
                        <Hearing sx={{ fontSize: 32, color: component.color }} />
                      )}
                      {component.name === t('visual_checking') && (
                        <Visibility sx={{ fontSize: 32, color: component.color }} />
                      )}
                    </Box>
                    <Box flex={1}>
                      <Typography variant="body2" color="text.secondary">
                        {component.name}
                      </Typography>
                      <Typography variant="h5" fontWeight="bold" color={component.color}>
                        {component.value}
                      </Typography>
                    </Box>
                    <ArrowForward sx={{ color: 'text.secondary' }} />
                  </Box>
                </CardContent>
              </Card>
            </Grid>
          ))}
        </Grid>
      </Paper>

      {/* Charts and Recent Activity */}
      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('group')} {t('distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={groupData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {groupData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('age_distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={ageDistribution} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" />
                <YAxis dataKey="name" type="category" width={80} />
                <Tooltip />
                <Bar dataKey="value" fill="#1976d2" radius={[0, 8, 8, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('recent_children')}
            </Typography>
            <Box sx={{ mt: 2 }}>
              {recentChildren.length === 0 ? (
                <Typography variant="body2" color="text.secondary" align="center" sx={{ py: 4 }}>
                  {t('no_data')}
                </Typography>
              ) : (
                recentChildren.map((child, index) => (
                  <Box key={child.id}>
                    <Box
                      display="flex"
                      justifyContent="space-between"
                      alignItems="center"
                      py={1.5}
                      sx={{ cursor: 'pointer' }}
                      onClick={() => navigate(`/children/${child.id}`)}
                    >
                      <Box>
                        <Typography variant="body2" fontWeight="medium">
                          {child.name}
                        </Typography>
                        <Typography variant="caption" color="text.secondary">
                          {child.child_code || '-'} • {child.age?.toFixed(1) || '-'} {t('years')}
                        </Typography>
                      </Box>
                      <Chip
                        label={t(child.group || 'typically_developing')}
                        size="small"
                        color={child.group === 'asd' ? 'error' : 'success'}
                      />
                    </Box>
                    {index < recentChildren.length - 1 && <Divider />}
                  </Box>
                ))
              )}
            </Box>
            <Button
              fullWidth
              variant="outlined"
              sx={{ mt: 2 }}
              onClick={() => navigate('/children')}
            >
              {t('view_all')}
            </Button>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  )
}

export default Dashboard
