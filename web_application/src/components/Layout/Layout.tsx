import { useState } from 'react'
import { Outlet, useNavigate, useLocation } from 'react-router-dom'
import {
  Box,
  Drawer,
  AppBar,
  Toolbar,
  List,
  Typography,
  Divider,
  ListItem,
  ListItemButton,
  ListItemIcon,
  ListItemText,
  IconButton,
  Menu,
  MenuItem,
} from '@mui/material'
import {
  Dashboard as DashboardIcon,
  People as PeopleIcon,
  Assessment as AssessmentIcon,
  FileDownload as ExportIcon,
  Settings as SettingsIcon,
  Menu as MenuIcon,
  Language as LanguageIcon,
  Logout as LogoutIcon,
  Psychology as PsychologyIcon,
  PersonSearch as PersonSearchIcon,
} from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { logout, getCurrentUser, isAdmin } from '../../services/auth'

const drawerWidth = 240

const Layout = () => {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
  const location = useLocation()
  const [mobileOpen, setMobileOpen] = useState(false)
  const [langAnchor, setLangAnchor] = useState<null | HTMLElement>(null)

  const user = getCurrentUser()
  const admin = isAdmin()

  const menuItems = [
    { text: t('dashboard'), icon: <DashboardIcon />, path: '/dashboard' },
    { text: t('children'), icon: <PeopleIcon />, path: '/children' },
    { text: t('cognitive'), icon: <PsychologyIcon />, path: '/cognitive' },
    { text: t('sessions'), icon: <AssessmentIcon />, path: '/sessions' },
    ...(admin ? [
      { text: t('clinicians_list'), icon: <PersonSearchIcon />, path: '/doctors' },
      { text: t('doctor_relations'), icon: <PersonSearchIcon />, path: '/admin/doctor-relations' },
    ] : []),
    { text: t('export'), icon: <ExportIcon />, path: '/export' },
    { text: t('settings'), icon: <SettingsIcon />, path: '/settings' },
  ]

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen)
  }

  const handleLanguageClick = (event: React.MouseEvent<HTMLElement>) => {
    setLangAnchor(event.currentTarget)
  }

  const handleLanguageClose = (lang?: string) => {
    if (lang) {
      i18n.changeLanguage(lang)
      localStorage.setItem('language', lang)
    }
    setLangAnchor(null)
  }

  const handleLogout = () => {
    logout()
    navigate('/login')
  }

  const drawer = (
    <Box>
      <Toolbar>
        <Typography variant="h6" noWrap component="div">
          SenseAI
        </Typography>
      </Toolbar>
      <Divider />
      <List>
        {menuItems.map((item) => (
          <ListItem key={item.path} disablePadding>
            <ListItemButton
              selected={location.pathname === item.path}
              onClick={() => navigate(item.path)}
            >
              <ListItemIcon>{item.icon}</ListItemIcon>
              <ListItemText primary={item.text} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  )

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          ml: { sm: `${drawerWidth}px` },
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            aria-label="open drawer"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            {t('app_name')}
          </Typography>
          {user && (
            <Typography variant="body2" sx={{ mr: 2 }}>
              {user.name} {admin && '(Admin)'}
            </Typography>
          )}
          <IconButton color="inherit" onClick={handleLanguageClick}>
            <LanguageIcon />
          </IconButton>
          <IconButton color="inherit" onClick={handleLogout}>
            <LogoutIcon />
          </IconButton>
        </Toolbar>
      </AppBar>
      <Box
        component="nav"
        sx={{ width: { sm: drawerWidth }, flexShrink: { sm: 0 } }}
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true,
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: drawerWidth },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          p: 3,
          width: { sm: `calc(100% - ${drawerWidth}px)` },
        }}
      >
        <Toolbar />
        <Outlet />
      </Box>
      <Menu
        anchorEl={langAnchor}
        open={Boolean(langAnchor)}
        onClose={() => handleLanguageClose()}
      >
        <MenuItem onClick={() => handleLanguageClose('en')}>
          {t('english')}
        </MenuItem>
        <MenuItem onClick={() => handleLanguageClose('si')}>
          {t('sinhala')}
        </MenuItem>
        <MenuItem onClick={() => handleLanguageClose('ta')}>
          {t('tamil')}
        </MenuItem>
      </Menu>
    </Box>
  )
}

export default Layout

