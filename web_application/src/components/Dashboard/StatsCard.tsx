import { Paper, Typography, Box } from '@mui/material'

interface StatsCardProps {
  title: string
  value: number
  color?: 'primary' | 'secondary' | 'error' | 'warning' | 'info' | 'success'
}

const StatsCard = ({ title, value, color = 'primary' }: StatsCardProps) => {
  return (
    <Paper
      elevation={2}
      sx={{
        p: 3,
        textAlign: 'center',
        borderLeft: `4px solid`,
        borderColor: `${color}.main`,
      }}
    >
      <Typography variant="h4" color={`${color}.main`} fontWeight="bold">
        {value}
      </Typography>
      <Typography variant="body2" color="text.secondary" sx={{ mt: 1 }}>
        {title}
      </Typography>
    </Paper>
  )
}

export default StatsCard






