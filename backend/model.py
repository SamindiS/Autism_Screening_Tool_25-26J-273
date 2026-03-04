"""
Model Wrapper for Gaze Pattern Analysis
=======================================

This module provides the interface between the FastAPI backend and the
gaze pattern analyzer. It analyzes gaze data to produce clinical metrics
for autism screening.
"""

import os
from typing import List, Dict
from gaze_analyzer import analyze_gaze_patterns, GazePatternAnalyzer


class ModelWrapper:
    """
    Wrapper for the gaze pattern analysis model.
    
    Provides inference on gaze events to produce:
    - Clinical metrics (fixations, saccades, attention patterns)
    - Autism screening scores by domain
    - Overall risk assessment
    - Clinical interpretation and recommendations
    """
    
    def __init__(self):
        """Initialize the gaze pattern analyzer"""
        self.analyzer = GazePatternAnalyzer()
        print("Gaze Pattern Analyzer initialized for autism screening")

    def infer(self, events: List[Dict]) -> Dict:
        """
        Analyze gaze events and return comprehensive clinical results.
        
        Args:
            events: List of gaze event dicts with keys:
                - x: normalized x position (0-1)
                - y: normalized y position (0-1)
                - timestamp: time in seconds
                - target_x, target_y: stimulus position (optional)
                - game: which game/task (optional)
        
        Returns:
            Dict containing:
            - score: Overall performance score (0-100)
            - scores: Domain-specific scores and risk category
            - metrics: Detailed gaze metrics
            - interpretation: Clinical findings and recommendations
            - events: Annotated events with on_target flags
        """
        if not events:
            return {
                'score': 0.0,
                'scores': {
                    'attention_score': 0,
                    'fixation_score': 0,
                    'exploration_score': 0,
                    'tracking_score': 0,
                    'flexibility_score': 0,
                    'overall_score': 0,
                    'risk_category': 'Insufficient Data'
                },
                'metrics': {},
                'interpretation': {
                    'summary': 'No gaze data available for analysis.',
                    'findings': [],
                    'recommendations': ['Please ensure the eye tracking session captures sufficient data.']
                },
                'events': []
            }
        
        # Run the clinical gaze pattern analysis
        result = analyze_gaze_patterns(events)
        
        return result
    
    def analyze_by_game(self, events: List[Dict]) -> Dict:
        """
        Analyze gaze events separately for each game/task.
        
        Args:
            events: List of gaze events with 'game' field
            
        Returns:
            Dict with per-game analysis and combined results
        """
        # Separate events by game
        games = {}
        for e in events:
            game = e.get('game', 'unknown')
            if game not in games:
                games[game] = []
            games[game].append(e)
        
        # Analyze each game
        game_results = {}
        for game, game_events in games.items():
            game_results[game] = analyze_gaze_patterns(game_events)
        
        # Combined analysis
        combined = analyze_gaze_patterns(events)
        
        return {
            'combined': combined,
            'by_game': game_results
        }
    
    def get_report_data(self, events: List[Dict], child_info: Dict = None) -> Dict:
        """
        Generate comprehensive report data.
        
        Args:
            events: Gaze events
            child_info: Child's basic info (name, age, etc.)
            
        Returns:
            Complete data for PDF report generation
        """
        analysis = self.analyze_by_game(events)
        
        report = {
            'child_info': child_info or {},
            'analysis': analysis['combined'],
            'game_analysis': analysis['by_game'],
            'summary': {
                'overall_score': analysis['combined']['score'],
                'risk_category': analysis['combined']['scores']['risk_category'],
                'total_duration': analysis['combined']['metrics'].get('total_duration', 0),
                'total_events': analysis['combined']['metrics'].get('total_events', 0),
            }
        }
        
        return report


# Create singleton model instance
model = ModelWrapper()
