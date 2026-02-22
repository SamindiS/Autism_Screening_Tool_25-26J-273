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
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  IconButton,
} from '@mui/material'
import { Visibility, Person } from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { cliniciansApi, childrenApi } from '../../services/api'
import { format } from 'date-fns'

interface Doctor {
  id: string
  name: string
  hospital: string
  created_at?: number
}

const Doctors = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [doctors, setDoctors] = useState<Doctor[]>([])
  const [filteredDoctors, setFilteredDoctors] = useState<Doctor[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [hospitalFilter, setHospitalFilter] = useState<string>('LRH')
  const [loading, setLoading] = useState(true)
  const [patientCounts, setPatientCounts] = useState<Record<string, number>>({})

  useEffect(() => {
    loadDoctors()
  }, [hospitalFilter])

  useEffect(() => {
    filterDoctors()
  }, [doctors, searchTerm, hospitalFilter])

  const loadDoctors = async () => {
    try {
      const response = await cliniciansApi.getAll(hospitalFilter || undefined)
      const doctorsList = response.data.clinicians || []
      setDoctors(doctorsList)

      // Load patient counts for each doctor
      const counts: Record<string, number> = {}
      try {
        // Get all children and count by clinician_id
        const allChildrenRes = await childrenApi.getAll()
        const allChildren = allChildrenRes.data.children || []
        
        for (const doctor of doctorsList) {
          counts[doctor.id] = allChildren.filter(
            (child: any) => child.clinician_id === doctor.id
          ).length
        }
      } catch (error) {
        console.error('Error loading patient counts:', error)
      }
      setPatientCounts(counts)
    } catch (error) {
      console.error('Error loading doctors:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterDoctors = () => {
    let filtered = doctors

    if (hospitalFilter && hospitalFilter !== 'all') {
      filtered = filtered.filter((d) => d.hospital === hospitalFilter)
    }

    if (searchTerm) {
      filtered = filtered.filter(
        (d) =>
          d.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
          d.hospital.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    setFilteredDoctors(filtered)
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
      <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
        <Box>
          <Typography variant="h4" fontWeight="bold">{t('clinicians_list')}</Typography>
          <Typography variant="body2" color="text.secondary">
            {t('mobile_app_clinicians')} - {t('registered_via_mobile_app')}
          </Typography>
        </Box>
        <Chip
          label={`${filteredDoctors.length} ${t('clinicians')}`}
          color="primary"
          sx={{ fontSize: '0.875rem', height: 32 }}
        />
      </Box>

      <Box display="flex" gap={2} mb={3}>
        <FormControl sx={{ minWidth: 200 }}>
          <InputLabel>{t('filter_by_hospital')}</InputLabel>
          <Select
            value={hospitalFilter}
            label={t('filter_by_hospital')}
            onChange={(e) => setHospitalFilter(e.target.value)}
          >
            <MenuItem value="all">{t('all_hospitals')}</MenuItem>
            <MenuItem value="LRH">{t('lrh')}</MenuItem>
            <MenuItem value="General Hospital">General Hospital</MenuItem>
            <MenuItem value="Other">Other</MenuItem>
          </Select>
        </FormControl>

        <TextField
          fullWidth
          label={t('search')}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          sx={{ maxWidth: 400 }}
        />
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>{t('doctor_name')}</TableCell>
              <TableCell>{t('hospital')}</TableCell>
              <TableCell>{t('registered_date')}</TableCell>
              <TableCell>{t('total_patients')}</TableCell>
              <TableCell>{t('actions')}</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredDoctors.length === 0 ? (
              <TableRow>
                <TableCell colSpan={5} align="center">
                  {t('no_data')}
                </TableCell>
              </TableRow>
            ) : (
              filteredDoctors.map((doctor) => (
                <TableRow key={doctor.id} hover>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={1}>
                      <Person color="primary" />
                      {doctor.name}
                    </Box>
                  </TableCell>
                  <TableCell>
                    <Chip label={doctor.hospital} size="small" color="primary" />
                  </TableCell>
                  <TableCell>
                    {doctor.created_at
                      ? format(new Date(doctor.created_at), 'yyyy-MM-dd')
                      : '-'}
                  </TableCell>
                  <TableCell>
                    <Chip
                      label={patientCounts[doctor.id] || 0}
                      size="small"
                      color="secondary"
                    />
                  </TableCell>
                  <TableCell>
                    <IconButton
                      size="small"
                      onClick={() => navigate(`/doctors/${doctor.id}`)}
                    >
                      <Visibility />
                    </IconButton>
                  </TableCell>
                </TableRow>
              ))
            )}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  )
}

export default Doctors

