"""
Tap the Sound Game Service
Manages game sessions, responses, and results
"""
from datetime import datetime
from typing import Dict, List, Optional


class TapGameService:
    """Service for managing Tap the Sound game sessions"""
    
    def __init__(self):
        # In-memory storage (in production, use a database)
        self.sessions: Dict[str, Dict] = {}
        self.responses: Dict[str, List[Dict]] = {}
    
    def start_session(self, child_id: str, child_name: str, child_age: int) -> Dict:
        """
        Start a new game session
        
        Args:
            child_id: Unique identifier for the child
            child_name: Name of the child
            child_age: Age of the child
        
        Returns:
            dict: Session information
        """
        session = {
            'child_id': child_id,
            'child_name': child_name,
            'child_age': child_age,
            'start_time': datetime.now().isoformat(),
            'status': 'active',
            'round_number': 0,
            'total_rounds': 10
        }
        
        self.sessions[child_id] = session
        self.responses[child_id] = []
        
        return {
            'status': 'success',
            'session': session,
            'message': 'Game session started'
        }
    
    def record_response(
        self,
        child_id: str,
        round_number: int,
        sound_id: str,
        selected_image_id: str,
        response_time: Optional[float] = None,
        is_correct: bool = False
    ) -> Dict:
        """
        Record a tap response
        
        Args:
            child_id: Child identifier
            round_number: Current round number
            sound_id: ID of the sound played
            selected_image_id: ID of the image selected
            response_time: Time taken to respond (seconds)
            is_correct: Whether the selection was correct
        
        Returns:
            dict: Response recording result
        """
        if child_id not in self.sessions:
            return {
                'status': 'error',
                'message': 'Session not found. Please start a new session.'
            }
        
        response = {
            'round_number': round_number,
            'sound_id': sound_id,
            'selected_image_id': selected_image_id,
            'response_time': response_time,
            'is_correct': is_correct,
            'timestamp': datetime.now().isoformat()
        }
        
        if child_id not in self.responses:
            self.responses[child_id] = []
        
        self.responses[child_id].append(response)
        
        # Update session
        self.sessions[child_id]['round_number'] = round_number
        
        return {
            'status': 'success',
            'response': response,
            'message': 'Response recorded'
        }
    
    def get_results(self, child_id: str) -> Dict:
        """
        Get game results for a child
        
        Args:
            child_id: Child identifier
        
        Returns:
            dict: Game results and statistics
        """
        if child_id not in self.sessions:
            return {
                'status': 'error',
                'message': 'Session not found'
            }
        
        session = self.sessions[child_id]
        responses = self.responses.get(child_id, [])
        
        # Calculate statistics
        total_responses = len(responses)
        correct_responses = sum(1 for r in responses if r.get('is_correct', False))
        accuracy = (correct_responses / total_responses * 100) if total_responses > 0 else 0
        
        avg_response_time = 0
        if responses:
            response_times = [r.get('response_time', 0) for r in responses if r.get('response_time')]
            if response_times:
                avg_response_time = sum(response_times) / len(response_times)
        
        return {
            'status': 'success',
            'session': session,
            'responses': responses,
            'statistics': {
                'total_rounds': total_responses,
                'correct_answers': correct_responses,
                'incorrect_answers': total_responses - correct_responses,
                'accuracy_percentage': round(accuracy, 2),
                'average_response_time': round(avg_response_time, 2)
            }
        }
    
    def end_session(self, child_id: str) -> Dict:
        """
        End a game session
        
        Args:
            child_id: Child identifier
        
        Returns:
            dict: Session end result
        """
        if child_id not in self.sessions:
            return {
                'status': 'error',
                'message': 'Session not found'
            }
        
        self.sessions[child_id]['status'] = 'completed'
        self.sessions[child_id]['end_time'] = datetime.now().isoformat()
        
        return {
            'status': 'success',
            'message': 'Session ended',
            'results': self.get_results(child_id)
        }
