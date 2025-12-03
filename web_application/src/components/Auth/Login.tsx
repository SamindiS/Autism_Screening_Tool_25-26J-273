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
      const result = await login(pin)
      if (result.success) {
        navigate('/dashboard')
      } else {
        setError(result.error || t('invalid_pin'))
      }
    } catch (err) {
      setError(t('error_occurred'))
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
              onChange={(e) => setPin(e.target.value)}
              margin="normal"
              required
              inputProps={{ maxLength: 4, pattern: '[0-9]*' }}
              autoFocus
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={loading || pin.length !== 4}
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

