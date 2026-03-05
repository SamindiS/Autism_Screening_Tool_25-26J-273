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
  Stack,
  Avatar,
  IconButton,
  Tooltip,
  Menu,
  MenuItem,
  Select,
  FormControl,
  InputLabel,
  alpha,
} from '@mui/material'
import {
  Psychology,
  Repeat,
  Hearing,
  Visibility,
  People,
  Assessment,
  TrendingUp,
  TrendingDown,
  CalendarToday,
  PersonAdd,
  FileDownload,
  ArrowForward,
  Refresh,
  MoreVert,
  Warning,
  CheckCircle,
  Schedule,
  Analytics,
  Timeline,
  BarChart as BarChartIcon,
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
  Tooltip as RechartsTooltip,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  LineChart,
  Line,
  Legend,
  Area,
  AreaChart,
} from 'recharts'
import { isAdmin } from '../../services/auth'
import { format, subDays, startOfWeek, endOfWeek } from 'date-fns'

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
    avgRiskScore: 0,
    weeklyGrowth: 0,
  })
  const [recentChildren, setRecentChildren] = useState<any[]>([])
  const [ageDistribution, setAgeDistribution] = useState<any[]>([])
  const [componentStats, setComponentStats] = useState({
    cognitive: 0,
    rrb: 0,
    auditory: 0,
    visual: 0,
  })
  const [sessionTrend, setSessionTrend] = useState<any[]>([])
  const [riskTrend, setRiskTrend] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d' | 'all'>('30d')
  const [refreshAnchor, setRefreshAnchor] = useState<null | HTMLElement>(null)

  useEffect(() => {
    loadStats()
  }, [timeRange])

  const loadStats = async () => {
    try {
      setLoading(true)
      console.log('📊 Loading dashboard stats...')
      
      const [childrenRes, sessionsRes, doctorsRes] = await Promise.all([
        childrenApi.getAll(),
        sessionsApi.getAll(),
        isAdmin() ? cliniciansApi.getAll() : Promise.resolve({ data: { clinicians: [] } }),
      ])

      console.log('📥 Dashboard data received:', {
        childrenCount: childrenRes.data.children?.length || 0,
        sessionsCount: sessionsRes.data.sessions?.length || 0,
        doctorsCount: doctorsRes.data.clinicians?.length || 0,
      })

      const children = childrenRes.data.children || []
      const sessions = sessionsRes.data.sessions || []
      const doctors = doctorsRes.data.clinicians || []
      
      console.log('📊 Processed data:', {
        children: children.length,
        sessions: sessions.length,
        doctors: doctors.length,
      })

      // Filter by time range
      const filteredSessions = filterByTimeRange(sessions, timeRange)

      // Basic stats
      const asdCount = children.filter((c: any) => c.group === 'asd').length
      const controlCount = children.filter((c: any) => c.group === 'typically_developing').length
      const completedSessions = filteredSessions.filter((s: any) => s.end_time != null).length
      const pendingSessions = filteredSessions.filter((s: any) => s.end_time == null).length

      const today = new Date()
      today.setHours(0, 0, 0, 0)
      const todaySessions = filteredSessions.filter((s: any) => {
        if (!s.created_at) return false
        const sessionDate = new Date(s.created_at)
        return sessionDate >= today
      }).length

      const highRisk = filteredSessions.filter((s: any) => s.risk_level === 'high').length
      const moderateRisk = filteredSessions.filter((s: any) => s.risk_level === 'moderate').length
      const lowRisk = filteredSessions.filter((s: any) => s.risk_level === 'low').length

      // Calculate average risk score
      const sessionsWithRisk = filteredSessions.filter((s: any) => s.risk_score != null)
      const avgRiskScore = sessionsWithRisk.length > 0
        ? sessionsWithRisk.reduce((sum: number, s: any) => sum + (s.risk_score || 0), 0) / sessionsWithRisk.length
        : 0

      // Weekly growth calculation
      const lastWeek = sessions.filter((s: any) => {
        if (!s.created_at) return false
        const sessionDate = new Date(s.created_at)
        const weekAgo = subDays(new Date(), 7)
        return sessionDate >= weekAgo && sessionDate < today
      }).length
      const previousWeek = sessions.filter((s: any) => {
        if (!s.created_at) return false
        const sessionDate = new Date(s.created_at)
        const twoWeeksAgo = subDays(new Date(), 14)
        const weekAgo = subDays(new Date(), 7)
        return sessionDate >= twoWeeksAgo && sessionDate < weekAgo
      }).length
      const weeklyGrowth = previousWeek > 0 ? ((lastWeek - previousWeek) / previousWeek) * 100 : 0

      // Component stats
      const cognitiveSessions = filteredSessions.filter((s: any) =>
        ['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment'].includes(s.session_type)
      )
      const rrbSessions = filteredSessions.filter((s: any) => s.session_type === 'rrb')
      const auditorySessions = filteredSessions.filter((s: any) => s.session_type === 'auditory')
      const visualSessions = filteredSessions.filter((s: any) => s.session_type === 'visual')

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

      // Session trend (last 7 days)
      const trendData = generateSessionTrend(filteredSessions, 7)
      setSessionTrend(trendData)

      // Risk trend
      const riskTrendData = generateRiskTrend(filteredSessions, 7)
      setRiskTrend(riskTrendData)

      // Recent children (last 5)
      const sortedChildren = [...children].sort(
        (a: any, b: any) => (b.created_at || 0) - (a.created_at || 0)
      )
      setRecentChildren(sortedChildren.slice(0, 5))

      setStats({
        totalChildren: children.length,
        totalSessions: filteredSessions.length,
        completedSessions,
        pendingSessions,
        todaySessions,
        asdCount,
        controlCount,
        highRisk,
        moderateRisk,
        lowRisk,
        totalDoctors: doctors.length,
        avgRiskScore: Math.round(avgRiskScore),
        weeklyGrowth: Math.round(weeklyGrowth),
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

  const filterByTimeRange = (sessions: any[], range: string) => {
    if (range === 'all') return sessions
    const days = range === '7d' ? 7 : range === '30d' ? 30 : 90
    const cutoff = subDays(new Date(), days)
    return sessions.filter((s: any) => {
      if (!s.created_at) return false
      return new Date(s.created_at) >= cutoff
    })
  }

  const generateSessionTrend = (sessions: any[], days: number) => {
    const data = []
    for (let i = days - 1; i >= 0; i--) {
      const date = subDays(new Date(), i)
      const dayStart = new Date(date)
      dayStart.setHours(0, 0, 0, 0)
      const dayEnd = new Date(date)
      dayEnd.setHours(23, 59, 59, 999)

      const daySessions = sessions.filter((s: any) => {
        if (!s.created_at) return false
        const sessionDate = new Date(s.created_at)
        return sessionDate >= dayStart && sessionDate <= dayEnd
      })

      data.push({
        date: format(date, 'MMM dd'),
        sessions: daySessions.length,
        completed: daySessions.filter((s: any) => s.end_time != null).length,
      })
    }
    return data
  }

  const generateRiskTrend = (sessions: any[], days: number) => {
    const data = []
    for (let i = days - 1; i >= 0; i--) {
      const date = subDays(new Date(), i)
      const dayStart = new Date(date)
      dayStart.setHours(0, 0, 0, 0)
      const dayEnd = new Date(date)
      dayEnd.setHours(23, 59, 59, 999)

      const daySessions = sessions.filter((s: any) => {
        if (!s.created_at) return false
        const sessionDate = new Date(s.created_at)
        return sessionDate >= dayStart && sessionDate <= dayEnd
      })

      data.push({
        date: format(date, 'MMM dd'),
        high: daySessions.filter((s: any) => s.risk_level === 'high').length,
        moderate: daySessions.filter((s: any) => s.risk_level === 'moderate').length,
        low: daySessions.filter((s: any) => s.risk_level === 'low').length,
      })
    }
    return data
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
    { name: t('cognitive_flexibility'), value: componentStats.cognitive, color: '#2563EB', icon: Psychology },
    { name: t('rrb'), value: componentStats.rrb, color: '#7C3AED', icon: Repeat },
    { name: t('auditory_checking'), value: componentStats.auditory, color: '#0EA5E9', icon: Hearing },
    { name: t('visual_checking'), value: componentStats.visual, color: '#059669', icon: Visibility },
  ]

  const completionRate =
    stats.totalSessions > 0
      ? ((stats.completedSessions / stats.totalSessions) * 100).toFixed(1)
      : '0'

  const handleRefresh = () => {
    loadStats()
    setRefreshAnchor(null)
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  return (
    <Box sx={{ pb: 4 }}>
      {/* Professional Header */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          borderRadius: 3,
          p: 4,
          mb: 4,
          color: 'white',
        }}
      >
        <Box display="flex" justifyContent="space-between" alignItems="flex-start">
          <Box>
            <Typography variant="h4" fontWeight="bold" gutterBottom>
              {t('dashboard')}
            </Typography>
            <Typography variant="body1" sx={{ opacity: 0.9, mb: 2 }}>
              {format(new Date(), 'EEEE, MMMM dd, yyyy')}
            </Typography>
            <Stack direction="row" spacing={2} alignItems="center">
              <Chip
                icon={<Schedule />}
                label={`${stats.todaySessions} ${t('assessments_today')}`}
                sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white' }}
              />
              {stats.weeklyGrowth !== 0 && (
                <Chip
                  icon={stats.weeklyGrowth > 0 ? <TrendingUp /> : <TrendingDown />}
                  label={`${stats.weeklyGrowth > 0 ? '+' : ''}${stats.weeklyGrowth}% ${t('weekly_growth')}`}
                  sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white' }}
                />
              )}
            </Stack>
          </Box>
          <Stack direction="row" spacing={2}>
            <FormControl size="small" sx={{ minWidth: 120, bgcolor: 'rgba(255,255,255,0.2)' }}>
              <InputLabel sx={{ color: 'white' }}>{t('time_range')}</InputLabel>
              <Select
                value={timeRange}
                onChange={(e) => setTimeRange(e.target.value as any)}
                label={t('time_range')}
                sx={{ color: 'white', '& .MuiOutlinedInput-notchedOutline': { borderColor: 'rgba(255,255,255,0.3)' } }}
              >
                <MenuItem value="7d">{t('last_7_days')}</MenuItem>
                <MenuItem value="30d">{t('last_30_days')}</MenuItem>
                <MenuItem value="90d">{t('last_90_days')}</MenuItem>
                <MenuItem value="all">{t('all_time')}</MenuItem>
              </Select>
            </FormControl>
            <Tooltip title={t('refresh')}>
              <IconButton
                onClick={(e) => setRefreshAnchor(e.currentTarget)}
                sx={{ color: 'white', bgcolor: 'rgba(255,255,255,0.2)' }}
              >
                <Refresh />
              </IconButton>
            </Tooltip>
            <Button
              variant="contained"
              startIcon={<FileDownload />}
              onClick={() => navigate('/export')}
              sx={{ bgcolor: 'white', color: '#667eea', '&:hover': { bgcolor: 'rgba(255,255,255,0.9)' } }}
            >
              {t('export')}
            </Button>
          </Stack>
        </Box>
      </Box>

      {/* Key Metrics Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              height: '100%',
              background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
              color: 'white',
              transition: 'transform 0.2s',
              '&:hover': { transform: 'translateY(-4px)' },
            }}
          >
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="flex-start">
                <Box>
                  <Typography variant="body2" sx={{ opacity: 0.9 }} gutterBottom>
                    {t('total_children')}
                  </Typography>
                  <Typography variant="h3" fontWeight="bold">
                    {stats.totalChildren}
                  </Typography>
                  <Stack direction="row" spacing={1} sx={{ mt: 1 }}>
                    <Chip
                      label={`${stats.asdCount} ASD`}
                      size="small"
                      sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white', height: 20 }}
                    />
                    <Chip
                      label={`${stats.controlCount} Control`}
                      size="small"
                      sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white', height: 20 }}
                    />
                  </Stack>
                </Box>
                <Avatar sx={{ bgcolor: 'rgba(255,255,255,0.2)', width: 56, height: 56 }}>
                  <People sx={{ fontSize: 32 }} />
                </Avatar>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              height: '100%',
              background: 'linear-gradient(135deg, #f093fb 0%, #f5576c 100%)',
              color: 'white',
              transition: 'transform 0.2s',
              '&:hover': { transform: 'translateY(-4px)' },
            }}
          >
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="flex-start">
                <Box>
                  <Typography variant="body2" sx={{ opacity: 0.9 }} gutterBottom>
                    {t('total_assessments')}
                  </Typography>
                  <Typography variant="h3" fontWeight="bold">
                    {stats.totalSessions}
                  </Typography>
                  <Stack direction="row" spacing={1} sx={{ mt: 1 }}>
                    <Chip
                      icon={<CheckCircle sx={{ fontSize: 14 }} />}
                      label={`${stats.completedSessions} ${t('completed')}`}
                      size="small"
                      sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white', height: 20 }}
                    />
                    {stats.pendingSessions > 0 && (
                      <Chip
                        icon={<Schedule sx={{ fontSize: 14 }} />}
                        label={`${stats.pendingSessions} ${t('pending')}`}
                        size="small"
                        sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white', height: 20 }}
                      />
                    )}
                  </Stack>
                </Box>
                <Avatar sx={{ bgcolor: 'rgba(255,255,255,0.2)', width: 56, height: 56 }}>
                  <Assessment sx={{ fontSize: 32 }} />
                </Avatar>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              height: '100%',
              background: 'linear-gradient(135deg, #4facfe 0%, #00f2fe 100%)',
              color: 'white',
              transition: 'transform 0.2s',
              '&:hover': { transform: 'translateY(-4px)' },
            }}
          >
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="flex-start">
                <Box>
                  <Typography variant="body2" sx={{ opacity: 0.9 }} gutterBottom>
                    {t('avg_risk_score')}
                  </Typography>
                  <Typography variant="h3" fontWeight="bold">
                    {stats.avgRiskScore}
                  </Typography>
                  <Stack direction="row" spacing={1} sx={{ mt: 1 }}>
                    <Chip
                      icon={<Warning sx={{ fontSize: 14 }} />}
                      label={`${stats.highRisk} ${t('high_risk')}`}
                      size="small"
                      sx={{ bgcolor: 'rgba(255,255,255,0.2)', color: 'white', height: 20 }}
                    />
                  </Stack>
                </Box>
                <Avatar sx={{ bgcolor: 'rgba(255,255,255,0.2)', width: 56, height: 56 }}>
                  <Analytics sx={{ fontSize: 32 }} />
                </Avatar>
              </Box>
            </CardContent>
          </Card>
        </Grid>

        <Grid item xs={12} sm={6} md={3}>
          <Card
            sx={{
              height: '100%',
              background: 'linear-gradient(135deg, #43e97b 0%, #38f9d7 100%)',
              color: 'white',
              transition: 'transform 0.2s',
              '&:hover': { transform: 'translateY(-4px)' },
            }}
          >
            <CardContent>
              <Box display="flex" justifyContent="space-between" alignItems="flex-start">
                <Box>
                  <Typography variant="body2" sx={{ opacity: 0.9 }} gutterBottom>
                    {t('completion_rate')}
                  </Typography>
                  <Typography variant="h3" fontWeight="bold">
                    {completionRate}%
                  </Typography>
                  <LinearProgress
                    variant="determinate"
                    value={parseFloat(completionRate)}
                    sx={{
                      mt: 1.5,
                      height: 8,
                      borderRadius: 4,
                      bgcolor: 'rgba(255,255,255,0.2)',
                      '& .MuiLinearProgress-bar': {
                        bgcolor: 'white',
                        borderRadius: 4,
                      },
                    }}
                  />
                </Box>
                <Avatar sx={{ bgcolor: 'rgba(255,255,255,0.2)', width: 56, height: 56 }}>
                  <TrendingUp sx={{ fontSize: 32 }} />
                </Avatar>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Charts Row */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Session Trend */}
        <Grid item xs={12} md={8}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
              <Typography variant="h6" fontWeight="bold">
                {t('session_trend')}
              </Typography>
              <Chip icon={<Timeline />} label={t('last_7_days')} size="small" />
            </Box>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={sessionTrend}>
                <defs>
                  <linearGradient id="colorSessions" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#667eea" stopOpacity={0.8} />
                    <stop offset="95%" stopColor="#667eea" stopOpacity={0} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis dataKey="date" stroke="#666" />
                <YAxis stroke="#666" />
                <RechartsTooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    border: '1px solid #e0e0e0',
                    borderRadius: 8,
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="sessions"
                  stroke="#667eea"
                  fillOpacity={1}
                  fill="url(#colorSessions)"
                  name={t('total_sessions')}
                />
                <Area
                  type="monotone"
                  dataKey="completed"
                  stroke="#43e97b"
                  fillOpacity={0.6}
                  fill="#43e97b"
                  name={t('completed')}
                />
              </AreaChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        {/* Risk Distribution */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('risk_distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={riskData}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {riskData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <RechartsTooltip />
              </PieChart>
            </ResponsiveContainer>
            <Stack spacing={1} sx={{ mt: 2 }}>
              {riskData.map((item) => (
                <Box key={item.name} display="flex" justifyContent="space-between" alignItems="center">
                  <Box display="flex" alignItems="center" gap={1}>
                    <Box
                      sx={{
                        width: 12,
                        height: 12,
                        borderRadius: '50%',
                        bgcolor: item.color,
                      }}
                    />
                    <Typography variant="body2">{item.name}</Typography>
                  </Box>
                  <Typography variant="body2" fontWeight="bold">
                    {item.value}
                  </Typography>
                </Box>
              ))}
            </Stack>
          </Paper>
        </Grid>
      </Grid>

      {/* Study Progress & Assessment Components */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        {/* Study Progress */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('study_progress')}
            </Typography>
            <Box sx={{ mt: 3 }}>
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2" fontWeight="medium">
                  {t('asd_group')}
                </Typography>
                <Typography variant="body2" fontWeight="bold">
                  {stats.asdCount} / 90 ({((stats.asdCount / 90) * 100).toFixed(1)}%)
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={(stats.asdCount / 90) * 100}
                sx={{
                  height: 12,
                  borderRadius: 6,
                  mb: 3,
                  bgcolor: alpha('#d32f2f', 0.1),
                  '& .MuiLinearProgress-bar': {
                    bgcolor: '#d32f2f',
                    borderRadius: 6,
                  },
                }}
              />
              <Box display="flex" justifyContent="space-between" mb={1}>
                <Typography variant="body2" fontWeight="medium">
                  {t('control_group')}
                </Typography>
                <Typography variant="body2" fontWeight="bold">
                  {stats.controlCount} / 90 ({((stats.controlCount / 90) * 100).toFixed(1)}%)
                </Typography>
              </Box>
              <LinearProgress
                variant="determinate"
                value={(stats.controlCount / 90) * 100}
                sx={{
                  height: 12,
                  borderRadius: 6,
                  bgcolor: alpha('#2e7d32', 0.1),
                  '& .MuiLinearProgress-bar': {
                    bgcolor: '#2e7d32',
                    borderRadius: 6,
                  },
                }}
              />
            </Box>
          </Paper>
        </Grid>

        {/* Assessment Components */}
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('assessment_components')}
            </Typography>
            <Grid container spacing={2} sx={{ mt: 1 }}>
              {componentData.map((component) => {
                const IconComponent = component.icon
                return (
                  <Grid item xs={6} key={component.name}>
                    <Card
                      sx={{
                        cursor: 'pointer',
                        transition: 'all 0.3s',
                        border: '1px solid',
                        borderColor: 'divider',
                        '&:hover': {
                          transform: 'translateY(-4px)',
                          boxShadow: 4,
                          borderColor: component.color,
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
                              width: 48,
                              height: 48,
                              borderRadius: 2,
                              bgcolor: alpha(component.color, 0.1),
                              display: 'flex',
                              alignItems: 'center',
                              justifyContent: 'center',
                            }}
                          >
                            <IconComponent sx={{ fontSize: 24, color: component.color }} />
                          </Box>
                          <Box flex={1}>
                            <Typography variant="body2" color="text.secondary" noWrap>
                              {component.name}
                            </Typography>
                            <Typography variant="h5" fontWeight="bold" color={component.color}>
                              {component.value}
                            </Typography>
                          </Box>
                        </Box>
                      </CardContent>
                    </Card>
                  </Grid>
                )
              })}
            </Grid>
          </Paper>
        </Grid>
      </Grid>

      {/* Bottom Row: Charts and Recent Activity */}
      <Grid container spacing={3}>
        {/* Group Distribution */}
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
                <RechartsTooltip />
              </PieChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        {/* Age Distribution */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Typography variant="h6" fontWeight="bold" gutterBottom>
              {t('age_distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={ageDistribution} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" stroke="#f0f0f0" />
                <XAxis type="number" stroke="#666" />
                <YAxis dataKey="name" type="category" width={80} stroke="#666" />
                <RechartsTooltip
                  contentStyle={{
                    backgroundColor: 'white',
                    border: '1px solid #e0e0e0',
                    borderRadius: 8,
                  }}
                />
                <Bar dataKey="value" fill="#667eea" radius={[0, 8, 8, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        {/* Recent Children */}
        <Grid item xs={12} md={4}>
          <Paper sx={{ p: 3, height: '100%' }}>
            <Box display="flex" justifyContent="space-between" alignItems="center" mb={2}>
              <Typography variant="h6" fontWeight="bold">
                {t('recent_children')}
              </Typography>
              <Button
                size="small"
                onClick={() => navigate('/children')}
                endIcon={<ArrowForward />}
              >
                {t('view_all')}
              </Button>
            </Box>
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
                      sx={{
                        cursor: 'pointer',
                        borderRadius: 1,
                        px: 1,
                        '&:hover': { bgcolor: 'action.hover' },
                      }}
                      onClick={() => navigate(`/children/${child.id}`)}
                    >
                      <Box display="flex" alignItems="center" gap={2}>
                        <Avatar
                          sx={{
                            width: 40,
                            height: 40,
                            bgcolor: child.group === 'asd' ? 'error.main' : 'success.main',
                          }}
                        >
                          {child.name?.charAt(0)?.toUpperCase() || '?'}
                        </Avatar>
                        <Box>
                          <Typography variant="body2" fontWeight="medium">
                            {child.name}
                          </Typography>
                          <Typography variant="caption" color="text.secondary">
                            {child.child_code || '-'} • {child.age?.toFixed(1) || '-'} {t('years')}
                          </Typography>
                        </Box>
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
          </Paper>
        </Grid>
      </Grid>

      {/* Refresh Menu */}
      <Menu
        anchorEl={refreshAnchor}
        open={Boolean(refreshAnchor)}
        onClose={() => setRefreshAnchor(null)}
      >
        <MenuItem onClick={handleRefresh}>
          <Refresh sx={{ mr: 1 }} />
          {t('refresh_data')}
        </MenuItem>
      </Menu>
    </Box>
  )
}

export default Dashboard
