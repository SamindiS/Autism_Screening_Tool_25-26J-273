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
} from '@mui/material'
import { ArrowBack, Person } from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { cliniciansApi, childrenApi } from '../../services/api'
import { format } from 'date-fns'

const DoctorDetails = () => {
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()
  const { t } = useTranslation()
  const [doctor, setDoctor] = useState<any>(null)
  const [patients, setPatients] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (id) {
      loadData()
    }
  }, [id])

  const loadData = async () => {
    try {
      const [doctorRes, allChildrenRes] = await Promise.all([
        cliniciansApi.getById(id!),
        childrenApi.getAll(),
      ])
      setDoctor(doctorRes.data.clinician)
      // Filter children by clinician_id
      const allChildren = allChildrenRes.data.children || []
      const doctorPatients = allChildren.filter(
        (child: any) => child.clinician_id === id
      )
      setPatients(doctorPatients)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    )
  }

  if (!doctor) {
    return <Typography>{t('no_data')}</Typography>
  }

  return (
    <Box>
      <Button startIcon={<ArrowBack />} onClick={() => navigate('/doctors')} sx={{ mb: 2 }}>
        {t('back')}
      </Button>

      <Box mb={2}>
        <Typography variant="h4" gutterBottom>
          {t('doctor_profile')}
        </Typography>
        <Typography variant="body2" color="text.secondary">
          {t('mobile_app_clinician')} - {t('registered_via_mobile_app')}
        </Typography>
      </Box>

      <Grid container spacing={3} sx={{ mt: 2 }}>
        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Box display="flex" alignItems="center" gap={2} mb={2}>
              <Person sx={{ fontSize: 48, color: 'primary.main' }} />
              <Box>
                <Typography variant="h5">{doctor.name}</Typography>
                <Chip label={doctor.hospital} color="primary" sx={{ mt: 1 }} />
              </Box>
            </Box>
            <Typography variant="body1" gutterBottom>
              <strong>{t('hospital')}:</strong> {doctor.hospital}
            </Typography>
            {doctor.created_at && (
              <Typography variant="body1" gutterBottom>
                <strong>{t('registered_date')}:</strong>{' '}
                {format(new Date(doctor.created_at), 'yyyy-MM-dd')}
              </Typography>
            )}
          </Paper>
        </Grid>

        <Grid item xs={12} md={6}>
          <Paper sx={{ p: 3 }}>
            <Typography variant="h6" gutterBottom>
              {t('statistics')}
            </Typography>
            <Typography variant="h4" color="primary">
              {patients.length}
            </Typography>
            <Typography variant="body2" color="text.secondary">
              {t('total_patients')}
            </Typography>
          </Paper>
        </Grid>
      </Grid>

      <Box sx={{ mt: 3 }}>
        <Typography variant="h6" gutterBottom>
          {t('patients')}
        </Typography>
        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('name')}</TableCell>
                <TableCell>{t('code')}</TableCell>
                <TableCell>{t('age')}</TableCell>
                <TableCell>{t('group')}</TableCell>
                <TableCell>{t('actions')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {patients.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} align="center">
                    {t('no_data')}
                  </TableCell>
                </TableRow>
              ) : (
                patients.map((patient) => (
                  <TableRow key={patient.id}>
                    <TableCell>{patient.name}</TableCell>
                    <TableCell>{patient.child_code || '-'}</TableCell>
                    <TableCell>
                      {patient.age ? `${patient.age.toFixed(1)} ${t('years')}` : '-'}
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={t(patient.group || 'typically_developing')}
                        size="small"
                        color={patient.group === 'asd' ? 'error' : 'success'}
                      />
                    </TableCell>
                    <TableCell>
                      <Button
                        size="small"
                        onClick={() => navigate(`/children/${patient.id}`)}
                      >
                        {t('view')}
                      </Button>
                    </TableCell>
                  </TableRow>
                ))
              )}
            </TableBody>
          </Table>
        </TableContainer>
      </Box>
    </Box>
  )
}

export default DoctorDetails

