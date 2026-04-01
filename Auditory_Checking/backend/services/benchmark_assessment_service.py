"""
Benchmark Assessment Service
- M-CHAT-R/F: 20 yes/no questions, auto-scoring, store/retrieve
- Compare M-CHAT with ML predictions (correlation)
- Developmental Milestone Tracker: CDC age bands, expected vs actual
- Parent Report Questionnaire (PRQ): social communication, repetitive behaviors, sensory, RTN history
"""
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Any

try:
    from data.mchat_questions import MCHAT_ITEMS
    from data.cdc_milestones import CDC_MILESTONES, get_milestones_for_age
except ImportError:
    # When running from backend/ as cwd (e.g. Flask app)
    import sys
    _backend = Path(__file__).resolve().parent.parent
    if str(_backend) not in sys.path:
        sys.path.insert(0, str(_backend))
    from data.mchat_questions import MCHAT_ITEMS
    from data.cdc_milestones import CDC_MILESTONES, get_milestones_for_age


class BenchmarkAssessmentService:
    """M-CHAT, milestones, PRQ storage and scoring; comparison with ML."""
    
    def __init__(self, data_dir: str = 'data/assessments'):
        self.data_dir = Path(data_dir)
        self.data_dir.mkdir(parents=True, exist_ok=True)
        self._mchat_path = self.data_dir / 'mchat_results.json'
        self._prq_path = self.data_dir / 'prq_results.json'
        self._milestones_path = self.data_dir / 'milestone_progress.json'
        self._ml_predictions_path = self.data_dir / 'ml_predictions.json'
    
    # ---------- M-CHAT-R/F ----------
    
    def get_mchat_questions(self) -> List[Dict]:
        """Return 20 M-CHAT-R/F questions (id, text, yes_means_risk)."""
        return [{"id": q["id"], "text": q["text"], "yes_means_risk": q["yes_means_risk"]} for q in MCHAT_ITEMS]
    
    def score_mchat(self, answers: List[Dict]) -> Dict[str, Any]:
        """
        answers: [{"item_id": 1, "answer": "yes"|"no"}, ...]
        Returns: total_score, risk_level (low/medium/high), follow_up_needed, item_scores.
        """
        by_id = {int(a["item_id"]): str(a.get("answer", "")).strip().lower() for a in answers}
        item_scores = []
        total = 0
        for q in MCHAT_ITEMS:
            iid = q["id"]
            ans = by_id.get(iid, "")
            yes = ans in ("yes", "y", "1", "true")
            risk = (yes and q["yes_means_risk"]) or (not yes and not q["yes_means_risk"])
            point = 1 if risk else 0
            total += point
            item_scores.append({"item_id": iid, "answer": ans, "risk_point": point})
        
        if total <= 2:
            risk_level = "low"
            follow_up_needed = False
        elif total <= 7:
            risk_level = "medium"
            follow_up_needed = True
        else:
            risk_level = "high"
            follow_up_needed = True
        
        return {
            "total_score": total,
            "risk_level": risk_level,
            "follow_up_needed": follow_up_needed,
            "item_scores": item_scores,
            "max_score": 20,
        }
    
    def save_mchat(self, child_id: str, child_name: str, child_age_months: Optional[int],
                   answers: List[Dict], score_result: Dict) -> Dict:
        """Persist M-CHAT result and return record with timestamp."""
        record = {
            "child_id": child_id,
            "child_name": child_name,
            "child_age_months": child_age_months,
            "answers": answers,
            "score": score_result,
            "timestamp": datetime.now().isoformat(),
        }
        data = self._load_json(self._mchat_path, [])
        data.append(record)
        self._save_json(self._mchat_path, data)
        return record
    
    def get_mchat_history(self, child_id: Optional[str] = None) -> List[Dict]:
        """Get M-CHAT results, optionally filtered by child_id."""
        data = self._load_json(self._mchat_path, [])
        if child_id:
            data = [r for r in data if r.get("child_id") == child_id]
        return data
    
    # ---------- Comparison with ML ----------
    
    def save_ml_prediction(self, child_id: str, video_analysis_result: Dict) -> None:
        """Store latest ML prediction for a child (for correlation with M-CHAT)."""
        pred = video_analysis_result.get("ML_Prediction") or {}
        record = {
            "child_id": child_id,
            "prediction": pred.get("prediction"),
            "autism_probability": pred.get("autism_probability"),
            "typical_probability": pred.get("typical_probability"),
            "confidence": pred.get("confidence"),
            "RTN_Status": video_analysis_result.get("RTN_Status"),
            "Reaction_Time": video_analysis_result.get("Reaction_Time"),
            "timestamp": datetime.now().isoformat(),
        }
        data = self._load_json(self._ml_predictions_path, [])
        data.append(record)
        self._save_json(self._ml_predictions_path, data)
    
    def get_comparison(self, child_id: str) -> Dict[str, Any]:
        """Compare M-CHAT results with ML predictions for a child (correlation)."""
        mchat_list = [r for r in self.get_mchat_history(child_id) if r.get("child_id") == child_id]
        preds = self._load_json(self._ml_predictions_path, [])
        preds = [p for p in preds if p.get("child_id") == child_id]
        
        latest_mchat = mchat_list[-1] if mchat_list else None
        latest_ml = preds[-1] if preds else None
        
        agreement = None
        if latest_mchat and latest_ml:
            mchat_risk = latest_mchat.get("score", {}).get("risk_level", "")
            ml_pred = latest_ml.get("prediction", "")
            # Agreement: both suggest concern or both suggest low concern
            mchat_concern = mchat_risk in ("medium", "high")
            ml_concern = ml_pred == "autism"
            agreement = mchat_concern == ml_concern
        
        return {
            "child_id": child_id,
            "latest_mchat": latest_mchat,
            "latest_ml_prediction": latest_ml,
            "agreement": agreement,
            "mchat_count": len(mchat_list),
            "ml_prediction_count": len(preds),
        }
    
    # ---------- Developmental Milestones ----------
    
    def get_milestones(self, age_months: int) -> Dict:
        """Return CDC milestones for age band and band used."""
        milestones, band = get_milestones_for_age(age_months)
        return {"age_band_months": band, "milestones": milestones}
    
    def save_milestone_progress(self, child_id: str, child_name: str, age_months: int,
                                achieved: List[str]) -> Dict:
        """achieved = list of milestone ids the child has met."""
        record = {
            "child_id": child_id,
            "child_name": child_name,
            "age_months": age_months,
            "achieved_ids": achieved,
            "timestamp": datetime.now().isoformat(),
        }
        data = self._load_json(self._milestones_path, [])
        data.append(record)
        self._save_json(self._milestones_path, data)
        milestones, band = get_milestones_for_age(age_months)
        total = len(milestones)
        met = sum(1 for m in milestones if m["id"] in achieved)
        delays = [m for m in milestones if m["id"] not in achieved]
        return {
            **record,
            "expected_count": total,
            "achieved_count": met,
            "delays_flagged": delays,
        }
    
    def get_milestone_history(self, child_id: Optional[str] = None) -> List[Dict]:
        data = self._load_json(self._milestones_path, [])
        if child_id:
            data = [r for r in data if r.get("child_id") == child_id]
        return data
    
    # ---------- PRQ (Parent Report Questionnaire) ----------
    
    def get_prq_schema(self) -> Dict:
        """Return PRQ sections: social communication, repetitive behaviors, sensory, RTN history."""
        return {
            "sections": [
                {
                    "id": "social_communication",
                    "title": "Social communication skills",
                    "questions": [
                        {"id": "sc1", "text": "Does your child make eye contact when interacting?", "type": "yes_no"},
                        {"id": "sc2", "text": "Does your child point to share interest with you?", "type": "yes_no"},
                        {"id": "sc3", "text": "Does your child show things to you by bringing or holding them up?", "type": "yes_no"},
                        {"id": "sc4", "text": "Does your child respond to other people's emotions?", "type": "yes_no"},
                        {"id": "sc5", "text": "Does your child play pretend or imitate you?", "type": "yes_no"},
                    ],
                },
                {
                    "id": "repetitive_behaviors",
                    "title": "Repetitive behaviors",
                    "questions": [
                        {"id": "rb1", "text": "Does your child repeat the same actions over and over (e.g., lining up toys)?", "type": "yes_no"},
                        {"id": "rb2", "text": "Does your child have strong, narrow interests?", "type": "yes_no"},
                        {"id": "rb3", "text": "Does your child get upset by small changes in routine?", "type": "yes_no"},
                        {"id": "rb4", "text": "Does your child use repeated hand or finger movements?", "type": "yes_no"},
                    ],
                },
                {
                    "id": "sensory_sensitivities",
                    "title": "Sensory sensitivities",
                    "questions": [
                        {"id": "ss1", "text": "Is your child sensitive to sounds (e.g., covers ears, upset by noise)?", "type": "yes_no"},
                        {"id": "ss2", "text": "Is your child sensitive to textures or clothing?", "type": "yes_no"},
                        {"id": "ss3", "text": "Does your child seek or avoid certain movements (spinning, swinging)?", "type": "yes_no"},
                        {"id": "ss4", "text": "Does your child have strong reactions to smells or tastes?", "type": "yes_no"},
                    ],
                },
                {
                    "id": "rtn_history",
                    "title": "Response to name (RTN) history",
                    "questions": [
                        {"id": "rtn1", "text": "Does your child usually respond when you call his or her name?", "type": "yes_no"},
                        {"id": "rtn2", "text": "If not always, how often does your child respond? (Rarely / Sometimes / Often / Almost always)", "type": "scale"},
                        {"id": "rtn3", "text": "Do you need to call their name more than once for them to respond?", "type": "yes_no"},
                        {"id": "rtn4", "text": "Does your child respond better in quiet vs busy settings?", "type": "yes_no"},
                    ],
                },
            ],
        }
    
    def save_prq(self, child_id: str, child_name: str, answers: Dict[str, Any]) -> Dict:
        """Save PRQ answers (section_id -> list of {question_id, answer})."""
        record = {
            "child_id": child_id,
            "child_name": child_name,
            "answers": answers,
            "timestamp": datetime.now().isoformat(),
        }
        data = self._load_json(self._prq_path, [])
        data.append(record)
        self._save_json(self._prq_path, data)
        return record
    
    def get_prq_history(self, child_id: Optional[str] = None) -> List[Dict]:
        data = self._load_json(self._prq_path, [])
        if child_id:
            data = [r for r in data if r.get("child_id") == child_id]
        return data
    
    # ---------- Helpers ----------
    
    def _load_json(self, path: Path, default):
        if not path.exists():
            return default
        try:
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return default
    
    def _save_json(self, path: Path, data) -> None:
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
