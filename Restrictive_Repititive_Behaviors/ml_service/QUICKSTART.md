# Quick Start Guide - RRB Detection ML Service

## 🚀 Get Started in 5 Minutes

### Step 1: Install Dependencies (2 minutes)

```bash
# Navigate to ml_service directory
cd ml_service

# Run setup script
python setup.py
```

This will:
- Create necessary directories
- Install all Python dependencies
- Check for dataset availability

### Step 2: Analyze Dataset (1 minute)

```bash
# Analyze the dataset to understand its structure
python analyze_dataset.py
```

This generates:
- Dataset statistics (JSON)
- Visualization plots
- Category breakdown

### Step 3: Train the Model (30-60 minutes)

```bash
# Quick training (50 epochs)
python train.py --epochs 50 --batch_size 8

# Or use the batch script (Windows)
run_training.bat
```

**Training Options:**

**Fast Training (for testing):**
```bash
python train.py --epochs 10 --batch_size 4
```

**Production Training (best accuracy):**
```bash
python train.py --epochs 100 --batch_size 16 --learning_rate 0.0001
```

**What happens during training:**
1. Dataset is loaded and preprocessed
2. Videos are converted to frame sequences
3. CNN+LSTM model is trained
4. Best model is saved automatically
5. Training plots and metrics are generated

**Output:**
- Model file: `outputs/training_YYYYMMDD_HHMMSS/best_model.h5`
- Training plots: `outputs/training_YYYYMMDD_HHMMSS/training_history.png`
- Classification report: `outputs/training_YYYYMMDD_HHMMSS/classification_report.json`

### Step 4: Copy Trained Model (30 seconds)

After training completes, copy the best model to the models directory:

```bash
# Windows
copy outputs\training_YYYYMMDD_HHMMSS\checkpoints\best_model.h5 models\rrb_classifier.h5

# Linux/Mac
cp outputs/training_YYYYMMDD_HHMMSS/checkpoints/best_model.h5 models/rrb_classifier.h5
```

Also copy the label encoder:

```bash
# Windows
copy preprocessed_data\label_encoder.pkl models\label_encoder.pkl

# Linux/Mac
cp preprocessed_data/label_encoder.pkl models/label_encoder.pkl
```

### Step 5: Test Inference (1 minute)

```bash
# Test on a single video
python test_inference.py --mode single --video_path ../Dataset/Spinning/v_Spinning_1.mp4

# Test on a folder
python test_inference.py --mode folder --folder_path ../Dataset/Spinning
```

### Step 6: Start API Server (30 seconds)

```bash
# Start the Flask server
python app.py

# Or use batch script (Windows)
run_server.bat
```

Server will start at: `http://localhost:5000`

### Step 7: Test API (1 minute)

**Using curl:**
```bash
curl -X POST -F "video=@test_video.mp4" http://localhost:5000/api/v1/detect
```

**Using Python:**
```python
import requests

url = "http://localhost:5000/api/v1/detect"
files = {'video': open('test_video.mp4', 'rb')}
response = requests.post(url, files=files)
print(response.json())
```

**Using Postman:**
1. Create POST request to `http://localhost:5000/api/v1/detect`
2. Select Body → form-data
3. Add key "video" with type "File"
4. Select your video file
5. Send request

## 📊 Expected Results

**Successful Detection Response:**
```json
{
  "success": true,
  "detection": {
    "detected": true,
    "primary_behavior": "hand_flapping",
    "confidence": 0.92,
    "behaviors": [
      {
        "behavior": "hand_flapping",
        "confidence": 0.92,
        "occurrences": 5,
        "total_duration": 12.5
      }
    ]
  },
  "metadata": {
    "video_duration": 15.0,
    "video_fps": 30,
    "sequences_analyzed": 10
  }
}
```

## 🔧 Troubleshooting

### Issue: "Model not found"
**Solution:** Make sure you've completed Step 4 (copy trained model)

### Issue: "Out of memory during training"
**Solution:** Reduce batch size
```bash
python train.py --batch_size 4
```

### Issue: "No module named 'tensorflow'"
**Solution:** Reinstall dependencies
```bash
pip install -r requirements.txt
```

### Issue: "Dataset not found"
**Solution:** Ensure Dataset folder is in parent directory
```
RRB/
├── Dataset/
│   ├── Spinning/
│   ├── Hand Flapping/
│   └── ...
└── ml_service/
    ├── train.py
    └── ...
```

## 📈 Performance Tips

1. **Use GPU for training** (if available):
   - Install tensorflow-gpu
   - Training will be 10-20x faster

2. **Use preprocessed data**:
   - First run saves preprocessed data
   - Subsequent runs load it directly
   - Saves 10-15 minutes per training session

3. **Adjust sequence length**:
   - Shorter sequences (15-20 frames) = faster training
   - Longer sequences (30-40 frames) = better accuracy

## 🎯 Next Steps

1. **Integrate with Backend:**
   - See Node.js backend integration guide
   - Configure API endpoints

2. **Deploy to Production:**
   - Use Docker: `docker-compose up -d`
   - Configure environment variables
   - Set up monitoring

3. **Optimize Model:**
   - Try different architectures
   - Implement data augmentation
   - Fine-tune hyperparameters

## 📚 Additional Resources

- Full documentation: `README.md`
- API documentation: See API Endpoints section in README
- Model architecture: `models/rrb_model.py`
- Configuration: `config.py` and `.env`

## ✅ Checklist

- [ ] Dependencies installed
- [ ] Dataset analyzed
- [ ] Model trained (50+ epochs)
- [ ] Model copied to models directory
- [ ] Inference tested successfully
- [ ] API server running
- [ ] API endpoints tested

**Congratulations! Your RRB Detection ML Service is ready! 🎉**

