# DCCS Task Flow Diagram Generator

This tool generates publication-ready flowcharts for the DCCS (Dimensional Change Card Sort) task workflow, suitable for research papers and presentations.

## 📋 Files

- **`generate_dccs_flow_diagram.py`** - Standalone Python script
- **`DCCS_FLOW_DIAGRAM_NOTEBOOK.ipynb`** - Jupyter notebook version (for Colab/local notebooks)

## 🚀 Quick Start

### Option 1: Python Script (Recommended)

```bash
# Install dependencies
pip install matplotlib numpy

# Run the script
python generate_dccs_flow_diagram.py
```

**Output:**
- `dccs_flow_diagram.png` (300 DPI, high-resolution)
- `dccs_flow_diagram.pdf` (vector format for publications)
- `dccs_flow_diagram.svg` (scalable vector graphics)

### Option 2: Jupyter Notebook / Google Colab

1. Open `DCCS_FLOW_DIAGRAM_NOTEBOOK.ipynb` in Jupyter or upload to Google Colab
2. Run all cells
3. Download the generated files

## 📊 Diagram Components

The flowchart includes:

1. **START** - Child begins assessment, age verification
2. **PRE-SWITCH INSTRUCTION** - Display sorting rule (Rule A: "Sort by Color")
3. **PRE-SWITCH BLOCK** - Rule A execution (15-20 trials)
4. **RULE SWITCH INSTRUCTION** - Display new rule (Rule B: "Sort by Shape")
5. **POST-SWITCH BLOCK** - Rule B execution (15-20 trials)
6. **FEATURE COMPUTATION** - Calculate metrics (accuracy, switch cost, perseverative errors)
7. **AGE NORMALIZATION** - Apply z-score normalization
8. **ML FEATURE EXPORT** - Send to Logistic Regression model
9. **END** - Return risk score to clinician dashboard

## 🎨 Customization

### Change Output Format

```python
# Generate only PNG
create_dccs_flow_diagram(output_format='png', dpi=300)

# Generate only PDF (vector format)
create_dccs_flow_diagram(output_format='pdf')

# Generate all formats
create_dccs_flow_diagram(output_format='all', dpi=300)
```

### Adjust Resolution

```python
# High resolution for publications (300 DPI)
create_dccs_flow_diagram(dpi=300)

# Lower resolution for web (150 DPI)
create_dccs_flow_diagram(dpi=150)
```

### Adjust Figure Size

```python
# Wider diagram
create_dccs_flow_diagram(figsize=(10, 14))

# Narrower diagram
create_dccs_flow_diagram(figsize=(6, 10))
```

## 📝 Figure Caption (IEEE Style)

The diagram includes this caption:

> **Fig. X.** Workflow of the digital Dimensional Change Card Sort (DCCS) task illustrating pre-switch and post-switch phases, trial-level data capture, feature extraction, age normalization, and risk prediction.

## 🔧 Requirements

- Python 3.8+
- matplotlib >= 3.0.0
- numpy >= 1.20.0

## 📦 Installation

```bash
pip install matplotlib numpy
```

## 💡 Usage Tips

1. **For Publications**: Use PDF format (vector graphics, scalable)
2. **For Presentations**: Use PNG format (300 DPI for high quality)
3. **For Web**: Use SVG format (scalable, small file size)
4. **Color Scheme**: The diagram uses color-coded nodes:
   - Green: Start/End nodes
   - Blue: Pre-switch phase
   - Orange: Rule switch
   - Red: Post-switch phase
   - Purple: Feature computation
   - Cyan: Age normalization
   - Brown: ML export

## 🎯 Output Quality

- **PNG**: 300 DPI (publication quality)
- **PDF**: Vector format (infinitely scalable, best for publications)
- **SVG**: Scalable vector graphics (web-friendly)

## 📄 License

Part of the SenseAI Autism Screening Tool project (25-26J-273)

---

**Generated diagrams are ready for use in research papers, presentations, and documentation.**
