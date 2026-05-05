import json
import os

base_dir = r"d:\GitHub\temp\Autism_Screening_Tool_25-26J-273\SenseAI\assets\translations"

new_keys_en = {
    "clinical_analytics": "Clinical Analytics",
    "no_data_available": "No data available for analytics.",
    "total_cohort": "Total Cohort",
    "completed": "Completed",
    "pending": "Pending",
    "current_diagnostic_spread": "Current Diagnostic Spread",
    "ratio_diagnostic_spread": "Ratio of children with standing ASD diagnosis vs. control screening",
    "asd": "ASD",
    "control": "Control",
    "total_users": "Total Users",
    "algorithmic_risk_distribution": "Algorithmic Risk Distribution",
    "breakdown_predictions": "Breakdown of completed session predictions",
    "low": "Low",
    "moderate": "Moderate",
    "high": "High",
    "demographic_age_cohorts": "Demographic Age Cohorts",
    "cohort_representation": "Cohort representation matching the target ML Models",
    "age_group_2_3": "2-3.5 yrs",
    "age_group_3_5": "3.5-5.5 yrs",
    "age_group_5_6": "5.5-6.9 yrs",
    "view_interactive_cohort": "View Interactive Cohort Analytics",
    "explore_statistical": "Explore statistical breakdowns of your diagnostic groups and ASD risk profiles.",
    "export_anonymized": "Export Anonymized Research Dataset",
    "generate_hipaa": "Generate HIPAA-compliant, de-identified datasets for external ML toolchains.",
    "generate_research_dataset": "Generate Research Dataset",
    "strictly_for_research": "Strictly for research use. All Primary Identifiable Information is stripped.",
    "diagnostic_group_label": "Diagnostic Group:",
    "all": "All",
    "age_cohort_label": "Age Cohort:",
    "all_ages": "All Ages",
    "export_securely": "Export Securely"
}

new_keys_si = {
    "clinical_analytics": "සායනික විශ්ලේෂණ",
    "no_data_available": "විශ්ලේෂණය සඳහා දත්ත නොමැත.",
    "total_cohort": "මුළු කණ්ඩායම",
    "completed": "සම්පූර්ණයි",
    "pending": "පොරොත්තු",
    "current_diagnostic_spread": "වත්මන් රෝග විනිශ්චය ව්‍යාප්තිය",
    "ratio_diagnostic_spread": "ASD රෝග විනිශ්චය සහ පාලන තිරගත කිරීමේ අනුපාතය",
    "asd": "ඔටිසම්",
    "control": "පාලනය",
    "total_users": "මුළු පරිශීලකයින්",
    "algorithmic_risk_distribution": "ඇල්ගොරිතම අවදානම් ව්‍යාප්තිය",
    "breakdown_predictions": "සම්පූර්ණ කරන ලද සැසි පුරෝකථන බිඳවැටීම",
    "low": "අඩු",
    "moderate": "මධ්‍යම",
    "high": "ඉහළ",
    "demographic_age_cohorts": "ජනවිකාස වයස් කාණ්ඩ",
    "cohort_representation": "ML මාදිලි වලට ගැලපෙන කණ්ඩායම් නිරූපණය",
    "age_group_2_3": "අවු 2-3.5",
    "age_group_3_5": "අවු 3.5-5.5",
    "age_group_5_6": "අවු 5.5-6.9",
    "view_interactive_cohort": "අන්තර්ක්‍රියාකාරී කණ්ඩායම් විශ්ලේෂණ බලන්න",
    "explore_statistical": "රෝග විනිශ්චය සහ ASD අවදානම් වල සංඛ්‍යානමය බිඳවැටීම් ගවේෂණය කරන්න.",
    "export_anonymized": "නිර්නාමික පර්යේෂණ දත්ත කට්ටලය නිර්යාත කරන්න",
    "generate_hipaa": "බාහිර ML මෙවලම් සඳහා HIPAA-අනුකූල දත්ත සමූහයක් ජනනය කරන්න.",
    "generate_research_dataset": "පර්යේෂණ දත්ත සමූහය ජනනය කරන්න",
    "strictly_for_research": "පර්යේෂණ භාවිතය සඳහා පමණි. හඳුනාගත හැකි තොරතුරු ඉවත් කර ඇත.",
    "diagnostic_group_label": "රෝග විනිශ්චය කණ්ඩායම:",
    "all": "සියල්ල",
    "age_cohort_label": "වයස් කාණ්ඩය:",
    "all_ages": "සියලුම වයස්",
    "export_securely": "ආරක්ෂිතව නිර්යාත කරන්න"
}

new_keys_ta = {
    "clinical_analytics": "மருத்துவ பகுப்பாய்வு",
    "no_data_available": "பகுப்பாய்வுக்கு தரவு எதுவும் இல்லை.",
    "total_cohort": "மொத்த குழு",
    "completed": "முடிக்கப்பட்டது",
    "pending": "நிலுவையில் உள்ளது",
    "current_diagnostic_spread": "தற்போதைய கண்டறிதல் பரவல்",
    "ratio_diagnostic_spread": "ஆட்டிசம் vs கட்டுப்பாட்டு ஸ்கிரீனிங் விகிதம்",
    "asd": "ஆட்டிஸம்",
    "control": "கட்டுப்பாடு",
    "total_users": "மொத்த பயனர்கள்",
    "algorithmic_risk_distribution": "அல்காரிதம் ஆபத்து விநியோகம்",
    "breakdown_predictions": "முடிக்கப்பட்ட அமர்வு கணிப்புகளின் முறிவு",
    "low": "குறைந்த",
    "moderate": "மிதமான",
    "high": "அதிக",
    "demographic_age_cohorts": "மக்கள்தொகை வயது குழுக்கள்",
    "cohort_representation": "ML மாடல்களுடன் பொருந்தும் குழு பிரதிநிதித்துவம்",
    "age_group_2_3": "2-3.5 ஆண்டுகள்",
    "age_group_3_5": "3.5-5.5 ஆண்டுகள்",
    "age_group_5_6": "5.5-6.9 ஆண்டுகள்",
    "view_interactive_cohort": "ஊடாடும் குழு பகுப்பாய்வைக் காண்க",
    "explore_statistical": "உங்கள் கண்டறியும் குழுக்களின் புள்ளிவிவர முறிவுகளை ஆராயுங்கள்.",
    "export_anonymized": "அநாமதேய ஆராய்ச்சி தரவுத்தொகுப்பை ஏற்றுமதி செய்க",
    "generate_hipaa": "வெளிப்புற எம்.எல் கருவிகளுக்கான தரவுத்தொகுப்புகளை உருவாக்கவும்.",
    "generate_research_dataset": "ஆராய்ச்சி தரவுத்தொகுப்பை உருவாக்கவும்",
    "strictly_for_research": "ஆராய்ச்சி பயன்பாட்டிற்கு மட்டுமே.",
    "diagnostic_group_label": "கண்டறியும் குழு:",
    "all": "அனைத்தும்",
    "age_cohort_label": "வயது குழு:",
    "all_ages": "அனைத்து வயது",
    "export_securely": "பாதுகாப்பாக ஏற்றுமதி செய்"
}

for lang, new_data in [('en', new_keys_en), ('si', new_keys_si), ('ta', new_keys_ta)]:
    filepath = os.path.join(base_dir, f'{lang}.json')
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        for k, v in new_data.items():
            if k not in data:
                data[k] = v
                
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Updated {filepath}")
    else:
        print(f"Not found: {filepath}")
