import { useEffect, useState } from 'react'
import {
  Box,
  Paper,
  Typography,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  CircularProgress,
  Chip,
  TextField,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  Button,
} from '@mui/material'
import { Person, Visibility } from '@mui/icons-material'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { cliniciansApi, childrenApi } from '../../services/api'
import { format } from 'date-fns'

const DoctorChildRelations = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [doctors, setDoctors] = useState<any[]>([])
  const [children, setChildren] = useState<any[]>([])
  const [relations, setRelations] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [hospitalFilter, setHospitalFilter] = useState<string>('LRH')
  const [searchTerm, setSearchTerm] = useState('')

  useEffect(() => {
    loadData()
  }, [hospitalFilter])

  const loadData = async () => {
    try {
      const [doctorsRes, childrenRes] = await Promise.all([
        cliniciansApi.getAll(hospitalFilter || undefined),
        childrenApi.getAll(),
      ])

      const doctorsList = doctorsRes.data.clinicians || []
      const childrenList = childrenRes.data.children || []

      // Build relations: which doctor examined which children
      const relationsList: any[] = []
      doctorsList.forEach((doctor: any) => {
        const doctorChildren = childrenList.filter(
          (child: any) => child.clinician_id === doctor.id
        )
        doctorChildren.forEach((child: any) => {
          relationsList.push({
            doctorId: doctor.id,
            doctorName: doctor.name,
            doctorHospital: doctor.hospital,
            childId: child.id,
            childName: child.name,
            childCode: child.child_code,
            childAge: child.age,
            childGroup: child.group,
            createdAt: child.created_at,
          })
        })
      })

      setDoctors(doctorsList)
      setChildren(childrenList)
      setRelations(relationsList)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  const filteredRelations = relations.filter((rel) => {
    const matchesSearch =
      rel.doctorName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      rel.childName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      rel.childCode?.toLowerCase().includes(searchTerm.toLowerCase())
    return matchesSearch
  })

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
        <Person sx={{ fontSize: 40, color: 'primary.main' }} />
        <Box>
          <Typography variant="h4">{t('doctor_child_relations')}</Typography>
          <Typography variant="body2" color="text.secondary">
            {t('view_which_clinician_examined_which_children')}
          </Typography>
        </Box>
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

      <Paper>
        <TableContainer>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>{t('doctor_name')}</TableCell>
                <TableCell>{t('hospital')}</TableCell>
                <TableCell>{t('child_name')}</TableCell>
                <TableCell>{t('code')}</TableCell>
                <TableCell>{t('age')}</TableCell>
                <TableCell>{t('group')}</TableCell>
                <TableCell>{t('registered_date')}</TableCell>
                <TableCell>{t('actions')}</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {filteredRelations.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={8} align="center">
                    {t('no_data')}
                  </TableCell>
                </TableRow>
              ) : (
                filteredRelations.map((rel, index) => (
                  <TableRow key={`${rel.doctorId}-${rel.childId}-${index}`} hover>
                    <TableCell>
                      <Box display="flex" alignItems="center" gap={1}>
                        <Person color="primary" />
                        {rel.doctorName}
                      </Box>
                    </TableCell>
                    <TableCell>
                      <Chip label={rel.doctorHospital} size="small" color="primary" />
                    </TableCell>
                    <TableCell>{rel.childName}</TableCell>
                    <TableCell>{rel.childCode || '-'}</TableCell>
                    <TableCell>
                      {rel.childAge ? `${rel.childAge.toFixed(1)} ${t('years')}` : '-'}
                    </TableCell>
                    <TableCell>
                      <Chip
                        label={t(rel.childGroup || 'typically_developing')}
                        size="small"
                        color={rel.childGroup === 'asd' ? 'error' : 'success'}
                      />
                    </TableCell>
                    <TableCell>
                      {rel.createdAt
                        ? format(new Date(rel.createdAt), 'yyyy-MM-dd')
                        : '-'}
                    </TableCell>
                    <TableCell>
                      <Button
                        size="small"
                        startIcon={<Visibility />}
                        onClick={() => navigate(`/children/${rel.childId}`)}
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
      </Paper>

      <Box sx={{ mt: 3, p: 2, bgcolor: 'info.light', borderRadius: 1 }}>
        <Typography variant="body2">
          <strong>{t('summary')}:</strong> {filteredRelations.length} {t('examinations')} by{' '}
          {new Set(filteredRelations.map((r) => r.doctorId)).size} {t('doctors')}
        </Typography>
      </Box>
    </Box>
  )
}

export default DoctorChildRelations

