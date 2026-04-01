import { useEffect, useState } from 'react'
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
import { Repeat, Person, Visibility } from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { childrenApi, sessionsApi } from '../../services/api'
import { format } from 'date-fns'

const RRBDashboard = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [children, setChildren] = useState<any[]>([])
  const [sessions, setSessions] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalChildren: 0,
    totalSessions: 0,
    highRisk: 0,
    moderateRisk: 0,
    lowRisk: 0,
  })

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

      const rrbSessions = allSessions.filter((s: any) => s.session_type === 'rrb')

      const childIdsWithRRB = new Set(rrbSessions.map((s: any) => s.child_id))
      const childrenWithRRB = allChildren.filter((c: any) =>
        childIdsWithRRB.has(c.id)
      )

      const highRisk = rrbSessions.filter((s: any) => s.risk_level === 'high').length
      const moderateRisk = rrbSessions.filter(
        (s: any) => s.risk_level === 'moderate'
      ).length
      const lowRisk = rrbSessions.filter((s: any) => s.risk_level === 'low').length

      setChildren(childrenWithRRB)
      setSessions(rrbSessions)
      setStats({
        totalChildren: childrenWithRRB.length,
        totalSessions: rrbSessions.length,
        highRisk,
        moderateRisk,
        lowRisk,
      })
    } catch (error) {
      console.error('Error loading RRB data:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredChildren = children.filter(
    (child) =>
      child.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      child.child_code?.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const getChildSessions = (childId: string) => {
    return sessions.filter((s) => s.child_id === childId)
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
        <Repeat sx={{ fontSize: 40, color: '#7C3AED' }} />
        <Typography variant="h4">
          {t('rrb')} {t('dashboard')}
        </Typography>
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
                {t('high_risk')}
              </Typography>
              <Typography variant="h4" color="error.main">
                {stats.highRisk}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="h6" color="text.secondary" gutterBottom>
                {t('moderate_risk')} / {t('low_risk')}
              </Typography>
              <Typography variant="h5">
                {stats.moderateRisk} / {stats.lowRisk}
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
                        <Chip
                          label={t(child.group || 'typically_developing')}
                          size="small"
                          color={child.group === 'asd' ? 'error' : 'success'}
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
                        {childSessions.length} {t('rrb')} {t('sessions')}
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
                        startIcon={<Visibility />}
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

export default RRBDashboard

