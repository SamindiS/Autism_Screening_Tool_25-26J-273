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
  Avatar,
  Chip,
  alpha,
  useTheme,
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
  AccountCircle,
  Notifications,
  Brightness4,
  Brightness7,
} from '@mui/icons-material'
import { useTranslation } from 'react-i18next'
import { logout, getCurrentUser, isAdmin } from '../../services/auth'

const drawerWidth = 280

const Layout = () => {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()
  const location = useLocation()
  const theme = useTheme()
  const [mobileOpen, setMobileOpen] = useState(false)
  const [langAnchor, setLangAnchor] = useState<null | HTMLElement>(null)
  const [userMenuAnchor, setUserMenuAnchor] = useState<null | HTMLElement>(null)

  const user = getCurrentUser()
  const admin = isAdmin()

  const menuItems = [
    { text: t('dashboard'), icon: <DashboardIcon />, path: '/dashboard' },
    { text: t('children'), icon: <PeopleIcon />, path: '/children' },
    { text: t('cognitive'), icon: <PsychologyIcon />, path: '/cognitive' },
    { text: t('sessions'), icon: <AssessmentIcon />, path: '/sessions' },
    ...(admin
      ? [
          { text: t('clinicians_list'), icon: <PersonSearchIcon />, path: '/doctors' },
          {
            text: t('doctor_relations'),
            icon: <PersonSearchIcon />,
            path: '/admin/doctor-relations',
          },
        ]
      : []),
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

  const handleUserMenuClick = (event: React.MouseEvent<HTMLElement>) => {
    setUserMenuAnchor(event.currentTarget)
  }

  const handleUserMenuClose = () => {
    setUserMenuAnchor(null)
  }

  const handleLogout = () => {
    logout()
    handleUserMenuClose()
    // Use window.location for a full page reload to clear any state
    window.location.href = '/login'
  }

  const drawer = (
    <Box sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
      {/* Logo/Brand Section */}
      <Box
        sx={{
          p: 3,
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white',
        }}
      >
        <Typography variant="h5" fontWeight="bold" gutterBottom>
          SenseAI
        </Typography>
        <Typography variant="body2" sx={{ opacity: 0.9 }}>
          {t('admin_portal')}
        </Typography>
      </Box>
      <Divider />
      {/* Navigation Menu */}
      <List sx={{ flex: 1, pt: 2 }}>
        {menuItems.map((item) => {
          const isActive = location.pathname === item.path
          return (
            <ListItem key={item.path} disablePadding sx={{ mb: 0.5, px: 2 }}>
              <ListItemButton
                selected={isActive}
                onClick={() => navigate(item.path)}
                sx={{
                  borderRadius: 2,
                  '&.Mui-selected': {
                    bgcolor: alpha(theme.palette.primary.main, 0.1),
                    color: theme.palette.primary.main,
                    '&:hover': {
                      bgcolor: alpha(theme.palette.primary.main, 0.15),
                    },
                    '& .MuiListItemIcon-root': {
                      color: theme.palette.primary.main,
                    },
                  },
                  '&:hover': {
                    bgcolor: alpha(theme.palette.primary.main, 0.05),
                  },
                }}
              >
                <ListItemIcon
                  sx={{
                    minWidth: 40,
                    color: isActive ? theme.palette.primary.main : 'inherit',
                  }}
                >
                  {item.icon}
                </ListItemIcon>
                <ListItemText
                  primary={item.text}
                  primaryTypographyProps={{
                    fontWeight: isActive ? 600 : 400,
                  }}
                />
              </ListItemButton>
            </ListItem>
          )
        })}
      </List>
      {/* User Info Footer */}
      {user && (
        <>
          <Divider />
          <Box sx={{ p: 2 }}>
            <Box display="flex" alignItems="center" gap={2}>
              <Avatar sx={{ bgcolor: 'primary.main', width: 40, height: 40 }}>
                {user.name?.charAt(0)?.toUpperCase() || 'A'}
              </Avatar>
              <Box flex={1}>
                <Typography variant="body2" fontWeight="medium" noWrap>
                  {user.name}
                </Typography>
                {admin && (
                  <Chip
                    label={t('admin')}
                    size="small"
                    color="primary"
                    sx={{ height: 20, fontSize: '0.7rem', mt: 0.5 }}
                  />
                )}
              </Box>
            </Box>
          </Box>
        </>
      )}
    </Box>
  )

  return (
    <Box sx={{ display: 'flex' }}>
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${drawerWidth}px)` },
          ml: { sm: `${drawerWidth}px` },
          bgcolor: 'background.paper',
          color: 'text.primary',
          boxShadow: '0 1px 3px rgba(0,0,0,0.12)',
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
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1, fontWeight: 600 }}>
            {t('app_name')}
          </Typography>
          <Box display="flex" alignItems="center" gap={1}>
            <IconButton color="inherit" onClick={handleLanguageClick} size="small">
              <LanguageIcon />
            </IconButton>
            <IconButton color="inherit" size="small">
              <Notifications />
            </IconButton>
            <IconButton
              color="inherit"
              onClick={handleUserMenuClick}
              size="small"
              sx={{ ml: 1 }}
            >
              <AccountCircle />
            </IconButton>
          </Box>
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
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: drawerWidth,
            },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': {
              boxSizing: 'border-box',
              width: drawerWidth,
              borderRight: '1px solid',
              borderColor: 'divider',
            },
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
          bgcolor: 'background.default',
          minHeight: '100vh',
        }}
      >
        <Toolbar />
        <Outlet />
      </Box>
      {/* Language Menu */}
      <Menu
        anchorEl={langAnchor}
        open={Boolean(langAnchor)}
        onClose={() => handleLanguageClose()}
      >
        <MenuItem onClick={() => handleLanguageClose('en')}>
          <LanguageIcon sx={{ mr: 1 }} />
          {t('english')}
        </MenuItem>
        <MenuItem onClick={() => handleLanguageClose('si')}>
          <LanguageIcon sx={{ mr: 1 }} />
          {t('sinhala')}
        </MenuItem>
        <MenuItem onClick={() => handleLanguageClose('ta')}>
          <LanguageIcon sx={{ mr: 1 }} />
          {t('tamil')}
        </MenuItem>
      </Menu>
      {/* User Menu */}
      <Menu
        anchorEl={userMenuAnchor}
        open={Boolean(userMenuAnchor)}
        onClose={handleUserMenuClose}
      >
        <MenuItem disabled>
          <AccountCircle sx={{ mr: 1 }} />
          {user?.name || 'User'}
          {admin && (
            <Chip label={t('admin')} size="small" color="primary" sx={{ ml: 1, height: 20 }} />
          )}
        </MenuItem>
        <Divider />
        <MenuItem onClick={handleLogout}>
          <LogoutIcon sx={{ mr: 1 }} />
          {t('logout')}
        </MenuItem>
      </Menu>
    </Box>
  )
}

export default Layout
