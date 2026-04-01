"""
Outlier Detection and Handling Utilities
IQR-based detection, Winsorization, Statistical validation
"""

import pandas as pd
import numpy as np
from typing import List, Dict, Tuple, Optional


class OutlierDetector:
    """Outlier detection and handling for clinical data"""
    
    def __init__(self, method: str = "iqr", iqr_factor: float = 1.5):
        """
        Initialize outlier detector
        
        Args:
            method: Detection method ("iqr" or "zscore")
            iqr_factor: IQR multiplier for outlier detection
        """
        self.method = method
        self.iqr_factor = iqr_factor
        self.outlier_info = {}
    
    def detect_outliers_iqr(
        self,
        df: pd.DataFrame,
        columns: List[str]
    ) -> Dict[str, Tuple[np.ndarray, Dict]]:
        """
        Detect outliers using IQR method
        
        Args:
            df: DataFrame with data
            columns: List of columns to check
        
        Returns:
            Dict of {column: (outlier_indices, stats)}
        """
        outliers = {}
        
        for col in columns:
            if col not in df.columns:
                continue
            
            data = df[col].dropna()
            if len(data) == 0:
                continue
            
            Q1 = data.quantile(0.25)
            Q3 = data.quantile(0.75)
            IQR = Q3 - Q1
            
            lower_bound = Q1 - self.iqr_factor * IQR
            upper_bound = Q3 + self.iqr_factor * IQR
            
            outlier_mask = (df[col] < lower_bound) | (df[col] > upper_bound)
            outlier_indices = df.index[outlier_mask].tolist()
            
            outliers[col] = (
                outlier_indices,
                {
                    "Q1": Q1,
                    "Q3": Q3,
                    "IQR": IQR,
                    "lower_bound": lower_bound,
                    "upper_bound": upper_bound,
                    "count": len(outlier_indices),
                    "percentage": len(outlier_indices) / len(df) * 100
                }
            )
        
        return outliers
    
    def detect_outliers_zscore(
        self,
        df: pd.DataFrame,
        columns: List[str],
        threshold: float = 3.0
    ) -> Dict[str, Tuple[np.ndarray, Dict]]:
        """
        Detect outliers using Z-score method
        
        Args:
            df: DataFrame with data
            columns: List of columns to check
            threshold: Z-score threshold (default: 3.0)
        
        Returns:
            Dict of {column: (outlier_indices, stats)}
        """
        outliers = {}
        
        for col in columns:
            if col not in df.columns:
                continue
            
            data = df[col].dropna()
            if len(data) == 0 or data.std() == 0:
                continue
            
            z_scores = np.abs((data - data.mean()) / data.std())
            outlier_mask = z_scores > threshold
            
            outlier_indices = data.index[outlier_mask].tolist()
            
            outliers[col] = (
                outlier_indices,
                {
                    "mean": data.mean(),
                    "std": data.std(),
                    "threshold": threshold,
                    "count": len(outlier_indices),
                    "percentage": len(outlier_indices) / len(data) * 100
                }
            )
        
        return outliers
    
    def detect_outliers(
        self,
        df: pd.DataFrame,
        columns: List[str],
        method: Optional[str] = None
    ) -> Dict[str, Tuple[np.ndarray, Dict]]:
        """
        Detect outliers using specified method
        
        Args:
            df: DataFrame with data
            columns: List of columns to check
            method: Override default method
        
        Returns:
            Dict of {column: (outlier_indices, stats)}
        """
        method = method or self.method
        
        if method == "iqr":
            return self.detect_outliers_iqr(df, columns)
        elif method == "zscore":
            return self.detect_outliers_zscore(df, columns)
        else:
            raise ValueError(f"Unknown method: {method}")
    
    def winsorize(
        self,
        df: pd.DataFrame,
        columns: List[str],
        limits: Tuple[float, float] = (0.01, 0.99)
    ) -> pd.DataFrame:
        """
        Winsorize (cap) outliers instead of removing them
        
        Args:
            df: DataFrame with data
            columns: List of columns to winsorize
            limits: Tuple of (lower_percentile, upper_percentile)
        
        Returns:
            DataFrame with winsorized values
        """
        df_winsorized = df.copy()
        
        for col in columns:
            if col not in df.columns:
                continue
            
            data = df[col].dropna()
            if len(data) == 0:
                continue
            
            lower_limit = data.quantile(limits[0])
            upper_limit = data.quantile(limits[1])
            
            df_winsorized[col] = df[col].clip(lower=lower_limit, upper=upper_limit)
        
        return df_winsorized
    
    def remove_outliers(
        self,
        df: pd.DataFrame,
        columns: List[str],
        method: Optional[str] = None
    ) -> pd.DataFrame:
        """
        Remove rows with outliers
        
        Args:
            df: DataFrame with data
            columns: List of columns to check
            method: Detection method
        
        Returns:
            DataFrame with outliers removed
        """
        outliers = self.detect_outliers(df, columns, method)
        
        # Get all outlier indices
        all_outlier_indices = set()
        for col, (indices, stats) in outliers.items():
            all_outlier_indices.update(indices)
        
        # Remove rows with outliers
        df_cleaned = df.drop(index=list(all_outlier_indices))
        
        self.outlier_info = {
            "removed_count": len(all_outlier_indices),
            "remaining_count": len(df_cleaned),
            "removed_percentage": len(all_outlier_indices) / len(df) * 100,
            "outliers_by_column": outliers
        }
        
        return df_cleaned
    
    def get_outlier_summary(self) -> Dict:
        """Get summary of detected outliers"""
        return self.outlier_info
