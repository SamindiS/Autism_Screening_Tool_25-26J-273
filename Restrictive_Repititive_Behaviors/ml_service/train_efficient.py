"""
Memory-efficient training script for RRB Detection Model
Uses data generators to avoid loading all data into memory
"""

import os
import sys
import argparse
import logging
from datetime import datetime
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import classification_report, confusion_matrix
import tensorflow as tf
from tensorflow import keras

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.data_loader_efficient import RRBDataLoaderEfficient
from utils.data_generator import create_generators
from models.rrb_model import build_cnn_lstm_model

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def parse_args():
    """Parse command line arguments"""
    parser = argparse.ArgumentParser(description='Train RRB Detection Model (Memory-Efficient)')
    
    # Data parameters
    parser.add_argument('--dataset_root', type=str, default='../Dataset',
                        help='Root directory of dataset')
    parser.add_argument('--sequence_length', type=int, default=30,
                        help='Number of frames per sequence')
    parser.add_argument('--img_size', type=int, default=224,
                        help='Image size (height and width)')
    
    # Training parameters
    parser.add_argument('--epochs', type=int, default=50,
                        help='Number of training epochs')
    parser.add_argument('--batch_size', type=int, default=8,
                        help='Batch size for training')
    parser.add_argument('--learning_rate', type=float, default=0.001,
                        help='Initial learning rate')
    
    # Model parameters
    parser.add_argument('--use_pretrained', action='store_true', default=True,
                        help='Use pretrained MobileNetV2 weights')
    parser.add_argument('--dropout_rate', type=float, default=0.4,
                        help='Dropout rate')
    
    # Data split parameters
    parser.add_argument('--test_size', type=float, default=0.15,
                        help='Proportion of data for testing')
    parser.add_argument('--val_size', type=float, default=0.15,
                        help='Proportion of training data for validation')
    
    # Output parameters
    parser.add_argument('--output_dir', type=str, default='outputs',
                        help='Directory to save outputs')
    parser.add_argument('--save_preprocessed', action='store_true',
                        help='Save preprocessed data for future use')
    
    return parser.parse_args()


def plot_training_history(history, output_dir):
    """Plot and save training history"""
    fig, axes = plt.subplots(1, 2, figsize=(15, 5))
    
    # Plot accuracy
    axes[0].plot(history.history['accuracy'], label='Train Accuracy')
    axes[0].plot(history.history['val_accuracy'], label='Val Accuracy')
    axes[0].set_title('Model Accuracy')
    axes[0].set_xlabel('Epoch')
    axes[0].set_ylabel('Accuracy')
    axes[0].legend()
    axes[0].grid(True)
    
    # Plot loss
    axes[1].plot(history.history['loss'], label='Train Loss')
    axes[1].plot(history.history['val_loss'], label='Val Loss')
    axes[1].set_title('Model Loss')
    axes[1].set_xlabel('Epoch')
    axes[1].set_ylabel('Loss')
    axes[1].legend()
    axes[1].grid(True)
    
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'training_history.png'), dpi=300, bbox_inches='tight')
    plt.close()
    
    logger.info(f"Saved training history plot to {output_dir}/training_history.png")


def evaluate_model(model, test_gen, class_names, output_dir):
    """Evaluate model on test set"""
    logger.info("\n[5/5] Evaluating model on test set...")
    
    # Get predictions
    y_true = []
    y_pred = []
    
    for i in range(len(test_gen)):
        X_batch, y_batch = test_gen[i]
        predictions = model.predict(X_batch, verbose=0)
        y_pred.extend(np.argmax(predictions, axis=1))
        y_true.extend(y_batch)
    
    y_true = np.array(y_true)
    y_pred = np.array(y_pred)
    
    # Classification report
    report = classification_report(y_true, y_pred, target_names=class_names)
    logger.info("\nClassification Report:")
    logger.info("\n" + report)
    
    # Save report
    with open(os.path.join(output_dir, 'classification_report.txt'), 'w') as f:
        f.write(report)
    
    # Confusion matrix
    cm = confusion_matrix(y_true, y_pred)
    
    # Plot confusion matrix
    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues',
                xticklabels=class_names, yticklabels=class_names)
    plt.title('Confusion Matrix')
    plt.ylabel('True Label')
    plt.xlabel('Predicted Label')
    plt.tight_layout()
    plt.savefig(os.path.join(output_dir, 'confusion_matrix.png'), dpi=300, bbox_inches='tight')
    plt.close()
    
    logger.info(f"Saved confusion matrix to {output_dir}/confusion_matrix.png")
    
    # Calculate accuracy
    accuracy = np.sum(y_true == y_pred) / len(y_true)
    logger.info(f"\nTest Accuracy: {accuracy:.4f}")
    
    return accuracy


