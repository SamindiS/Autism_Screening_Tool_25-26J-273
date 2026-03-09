import { initializeApp, getApps, type FirebaseApp } from 'firebase/app'
import {
  getFirestore,
  collection,
  getDocs,
  query,
  orderBy,
  limit as fsLimit,
  type Firestore,
} from 'firebase/firestore'

export interface VisualReport {
  id: string
  childName?: string
  childAge?: number
  testDateTime?: string
  score?: number
  scores?: any
  metrics?: any
  interpretation?: {
    summary?: string
    findings?: string[]
    recommendations?: string[]
  }
  parent_name?: string
  parent_email?: string
  parent_phone?: string
  parent_relationship?: string
  created_at?: string | number
  [key: string]: any
}

let app: FirebaseApp | null = null
let db: Firestore | null = null

const getFirebaseConfig = () => {
  const apiKey = import.meta.env.VITE_FIREBASE_API_KEY
  const authDomain = import.meta.env.VITE_FIREBASE_AUTH_DOMAIN
  const projectId = import.meta.env.VITE_FIREBASE_PROJECT_ID
  const appId = import.meta.env.VITE_FIREBASE_APP_ID

  if (!apiKey || !authDomain || !projectId || !appId) {
    throw new Error(
      '[VisualReports] Firebase config missing. Please set VITE_FIREBASE_API_KEY, VITE_FIREBASE_AUTH_DOMAIN, VITE_FIREBASE_PROJECT_ID, VITE_FIREBASE_APP_ID in your .env file.'
    )
  }

  return {
    apiKey,
    authDomain,
    projectId,
    appId,
  }
}

const ensureFirestore = (): Firestore => {
  if (db) return db

  const config = getFirebaseConfig()

  if (!getApps().length) {
    app = initializeApp(config)
  } else {
    app = getApps()[0]!
  }

  db = getFirestore(app)
  return db
}

export const fetchVisualReports = async (max: number = 100): Promise<VisualReport[]> => {
  const firestore = ensureFirestore()
  const col = collection(firestore, 'reports')

  const q = query(col, orderBy('created_at', 'desc'), fsLimit(max))
  const snap = await getDocs(q)

  return snap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  })) as VisualReport[]
}

