import { Navigate, Outlet } from 'react-router-dom'
import { isAuthenticated } from '../../services/auth'

const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  if (!isAuthenticated()) {
    return <Navigate to="/login" replace />
  }

  return <>{children}</>
}

export default ProtectedRoute





