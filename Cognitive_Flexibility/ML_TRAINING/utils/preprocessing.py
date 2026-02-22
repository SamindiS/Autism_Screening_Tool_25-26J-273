"""
Data Preprocessing Utilities
Data loading, cleaning, train/test splitting
"""

import pandas as pd
import numpy as np
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler, RobustScaler


class DataPreprocessor:
    """Data preprocessing for ML training"""
    
    def __init__(self, random_state: int = 42):
        """
        Initialize preprocessor
        
        Args:
            random_state: Random seed
        """
        self.random_state = random_state
        self.scaler = None
    
    def load_csv(self, file_path: Path, **kwargs) -> pd.DataFrame:
        """Load CSV file with error handling"""
        try:
            return pd.read_csv(file_path, **kwargs)
        except FileNotFoundError:
            print(f"[WARN] File not found: {file_path}")
            return pd.DataFrame()
        except Exception as e:
            print(f"[ERROR] Error loading {file_path}: {e}")
            return pd.DataFrame()
    
    def clean_data(
        self,
        df: pd.DataFrame,
        drop_na_threshold: float = 0.5
    ) -> pd.DataFrame:
        """
        Clean dataset
        
        Args:
            df: DataFrame to clean
            drop_na_threshold: Drop columns with > threshold missing values
        
        Returns:
            Cleaned DataFrame
        """
        df_clean = df.copy()
        
        # Drop columns with too many missing values
        missing_ratio = df_clean.isnull().sum() / len(df_clean)
        cols_to_drop = missing_ratio[missing_ratio > drop_na_threshold].index
        if len(cols_to_drop) > 0:
            print(f"[INFO] Dropping columns with >{drop_na_threshold*100}% missing: {cols_to_drop.tolist()}")
            df_clean = df_clean.drop(columns=cols_to_drop)
        
        # Fill remaining missing values with median (numerical) or mode (categorical)
        for col in df_clean.columns:
            if df_clean[col].isnull().sum() > 0:
                if df_clean[col].dtype in [np.int64, np.float64]:
                    df_clean[col].fillna(df_clean[col].median(), inplace=True)
                else:
                    df_clean[col].fillna(df_clean[col].mode()[0] if len(df_clean[col].mode()) > 0 else "", inplace=True)
        
        return df_clean
    
    def split_train_test(
        self,
        df: pd.DataFrame,
        target_col: str,
        test_size: float = 0.2,
        stratify: bool = True,
        child_id_col: Optional[str] = None
    ) -> Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
        """
        Split data into train and test sets
        
        Args:
            df: DataFrame with data
            target_col: Target column name
            test_size: Test set size (0.0-1.0)
            stratify: Whether to stratify by target
            child_id_col: Column with child IDs (for child-level splitting)
        
        Returns:
            (X_train, X_test, y_train, y_test)
        """
        if child_id_col and child_id_col in df.columns:
            # Child-level splitting (no data leakage)
            unique_children = df[child_id_col].unique()
            children_train, children_test = train_test_split(
                unique_children,
                test_size=test_size,
                random_state=self.random_state,
                stratify=df.groupby(child_id_col)[target_col].first() if stratify else None
            )
            
            train_df = df[df[child_id_col].isin(children_train)]
            test_df = df[df[child_id_col].isin(children_test)]
        else:
            # Row-level splitting
            train_df, test_df = train_test_split(
                df,
                test_size=test_size,
                random_state=self.random_state,
                stratify=df[target_col] if stratify else None
            )
        
        X_train = train_df.drop(columns=[target_col])
        X_test = test_df.drop(columns=[target_col])
        y_train = train_df[target_col]
        y_test = test_df[target_col]
        
        return X_train, X_test, y_train, y_test
    
    def scale_features(
        self,
        X_train: pd.DataFrame,
        X_test: pd.DataFrame,
        method: str = "standard",
        fit_only_on_train: bool = True
    ) -> Tuple[pd.DataFrame, pd.DataFrame]:
        """
        Scale features
        
        Args:
            X_train: Training features
            X_test: Test features
            method: Scaling method ("standard" or "robust")
            fit_only_on_train: Fit scaler only on training data
        
        Returns:
            (X_train_scaled, X_test_scaled)
        """
        if method == "standard":
            self.scaler = StandardScaler()
        elif method == "robust":
            self.scaler = RobustScaler()
        else:
            raise ValueError(f"Unknown scaling method: {method}")
        
        if fit_only_on_train:
            X_train_scaled = pd.DataFrame(
                self.scaler.fit_transform(X_train),
                columns=X_train.columns,
                index=X_train.index
            )
            X_test_scaled = pd.DataFrame(
                self.scaler.transform(X_test),
                columns=X_test.columns,
                index=X_test.index
            )
        else:
            # Fit on combined data (not recommended for real-world)
            X_combined = pd.concat([X_train, X_test])
            self.scaler.fit(X_combined)
            X_train_scaled = pd.DataFrame(
                self.scaler.transform(X_train),
                columns=X_train.columns,
                index=X_train.index
            )
            X_test_scaled = pd.DataFrame(
                self.scaler.transform(X_test),
                columns=X_test.columns,
                index=X_test.index
            )
        
        return X_train_scaled, X_test_scaled
    
    def get_scaler(self):
        """Get fitted scaler"""
        return self.scaler
