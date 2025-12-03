import { useEffect, useState } from 'react'
import { Grid, Paper, Typography, Box, CircularProgress } from '@mui/material'
import { useTranslation } from 'react-i18next'
import { childrenApi, sessionsApi } from '../../services/api'
import StatsCard from './StatsCard'
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, PieChart, Pie, Cell } from 'recharts'

const Dashboard = () => {
  const { t } = useTranslation()
  const [stats, setStats] = useState({
    totalChildren: 0,
    totalSessions: 0,
    asdCount: 0,
    controlCount: 0,
    highRisk: 0,
    moderateRisk: 0,
    lowRisk: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadStats()
  }, [])

  const loadStats = async () => {
    try {
      const [childrenRes, sessionsRes] = await Promise.all([
        childrenApi.getAll(),
        sessionsApi.getAll(),
      ])

      const children = childrenRes.data.children || []
      const sessions = sessionsRes.data.sessions || []

      const asdCount = children.filter((c: any) => c.group === 'asd').length
      const controlCount = children.filter((c: any) => c.group === 'typically_developing').length

      const highRisk = sessions.filter((s: any) => s.risk_level === 'high').length
      const moderateRisk = sessions.filter((s: any) => s.risk_level === 'moderate').length
      const lowRisk = sessions.filter((s: any) => s.risk_level === 'low').length

      setStats({
        totalChildren: children.length,
        totalSessions: sessions.length,
        asdCount,
        controlCount,
        highRisk,
        moderateRisk,
        lowRisk,
      })
    } catch (error) {
      console.error('Error loading stats:', error)
    } finally {
      setLoading(false)
    }
  }

  const groupData = [
    { name: t('asd_group'), value: stats.asdCount },
    { name: t('control_group'), value: stats.controlCount },
  ]

  const riskData = [
    { name: t('high_risk'), value: stats.highRisk },
    { name: t('moderate_risk'), value: stats.moderateRisk },
    { name: t('low_risk'), value: stats.lowRisk },
  ]

  const COLORS = ['#1976d2', '#dc004e', '#ed6c02', '#2e7d32']

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
        {t('dashboard')}
      </Typography>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard title={t('total_children')} value={stats.totalChildren} color="primary" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard title={t('total_assessments')} value={stats.totalSessions} color="secondary" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard title={t('asd_group')} value={stats.asdCount} color="info" />
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <StatsCard title={t('control_group')} value={stats.controlCount} color="success" />
        </Grid>
      </Grid>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              {t('group')} {t('distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
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
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              {t('risk_level')} {t('distribution')}
            </Typography>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart data={riskData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="value" fill="#1976d2" />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  )
}

export default Dashboard

