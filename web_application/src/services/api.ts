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
  getAll: () => api.get('/api/children'),
  getById: (id: string) => api.get(`/api/children/${id}`),
  create: (data: any) => api.post('/api/children', data),
  update: (id: string, data: any) => api.put(`/api/children/${id}`, data),
  delete: (id: string) => api.delete(`/api/children/${id}`),
  getByClinician: (clinicianId: string) =>
    api.get(`/api/children/clinician/${clinicianId}`),
}

// Sessions API
export const sessionsApi = {
  getAll: () => api.get('/api/sessions'),
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
}

// Trials API
export const trialsApi = {
  getBySession: (sessionId: string) => api.get(`/api/trials/session/${sessionId}`),
  getById: (id: string) => api.get(`/api/trials/${id}`),
}

export default api

