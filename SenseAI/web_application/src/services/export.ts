import jsPDF from 'jspdf'
import { childrenApi, sessionsApi } from './api'
import { format } from 'date-fns'

const PAGE_MARGIN = 14
const PAGE_WIDTH = 210
const PAGE_HEIGHT = 297
const CONTENT_WIDTH = PAGE_WIDTH - PAGE_MARGIN * 2
const FOOTER_Y = 287

const COGNITIVE_TYPES = new Set(['color_shape', 'frog_jump', 'ai_doctor_bot', 'manual_assessment'])

const normalizeSessionType = (v: unknown) =>
  String(v || '')
    .toLowerCase()
    .replace(/-/g, '_')
    .replace(/^dccs_/, '')

const isCognitiveSession = (session: any) => COGNITIVE_TYPES.has(normalizeSessionType(session?.session_type))

const formatSessionTypeLabel = (type: string): string => {
  const t = normalizeSessionType(type)
  switch (t) {
    case 'color_shape':
      return 'Color–Shape (DCCS)'
    case 'frog_jump':
      return 'Frog Jump (Go/No-Go)'
    case 'ai_doctor_bot':
      return 'AI Questionnaire'
    case 'manual_assessment':
      return 'Manual assessment'
    default:
      return String(type || '—')
  }
}

const riskPalette = (level: string | undefined): [number, number, number] => {
  const r = (level || '').toLowerCase()
  if (r === 'high') return [185, 28, 28]
  if (r === 'moderate') return [180, 83, 9]
  if (r === 'low') return [22, 101, 52]
  return [80, 80, 80]
}

function drawHeader(doc: jsPDF, title: string, subtitle: string, accentRgb: [number, number, number]) {
  doc.setFillColor(...accentRgb)
  doc.rect(0, 0, PAGE_WIDTH, 32, 'F')
  doc.setTextColor(255, 255, 255)
  doc.setFontSize(16)
  doc.setFont('helvetica', 'bold')
  doc.text(title, PAGE_MARGIN, 14)
  doc.setFontSize(9)
  doc.setFont('helvetica', 'normal')
  doc.text(subtitle, PAGE_MARGIN, 22)
  doc.setTextColor(0, 0, 0)
}

function drawFooterOnAllPages(doc: jsPDF, generatedAt: string) {
  const total = doc.getNumberOfPages()
  for (let i = 1; i <= total; i++) {
    doc.setPage(i)
    doc.setFontSize(7)
    doc.setTextColor(120, 120, 120)
    doc.setFont('helvetica', 'italic')
    doc.text(
      `SenseAI • ${generatedAt} • Page ${i} of ${total}`,
      PAGE_MARGIN,
      FOOTER_Y,
      { maxWidth: CONTENT_WIDTH }
    )
    doc.setFont('helvetica', 'normal')
    doc.setTextColor(0, 0, 0)
  }
}

function ensureSpace(doc: jsPDF, y: number, needed: number): number {
  if (y + needed > FOOTER_Y - 10) {
    doc.addPage()
    return PAGE_MARGIN + 8
  }
  return y
}

function sectionTitle(doc: jsPDF, y: number, label: string): number {
  y = ensureSpace(doc, y, 14)
  doc.setFontSize(11)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(37, 99, 235)
  doc.text(label, PAGE_MARGIN, y)
  doc.setDrawColor(200, 210, 230)
  doc.setLineWidth(0.3)
  doc.line(PAGE_MARGIN, y + 1.5, PAGE_WIDTH - PAGE_MARGIN, y + 1.5)
  doc.setTextColor(0, 0, 0)
  doc.setFont('helvetica', 'normal')
  return y + 8
}

function bodyLine(doc: jsPDF, y: number, label: string, value: string): number {
  y = ensureSpace(doc, y, 8)
  doc.setFontSize(9)
  doc.setFont('helvetica', 'bold')
  doc.text(`${label}:`, PAGE_MARGIN, y)
  doc.setFont('helvetica', 'normal')
  const lines = doc.splitTextToSize(value || '—', CONTENT_WIDTH - 42)
  doc.text(lines, PAGE_MARGIN + 40, y)
  return y + Math.max(5, lines.length * 4.2)
}

