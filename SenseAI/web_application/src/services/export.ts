import jsPDF from 'jspdf'
import { childrenApi, sessionsApi } from './api'
import { format } from 'date-fns'

// Browser-compatible CSV export function
const convertToCSV = (data: any[]): string => {
  if (data.length === 0) return ''
  
  // Get headers from first object
  const headers = Object.keys(data[0])
  
  // Create CSV header row
  const headerRow = headers.join(',')
  
  // Create data rows
  const dataRows = data.map((row) => {
    return headers.map((header) => {
      const value = row[header]
      // Escape commas and quotes in values
      if (value === null || value === undefined) return ''
      const stringValue = String(value)
      if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
        return `"${stringValue.replace(/"/g, '""')}"`
      }
      return stringValue
    }).join(',')
  })
  
  return [headerRow, ...dataRows].join('\n')
}

export const exportToCSV = async (
  type: 'children' | 'sessions' | 'all',
  dateRange?: { from: Date; to: Date }
) => {
  let data: any[] = []

  try {
    if (type === 'children' || type === 'all') {
      const response = await childrenApi.getAll()
      const children = response.data.children || []
      
      data = children.map((child: any) => ({
        id: child.id,
        name: child.name,
        code: child.child_code || child.name,
        age: child.age?.toFixed(2) || '',
        age_months: child.age_in_months || '',
        gender: child.gender,
        group: child.group || 'typically_developing',
        asd_level: child.asd_level || '',
        diagnosis_source: child.diagnosis_source || '',
        clinician_id: child.clinician_id || '',
        clinician_name: child.clinician_name || '',
        created_at: child.created_at ? format(new Date(child.created_at), 'yyyy-MM-dd HH:mm:ss') : '',
      }))
    }

    if (type === 'sessions' || type === 'all') {
      const response = await sessionsApi.getAll()
      const sessions = (response.data.sessions || []).map((session: any) => ({
        session_id: session.id,
        child_id: session.child_id,
        session_type: session.session_type,
        age_group: session.age_group || '',
        risk_score: session.risk_score || '',
        risk_level: session.risk_level || '',
        start_time: session.start_time ? format(new Date(session.start_time), 'yyyy-MM-dd HH:mm:ss') : '',
        end_time: session.end_time ? format(new Date(session.end_time), 'yyyy-MM-dd HH:mm:ss') : '',
        created_at: session.created_at ? format(new Date(session.created_at), 'yyyy-MM-dd HH:mm:ss') : '',
      }))
      
      if (dateRange) {
        const filtered = sessions.filter((s: any) => {
          const date = new Date(s.created_at)
          return date >= dateRange.from && date <= dateRange.to
        })
        data = type === 'all' ? [...data, ...filtered] : filtered
      } else {
        data = type === 'all' ? [...data, ...sessions] : sessions
      }
    }

    const csv = convertToCSV(data)
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = window.URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `senseai_export_${type}_${format(new Date(), 'yyyyMMdd_HHmmss')}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    window.URL.revokeObjectURL(url)
  } catch (error) {
    console.error('Export error:', error)
    throw error
  }
}

export const exportChildToPDF = async (childId: string) => {
  try {
    const [childRes, sessionsRes] = await Promise.all([
      childrenApi.getById(childId),
      sessionsApi.getByChild(childId),
    ])

    const child = childRes.data.child
    const sessions = sessionsRes.data.sessions || []

    const doc = new jsPDF()
    let y = 20

    // Header
    doc.setFontSize(18)
    doc.text('Child Assessment Report', 10, y)
    y += 10

    // Child Information
    doc.setFontSize(12)
    doc.text(`Name: ${child.name}`, 10, y)
    y += 7
    doc.text(`Code: ${child.child_code || child.name}`, 10, y)
    y += 7
    doc.text(`Age: ${child.age?.toFixed(1) || 'N/A'} years`, 10, y)
    y += 7
    doc.text(`Gender: ${child.gender}`, 10, y)
    y += 7
    doc.text(`Group: ${child.group || 'N/A'}`, 10, y)
    y += 7
    if (child.asd_level) {
      doc.text(`ASD Level: ${child.asd_level}`, 10, y)
      y += 7
    }
    y += 5

    // Assessment History
    doc.setFontSize(14)
    doc.text('Assessment History', 10, y)
    y += 10

    doc.setFontSize(10)
    if (sessions.length === 0) {
      doc.text('No assessments completed', 10, y)
    } else {
      sessions.forEach((session: any, index: number) => {
        if (y > 270) {
          doc.addPage()
          y = 20
        }
        doc.text(`${index + 1}. ${session.session_type}`, 10, y)
        y += 5
        if (session.risk_level) {
          doc.text(`   Risk Level: ${session.risk_level}`, 10, y)
          y += 5
        }
        if (session.risk_score !== null && session.risk_score !== undefined) {
          doc.text(`   Risk Score: ${session.risk_score}`, 10, y)
          y += 5
        }
        if (session.created_at) {
          doc.text(`   Date: ${format(new Date(session.created_at), 'yyyy-MM-dd')}`, 10, y)
          y += 5
        }
        y += 3
      })
    }

    doc.save(`child_report_${child.child_code || child.id}.pdf`)
  } catch (error) {
    console.error('PDF export error:', error)
    throw error
  }
}

