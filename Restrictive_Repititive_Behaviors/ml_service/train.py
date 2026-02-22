import os
import sys
import argparse
import numpy as np
import tensorflow as tf
from tensorflow import keras
from datetime import datetime
import json
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from models.rrb_model import RRBClassifier
from utils.data_loader import RRBDataLoader
from config import Config

def plot_training_history(history, output_dir):
    """Plot and save training history"""
    fig, axes = plt.subplots(2, 2, figsize=(15, 10))
    
    # Accuracy
    axes[0, 0].plot(history.history['accuracy'], label='Train Accuracy')
    axes[0, 0].plot(history.history['val_accuracy'], label='Val Accuracy')
    axes[0, 0].set_title('Model Accuracy')
    axes[0, 0].set_xlabel('Epoch')
    axes[0, 0].set_ylabel('Accuracy')
    axes[0, 0].legend()
    axes[0, 0].grid(True)
    
    # Loss
    axes[0, 1].plot(history.history['loss'], label='Train Loss')
    axes[0, 1].plot(history.history['val_loss'], label='Val Loss')
    axes[0, 1].set_title('Model Loss')
    axes[0, 1].set_xlabel('Epoch')
    axes[0, 1].set_ylabel('Loss')
    axes[0, 1].legend()
    axes[0, 1].grid(True)
    
    # Precision
    if 'precision' in history.history:
        axes[1, 0].plot(history.history['precision'], label='Train Precision')
        axes[1, 0].plot(history.history['val_precision'], label='Val Precision')
        axes[1, 0].set_title('Model Precision')
        axes[1, 0].set_xlabel('Epoch')
        axes[1, 0].set_ylabel('Precision')
        axes[1, 0].legend()
        axes[1, 0].grid(True)
    
    # Recall
    if 'recall' in history.history:
        axes[1, 1].plot(history.history['recall'], label='Train Recall')
        axes[1, 1].plot(history.history['val_recall'], label='Val Recall')
        axes[1, 1].set_title('Model Recall')
        axes[1, 1].set_xlabel('Epoch')
        axes[1, 1].set_ylabel('Recall')
        axes[1, 1].legend()
        axes[1, 1].grid(True)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'training_history.png'), dpi=300)
    plt.close()

def plot_confusion_matrix(y_true, y_pred, class_names, output_dir):
    """Plot and save confusion matrix"""
    cm = confusion_matrix(y_true, y_pred)
    
    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', 
                xticklabels=class_names, yticklabels=class_names)
    plt.title('Confusion Matrix')
    plt.ylabel('True Label')
    plt.xlabel('Predicted Label')
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'confusion_matrix.png'), dpi=300)
    plt.close()

def evaluate_model(model, X_test, y_test, label_encoder, output_dir):
    """Evaluate model and save results"""
    # Predictions
    y_pred_probs = model.predict(X_test)
    y_pred = np.argmax(y_pred_probs, axis=1)
    
    # Classification report
    class_names = label_encoder.classes_
    report = classification_report(y_test, y_pred, target_names=class_names, output_dict=True)
    
    # Save report
    with open(os.path.join(output_dir, 'classification_report.json'), 'w') as f:
        json.dump(report, f, indent=2)
    
    # Print report
    print("\nClassification Report:")
    print(classification_report(y_test, y_pred, target_names=class_names))
    
    # Plot confusion matrix
    plot_confusion_matrix(y_test, y_pred, class_names, output_dir)
    
    # Calculate per-class accuracy
    cm = confusion_matrix(y_test, y_pred)
    per_class_accuracy = cm.diagonal() / cm.sum(axis=1)
    
    print("\nPer-class Accuracy:")
    for i, class_name in enumerate(class_names):
        print(f"{class_name}: {per_class_accuracy[i]:.4f}")
    
    return report

