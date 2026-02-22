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
  InputAdornment,
  IconButton,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Stack,
  Card,
  CardContent,
  Avatar,
  Tooltip,
  TablePagination,
  Grid,
  alpha,
} from '@mui/material'
import { useNavigate } from 'react-router-dom'
import {
  Visibility,
  Search,
  FilterList,
  Refresh,
  Clear,
  Assessment,
  TrendingUp,
  Warning,
  CheckCircle,
} from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { sessionsApi } from '../../services/api'
import { format } from 'date-fns'

const Sessions = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [sessions, setSessions] = useState<any[]>([])
  const [filteredSessions, setFilteredSessions] = useState<any[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [typeFilter, setTypeFilter] = useState<string>('all')
  const [riskFilter, setRiskFilter] = useState<string>('all')
  const [loading, setLoading] = useState(true)
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(10)

  useEffect(() => {
    loadSessions()
  }, [])

  useEffect(() => {
    applyFilters()
  }, [sessions, searchTerm, typeFilter, riskFilter])

  const loadSessions = async () => {
    try {
      setLoading(true)
      const response = await sessionsApi.getAll()
      setSessions(response.data.sessions || [])
    } catch (error) {
      console.error('Error loading sessions:', error)
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let filtered = [...sessions]

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(
        (session) =>
          session.session_type?.toLowerCase().includes(searchTerm.toLowerCase()) ||
          session.child_id?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    // Type filter
    if (typeFilter !== 'all') {
      filtered = filtered.filter((session) => session.session_type === typeFilter)
    }

    // Risk filter
    if (riskFilter !== 'all') {
      filtered = filtered.filter((session) => session.risk_level === riskFilter)
    }

    setFilteredSessions(filtered)
    setPage(0)
  }

  const formatSessionType = (type: string): string => {
    const typeMap: Record<string, string> = {
      color_shape: 'Color-Shape Game',
      frog_jump: 'Frog Jump Game',
      ai_doctor_bot: 'AI Questionnaire',
      manual_assessment: 'Manual Assessment',
      rrb: 'RRB Assessment',
      auditory: 'Auditory Assessment',
      visual: 'Visual Assessment',
    }
    return typeMap[type] || type
  }

  const getRiskColor = (risk: string): 'error' | 'warning' | 'success' => {
    if (risk === 'high') return 'error'
    if (risk === 'moderate') return 'warning'
    return 'success'
  }

  const handleChangePage = (_event: unknown, newPage: number) => {
    setPage(newPage)
  }

  const handleChangeRowsPerPage = (event: React.ChangeEvent<HTMLInputElement>) => {
    setRowsPerPage(parseInt(event.target.value, 10))
    setPage(0)
  }

  const clearFilters = () => {
    setSearchTerm('')
    setTypeFilter('all')
    setRiskFilter('all')
  }

  const paginatedSessions = filteredSessions.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  )

  // Statistics
  const stats = {
    total: sessions.length,
    completed: sessions.filter((s) => s.end_time != null).length,
    highRisk: sessions.filter((s) => s.risk_level === 'high').length,
    moderateRisk: sessions.filter((s) => s.risk_level === 'moderate').length,
    lowRisk: sessions.filter((s) => s.risk_level === 'low').length,
    filtered: filteredSessions.length,
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
      {/* Professional Header */}
      <Box
        sx={{
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          borderRadius: 3,
          p: 3,
          mb: 3,
          color: 'white',
        }}
      >
        <Box display="flex" justifyContent="space-between" alignItems="center">
          <Box>
            <Typography variant="h4" fontWeight="bold" gutterBottom>
              {t('sessions')}
            </Typography>
            <Typography variant="body2" sx={{ opacity: 0.9 }}>
              {t('manage_assessments')}
            </Typography>
          </Box>
        </Box>
      </Box>

      {/* Statistics Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Box display="flex" alignItems="center" gap={2}>
                <Avatar sx={{ bgcolor: 'primary.main' }}>
                  <Assessment />
                </Avatar>
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    {t('total_assessments')}
                  </Typography>
                  <Typography variant="h4" fontWeight="bold">
                    {stats.total}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'success.main' }}>
            <CardContent>
              <Box display="flex" alignItems="center" gap={2}>
                <Avatar sx={{ bgcolor: 'success.main' }}>
                  <CheckCircle />
                </Avatar>
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    {t('completed')}
                  </Typography>
                  <Typography variant="h4" fontWeight="bold" color="success.main">
                    {stats.completed}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'error.main' }}>
            <CardContent>
              <Box display="flex" alignItems="center" gap={2}>
                <Avatar sx={{ bgcolor: 'error.main' }}>
                  <Warning />
                </Avatar>
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    {t('high_risk')}
                  </Typography>
                  <Typography variant="h4" fontWeight="bold" color="error.main">
                    {stats.highRisk}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'primary.main' }}>
            <CardContent>
              <Box display="flex" alignItems="center" gap={2}>
                <Avatar sx={{ bgcolor: 'primary.main' }}>
                  <TrendingUp />
                </Avatar>
                <Box>
                  <Typography variant="body2" color="text.secondary">
                    {t('filtered_results')}
                  </Typography>
                  <Typography variant="h4" fontWeight="bold" color="primary.main">
                    {stats.filtered}
                  </Typography>
                </Box>
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
          <TextField
            size="small"
            placeholder={t('search_sessions')}
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <Search />
                </InputAdornment>
              ),
              endAdornment: searchTerm && (
                <InputAdornment position="end">
                  <IconButton size="small" onClick={() => setSearchTerm('')}>
                    <Clear />
                  </IconButton>
                </InputAdornment>
              ),
            }}
            sx={{ minWidth: 250, flex: 1 }}
          />
          <FormControl size="small" sx={{ minWidth: 180 }}>
            <InputLabel>{t('session_type')}</InputLabel>
            <Select
              value={typeFilter}
              onChange={(e) => setTypeFilter(e.target.value)}
              label={t('session_type')}
            >
              <MenuItem value="all">{t('all_types')}</MenuItem>
              <MenuItem value="color_shape">{t('color_shape_game')}</MenuItem>
              <MenuItem value="frog_jump">{t('frog_jump_game')}</MenuItem>
              <MenuItem value="ai_doctor_bot">{t('ai_questionnaire')}</MenuItem>
              <MenuItem value="manual_assessment">{t('manual_assessment')}</MenuItem>
            </Select>
          </FormControl>
          <FormControl size="small" sx={{ minWidth: 150 }}>
            <InputLabel>{t('risk_level')}</InputLabel>
            <Select
              value={riskFilter}
              onChange={(e) => setRiskFilter(e.target.value)}
              label={t('risk_level')}
            >
              <MenuItem value="all">{t('all_risks')}</MenuItem>
              <MenuItem value="high">{t('high_risk')}</MenuItem>
              <MenuItem value="moderate">{t('moderate_risk')}</MenuItem>
              <MenuItem value="low">{t('low_risk')}</MenuItem>
            </Select>
          </FormControl>
          <Button
            variant="outlined"
            startIcon={<FilterList />}
            onClick={clearFilters}
            disabled={searchTerm === '' && typeFilter === 'all' && riskFilter === 'all'}
          >
            {t('clear_filters')}
          </Button>
          <Tooltip title={t('refresh')}>
            <IconButton onClick={loadSessions}>
              <Refresh />
            </IconButton>
          </Tooltip>
        </Stack>
      </Paper>

      {/* Data Table */}
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow sx={{ bgcolor: 'action.hover' }}>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('session_type')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('child_id')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('risk_level')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('risk_score')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('date')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('status')}
                </Typography>
              </TableCell>
              <TableCell align="right">
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('actions')}
                </Typography>
              </TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {paginatedSessions.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center" sx={{ py: 6 }}>
                  <Typography variant="body2" color="text.secondary">
                    {t('no_sessions_found')}
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              paginatedSessions.map((session) => (
                <TableRow key={session.id} hover sx={{ cursor: 'pointer' }}>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={1}>
                      <Chip
                        label={formatSessionType(session.session_type)}
                        size="small"
                        variant="outlined"
                      />
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {session.child_id || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    {session.risk_level ? (
                      <Chip
                        label={t(session.risk_level)}
                        size="small"
                        color={getRiskColor(session.risk_level)}
                      />
                    ) : (
                      <Chip label={t('not_assessed')} size="small" variant="outlined" />
                    )}
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" fontWeight="medium">
                      {session.risk_score != null ? `${session.risk_score.toFixed(1)}` : '-'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" color="text.secondary">
                      {session.created_at
                        ? format(new Date(session.created_at), 'MMM dd, yyyy HH:mm')
                        : '-'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      icon={session.end_time ? <CheckCircle /> : <Warning />}
                      label={session.end_time ? t('completed') : t('pending')}
                      size="small"
                      color={session.end_time ? 'success' : 'warning'}
                    />
                  </TableCell>
                  <TableCell align="right">
                    <Tooltip title={t('view_details')}>
                      <IconButton
                        size="small"
                        onClick={() => navigate(`/sessions/${session.id}`)}
                        color="primary"
                      >
                        <Visibility />
                      </IconButton>
                    </Tooltip>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        <TablePagination
          component="div"
          count={filteredSessions.length}
          page={page}
          onPageChange={handleChangePage}
          rowsPerPage={rowsPerPage}
          onRowsPerPageChange={handleChangeRowsPerPage}
          rowsPerPageOptions={[5, 10, 25, 50]}
          labelRowsPerPage={t('rows_per_page')}
        />
      </TableContainer>
    </Box>
  )
}

export default Sessions
