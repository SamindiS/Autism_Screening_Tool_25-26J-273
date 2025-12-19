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
} from '@mui/material'
import { useNavigate } from 'react-router-dom'
import { Visibility, Edit, Delete } from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { childrenApi } from '../../services/api'

interface Child {
  id: string
  name: string
  child_code?: string
  age?: number
  gender: string
  group?: string
  risk_level?: string
}

const Children = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [children, setChildren] = useState<Child[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadChildren()
  }, [])

  const loadChildren = async () => {
    try {
      const response = await childrenApi.getAll()
      setChildren(response.data.children || [])
    } catch (error) {
      console.error('Error loading children:', error)
    } finally {
      setLoading(false)
    }
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

  const filteredChildren = children.filter(
    (child) =>
      child.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      child.child_code?.toLowerCase().includes(searchTerm.toLowerCase())
  )

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
        <Typography variant="h4">{t('children')}</Typography>
      </Box>

      <TextField
        fullWidth
        label={t('search')}
        value={searchTerm}
        onChange={(e) => setSearchTerm(e.target.value)}
        margin="normal"
        sx={{ mb: 2 }}
      />

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>{t('name')}</TableCell>
              <TableCell>{t('code')}</TableCell>
              <TableCell>{t('age')}</TableCell>
              <TableCell>{t('gender')}</TableCell>
              <TableCell>{t('group')}</TableCell>
              <TableCell>{t('risk_level')}</TableCell>
              <TableCell>{t('actions')}</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredChildren.length === 0 ? (
              <TableRow>
                <TableCell colSpan={7} align="center">
                  {t('no_data')}
                </TableCell>
              </TableRow>
            ) : (
              filteredChildren.map((child) => (
                <TableRow key={child.id} hover>
                  <TableCell>{child.name}</TableCell>
                  <TableCell>{child.child_code || '-'}</TableCell>
                  <TableCell>
                    {child.age ? `${child.age.toFixed(1)} ${t('years')}` : '-'}
                  </TableCell>
                  <TableCell>{t(child.gender)}</TableCell>
                  <TableCell>
                    <Chip
                      label={t(child.group || 'typically_developing')}
                      size="small"
                      color={child.group === 'asd' ? 'error' : 'success'}
                    />
                  </TableCell>
                  <TableCell>
                    {child.risk_level ? (
                      <Chip
                        label={t(child.risk_level)}
                        size="small"
                        color={
                          child.risk_level === 'high'
                            ? 'error'
                            : child.risk_level === 'moderate'
                            ? 'warning'
                            : 'success'
                        }
                      />
                    ) : (
                      '-'
                    )}
                  </TableCell>
                  <TableCell>
                    <IconButton
                      size="small"
                      onClick={() => navigate(`/children/${child.id}`)}
                    >
                      <Visibility />
                    </IconButton>
                    <IconButton size="small" onClick={() => handleDelete(child.id)}>
                      <Delete />
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

export default Children





