import axios from 'axios'

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000'

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor to add auth token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('authToken')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Unauthorized - clear auth and redirect to login
      localStorage.removeItem('authToken')
      localStorage.removeItem('clinician')
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)

// Children API
export const childrenApi = {
  getAll: async () => {
    try {
      console.log('📡 Fetching all children from API...')
      const response = await api.get('/api/children')
      console.log('✅ Children API response:', {
        count: response.data.count,
        childrenCount: response.data.children?.length || 0,
        firstChild: response.data.children?.[0] || null,
      })
      return response
    } catch (error: any) {
      console.error('❌ Error fetching children:', error)
      throw error
    }
  },
  getById: (id: string) => api.get(`/api/children/${id}`),
  create: (data: any) => api.post('/api/children', data),
  update: (id: string, data: any) => api.put(`/api/children/${id}`, data),
  delete: (id: string) => api.delete(`/api/children/${id}`),
  getByClinician: (clinicianId: string) =>
    api.get(`/api/children/clinician/${clinicianId}`),
}

// Sessions API
export const sessionsApi = {
  getAll: async (type?: string, hospital?: string) => {
    try {
      const params = new URLSearchParams()
      if (type) params.append('type', type)
      if (hospital) params.append('hospital', hospital)
      const query = params.toString()
      console.log('📡 Fetching sessions from API...', { type, hospital })
      const response = await api.get(`/api/sessions${query ? `?${query}` : ''}`)
      console.log('✅ Sessions API response:', {
        count: response.data.count,
        sessionsCount: response.data.sessions?.length || 0,
        firstSession: response.data.sessions?.[0] || null,
      })
      return response
    } catch (error: any) {
      console.error('❌ Error fetching sessions:', error)
      throw error
    }
  },
  getById: (id: string) => api.get(`/api/sessions/${id}`),
  getByChild: (childId: string) => api.get(`/api/sessions/child/${childId}`),
  create: (data: any) => api.post('/api/sessions', data),
  update: (id: string, data: any) => api.put(`/api/sessions/${id}`, data),
  delete: (id: string) => api.delete(`/api/sessions/${id}`),
}

// Clinicians API
export const cliniciansApi = {
  login: (pin: string) => api.post('/api/clinicians/login', { pin }),
  getCurrent: () => api.get('/api/clinicians/me'),
  register: (data: any) => api.post('/api/clinicians/register', data),
  getAll: (hospital?: string) => {
    const url = hospital 
      ? `/api/clinicians?hospital=${encodeURIComponent(hospital)}`
      : '/api/clinicians'
    return api.get(url)
  },
  getById: (id: string) => api.get(`/api/clinicians/${id}`),
  update: (id: string, data: any) => api.put(`/api/clinicians/${id}`, data),
  delete: (id: string) => api.delete(`/api/clinicians/${id}`),
}

// Trials API
export const trialsApi = {
  getBySession: (sessionId: string) => api.get(`/api/trials/session/${sessionId}`),
  getById: (id: string) => api.get(`/api/trials/${id}`),
}

export default api