function drawSessionTableHeader(doc: jsPDF, y: number): number {
  y = ensureSpace(doc, y, 10)
  doc.setFillColor(241, 245, 249)
  doc.rect(PAGE_MARGIN, y - 4, CONTENT_WIDTH, 8, 'F')
  doc.setFontSize(8)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(51, 65, 85)
  doc.text('Date', PAGE_MARGIN + 1, y)
  doc.text('Assessment', PAGE_MARGIN + 28, y)
  doc.text('Cohort', PAGE_MARGIN + 88, y)
  doc.text('Risk', PAGE_MARGIN + 118, y)
  doc.text('Score', PAGE_MARGIN + 145, y)
  doc.text('Status', PAGE_MARGIN + 165, y)
  doc.setFont('helvetica', 'normal')
  doc.setTextColor(0, 0, 0)
  return y + 6
}

function drawSessionRow(doc: jsPDF, y: number, session: any): number {
  const dateStr = session.created_at
    ? format(new Date(session.created_at), 'yyyy-MM-dd HH:mm')
    : '—'
  const typeStr = formatSessionTypeLabel(session.session_type)
  const cohort = session.age_group || '—'
  const risk = session.risk_level || '—'
  const score =
    session.risk_score !== null && session.risk_score !== undefined
      ? String(session.risk_score)
      : '—'
  const completed = session.end_time || session.status === 'completed' ? 'Completed' : 'In progress'

  y = ensureSpace(doc, y, 14)
  doc.setFontSize(8)
  doc.setFont('helvetica', 'normal')

  const [rr, rg, rb] = riskPalette(session.risk_level)
  doc.text(dateStr.slice(0, 16), PAGE_MARGIN + 1, y)

  const typeLines = doc.splitTextToSize(typeStr, 56)
  doc.text(typeLines, PAGE_MARGIN + 28, y)

  doc.text(String(cohort), PAGE_MARGIN + 88, y)
  doc.setTextColor(rr, rg, rb)
  doc.setFont('helvetica', 'bold')
  doc.text(String(risk), PAGE_MARGIN + 118, y)
  doc.setTextColor(0, 0, 0)
  doc.setFont('helvetica', 'normal')
  doc.text(score, PAGE_MARGIN + 145, y)
  doc.text(completed, PAGE_MARGIN + 165, y)

  const rowH = Math.max(12, typeLines.length * 4 + 4)
  doc.setDrawColor(226, 232, 240)
  doc.line(PAGE_MARGIN, y + 2, PAGE_WIDTH - PAGE_MARGIN, y + 2)
  return y + rowH
}

function summarizeFlatObject(obj: unknown, maxKeys = 14): string[] {
  if (!obj || typeof obj !== 'object') return []
  const out: string[] = []
  for (const [k, v] of Object.entries(obj as Record<string, unknown>)) {
    if (out.length >= maxKeys) break
    if (v === null || v === undefined) continue
    if (typeof v === 'object') continue
    const s = String(v)
    if (s.length > 120) out.push(`${k}: ${s.slice(0, 117)}…`)
    else out.push(`${k}: ${s}`)
  }
  return out
}

