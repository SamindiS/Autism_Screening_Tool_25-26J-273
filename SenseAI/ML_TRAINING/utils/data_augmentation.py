"""
Data Augmentation Utilities
Bootstrap resampling, SMOTE, Safe noise injection
"""

import pandas as pd
import numpy as np
from typing import List, Optional, Tuple
from sklearn.utils import resample


class DataAugmenter:
    """Data augmentation for small clinical datasets"""
    
    def __init__(self, random_state: int = 42):
        """
        Initialize data augmenter
        
        Args:
            random_state: Random seed
        """
        self.random_state = random_state
        np.random.seed(random_state)
    
    def bootstrap_resample(
        self,
        df: pd.DataFrame,
        n_samples: int,
        stratify_col: Optional[str] = None
    ) -> pd.DataFrame:
        """
        Bootstrap resampling (with replacement)
        
        Args:
            df: DataFrame to resample
            n_samples: Number of samples to generate
            stratify_col: Column to stratify by (for balanced resampling)
        
        Returns:
            Resampled DataFrame
        """
        if stratify_col and stratify_col in df.columns:
            # Stratified bootstrap
            augmented_samples = []
            
            for class_value in df[stratify_col].unique():
                class_df = df[df[stratify_col] == class_value]
                n_class_samples = int(n_samples * len(class_df) / len(df))
                
                if n_class_samples > 0:
                    resampled = resample(
                        class_df,
                        n_samples=n_class_samples,
                        replace=True,
                        random_state=self.random_state
                    )
                    augmented_samples.append(resampled)
            
            return pd.concat(augmented_samples, ignore_index=True)
        else:
            # Simple bootstrap
            return resample(
                df,
                n_samples=n_samples,
                replace=True,
                random_state=self.random_state
            )
    
    def add_noise(
        self,
        df: pd.DataFrame,
        columns: List[str],
        noise_level: float = 0.01
    ) -> pd.DataFrame:
        """
        Add small random noise to numerical columns
        
        Args:
            df: DataFrame to augment
            columns: List of numerical columns to add noise to
            noise_level: Noise level (percentage of std)
        
        Returns:
            DataFrame with noise added
        """
        df_noisy = df.copy()
        
        for col in columns:
            if col not in df.columns:
                continue
            
            if df[col].dtype in [np.int64, np.float64]:
                std = df[col].std()
                if std > 0:
                    noise = np.random.normal(0, std * noise_level, size=len(df))
                    df_noisy[col] = df[col] + noise
        
        return df_noisy
    
    def augment_with_smote(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        target_samples: Optional[int] = None
    ) -> Tuple[pd.DataFrame, pd.Series]:
        """
        Augment using SMOTE (Synthetic Minority Oversampling Technique)
        
        Args:
            X: Feature DataFrame
            y: Target Series
            target_samples: Target number of samples per class
        
        Returns:
            Augmented (X, y)
        """
        try:
            from imblearn.over_sampling import SMOTE
            
            smote = SMOTE(random_state=self.random_state)
            
            if target_samples:
                # Calculate samples needed per class
                class_counts = y.value_counts()
                sampling_strategy = {
                    cls: target_samples for cls in class_counts.index
                }
                smote = SMOTE(
                    random_state=self.random_state,
                    sampling_strategy=sampling_strategy
                )
            
            X_resampled, y_resampled = smote.fit_resample(X, y)
            
            return pd.DataFrame(X_resampled, columns=X.columns), pd.Series(y_resampled)
        
        except ImportError:
            print("[WARN] imbalanced-learn not installed. Using bootstrap instead.")
            return self.augment_with_bootstrap(X, y, target_samples)
    
    def augment_with_bootstrap(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        target_samples: Optional[int] = None
    ) -> Tuple[pd.DataFrame, pd.Series]:
        """
        Augment using bootstrap resampling
        
        Args:
            X: Feature DataFrame
            y: Target Series
            target_samples: Target number of samples per class
        
        Returns:
            Augmented (X, y)
        """
        df = X.copy()
        df['target'] = y
        
        if target_samples:
            # Balance classes to target_samples
            augmented_samples = []
            
            for class_value in y.unique():
                class_df = df[df['target'] == class_value]
                n_needed = target_samples - len(class_df)
                
                if n_needed > 0:
                    resampled = self.bootstrap_resample(
                        class_df.drop(columns=['target']),
                        n_samples=n_needed,
                        stratify_col=None
                    )
                    resampled['target'] = class_value
                    augmented_samples.append(resampled)
            
            if augmented_samples:
                augmented_df = pd.concat([df, pd.concat(augmented_samples, ignore_index=True)], ignore_index=True)
            else:
                augmented_df = df
        else:
            # Simple bootstrap (double the dataset)
            resampled = self.bootstrap_resample(df, n_samples=len(df), stratify_col='target')
            augmented_df = pd.concat([df, resampled], ignore_index=True)
        
        X_augmented = augmented_df.drop(columns=['target'])
        y_augmented = augmented_df['target']
        
        return X_augmented, y_augmented
    
    def augment(
        self,
        X: pd.DataFrame,
        y: pd.Series,
        method: str = "bootstrap",
        target_samples: Optional[int] = None,
        noise_level: float = 0.01
    ) -> Tuple[pd.DataFrame, pd.Series]:
        """
        Augment dataset using specified method
        
        Args:
            X: Feature DataFrame
            y: Target Series
            method: Augmentation method ("bootstrap", "smote", "noise")
            target_samples: Target number of samples per class
            noise_level: Noise level for noise augmentation
        
        Returns:
            Augmented (X, y)
        """
        if method == "bootstrap":
            return self.augment_with_bootstrap(X, y, target_samples)
        elif method == "smote":
            return self.augment_with_smote(X, y, target_samples)
        elif method == "noise":
            X_noisy = self.add_noise(X, X.columns.tolist(), noise_level)
            return X_noisy, y
        else:
            raise ValueError(f"Unknown method: {method}")
