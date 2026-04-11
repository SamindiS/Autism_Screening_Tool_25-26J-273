import requests
import json

# config.py uses port 8002
URL = "http://localhost:8002/predict"

def test_v3_hybrid(lang="en", age=30):
    print(f"\n🧪 Testing v3 Hybrid (Age: {age}, Lang: {lang})")
    payload = {
        "age_months": age,
        "features": {
            "age_months": age,
            "gender": 1,
            "language": lang,
            "q1_name_response": 2,      # Red flag
            "q4_eye_contact": 2,        # Red flag
            "q7_imitation": 2,          # Red flag
            "q9_joint_attention": 1,     # Red flag
            "critical_items_failed": 4,
            "failed_items_rate": 0.4,
            "completion_time_sec": 350
        }
    }
    
    try:
        response = requests.post(URL, json=payload)
        if response.status_code == 200:
            res = response.json()
            print(f"✅ Status: {res['severity']}")
            print(f"📊 Hybrid Score: {res['hybrid_score']}")
            print(f"🧠 Why this result? (XAI):")
            for reason in res['explanations']:
                print(f"   - {reason}")
        else:
            print(f"❌ Error {response.status_code}: {response.text}")
    except Exception as e:
        print(f"❌ Connection failed: {e}")

if __name__ == "__main__":
    test_v3_hybrid(lang="en")
    test_v3_hybrid(lang="si")
    test_v3_hybrid(lang="ta")