function drawSessionDetailBlock(doc: jsPDF, y: number, session: any, index: number): number {
  y = ensureSpace(doc, y, 20)
  doc.setFontSize(9)
  doc.setFont('helvetica', 'bold')
  doc.setTextColor(30, 41, 59)
  doc.text(`Session ${index + 1} — ${formatSessionTypeLabel(session.session_type)}`, PAGE_MARGIN, y)
  y += 5
  doc.setFont('helvetica', 'normal')
  doc.setFontSize(8)
  doc.setTextColor(71, 85, 105)

  const meta = [
    `Session ID: ${session.id || '—'}`,
    `Created: ${session.created_at ? format(new Date(session.created_at), 'yyyy-MM-dd HH:mm') : '—'}`,
    `Age cohort: ${session.age_group || '—'}`,
    `Risk: ${session.risk_level || '—'}  •  Score: ${
      session.risk_score !== null && session.risk_score !== undefined ? session.risk_score : '—'
    }`,
  ]
  for (const line of meta) {
    y = ensureSpace(doc, y, 5)
    doc.text(line, PAGE_MARGIN + 2, y)
    y += 4
  }

  const gameLines = summarizeFlatObject(session.game_results)
  const qLines = summarizeFlatObject(session.questionnaire_results)
  const reflLines = summarizeFlatObject(session.reflection_results)

  if (gameLines.length) {
    y += 2
    y = ensureSpace(doc, y, 8)
    doc.setFont('helvetica', 'bold')
    doc.text('Task / game metrics (excerpt)', PAGE_MARGIN + 2, y)
    y += 4
    doc.setFont('helvetica', 'normal')
    for (const line of gameLines) {
      const wrapped = doc.splitTextToSize(line, CONTENT_WIDTH - 6)
      for (const w of wrapped) {
        y = ensureSpace(doc, y, 4)
        doc.text(w, PAGE_MARGIN + 4, y)
        y += 3.5
      }
    }
  }

  if (qLines.length) {
    y += 2
    y = ensureSpace(doc, y, 8)
    doc.setFont('helvetica', 'bold')
    doc.text('Questionnaire (excerpt)', PAGE_MARGIN + 2, y)
    y += 4
    doc.setFont('helvetica', 'normal')
    for (const line of qLines) {
      const wrapped = doc.splitTextToSize(line, CONTENT_WIDTH - 6)
      for (const w of wrapped) {
        y = ensureSpace(doc, y, 4)
        doc.text(w, PAGE_MARGIN + 4, y)
        y += 3.5
      }
    }
  }

  if (reflLines.length) {
    y += 2
    y = ensureSpace(doc, y, 8)
    doc.setFont('helvetica', 'bold')
    doc.text('Clinician reflection (excerpt)', PAGE_MARGIN + 2, y)
    y += 4
    doc.setFont('helvetica', 'normal')
    for (const line of reflLines) {
      const wrapped = doc.splitTextToSize(line, CONTENT_WIDTH - 6)
      for (const w of wrapped) {
        y = ensureSpace(doc, y, 4)
        doc.text(w, PAGE_MARGIN + 4, y)
        y += 3.5
      }
    }
  }

  doc.setTextColor(0, 0, 0)
  y += 4
  return y
}

export type ChildPdfExportOptions = {
  /** Only include cognitive-flexibility pathway sessions (Color-Shape, Frog Jump, AI questionnaire, manual). */
  cognitiveOnly?: boolean
}

