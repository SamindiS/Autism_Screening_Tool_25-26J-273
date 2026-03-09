import { useEffect, useState } from 'react'
import {
  Box,
  Paper,
  Typography,
  CircularProgress,
  Table,
  TableHead,
  TableRow,
  TableCell,
  TableBody,
  Chip,
  Grid,
  Card,
  CardContent,
} from '@mui/material'
import { useTranslation } from 'react-i18next'
import { format } from 'date-fns'
import { fetchVisualReports, type VisualReport } from '../../services/firebaseClient'

const VisualReports = () => {
  const { t } = useTranslation()
  const [reports, setReports] = useState<VisualReport[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const load = async () => {
      try {
        setLoading(true)
        setError(null)
        const data = await fetchVisualReports(100)
        setReports(data)
      } catch (e: any) {
        console.error('Error loading visual reports from Firebase:', e)
        setError(e?.message || 'Failed to load visual reports')
      } finally {
        setLoading(false)
      }
    }

    load()
  }, [])

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
      <Box
        sx={{
          background: 'linear-gradient(135deg, #059669 0%, #38bdf8 100%)',
          borderRadius: 3,
          p: 3,
          mb: 3,
          color: 'white',
        }}
      >
        <Typography variant="h4" fontWeight="bold" gutterBottom>
          {t('visual_checking')} – Visual Reports
        </Typography>
        <Typography variant="body2" sx={{ opacity: 0.9 }}>
          Read‑only view of gaze‑based visual attention reports stored in Firebase (reports collection).
        </Typography>
      </Box>

      {error && (
        <Paper sx={{ p: 2, mb: 3 }}>
          <Typography color="error" variant="body2">
            {error}
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
            Ensure Firebase web config is set in <code>.env</code> (VITE_FIREBASE_… variables) and that this browser
            has access to the same project the backend writes to.
          </Typography>
        </Paper>
      )}

      {/* Quick stats */}
      <Grid container spacing={3} sx={{ mb: 3 }}>
        <Grid item xs={12} sm={6} md={3}>
          <Card>
            <CardContent>
              <Typography variant="body2" color="text.secondary" gutterBottom>
                Total visual reports
              </Typography>
              <Typography variant="h4" fontWeight="bold">
                {reports.length}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      {/* Table */}
      <Paper>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>{t('child_name') || 'Child'}</TableCell>
              <TableCell>{t('age') || 'Age'}</TableCell>
              <TableCell>Score</TableCell>
              <TableCell>Risk</TableCell>
              <TableCell>{t('date') || 'Date'}</TableCell>
              <TableCell>Parent</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {reports.length === 0 ? (
              <TableRow>
                <TableCell colSpan={6} align="center" sx={{ py: 4 }}>
                  {t('no_data') || 'No visual reports found'}
                </TableCell>
              </TableRow>
            ) : (
              reports.map((r) => {
                const created = r.created_at
                  ? new Date(typeof r.created_at === 'number' ? r.created_at : r.created_at)
                  : null
                const riskCategory =
                  (r.scores && (r.scores.risk_category || r.scores.riskCategory)) ||
                  r.interpretation?.summary ||
                  ''

                let riskColor: 'success' | 'warning' | 'error' | 'default' = 'default'
                const riskText = String(riskCategory).toLowerCase()
                if (riskText.includes('low')) riskColor = 'success'
                else if (riskText.includes('moderate') || riskText.includes('elevated')) riskColor = 'warning'
                else if (riskText.includes('high')) riskColor = 'error'

                return (
                  <TableRow key={r.id}>
                    <TableCell>{r.childName || '-'}</TableCell>
                    <TableCell>
                      {r.childAge != null ? `${Number(r.childAge).toFixed(1)} ${t('years') || 'years'}` : '-'}
                    </TableCell>
                    <TableCell>{r.score != null ? r.score.toFixed(1) : '-'}</TableCell>
                    <TableCell>
                      {riskCategory ? (
                        <Chip label={riskCategory} size="small" color={riskColor} />
                      ) : (
                        <Chip label="N/A" size="small" variant="outlined" />
                      )}
                    </TableCell>
                    <TableCell>
                      {created ? format(created, 'yyyy-MM-dd HH:mm') : '-'}
                    </TableCell>
                    <TableCell>
                      {r.parent_name || '-'}{' '}
                      {r.parent_relationship && (
                        <Typography component="span" variant="caption" color="text.secondary">
                          ({r.parent_relationship})
                        </Typography>
                      )}
                    </TableCell>
                  </TableRow>
                )
              })
            )}
          </TableBody>
        </Table>
      </Paper>
    </Box>
  )
}

export default VisualReports

