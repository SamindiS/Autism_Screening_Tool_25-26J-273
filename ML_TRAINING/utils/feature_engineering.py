"""
Feature Engineering Utilities
Age normalization, composite indices, binary flags
"""

import pandas as pd
import numpy as np
from scipy import stats
from typing import List, Dict, Tuple


class FeatureEngineer:
    """Feature engineering for autism screening models"""
    
    def __init__(self, age_bins: List[int], random_state: int = 42):
        """
        Initialize feature engineer
        
        Args:
            age_bins: List of age bin boundaries (e.g., [24, 30, 36, 42])
            random_state: Random seed
        """
        self.age_bins = age_bins
        self.random_state = random_state
        self.age_norms = {}  # Store age-specific norms
        
    def create_age_bins(self, age_months: pd.Series) -> pd.Series:
        """Create age bins from age in months"""
        return pd.cut(
            age_months,
            bins=self.age_bins,
            labels=[f"{self.age_bins[i]}-{self.age_bins[i+1]}" 
                   for i in range(len(self.age_bins)-1)],
            include_lowest=True
        )
    
    def calculate_zscore_by_age(
        self, 
        df: pd.DataFrame, 
        value_col: str, 
        age_bin_col: str = "age_bin"
    ) -> pd.Series:
        """
        Calculate age-normalized z-scores
        
        Args:
            df: DataFrame with data
            value_col: Column to normalize
            age_bin_col: Column with age bins
            
        Returns:
            Series with z-scores
        """
        zscores = df.groupby(age_bin_col)[value_col].transform(
            lambda x: stats.zscore(x.fillna(x.mean())) if len(x) > 1 and x.std() > 0 else 0
        )
        return zscores.fillna(0)
    
    def create_composite_index(
        self,
        df: pd.DataFrame,
        components: Dict[str, float],
        index_name: str
    ) -> pd.Series:
        """
        Create composite index from weighted components
        
        Args:
            df: DataFrame with component columns
            components: Dict of {column_name: weight}
            index_name: Name for the new index column
            
        Returns:
            Series with composite index
        """
        index = pd.Series(0.0, index=df.index)
        total_weight = sum(components.values())
        
        for col, weight in components.items():
            if col in df.columns:
                # Normalize to 0-1 scale if needed
                col_data = df[col]
                if col_data.max() > 1:
                    col_data = (col_data - col_data.min()) / (col_data.max() - col_data.min() + 1e-10)
                index += col_data * (weight / total_weight)
        
        return index
    
    def create_binary_flags(
        self,
        df: pd.DataFrame,
        flag_definitions: Dict[str, Dict]
    ) -> pd.DataFrame:
        """
        Create binary risk flags
        
        Args:
            df: DataFrame with data
            flag_definitions: Dict of {flag_name: {condition, threshold}}
                Example: {
                    "high_risk_flag": {
                        "column": "risk_score",
                        "operator": ">=",
                        "threshold": 0.7
                    }
                }
        
        Returns:
            DataFrame with binary flag columns added
        """
        flags_df = df.copy()
        
        for flag_name, definition in flag_definitions.items():
            col = definition["column"]
            operator = definition["operator"]
            threshold = definition["threshold"]
            
            if col in df.columns:
                if operator == ">=":
                    flags_df[flag_name] = (df[col] >= threshold).astype(int)
                elif operator == "<=":
                    flags_df[flag_name] = (df[col] <= threshold).astype(int)
                elif operator == ">":
                    flags_df[flag_name] = (df[col] > threshold).astype(int)
                elif operator == "<":
                    flags_df[flag_name] = (df[col] < threshold).astype(int)
                elif operator == "==":
                    flags_df[flag_name] = (df[col] == threshold).astype(int)
            else:
                flags_df[flag_name] = 0
        
        return flags_df
    
    def engineer_questionnaire_features(
        self,
        df: pd.DataFrame,
        a_cols: List[str] = None
    ) -> pd.DataFrame:
        """
        Engineer features for questionnaire model (Age 2-3.5)
        
        Args:
            df: DataFrame with A1-A10 columns
            a_cols: List of A column names (default: A1-A10)
        
        Returns:
            DataFrame with engineered features
        """
        if a_cols is None:
            a_cols = [f"A{i}" for i in range(1, 11)]
        
        features_df = df.copy()
        
        # Critical items failed
        if all(col in df.columns for col in a_cols):
            features_df["critical_items_failed"] = df[a_cols].sum(axis=1).astype(int)
        else:
            features_df["critical_items_failed"] = 0
        
        # Domain scores
        # Social Responsiveness: A1, A4, A5
        social_items = [col for col in ["A1", "A4", "A5"] if col in df.columns]
        if social_items:
            features_df["social_responsiveness_raw"] = (
                df[social_items].sum(axis=1) / len(social_items) * 100
            )
        else:
            features_df["social_responsiveness_raw"] = 0
        
        # Joint Attention: A5, A9
        joint_items = [col for col in ["A5", "A9"] if col in df.columns]
        if joint_items:
            features_df["joint_attention_raw"] = (
                df[joint_items].sum(axis=1) / len(joint_items) * 100
            )
        else:
            features_df["joint_attention_raw"] = 0
        
        # Total score
        if all(col in df.columns for col in a_cols):
            features_df["total_score_raw"] = df[a_cols].sum(axis=1) * 10
        else:
            features_df["total_score_raw"] = 0
        
        # Age-normalize if age_months exists
        if "age_months" in df.columns:
            features_df["age_bin"] = self.create_age_bins(df["age_months"])
            
            for col in ["social_responsiveness_raw", "joint_attention_raw", "total_score_raw"]:
                zscore_col = col.replace("_raw", "_zscore")
                features_df[zscore_col] = self.calculate_zscore_by_age(
                    features_df, col, "age_bin"
                )
        else:
            for col in ["social_responsiveness_raw", "joint_attention_raw", "total_score_raw"]:
                zscore_col = col.replace("_raw", "_zscore")
                features_df[zscore_col] = 0
        
        return features_df
    
    def engineer_frog_jump_features(
        self,
        df: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Engineer features for Frog Jump model (Age 3.5-5.5)
        
        Args:
            df: DataFrame with game metrics
        
        Returns:
            DataFrame with engineered features
        """
        features_df = df.copy()
        
        # Inhibition Control Index
        if all(col in df.columns for col in ["go_accuracy", "nogo_accuracy", "commission_error_rate"]):
            features_df["inhibition_control_index"] = self.create_composite_index(
                features_df,
                {
                    "go_accuracy": 0.3,
                    "nogo_accuracy": 0.4,
                    "commission_error_rate": 0.3
                },
                "inhibition_control_index"
            )
        else:
            features_df["inhibition_control_index"] = 0
        
        # Response Control Index
        if all(col in df.columns for col in ["avg_rt_go_ms", "rt_variability"]):
            # Normalize RT (lower is better, so invert)
            rt_normalized = 1 - (df["avg_rt_go_ms"] / (df["avg_rt_go_ms"].max() + 1e-10))
            rt_var_normalized = 1 - (df["rt_variability"] / (df["rt_variability"].max() + 1e-10))
            
            features_df["response_control_index"] = (
                rt_normalized * 0.6 + rt_var_normalized * 0.4
            )
        else:
            features_df["response_control_index"] = 0
        
        # Age-normalize if age_months exists
        if "age_months" in df.columns:
            features_df["age_bin"] = self.create_age_bins(df["age_months"])
            
            for col in ["inhibition_control_index", "response_control_index"]:
                if col in features_df.columns:
                    zscore_col = col.replace("_index", "_zscore")
                    features_df[zscore_col] = self.calculate_zscore_by_age(
                        features_df, col, "age_bin"
                    )
        
        return features_df
    
    def engineer_color_shape_features(
        self,
        df: pd.DataFrame
    ) -> pd.DataFrame:
        """
        Engineer features for Color-Shape model (Age 5.5-6.9)
        
        Args:
            df: DataFrame with DCCS game metrics
        
        Returns:
            DataFrame with engineered features
        """
        features_df = df.copy()
        
        # Cognitive Flexibility Index
        if all(col in df.columns for col in ["accuracy_drop_percent", "switch_cost_ms", "perseverative_error_rate_post_switch"]):
            # Normalize components
            accuracy_drop_norm = df["accuracy_drop_percent"] / 100
            switch_cost_norm = df["switch_cost_ms"] / (df["switch_cost_ms"].max() + 1e-10)
            perseveration_norm = df["perseverative_error_rate_post_switch"]
            
            features_df["cognitive_flexibility_index"] = (
                accuracy_drop_norm * 0.4 +
                switch_cost_norm * 0.3 +
                perseveration_norm * 0.3
            )
        else:
            features_df["cognitive_flexibility_index"] = 0
        
        # Perseveration Index
        if all(col in df.columns for col in ["total_perseverative_errors", "number_of_consecutive_perseverations"]):
            features_df["perseveration_index"] = self.create_composite_index(
                features_df,
                {
                    "total_perseverative_errors": 0.6,
                    "number_of_consecutive_perseverations": 0.4
                },
                "perseveration_index"
            )
        else:
            features_df["perseveration_index"] = 0
        
        # Age-normalize if age_months exists
        if "age_months" in df.columns:
            features_df["age_bin"] = self.create_age_bins(df["age_months"])
            
            for col in ["cognitive_flexibility_index", "perseveration_index"]:
                if col in features_df.columns:
                    zscore_col = col.replace("_index", "_zscore")
                    features_df[zscore_col] = self.calculate_zscore_by_age(
                        features_df, col, "age_bin"
                    )
        
        return features_df
