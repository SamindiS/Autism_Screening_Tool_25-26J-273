"""
M-CHAT-R/F (Modified Checklist for Autism in Toddlers, Revised with Follow-Up)
20 yes/no questions for parents. Standard scoring:
- Items 2, 5, 12: YES = 1 point (risk)
- All other items: NO = 1 point (risk)
Risk: 0-2 Low, 3-7 Medium (follow-up), 8-20 High
Reference: Robins et al.; validation Chlebowski et al. (2013).
"""

MCHAT_ITEMS = [
    {"id": 1, "text": "If you point at something across the room, does your child look at it?", "yes_means_risk": False},
    {"id": 2, "text": "Have you ever wondered if your child might be deaf?", "yes_means_risk": True},
    {"id": 3, "text": "Does your child play pretend or make-believe?", "yes_means_risk": False},
    {"id": 4, "text": "Does your child like climbing on things?", "yes_means_risk": False},
    {"id": 5, "text": "Does your child make unusual finger movements near his or her eyes?", "yes_means_risk": True},
    {"id": 6, "text": "Does your child point with one finger to ask for something or to get help?", "yes_means_risk": False},
    {"id": 7, "text": "Does your child point with one finger to show you something interesting?", "yes_means_risk": False},
    {"id": 8, "text": "Is your child interested in other children?", "yes_means_risk": False},
    {"id": 9, "text": "Does your child show you things by bringing them to you or holding them up for you to see – not to get help, but just to share?", "yes_means_risk": False},
    {"id": 10, "text": "Does your child respond when you call his or her name?", "yes_means_risk": False},
    {"id": 11, "text": "When you smile at your child, does he or she smile back at you?", "yes_means_risk": False},
    {"id": 12, "text": "Does your child get upset by everyday noises?", "yes_means_risk": True},
    {"id": 13, "text": "Does your child walk?", "yes_means_risk": False},
    {"id": 14, "text": "Does your child look you in the eye when you are talking to him or her, playing with him or her, or dressing him or her?", "yes_means_risk": False},
    {"id": 15, "text": "Does your child try to copy what you do?", "yes_means_risk": False},
    {"id": 16, "text": "If you turn your head to look at something, does your child look around to see what you are looking at?", "yes_means_risk": False},
    {"id": 17, "text": "Does your child try to get you to watch him or her?", "yes_means_risk": False},
    {"id": 18, "text": "Does your child understand when you tell him or her to do something?", "yes_means_risk": False},
    {"id": 19, "text": "If something new happens, does your child look at your face to see how you feel about it?", "yes_means_risk": False},
    {"id": 20, "text": "Does your child like movement activities?", "yes_means_risk": False},
]
