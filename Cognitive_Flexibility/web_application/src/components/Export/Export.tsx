import { useState } from 'react'
import {
  Box,
  Paper,
  Typography,
  Button,
  Grid,
  TextField,
  Alert,
  CircularProgress,
} from '@mui/material'
import { Download } from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { exportToCSV } from '../../services/export'
// Date picker - using native HTML5 date input for simplicity
// You can add @mui/x-date-pickers later if needed

const Export = () => {
  const { t } = useTranslation()
  const [exportType, setExportType] = useState<'children' | 'sessions' | 'all'>('all')
  const [fromDate, setFromDate] = useState<Date | null>(null)
  const [toDate, setToDate] = useState<Date | null>(null)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  const handleExport = async () => {
    setError('')
    setSuccess('')
    setLoading(true)

    try {
      const dateRange =
        fromDate && toDate ? { from: fromDate, to: toDate } : undefined
      await exportToCSV(exportType, dateRange)
      setSuccess('Export completed successfully!')
    } catch (err) {
      setError(t('error_occurred'))
      console.error('Export error:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {t('export')}
      </Typography>

      <Paper sx={{ p: 3, mt: 3 }}>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <Typography variant="h6" gutterBottom>
              {t('select_date_range')}
            </Typography>
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label={t('from_date')}
              type="date"
              value={fromDate ? fromDate.toISOString().split('T')[0] : ''}
              onChange={(e) => setFromDate(e.target.value ? new Date(e.target.value) : null)}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>

          <Grid item xs={12} md={6}>
            <TextField
              fullWidth
              label={t('to_date')}
              type="date"
              value={toDate ? toDate.toISOString().split('T')[0] : ''}
              onChange={(e) => setToDate(e.target.value ? new Date(e.target.value) : null)}
              InputLabelProps={{ shrink: true }}
            />
          </Grid>

          <Grid item xs={12}>
            <Typography variant="body2" color="text.secondary" gutterBottom>
              Export Type:
            </Typography>
            <Box display="flex" gap={2} flexWrap="wrap">
              <Button
                variant={exportType === 'children' ? 'contained' : 'outlined'}
                onClick={() => setExportType('children')}
              >
                {t('children')}
              </Button>
              <Button
                variant={exportType === 'sessions' ? 'contained' : 'outlined'}
                onClick={() => setExportType('sessions')}
              >
                {t('sessions')}
              </Button>
              <Button
                variant={exportType === 'all' ? 'contained' : 'outlined'}
                onClick={() => setExportType('all')}
              >
                {t('export_all')}
              </Button>
            </Box>
          </Grid>

          {error && (
            <Grid item xs={12}>
              <Alert severity="error">{error}</Alert>
            </Grid>
          )}

          {success && (
            <Grid item xs={12}>
              <Alert severity="success">{success}</Alert>
            </Grid>
          )}

          <Grid item xs={12}>
            <Button
              variant="contained"
              startIcon={loading ? <CircularProgress size={20} /> : <Download />}
              onClick={handleExport}
              disabled={loading}
              size="large"
            >
              {t('export_csv')}
            </Button>
          </Grid>
        </Grid>
      </Paper>
    </Box>
  )
}

export default Export