// Browser-compatible CSV export function
const convertToCSV = (data: any[]): string => {
  if (data.length === 0) return ''

  // Get headers from first object
  const headers = Object.keys(data[0])

  // Create CSV header row
  const headerRow = headers.join(',')

  // Create data rows
  const dataRows = data.map((row) => {
    return headers
      .map((header) => {
        const value = row[header]
        // Escape commas and quotes in values
        if (value === null || value === undefined) return ''
        const stringValue = String(value)
        if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
          return `"${stringValue.replace(/"/g, '""')}"`
        }
        return stringValue
      })
      .join(',')
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

export const exportChildToPDF = async (childId: string, options?: ChildPdfExportOptions) => {
  try {
    const cognitiveOnly = options?.cognitiveOnly === true

    const [childRes, sessionsRes] = await Promise.all([
      childrenApi.getById(childId),
      sessionsApi.getByChild(childId),
    ])

    const child = childRes.data.child
    let sessions = sessionsRes.data.sessions || []
    if (cognitiveOnly) {
      sessions = sessions.filter(isCognitiveSession)
    }

    sessions = [...sessions].sort(
      (a, b) => new Date(b.created_at || 0).getTime() - new Date(a.created_at || 0).getTime()
    )

    const doc = new jsPDF({ unit: 'mm', format: 'a4' })
    const generatedAt = format(new Date(), "yyyy-MM-dd HH:mm")

    const title = cognitiveOnly
      ? 'Cognitive flexibility — clinical summary'
      : 'Child assessment — clinical summary'
    const subtitle = cognitiveOnly
      ? 'Color–Shape • Frog Jump • Questionnaire • Manual tasks'
      : 'All assessment components on record'

    drawHeader(doc, title, subtitle, [37, 99, 235])

    let y = 40

    doc.setFontSize(7)
    doc.setTextColor(100, 116, 139)
    doc.text(
      'For research and clinical screening support only — not a standalone diagnosis. Interpret alongside full clinical evaluation.',
      PAGE_MARGIN,
      y,
      { maxWidth: CONTENT_WIDTH }
    )
    doc.setTextColor(0, 0, 0)
    y += 10

    y = sectionTitle(doc, y, 'Participant')
    y = bodyLine(doc, y, 'Name', child.name)
    y = bodyLine(doc, y, 'Code', child.child_code || '—')
    y = bodyLine(doc, y, 'Age', child.age != null ? `${Number(child.age).toFixed(1)} years` : '—')
    y = bodyLine(doc, y, 'Age (months)', child.age_in_months != null ? String(child.age_in_months) : '—')
    y = bodyLine(doc, y, 'Gender', child.gender || '—')
    y = bodyLine(doc, y, 'Study group', child.group || '—')
    if (child.asd_level) y = bodyLine(doc, y, 'ASD level', String(child.asd_level))
    y = bodyLine(doc, y, 'Language', child.language || '—')
    if (child.clinician_name) y = bodyLine(doc, y, 'Clinician', String(child.clinician_name))
    if (child.diagnosis_source || child.hospital_id) {
      y = bodyLine(doc, y, 'Site / source', String(child.diagnosis_source || child.hospital_id))
    }
    if (child.external_diagnosis) {
      y = bodyLine(doc, y, 'Recorded diagnosis flag', String(child.external_diagnosis))
    }
    y += 4

    const withRisk = sessions.filter((s: any) => s.risk_score != null && s.risk_score !== '')
    const avgRisk =
      withRisk.length > 0
        ? withRisk.reduce((sum: number, s: any) => sum + Number(s.risk_score), 0) / withRisk.length
        : null

    y = sectionTitle(doc, y, cognitiveOnly ? 'Cognitive pathway — overview' : 'Assessment overview')
    y = bodyLine(doc, y, 'Sessions in this report', String(sessions.length))
    y = bodyLine(
      doc,
      y,
      'High / moderate / low (count)',
      `${sessions.filter((s: any) => (s.risk_level || '').toLowerCase() === 'high').length} / ${sessions.filter((s: any) => (s.risk_level || '').toLowerCase() === 'moderate').length} / ${sessions.filter((s: any) => (s.risk_level || '').toLowerCase() === 'low').length}`
    )
    if (avgRisk != null && Number.isFinite(avgRisk)) {
      y = bodyLine(doc, y, 'Mean algorithmic risk score (sessions with score)', avgRisk.toFixed(1))
    }

    const latest = sessions[0]
    if (latest) {
      y = bodyLine(
        doc,
        y,
        'Most recent session',
        `${formatSessionTypeLabel(latest.session_type)} • ${latest.risk_level || '—'} • ${latest.created_at ? format(new Date(latest.created_at), 'yyyy-MM-dd') : '—'}`
      )
    }
    y += 6

    y = sectionTitle(doc, y, 'Session index')
    if (sessions.length === 0) {
      y = ensureSpace(doc, y, 8)
      doc.setFontSize(9)
      doc.text(cognitiveOnly ? 'No cognitive-flexibility sessions on file.' : 'No sessions on file.', PAGE_MARGIN, y)
      y += 8
    } else {
      y = drawSessionTableHeader(doc, y)
      sessions.forEach((session: any) => {
        y = drawSessionRow(doc, y, session)
      })
    }

    y += 8
    y = sectionTitle(doc, y, 'Session detail & extracted metrics')
    if (sessions.length === 0) {
      y = ensureSpace(doc, y, 8)
      doc.setFontSize(9)
      doc.text('—', PAGE_MARGIN, y)
      y += 8
    } else {
      sessions.forEach((session: any, index: number) => {
        y = drawSessionDetailBlock(doc, y, session, index)
      })
    }

    drawFooterOnAllPages(doc, generatedAt)

    const fname = cognitiveOnly
      ? `cognitive_report_${child.child_code || child.id}.pdf`
      : `child_report_${child.child_code || child.id}.pdf`
    doc.save(fname)
  } catch (error) {
    console.error('PDF export error:', error)
    throw error
  }
}
