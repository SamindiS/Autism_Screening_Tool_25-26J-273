import { cliniciansApi } from './api'

export interface Clinician {
  id: string
  name: string
  hospital: string
  created_at?: number
  role?: 'admin' | 'clinician'
}

export interface User {
  id: string
  name: string
  hospital: string
  role: 'admin' | 'clinician'
}

export const login = async (pin: string): Promise<{ success: boolean; user?: User; error?: string }> => {
  try {
    console.log('🔐 Attempting login with PIN:', pin?.substring(0, 2) + '***')
    const response = await cliniciansApi.login(pin)
    console.log('📥 Login response:', response.data)
    
    if (response.data.success) {
      // Backend returns both 'user' and 'clinician' for compatibility
      const user = response.data.user || response.data.clinician
      
      if (!user) {
        console.error('❌ No user data in response')
        return { success: false, error: 'Invalid response from server' }
      }
      
      const userData: User = {
        id: user.id,
        name: user.name,
        hospital: user.hospital || 'Unknown',
        role: response.data.role || user.role || 'clinician',
      }
      
      console.log('✅ Login successful, saving user:', userData)
      localStorage.setItem('authToken', 'authenticated')
      localStorage.setItem('user', JSON.stringify(userData))
      localStorage.setItem('role', userData.role)
      
      // Also store clinician_id if available (for clinician-specific data)
      if (user.id && userData.role === 'clinician') {
        localStorage.setItem('clinician_id', user.id)
      }
      
      return { success: true, user: userData }
    }
    
    return { success: false, error: response.data.error || 'Invalid PIN' }
  } catch (error: any) {
    console.error('❌ Login error:', error)
    const errorMessage = error.response?.data?.error || error.message || 'Login failed'
    return { success: false, error: errorMessage }
  }
}

export const logout = () => {
  console.log('🚪 Logging out...')
  localStorage.removeItem('authToken')
  localStorage.removeItem('user')
  localStorage.removeItem('role')
  localStorage.removeItem('clinician_id')
  localStorage.removeItem('clinician')
  // Redirect will be handled by the component calling this
}

export const isAuthenticated = (): boolean => {
  return !!localStorage.getItem('authToken')
}

export const getCurrentUser = (): User | null => {
  const userStr = localStorage.getItem('user')
  if (userStr) {
    try {
      return JSON.parse(userStr)
    } catch {
      return null
    }
  }
  return null
}

export const isAdmin = (): boolean => {
  return localStorage.getItem('role') === 'admin'
}

export const getCurrentClinician = (): Clinician | null => {
  const user = getCurrentUser()
  if (user && user.role === 'clinician') {
    return user
  }
  return null
}

