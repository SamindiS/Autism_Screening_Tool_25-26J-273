# Training Data Directory

This directory contains training videos and labels for the autism detection model.

## Directory Structure

```
training_data/
├── autism/
│   ├── video1.mp4
│   ├── video2.mp4
│   └── ...
├── typical/
│   ├── video1.mp4
│   ├── video2.mp4
│   └── ...
└── labels.csv
```

## Labels CSV Format

Create a `labels.csv` file with the following columns:

| video_path | label | child_age | notes |
|------------|-------|-----------|-------|
| training_data/autism/video1.mp4 | autism | 3 | Child diagnosed with autism |
| training_data/typical/video1.mp4 | typical | 3 | Typically developing child |

### Required Columns:
- **video_path**: Path to video file (relative to project root)
- **label**: Either "autism" or "typical"
- **child_age**: Age of child in video (optional but recommended)

### Optional Columns:
- **notes**: Additional information about the video
- **diagnosis_date**: When autism was diagnosed (for autism videos)
- **assessment_tool**: Assessment used (ADOS, etc.)

## Data Collection Guidelines

### For Autism Videos:
1. Videos should show children with confirmed autism diagnosis
2. Include various ages (1-6 years)
3. Include different response patterns (immediate, delayed, no response)
4. Ensure proper consent and privacy compliance

### For Typical Videos:
1. Videos should show typically developing children
2. Match age ranges with autism videos
3. Include various response patterns
4. Ensure proper consent and privacy compliance

## Privacy & Ethics

⚠️ **IMPORTANT**: 
- All videos must have proper consent from parents/guardians
- Follow HIPAA/GDPR regulations
- Anonymize any identifying information
- Store data securely
- Do not share videos publicly

## Minimum Data Requirements

For initial training:
- **Minimum**: 20 autism videos + 20 typical videos
- **Recommended**: 50+ autism videos + 50+ typical videos
- **Optimal**: 100+ videos per class

More data = better model accuracy!

## Video Requirements

- **Format**: MP4, AVI, MOV, MKV, WEBM
- **Duration**: 5-30 seconds (name calling scenarios)
- **Quality**: Clear view of child's face and upper body
- **Audio**: Not required (video analysis only)
- **Resolution**: Minimum 480p, recommended 720p or higher

## Example labels.csv

```csv
video_path,label,child_age,notes
training_data/autism/child1_response.mp4,autism,3,Diagnosed at age 2
training_data/autism/child2_response.mp4,autism,4,ADOS-2 confirmed
training_data/typical/child1_response.mp4,typical,3,Typically developing
training_data/typical/child2_response.mp4,typical,4,No developmental concerns
```




