def main(args):
    """Main training function"""
    print("=" * 80)
    print("RRB Detection Model Training")
    print("=" * 80)
    
    # Set random seeds for reproducibility
    np.random.seed(args.seed)
    tf.random.set_seed(args.seed)
    
    # Create output directories
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = os.path.join('outputs', f'training_{timestamp}')
    os.makedirs(output_dir, exist_ok=True)
    
    checkpoint_dir = os.path.join(output_dir, 'checkpoints')
    os.makedirs(checkpoint_dir, exist_ok=True)
    
    log_dir = os.path.join(output_dir, 'logs')
    os.makedirs(log_dir, exist_ok=True)
    
    # Initialize data loader
    print("\n[1/5] Loading and preparing dataset...")
    data_loader = RRBDataLoader(
        dataset_root=args.dataset_path,
        sequence_length=args.sequence_length,
        img_size=tuple(args.img_size)
    )
    
    # Check if preprocessed data exists
    preprocessed_dir = 'preprocessed_data'
    if args.use_preprocessed and os.path.exists(preprocessed_dir):
        print("Loading preprocessed data...")
        X_train, X_val, X_test, y_train, y_val, y_test, label_encoder = \
            data_loader.load_preprocessed_data(preprocessed_dir)
    else:
        print("Preparing dataset from scratch...")
        X_train, X_val, X_test, y_train, y_val, y_test = \
            data_loader.prepare_dataset(test_size=args.test_size, val_size=args.val_size)
        
        # Save preprocessed data
        if args.save_preprocessed:
            data_loader.save_preprocessed_data(
                preprocessed_dir, X_train, X_val, X_test, y_train, y_val, y_test
            )
        
        label_encoder = data_loader.label_encoder
    
    # Convert labels to categorical
    num_classes = len(label_encoder.classes_)
    y_train_cat = keras.utils.to_categorical(y_train, num_classes)
    y_val_cat = keras.utils.to_categorical(y_val, num_classes)
    y_test_cat = keras.utils.to_categorical(y_test, num_classes)
    
    print(f"\nDataset Information:")
    print(f"Number of classes: {num_classes}")
    print(f"Classes: {label_encoder.classes_}")
    print(f"Training samples: {len(X_train)}")
    print(f"Validation samples: {len(X_val)}")
    print(f"Test samples: {len(X_test)}")
    print(f"Input shape: {X_train.shape}")
    
    # Calculate class weights for imbalanced data
    class_weights = data_loader.get_class_weights(y_train)
    print(f"\nClass weights: {class_weights}")
    
    # Build model
    print("\n[2/5] Building model...")
    classifier = RRBClassifier(
        sequence_length=args.sequence_length,
        img_size=tuple(args.img_size),
        num_classes=num_classes,
        feature_dim=args.feature_dim
    )
    
    if args.model_type == 'cnn_lstm':
        model = classifier.build_cnn_lstm_model(use_pretrained=args.use_pretrained)
    elif args.model_type == 'pose_lstm':
        model = classifier.build_pose_lstm_model()
    elif args.model_type == 'hybrid':
        model = classifier.build_hybrid_model()
    else:
        raise ValueError(f"Unknown model type: {args.model_type}")
    
    # Compile model
    classifier.compile_model(model, learning_rate=args.learning_rate)
    
    print("\nModel Summary:")
    model.summary()
    
    # Get callbacks
    checkpoint_path = os.path.join(checkpoint_dir, 'best_model.h5')
    callbacks = classifier.get_callbacks(checkpoint_path, log_dir)
    
    # Train model
    print("\n[3/5] Training model...")
    history = model.fit(
        X_train, y_train_cat,
        validation_data=(X_val, y_val_cat),
        epochs=args.epochs,
        batch_size=args.batch_size,
        class_weight=class_weights if args.use_class_weights else None,
        callbacks=callbacks,
        verbose=1
    )
    
    # Plot training history
    print("\n[4/5] Plotting training history...")
    plot_training_history(history, output_dir)
    
    # Evaluate model
    print("\n[5/5] Evaluating model...")
    report = evaluate_model(model, X_test, y_test_cat, label_encoder, output_dir)
    
    # Save final model
    final_model_path = os.path.join(output_dir, 'final_model.h5')
    model.save(final_model_path)
    print(f"\nFinal model saved to: {final_model_path}")
    
    # Save training configuration
    config = vars(args)
    config['num_classes'] = num_classes
    config['classes'] = label_encoder.classes_.tolist()
    config['output_dir'] = output_dir
    
    with open(os.path.join(output_dir, 'training_config.json'), 'w') as f:
        json.dump(config, f, indent=2)
    
    print("\n" + "=" * 80)
    print("Training completed successfully!")
    print(f"Results saved to: {output_dir}")
    print("=" * 80)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Train RRB Detection Model')
    
    # Dataset arguments
    parser.add_argument('--dataset_path', type=str, default='../Dataset',
                       help='Path to dataset directory')
    parser.add_argument('--use_preprocessed', action='store_true',
                       help='Use preprocessed data if available')
    parser.add_argument('--save_preprocessed', action='store_true', default=True,
                       help='Save preprocessed data')
    
    # Model arguments
    parser.add_argument('--model_type', type=str, default='cnn_lstm',
                       choices=['cnn_lstm', 'pose_lstm', 'hybrid'],
                       help='Type of model to train')
    parser.add_argument('--use_pretrained', action='store_true', default=True,
                       help='Use pretrained CNN backbone')
    parser.add_argument('--sequence_length', type=int, default=30,
                       help='Number of frames per sequence')
    parser.add_argument('--img_size', type=int, nargs=2, default=[224, 224],
                       help='Image size (height width)')
    parser.add_argument('--feature_dim', type=int, default=256,
                       help='Feature dimension')
    
    # Training arguments
    parser.add_argument('--epochs', type=int, default=50,
                       help='Number of training epochs')
    parser.add_argument('--batch_size', type=int, default=8,
                       help='Batch size')
    parser.add_argument('--learning_rate', type=float, default=0.001,
                       help='Learning rate')
    parser.add_argument('--test_size', type=float, default=0.2,
                       help='Test set size')
    parser.add_argument('--val_size', type=float, default=0.1,
                       help='Validation set size')
    parser.add_argument('--use_class_weights', action='store_true', default=True,
                       help='Use class weights for imbalanced data')
    parser.add_argument('--seed', type=int, default=42,
                       help='Random seed')
    
    args = parser.parse_args()
    main(args)

