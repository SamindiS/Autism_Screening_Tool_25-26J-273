# 📄 PDF Report Generation Feature

## Overview

The SenseAI app now supports generating comprehensive PDF reports for each child, containing all assessment data, session summaries, and risk scores.

---

## 🎯 Features

### **1. Complete Child Reports**
- ✅ Cover page with child information
- ✅ Child demographics and study group details
- ✅ Individual session pages with detailed results
- ✅ Summary page with statistics and risk level distribution
- ✅ Professional formatting with SenseAI branding

### **2. Report Contents**

#### **Cover Page**
- SenseAI branding
- Child name and code
- Report generation date

#### **Child Information Page**
- Full demographics (name, DOB, age, gender)
- Study group (ASD/Control)
- ASD level (if applicable)
- Language preference

#### **Session Pages** (One per session)
- Session type and date/time
- Duration
- Risk assessment (score and level)
- Game results (DCCS, Frog Jump metrics)
- Questionnaire results
- Additional metrics

#### **Summary Page**
- Total sessions count
- Completed sessions
- Average risk score
- Risk level distribution (High/Moderate/Low)
- Complete session history list

---

## 📱 How to Use

### **Step 1: Navigate to Child Profile**
1. Open the app
2. Go to "Children" section
3. Select a child from the list

### **Step 2: Generate PDF Report**
1. On the child detail screen, tap the **PDF icon** (📄) in the top-right AppBar
2. Wait for PDF generation (shows loading dialog)
3. PDF will be generated and shared via system share dialog

### **Step 3: Save or Share**
- **Save**: Choose "Save to Files" or "Save to Downloads"
- **Share**: Share via email, messaging apps, etc.
- **Print**: Use system print option

---

## 🔧 Technical Details

### **PDF Service Location**
```
lib/core/services/pdf_report_service.dart
```

### **Key Functions**

#### **1. Generate and Share**
```dart
await PdfReportService.generateAndShareReport(
  child: childData,
  sessions: sessionsList,
);
```
- Generates PDF
- Opens system share dialog
- User can save/share/print

#### **2. Generate Only**
```dart
final filePath = await PdfReportService.generateChildReport(
  child: childData,
  sessions: sessionsList,
);
```
- Returns file path
- PDF saved to app documents directory

#### **3. Generate and Print**
```dart
await PdfReportService.generateAndPrintReport(
  child: childData,
  sessions: sessionsList,
);
```
- Generates PDF
- Opens system print dialog

### **Dependencies**
- `pdf: ^3.11.1` - PDF generation
- `printing: ^5.13.3` - Printing support
- `share_plus: ^10.0.2` - File sharing
- `path_provider: ^2.1.4` - File system access

---

## 📋 PDF Structure

### **Page 1: Cover Page**
```
┌─────────────────────────┐
│      SenseAI            │
│  ASD Screening System   │
│                         │
│  Child Assessment       │
│      Report             │
│                         │
│  Child Name: ...        │
│  Child Code: ...        │
│  Generated: ...         │
└─────────────────────────┘
```

### **Page 2: Child Information**
- Name, Code, DOB, Age
- Gender, Study Group
- ASD Level, Language

### **Page 3-N: Session Pages**
- One page per session
- Session details
- Risk assessment
- Game/questionnaire results

### **Last Page: Summary**
- Statistics
- Risk distribution
- Session history

---

## 🎨 Formatting

### **Colors**
- **High Risk**: Red (#C62828)
- **Moderate Risk**: Orange (#E65100)
- **Low Risk**: Green (#2E7D32)
- **Headers**: Blue (#1976D2)

### **Fonts**
- **Headers**: Bold, 18-24pt
- **Body**: Regular, 12pt
- **Labels**: Bold, 12pt

### **Layout**
- A4 page format
- 40pt margins
- Professional spacing
- Clear sections

---

## 📊 Data Included

### **Child Data**
- ✅ Name, Code, DOB
- ✅ Age (months/years)
- ✅ Gender
- ✅ Study Group
- ✅ ASD Level
- ✅ Language Preference

### **Session Data**
- ✅ Session Type
- ✅ Start/End Time
- ✅ Duration
- ✅ Risk Score
- ✅ Risk Level
- ✅ Game Results (all metrics)
- ✅ Questionnaire Results
- ✅ Additional Metrics

### **Summary Statistics**
- ✅ Total Sessions
- ✅ Completed Sessions
- ✅ Average Risk Score
- ✅ Risk Level Distribution
- ✅ Session History List

---

## 🔍 Example Report

**File Name Format:**
```
{ChildCode}_Report_YYYYMMDD_HHMMSS.pdf
```

**Example:**
```
LRH-001_Report_20260104_143022.pdf
```

---

## 🐛 Troubleshooting

### **Issue: PDF not generating**
- **Check**: Ensure child has at least one session
- **Check**: Storage permissions granted
- **Check**: Sufficient device storage

### **Issue: Share dialog not appearing**
- **Check**: `share_plus` package installed
- **Check**: Device supports file sharing

### **Issue: PDF is empty**
- **Check**: Child data is valid
- **Check**: Sessions have data
- **Check**: Error logs in console

---

## ✅ Testing

### **Test Cases**
1. ✅ Generate PDF for child with multiple sessions
2. ✅ Generate PDF for child with no sessions
3. ✅ Generate PDF for ASD child
4. ✅ Generate PDF for Control child
5. ✅ Share PDF via email
6. ✅ Save PDF to device
7. ✅ Print PDF

---

## 🚀 Future Enhancements

- [ ] Custom report templates
- [ ] Charts/graphs in PDF
- [ ] Multi-language PDF support
- [ ] Batch PDF generation
- [ ] PDF password protection
- [ ] Custom branding options

---

**Feature Status**: ✅ Complete and Ready to Use

**Last Updated**: January 2025


