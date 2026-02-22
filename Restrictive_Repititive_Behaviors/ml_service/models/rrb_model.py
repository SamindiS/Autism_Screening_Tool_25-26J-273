import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2, EfficientNetB0
import numpy as np
from typing import Tuple, Optional

class RRBClassifier:
    """CNN+LSTM model for RRB classification from video sequences"""
    
    def __init__(self, 
                 sequence_length: int = 30,
                 img_size: Tuple[int, int] = (224, 224),
                 num_classes: int = 6,
                 feature_dim: int = 256):
        """
        Initialize RRB Classifier model
        
        Args:
            sequence_length: Number of frames in each sequence
            img_size: Input image size (height, width)
            num_classes: Number of RRB categories
            feature_dim: Dimension of extracted features
        """
        self.sequence_length = sequence_length
        self.img_size = img_size
        self.num_classes = num_classes
        self.feature_dim = feature_dim
        self.model = None
    
    def build_cnn_lstm_model(self, use_pretrained: bool = True) -> keras.Model:
        """
        Build CNN+LSTM architecture for video classification
        
        Args:
            use_pretrained: Whether to use pretrained CNN backbone
            
        Returns:
            Compiled Keras model
        """
        # Input layer: (batch, sequence_length, height, width, channels)
        input_shape = (self.sequence_length, self.img_size[0], self.img_size[1], 3)
        inputs = layers.Input(shape=input_shape)
        
        # CNN Feature Extractor (applied to each frame)
        if use_pretrained:
            # Use MobileNetV2 as backbone (lightweight for mobile deployment)
            base_model = MobileNetV2(
                include_top=False,
                weights='imagenet',
                input_shape=(self.img_size[0], self.img_size[1], 3),
                pooling='avg'
            )
            base_model.trainable = False  # Freeze initially
        else:
            # Custom CNN
            base_model = self._build_custom_cnn()
        
        # Apply CNN to each frame using TimeDistributed
        x = layers.TimeDistributed(base_model)(inputs)
        
        # Additional dense layer for feature transformation
        x = layers.TimeDistributed(layers.Dense(self.feature_dim, activation='relu'))(x)
        x = layers.TimeDistributed(layers.Dropout(0.3))(x)
        
        # LSTM layers for temporal modeling
        x = layers.LSTM(256, return_sequences=True, dropout=0.3, recurrent_dropout=0.2)(x)
        x = layers.LSTM(128, return_sequences=False, dropout=0.3, recurrent_dropout=0.2)(x)
        
        # Dense layers for classification
        x = layers.Dense(128, activation='relu')(x)
        x = layers.Dropout(0.4)(x)
        x = layers.Dense(64, activation='relu')(x)
        x = layers.Dropout(0.3)(x)
        
        # Output layer with softmax for multi-class classification
        outputs = layers.Dense(self.num_classes, activation='softmax')(x)
        
        # Create model
        model = keras.Model(inputs=inputs, outputs=outputs, name='RRB_CNN_LSTM')
        
        return model
    
    def build_pose_lstm_model(self, pose_feature_dim: int = 132) -> keras.Model:
        """
        Build LSTM model for pose-based features (alternative architecture)
        
        Args:
            pose_feature_dim: Dimension of pose features (33 landmarks * 4 values)
            
        Returns:
            Compiled Keras model
        """
        # Input: (batch, sequence_length, pose_feature_dim)
        inputs = layers.Input(shape=(self.sequence_length, pose_feature_dim))
        
        # Normalization layer
        x = layers.BatchNormalization()(inputs)
        
        # LSTM layers
        x = layers.LSTM(256, return_sequences=True, dropout=0.3)(x)
        x = layers.LSTM(128, return_sequences=True, dropout=0.3)(x)
        x = layers.LSTM(64, return_sequences=False, dropout=0.3)(x)
        
        # Dense layers
        x = layers.Dense(128, activation='relu')(x)
        x = layers.Dropout(0.4)(x)
        x = layers.Dense(64, activation='relu')(x)
        x = layers.Dropout(0.3)(x)
        
        # Output layer
        outputs = layers.Dense(self.num_classes, activation='softmax')(x)
        
        model = keras.Model(inputs=inputs, outputs=outputs, name='RRB_Pose_LSTM')
        
        return model
    
    def build_hybrid_model(self, pose_feature_dim: int = 132) -> keras.Model:
        """
        Build hybrid model combining visual and pose features
        
        Args:
            pose_feature_dim: Dimension of pose features
            
        Returns:
            Compiled Keras model
        """
        # Visual input branch
        visual_input = layers.Input(
            shape=(self.sequence_length, self.img_size[0], self.img_size[1], 3),
            name='visual_input'
        )
        
        # CNN backbone
        base_cnn = MobileNetV2(
            include_top=False,
            weights='imagenet',
            input_shape=(self.img_size[0], self.img_size[1], 3),
            pooling='avg'
        )
        base_cnn.trainable = False
        
        visual_features = layers.TimeDistributed(base_cnn)(visual_input)
        visual_features = layers.TimeDistributed(layers.Dense(128, activation='relu'))(visual_features)
        
        # Pose input branch
        pose_input = layers.Input(
            shape=(self.sequence_length, pose_feature_dim),
            name='pose_input'
        )
        
        pose_features = layers.Dense(128, activation='relu')(pose_input)
        
        # Concatenate features
        combined = layers.Concatenate()([visual_features, pose_features])
        
        # LSTM for temporal modeling
        x = layers.LSTM(256, return_sequences=True, dropout=0.3)(combined)
        x = layers.LSTM(128, return_sequences=False, dropout=0.3)(x)
        
        # Classification head
        x = layers.Dense(128, activation='relu')(x)
        x = layers.Dropout(0.4)(x)
        x = layers.Dense(64, activation='relu')(x)
        x = layers.Dropout(0.3)(x)
        
        outputs = layers.Dense(self.num_classes, activation='softmax')(x)
        
        model = keras.Model(
            inputs=[visual_input, pose_input],
            outputs=outputs,
            name='RRB_Hybrid_Model'
        )
        
        return model
    
    def _build_custom_cnn(self) -> keras.Model:
        """
        Build custom CNN for feature extraction
        
        Returns:
            CNN model
        """
        inputs = layers.Input(shape=(self.img_size[0], self.img_size[1], 3))
        
        # Conv Block 1
        x = layers.Conv2D(32, (3, 3), activation='relu', padding='same')(inputs)
        x = layers.BatchNormalization()(x)
        x = layers.MaxPooling2D((2, 2))(x)
        
        # Conv Block 2
        x = layers.Conv2D(64, (3, 3), activation='relu', padding='same')(x)
        x = layers.BatchNormalization()(x)
        x = layers.MaxPooling2D((2, 2))(x)
        
        # Conv Block 3
        x = layers.Conv2D(128, (3, 3), activation='relu', padding='same')(x)
        x = layers.BatchNormalization()(x)
        x = layers.MaxPooling2D((2, 2))(x)
        
        # Conv Block 4
        x = layers.Conv2D(256, (3, 3), activation='relu', padding='same')(x)
        x = layers.BatchNormalization()(x)
        x = layers.MaxPooling2D((2, 2))(x)
        
        # Global pooling
        x = layers.GlobalAveragePooling2D()(x)
        
        model = keras.Model(inputs=inputs, outputs=x, name='Custom_CNN')
        
        return model
    
    def compile_model(self, model: keras.Model, learning_rate: float = 0.001):
        """
        Compile model with optimizer and loss function
        
        Args:
            model: Keras model to compile
            learning_rate: Learning rate for optimizer
        """
        optimizer = keras.optimizers.Adam(learning_rate=learning_rate)
        
        model.compile(
            optimizer=optimizer,
            loss='categorical_crossentropy',
            metrics=[
                'accuracy',
                keras.metrics.Precision(name='precision'),
                keras.metrics.Recall(name='recall'),
                keras.metrics.AUC(name='auc')
            ]
        )
        
        self.model = model
        return model
    
    def get_callbacks(self, checkpoint_path: str, log_dir: str) -> list:
        """
        Get training callbacks
        
        Args:
            checkpoint_path: Path to save model checkpoints
            log_dir: Directory for TensorBoard logs
            
        Returns:
            List of callbacks
        """
        callbacks = [
            keras.callbacks.ModelCheckpoint(
                checkpoint_path,
                monitor='val_accuracy',
                save_best_only=True,
                mode='max',
                verbose=1
            ),
            keras.callbacks.EarlyStopping(
                monitor='val_loss',
                patience=15,
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
                log_dir=log_dir,
                histogram_freq=1
            )
        ]
        
        return callbacks
    
    def summary(self):
        """Print model summary"""
        if self.model:
            self.model.summary()
        else:
            print("Model not built yet. Call build_*_model() first.")



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
