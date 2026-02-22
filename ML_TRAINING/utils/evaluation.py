"""
Model Evaluation Utilities
Metrics, plots, feature importance
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from typing import Dict, List, Optional
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, roc_curve, confusion_matrix, classification_report,
    precision_recall_curve, average_precision_score
)


class ModelEvaluator:
    """Model evaluation and reporting"""
    
    def __init__(self):
        """Initialize evaluator"""
        self.metrics = {}
        self.plots = {}
    
    def calculate_metrics(
        self,
        y_true: np.ndarray,
        y_pred: np.ndarray,
        y_proba: Optional[np.ndarray] = None
    ) -> Dict[str, float]:
        """
        Calculate evaluation metrics
        
        Args:
            y_true: True labels
            y_pred: Predicted labels
            y_proba: Predicted probabilities (optional)
        
        Returns:
            Dict of metrics
        """
        metrics = {
            "accuracy": accuracy_score(y_true, y_pred),
            "precision": precision_score(y_true, y_pred, average="weighted", zero_division=0),
            "recall": recall_score(y_true, y_pred, average="weighted", zero_division=0),
            "f1_score": f1_score(y_true, y_pred, average="weighted", zero_division=0)
        }
        
        if y_proba is not None:
            try:
                metrics["roc_auc"] = roc_auc_score(y_true, y_proba[:, 1] if y_proba.ndim > 1 else y_proba)
                metrics["pr_auc"] = average_precision_score(y_true, y_proba[:, 1] if y_proba.ndim > 1 else y_proba)
            except:
                metrics["roc_auc"] = 0.0
                metrics["pr_auc"] = 0.0
        
        self.metrics = metrics
        return metrics
    
    def plot_confusion_matrix(
        self,
        y_true: np.ndarray,
        y_pred: np.ndarray,
        title: str = "Confusion Matrix"
    ) -> plt.Figure:
        """Plot confusion matrix"""
        cm = confusion_matrix(y_true, y_pred)
        
        fig, ax = plt.subplots(figsize=(8, 6))
        sns.heatmap(
            cm,
            annot=True,
            fmt="d",
            cmap="Blues",
            ax=ax,
            xticklabels=["Control", "ASD"],
            yticklabels=["Control", "ASD"]
        )
        ax.set_xlabel("Predicted")
        ax.set_ylabel("Actual")
        ax.set_title(title)
        plt.tight_layout()
        
        return fig
    
    def plot_roc_curve(
        self,
        y_true: np.ndarray,
        y_proba: np.ndarray,
        title: str = "ROC Curve"
    ) -> plt.Figure:
        """Plot ROC curve"""
        if y_proba.ndim > 1:
            y_proba = y_proba[:, 1]
        
        fpr, tpr, thresholds = roc_curve(y_true, y_proba)
        roc_auc = roc_auc_score(y_true, y_proba)
        
        fig, ax = plt.subplots(figsize=(8, 6))
        ax.plot(fpr, tpr, label=f"ROC (AUC = {roc_auc:.3f})")
        ax.plot([0, 1], [0, 1], "k--", label="Random")
        ax.set_xlabel("False Positive Rate")
        ax.set_ylabel("True Positive Rate")
        ax.set_title(title)
        ax.legend()
        ax.grid(True)
        plt.tight_layout()
        
        return fig
    
    def plot_feature_importance(
        self,
        feature_names: List[str],
        importances: np.ndarray,
        title: str = "Feature Importance"
    ) -> plt.Figure:
        """Plot feature importance"""
        indices = np.argsort(importances)[::-1]
        
        fig, ax = plt.subplots(figsize=(10, 6))
        ax.barh(range(len(feature_names)), importances[indices])
        ax.set_yticks(range(len(feature_names)))
        ax.set_yticklabels([feature_names[i] for i in indices])
        ax.set_xlabel("Importance")
        ax.set_title(title)
        plt.tight_layout()
        
        return fig
    
    def generate_report(
        self,
        y_true: np.ndarray,
        y_pred: np.ndarray,
        y_proba: Optional[np.ndarray] = None,
        feature_names: Optional[List[str]] = None,
        feature_importances: Optional[np.ndarray] = None
    ) -> Dict:
        """
        Generate comprehensive evaluation report
        
        Args:
            y_true: True labels
            y_pred: Predicted labels
            y_proba: Predicted probabilities
            feature_names: Feature names
            feature_importances: Feature importances
        
        Returns:
            Dict with metrics and plots
        """
        # Calculate metrics
        metrics = self.calculate_metrics(y_true, y_pred, y_proba)
        
        # Classification report
        report = classification_report(y_true, y_pred, output_dict=True)
        
        # Generate plots
        plots = {
            "confusion_matrix": self.plot_confusion_matrix(y_true, y_pred)
        }
        
        if y_proba is not None:
            plots["roc_curve"] = self.plot_roc_curve(y_true, y_proba)
        
        if feature_names and feature_importances is not None:
            plots["feature_importance"] = self.plot_feature_importance(
                feature_names, feature_importances
            )
        
        return {
            "metrics": metrics,
            "classification_report": report,
            "plots": plots
        }
