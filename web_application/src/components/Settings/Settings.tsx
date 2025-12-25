import { Box, Paper, Typography, FormControl, Select, MenuItem, InputLabel } from '@mui/material'
import { useTranslation } from 'react-i18next'

const Settings = () => {
  const { t, i18n } = useTranslation()

  const handleLanguageChange = (lang: string) => {
    i18n.changeLanguage(lang)
    localStorage.setItem('language', lang)
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        {t('settings')}
      </Typography>

      <Paper sx={{ p: 3, mt: 3 }}>
        <FormControl fullWidth>
          <InputLabel>{t('language')}</InputLabel>
          <Select
            value={i18n.language}
            label={t('language')}
            onChange={(e) => handleLanguageChange(e.target.value)}
          >
            <MenuItem value="en">{t('english')}</MenuItem>
            <MenuItem value="si">{t('sinhala')}</MenuItem>
            <MenuItem value="ta">{t('tamil')}</MenuItem>
          </Select>
        </FormControl>
      </Paper>
    </Box>
  )
}

export default Settings






