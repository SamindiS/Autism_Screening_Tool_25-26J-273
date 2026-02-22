"""Add standalone function to rrb_model.py"""

with open('models/rrb_model.py', 'a') as f:
    f.write('''

# Standalone functions for easy import

def build_cnn_lstm_model(sequence_length=30, img_size=(224, 224), num_classes=6, use_pretrained=True, dropout_rate=0.4):
    """Build CNN+LSTM model (standalone function)"""
    classifier = RRBClassifier(sequence_length=sequence_length, img_size=img_size, num_classes=num_classes)
    return classifier.build_cnn_lstm_model(use_pretrained=use_pretrained)

def build_pose_lstm_model(sequence_length=30, num_classes=6, pose_feature_dim=132):
    """Build Pose-LSTM model (standalone function)"""
    classifier = RRBClassifier(sequence_length=sequence_length, num_classes=num_classes)
    return classifier.build_pose_lstm_model(pose_feature_dim=pose_feature_dim)

def build_hybrid_model(sequence_length=30, img_size=(224, 224), num_classes=6, pose_feature_dim=132, use_pretrained=True):
    """Build Hybrid model (standalone function)"""
    classifier = RRBClassifier(sequence_length=sequence_length, img_size=img_size, num_classes=num_classes)
    return classifier.build_hybrid_model(pose_feature_dim=pose_feature_dim, use_pretrained=use_pretrained)
''')

print("Added standalone functions to models/rrb_model.py")

