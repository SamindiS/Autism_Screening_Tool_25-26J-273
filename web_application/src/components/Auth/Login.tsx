import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import {
  Container,
  Paper,
  TextField,
  Button,
  Typography,
  Box,
  Alert,
  CircularProgress,
} from '@mui/material'
import { login } from '../../services/auth'
import { useTranslation } from 'react-i18next'

const Login = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const [pin, setPin] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError('')
    setLoading(true)

    try {
      // Allow admin123 or any PIN - let backend handle validation
      const result = await login(pin)
      if (result.success) {
        navigate('/dashboard')
      } else {
        setError(result.error || t('invalid_pin'))
      }
    } catch (err: any) {
      console.error('Login error:', err)
      const errorMessage = err?.response?.data?.error || err?.message || t('error_occurred')
      setError(errorMessage)
    } finally {
      setLoading(false)
    }
  }

  return (
    <Container maxWidth="sm">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Paper elevation={3} sx={{ p: 4, width: '100%' }}>
          <Typography variant="h4" component="h1" gutterBottom align="center">
            {t('app_name')}
          </Typography>
          <Typography variant="h6" component="h2" gutterBottom align="center" color="text.secondary">
            {t('login')}
          </Typography>

          <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
            {error && (
              <Alert severity="error" sx={{ mb: 2 }}>
                {error}
              </Alert>
            )}

            <TextField
              fullWidth
              label={t('pin')}
              type="password"
              value={pin}
              onChange={(e) => {
                setPin(e.target.value)
                setError('') // Clear error when typing
              }}
              margin="normal"
              required
              helperText="Enter PIN: admin123 (admin) or 4-digit PIN (clinician)"
              autoFocus
              inputProps={{
                maxLength: 20, // Allow up to 20 characters for admin123
              }}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading || pin.length === 0}
            >
              {loading ? <CircularProgress size={24} /> : t('login')}
            </Button>
          </Box>
        </Paper>
      </Box>
    </Container>
  )
}

export default Login

