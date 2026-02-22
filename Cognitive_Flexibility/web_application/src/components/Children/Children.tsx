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
  Button,
  IconButton,
  Typography,
  CircularProgress,
  Chip,
  InputAdornment,
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
import {
  Visibility,
  Edit,
  Delete,
  Search,
  FilterList,
  Download,
  PersonAdd,
  Refresh,
  Clear,
} from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { childrenApi } from '../../services/api'
import { format } from 'date-fns'

interface Child {
  id: string
  name: string
  child_code?: string
  age?: number
  gender: string
  group?: string
  risk_level?: string
  created_at?: number
}

const Children = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [children, setChildren] = useState<Child[]>([])
  const [filteredChildren, setFilteredChildren] = useState<Child[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [groupFilter, setGroupFilter] = useState<string>('all')
  const [riskFilter, setRiskFilter] = useState<string>('all')
  const [loading, setLoading] = useState(true)
  const [page, setPage] = useState(0)
  const [rowsPerPage, setRowsPerPage] = useState(10)

  useEffect(() => {
    loadChildren()
  }, [])

  useEffect(() => {
    applyFilters()
  }, [children, searchTerm, groupFilter, riskFilter])

  const loadChildren = async () => {
    try {
      setLoading(true)
      const response = await childrenApi.getAll()
      setChildren(response.data.children || [])
    } catch (error) {
      console.error('Error loading children:', error)
    } finally {
      setLoading(false)
    }
  }

  const applyFilters = () => {
    let filtered = [...children]

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(
        (child) =>
          child.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
          child.child_code?.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    // Group filter
    if (groupFilter !== 'all') {
      filtered = filtered.filter((child) => child.group === groupFilter)
    }

    // Risk filter (would need to get from sessions)
    // For now, skip risk filter

    setFilteredChildren(filtered)
    setPage(0) // Reset to first page when filters change
  }

  const handleDelete = async (id: string) => {
    if (window.confirm(t('confirm_delete'))) {
      try {
        await childrenApi.delete(id)
        loadChildren()
      } catch (error) {
        console.error('Error deleting child:', error)
        alert(t('error_occurred'))
      }
    }
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
    setGroupFilter('all')
    setRiskFilter('all')
  }

  const paginatedChildren = filteredChildren.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage
  )

  // Statistics
  const stats = {
    total: children.length,
    asd: children.filter((c) => c.group === 'asd').length,
    control: children.filter((c) => c.group === 'typically_developing').length,
    filtered: filteredChildren.length,
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
              {t('children')}
            </Typography>
            <Typography variant="body2" sx={{ opacity: 0.9 }}>
              {t('manage_child_profiles')}
            </Typography>
          </Box>
          <Button
            variant="contained"
            startIcon={<PersonAdd />}
            onClick={() => navigate('/children/new')}
            sx={{
              bgcolor: 'white',
              color: '#667eea',
              '&:hover': { bgcolor: 'rgba(255,255,255,0.9)' },
            }}
          >
            {t('add_child')}
          </Button>
        </Box>
      </Box>

      {/* Statistics Cards */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                {t('total_children')}
              </Typography>
              <Typography variant="h4" fontWeight="bold">
                {stats.total}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'error.main' }}>
            <CardContent>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                {t('asd_group')}
              </Typography>
              <Typography variant="h4" fontWeight="bold" color="error.main">
                {stats.asd}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'success.main' }}>
            <CardContent>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                {t('control_group')}
              </Typography>
              <Typography variant="h4" fontWeight="bold" color="success.main">
                {stats.control}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} sm={6} md={3}>
          <Card sx={{ borderLeft: '4px solid', borderColor: 'primary.main' }}>
            <CardContent>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                {t('filtered_results')}
              </Typography>
              <Typography variant="h4" fontWeight="bold" color="primary.main">
                {stats.filtered}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Filters */}
      <Paper sx={{ p: 2, mb: 3 }}>
        <Stack direction="row" spacing={2} alignItems="center" flexWrap="wrap">
          <TextField
            size="small"
            placeholder={t('search_children')}
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
          <FormControl size="small" sx={{ minWidth: 150 }}>
            <InputLabel>{t('group')}</InputLabel>
            <Select
              value={groupFilter}
              onChange={(e) => setGroupFilter(e.target.value)}
              label={t('group')}
            >
              <MenuItem value="all">{t('all_groups')}</MenuItem>
              <MenuItem value="asd">{t('asd_group')}</MenuItem>
              <MenuItem value="typically_developing">{t('control_group')}</MenuItem>
            </Select>
          </FormControl>
          <Button
            variant="outlined"
            startIcon={<FilterList />}
            onClick={clearFilters}
            disabled={searchTerm === '' && groupFilter === 'all' && riskFilter === 'all'}
          >
            {t('clear_filters')}
          </Button>
          <Tooltip title={t('refresh')}>
            <IconButton onClick={loadChildren}>
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
                  {t('child')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('code')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('age')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('gender')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('group')}
                </Typography>
              </TableCell>
              <TableCell>
                <Typography variant="subtitle2" fontWeight="bold">
                  {t('registered')}
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
            {paginatedChildren.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center" sx={{ py: 6 }}>
                  <Typography variant="body2" color="text.secondary">
                    {t('no_children_found')}
                  </Typography>
                </TableCell>
              </TableRow>
            ) : (
              paginatedChildren.map((child) => (
                <TableRow key={child.id} hover sx={{ cursor: 'pointer' }}>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={2}>
                      <Avatar
                        sx={{
                          bgcolor:
                            child.group === 'asd' ? 'error.main' : 'success.main',
                          width: 40,
                          height: 40,
                        }}
                      >
                        {child.name?.charAt(0)?.toUpperCase() || '?'}
                      </Avatar>
                      <Typography variant="body2" fontWeight="medium">
                        {child.name}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" color="text.secondary">
                      {child.child_code || '-'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2">
                      {child.age ? `${child.age.toFixed(1)} ${t('years')}` : '-'}
                    </Typography>
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={t(child.gender?.toLowerCase() || 'unknown')}
                      size="small"
                      variant="outlined"
                    />
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={t(child.group || 'typically_developing')}
                      size="small"
                      color={child.group === 'asd' ? 'error' : 'success'}
                    />
                  </TableCell>
                  <TableCell>
                    <Typography variant="body2" color="text.secondary">
                      {child.created_at
                        ? format(new Date(child.created_at), 'MMM dd, yyyy')
                        : '-'}
                    </Typography>
                  </TableCell>
                  <TableCell align="right">
                    <Stack direction="row" spacing={1} justifyContent="flex-end">
                      <Tooltip title={t('view_details')}>
                        <IconButton
                          size="small"
                          onClick={() => navigate(`/children/${child.id}`)}
                          color="primary"
                        >
                          <Visibility />
                        </IconButton>
                      </Tooltip>
                      <Tooltip title={t('delete')}>
                        <IconButton
                          size="small"
                          onClick={() => handleDelete(child.id)}
                          color="error"
                        >
                          <Delete />
                        </IconButton>
                      </Tooltip>
                    </Stack>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
        <TablePagination
          component="div"
          count={filteredChildren.length}
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

export default Children
