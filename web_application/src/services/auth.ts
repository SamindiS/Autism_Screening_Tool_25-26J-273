import { cliniciansApi } from './api'

export interface Clinician {
  id: string
  name: string
  hospital: string
  created_at?: number
}

export const login = async (pin: string): Promise<{ success: boolean; clinician?: Clinician; error?: string }> => {
  try {
    const response = await cliniciansApi.login(pin)
    if (response.data.success) {
      const clinician = response.data.clinician
      localStorage.setItem('authToken', 'authenticated') // Simple token for now
      localStorage.setItem('clinician', JSON.stringify(clinician))
      return { success: true, clinician }
    }
    return { success: false, error: 'Invalid PIN' }
  } catch (error: any) {
    return { success: false, error: error.response?.data?.error || 'Login failed' }
  }
}

export const logout = () => {
  localStorage.removeItem('authToken')
  localStorage.removeItem('clinician')
}

export const isAuthenticated = (): boolean => {
  return !!localStorage.getItem('authToken')
}

export const getCurrentClinician = (): Clinician | null => {
  const clinicianStr = localStorage.getItem('clinician')
  if (clinicianStr) {
    try {
      return JSON.parse(clinicianStr)
    } catch {
      return null
    }
  }
  return null
}