def main(args):
    """Main training function"""
    
    # Print header
    print("=" * 80)
    print("RRB Detection Model Training (Memory-Efficient)")
    print("=" * 80)
    print()
    
    # Create output directory
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_dir = os.path.join(args.output_dir, f"training_{timestamp}")
    os.makedirs(output_dir, exist_ok=True)
    
    checkpoint_dir = os.path.join(output_dir, "checkpoints")
    os.makedirs(checkpoint_dir, exist_ok=True)
    
    logger.info(f"Output directory: {output_dir}")
    
    # Step 1: Load and prepare dataset
    print("\n[1/5] Loading and preparing dataset...")
    data_loader = RRBDataLoaderEfficient(
        dataset_root=args.dataset_root,
        sequence_length=args.sequence_length,
        img_size=(args.img_size, args.img_size)
    )
    
    data_loader.prepare_dataset(test_size=args.test_size, val_size=args.val_size)
    
    # Save preprocessed data if requested
    if args.save_preprocessed:
        preprocessed_dir = os.path.join(args.output_dir, "preprocessed_data")
        data_loader.save_preprocessed_data(preprocessed_dir)
    
    # Get class information
    num_classes = data_loader.get_num_classes()
    class_names = data_loader.get_class_names()
    logger.info(f"Number of classes: {num_classes}")
    logger.info(f"Class names: {class_names}")
    
    # Calculate class weights
    class_weights = data_loader.get_class_weights()
    
    # Step 2: Create data generators
    print("\n[2/5] Creating data generators...")
    train_gen, val_gen, test_gen = create_generators(
        data_loader,
        batch_size=args.batch_size,
        augment_train=True
    )
    
    logger.info(f"Train batches: {len(train_gen)}")
    logger.info(f"Validation batches: {len(val_gen)}")
    logger.info(f"Test batches: {len(test_gen)}")
    
    # Step 3: Build model
    print("\n[3/5] Building model...")
    model = build_cnn_lstm_model(
        sequence_length=args.sequence_length,
        img_size=(args.img_size, args.img_size),
        num_classes=num_classes,
        use_pretrained=args.use_pretrained,
        dropout_rate=args.dropout_rate
    )
    
    # Compile model
    optimizer = keras.optimizers.Adam(learning_rate=args.learning_rate)
    model.compile(
        optimizer=optimizer,
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    model.summary()
    
    # Step 4: Train model
    print("\n[4/5] Training model...")
    
    # Callbacks
    callbacks = [
        keras.callbacks.ModelCheckpoint(
            filepath=os.path.join(checkpoint_dir, 'best_model.h5'),
            monitor='val_accuracy',
            save_best_only=True,
            mode='max',
            verbose=1
        ),
        keras.callbacks.EarlyStopping(
            monitor='val_loss',
            patience=10,
            restore_best_weights=True,
            verbose=1
        ),
        keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-7,
            verbose=1
        ),
        keras.callbacks.TensorBoard(
            log_dir=os.path.join(output_dir, 'logs'),
            histogram_freq=1
        )
    ]
    
    # Train
    history = model.fit(
        train_gen,
        validation_data=val_gen,
        epochs=args.epochs,
        class_weight=class_weights,
        callbacks=callbacks,
        verbose=1
    )
    
    # Plot training history
    plot_training_history(history, output_dir)
    
    # Step 5: Evaluate model
    accuracy = evaluate_model(model, test_gen, class_names, output_dir)
    
    # Save final model
    final_model_path = os.path.join(output_dir, 'final_model.h5')
    model.save(final_model_path)
    logger.info(f"Saved final model to {final_model_path}")
    
    # Print summary
    print("\n" + "=" * 80)
    print("Training Complete!")
    print("=" * 80)
    print(f"Output directory: {output_dir}")
    print(f"Best model: {os.path.join(checkpoint_dir, 'best_model.h5')}")
    print(f"Test accuracy: {accuracy:.4f}")
    print("=" * 80)


if __name__ == '__main__':
    args = parse_args()
    main(args)

