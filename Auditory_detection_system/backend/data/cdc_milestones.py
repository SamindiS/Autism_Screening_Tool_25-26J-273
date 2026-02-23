"""
CDC-inspired developmental milestone checklist by age band.
Used for Developmental Milestone Tracker: expected vs actual, flag delays.
Ages in months; categories: Social/Emotional, Language/Communication, Cognitive, Movement.
"""

# Age bands (months): 6, 9, 12, 18, 24, 36, 48, 60
# Each milestone: id, category, description
CDC_MILESTONES = {
    6: [
        {"id": "6_s1", "category": "Social/Emotional", "text": "Knows familiar people; may be shy with strangers"},
        {"id": "6_s2", "category": "Social/Emotional", "text": "Likes to play with others, especially parents"},
        {"id": "6_l1", "category": "Language/Communication", "text": "Takes turns making sounds with you"},
        {"id": "6_l2", "category": "Language/Communication", "text": "Responds to own name"},
        {"id": "6_c1", "category": "Cognitive", "text": "Reaches to grab a toy"},
        {"id": "6_m1", "category": "Movement", "text": "Pushes up with arms when on tummy"},
        {"id": "6_m2", "category": "Movement", "text": "Rolls from tummy to back"},
    ],
    9: [
        {"id": "9_s1", "category": "Social/Emotional", "text": "May be clingy with familiar adults"},
        {"id": "9_s2", "category": "Social/Emotional", "text": "Has favorite toys"},
        {"id": "9_l1", "category": "Language/Communication", "text": "Makes different sounds like 'mama', 'dada'"},
        {"id": "9_l2", "category": "Language/Communication", "text": "Lifts arms to be picked up"},
        {"id": "9_c1", "category": "Cognitive", "text": "Looks for objects when dropped"},
        {"id": "9_m1", "category": "Movement", "text": "Sits without support"},
        {"id": "9_m2", "category": "Movement", "text": "Moves things from one hand to the other"},
    ],
    12: [
        {"id": "12_s1", "category": "Social/Emotional", "text": "Plays games like peek-a-boo"},
        {"id": "12_s2", "category": "Social/Emotional", "text": "Shows facial expressions like happy, sad, angry"},
        {"id": "12_l1", "category": "Language/Communication", "text": "Waves 'bye-bye'"},
        {"id": "12_l2", "category": "Language/Communication", "text": "Calls parent 'mama' or 'dada'"},
        {"id": "12_l3", "category": "Language/Communication", "text": "Responds when name is called"},
        {"id": "12_c1", "category": "Cognitive", "text": "Puts things in a container"},
        {"id": "12_m1", "category": "Movement", "text": "Pulls up to stand"},
        {"id": "12_m2", "category": "Movement", "text": "May take a few steps"},
    ],
    18: [
        {"id": "18_s1", "category": "Social/Emotional", "text": "Moves away from you but checks to make sure you are close"},
        {"id": "18_s2", "category": "Social/Emotional", "text": "Points to show you something interesting"},
        {"id": "18_l1", "category": "Language/Communication", "text": "Says several single words"},
        {"id": "18_l2", "category": "Language/Communication", "text": "Follows one-step directions like 'Give me the ball'"},
        {"id": "18_c1", "category": "Cognitive", "text": "Copies you doing chores"},
        {"id": "18_m1", "category": "Movement", "text": "Walks alone"},
        {"id": "18_m2", "category": "Movement", "text": "Drinks from a cup"},
    ],
    24: [
        {"id": "24_s1", "category": "Social/Emotional", "text": "Notices when others are hurt or upset"},
        {"id": "24_s2", "category": "Social/Emotional", "text": "Plays beside other children"},
        {"id": "24_l1", "category": "Language/Communication", "text": "Says two-word phrases like 'More milk'"},
        {"id": "24_l2", "category": "Language/Communication", "text": "Points to things in a book when asked"},
        {"id": "24_c1", "category": "Cognitive", "text": "Plays simple pretend games"},
        {"id": "24_m1", "category": "Movement", "text": "Runs"},
        {"id": "24_m2", "category": "Movement", "text": "Kicks a ball"},
    ],
    36: [
        {"id": "36_s1", "category": "Social/Emotional", "text": "Calms down within 10 minutes after you leave"},
        {"id": "36_s2", "category": "Social/Emotional", "text": "Shows concern for a crying friend"},
        {"id": "36_l1", "category": "Language/Communication", "text": "Talks with you in conversation using at least two back-and-forth exchanges"},
        {"id": "36_l2", "category": "Language/Communication", "text": "Says first name when asked"},
        {"id": "36_c1", "category": "Cognitive", "text": "Draws a circle when shown how"},
        {"id": "36_m1", "category": "Movement", "text": "Uses a fork to eat"},
        {"id": "36_m2", "category": "Movement", "text": "Climbs well"},
    ],
    48: [
        {"id": "48_s1", "category": "Social/Emotional", "text": "Prefers playing with other children than alone"},
        {"id": "48_s2", "category": "Social/Emotional", "text": "Comforts others who are hurt or sad"},
        {"id": "48_l1", "category": "Language/Communication", "text": "Says words like 'I', 'me', 'we', 'you'"},
        {"id": "48_l2", "category": "Language/Communication", "text": "Talks about what happened during the day"},
        {"id": "48_c1", "category": "Cognitive", "text": "Names some colors and numbers"},
        {"id": "48_m1", "category": "Movement", "text": "Catches a ball most of the time"},
        {"id": "48_m2", "category": "Movement", "text": "Hops on one foot"},
    ],
    60: [
        {"id": "60_s1", "category": "Social/Emotional", "text": "Follows rules or takes turns when playing games"},
        {"id": "60_s2", "category": "Social/Emotional", "text": "Sings, dances, or acts for you"},
        {"id": "60_l1", "category": "Language/Communication", "text": "Tells a simple story using full sentences"},
        {"id": "60_l2", "category": "Language/Communication", "text": "Says name and address when asked"},
        {"id": "60_c1", "category": "Cognitive", "text": "Counts to 10"},
        {"id": "60_m1", "category": "Movement", "text": "Buttons some buttons"},
        {"id": "60_m2", "category": "Movement", "text": "Hops; may skip"},
    ],
}

def get_milestones_for_age(age_months):
    """Return milestone band: use closest age band <= age_months, or 6 if younger."""
    bands = sorted(CDC_MILESTONES.keys())
    chosen = 6
    for b in bands:
        if age_months >= b:
            chosen = b
    return CDC_MILESTONES.get(chosen, []), chosen
