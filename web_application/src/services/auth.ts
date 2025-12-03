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
    const response = await cliniciansApi.login(pin)
    if (response.data.success) {
      const user = response.data.user || response.data.clinician
      const userData: User = {
        id: user.id,
        name: user.name,
        hospital: user.hospital,
        role: response.data.role || 'clinician',
      }
      localStorage.setItem('authToken', 'authenticated')
      localStorage.setItem('user', JSON.stringify(userData))
      localStorage.setItem('role', userData.role)
      return { success: true, user: userData }
    }
    return { success: false, error: 'Invalid PIN' }
  } catch (error: any) {
    return { success: false, error: error.response?.data?.error || 'Login failed' }
  }
}

export const logout = () => {
  localStorage.removeItem('authToken')
  localStorage.removeItem('user')
  localStorage.removeItem('role')
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

