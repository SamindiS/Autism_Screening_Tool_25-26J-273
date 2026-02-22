"""
Create label encoder for RRB categories
"""
import pickle
from sklearn.preprocessing import LabelEncoder
import numpy as np

# RRB Categories (must match training data)
categories = [
    'hand_flapping',
    'head_banging',
    'head_nodding',
    'spinning',
    'atypical_hand_movements',
    'normal'
]

# Create label encoder
label_encoder = LabelEncoder()
label_encoder.fit(categories)

# Save label encoder
with open('models/label_encoder.pkl', 'wb') as f:
    pickle.dump(label_encoder, f)

print("Label encoder created successfully!")
print(f"Classes: {label_encoder.classes_}")
print(f"Saved to: models/label_encoder.pkl")

