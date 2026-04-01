import json
import os

l10n_dir = r'''d:\GitHub\Autism Screening Research Project\Autism_Screening_Tool_25-26J-273\SenseAI\lib\l10n'''

translations = {
    'visualCheckingTitle': {'en': 'Visual Checking', 'si': 'දෘශ්‍ය පරීක්ෂාව', 'ta': 'பார்வை சோதனை'},
    'enhanceFocus': {'en': 'Enhance focus and track eye movements', 'si': 'අවධානය වැඩි දියුණු කර ඇසේ චලනයන් නිරීක්ෂණය කරන්න', 'ta': 'கவனத்தை மேம்படுத்தி கண் அசைவுகளை கண்காணிக்கவும்'},
    'childInfoTitle': {'en': 'Child Information', 'si': 'ළමා තොරතුරු', 'ta': 'குழந்தை தகவல்'},
    'letsStartAdventure': {'en': "Let's Start Our Adventure!", 'si': 'අපි අපේ වික්‍රමය පටන් ගනිමු!', 'ta': 'நமது சாகசத்தை ஆரம்பிப்போம்!'},
    'whatsYourName': {'en': "What's your name?", 'si': 'ඔයාගේ නම මොකක්ද?', 'ta': 'உன் பெயர் என்ன?'},
    'howOldAreYou': {'en': 'How old are you?', 'si': 'ඔබේ වයස කීයද?', 'ta': 'உன் வயது என்ன?'},
    'letsGo': {'en': "Let's Go!", 'si': 'අපි යමු!', 'ta': 'போகலாம்!'},
    'funGamesAhead': {'en': 'Fun Games Ahead!', 'si': 'ඉදිරියේදී විනෝදාත්මක ක්‍රීඩා!', 'ta': 'வேடிக்கையான விளையாட்டுகள் காத்திருக்கின்றன!'},
    'playExcitingGames': {'en': 'Play exciting pattern and matching games', 'si': 'විචිත්‍රවත් රටා සහ ගැලපෙන ක්‍රීඩා කරන්න', 'ta': 'சுவாரஸ்யமான மாதிரி மற்றும் பொருத்தும் விளையாட்டுகளை விளையாடுங்கள்'},
    'parentGuardianInfo': {'en': 'Parent/Guardian Information', 'si': 'දෙමාපිය/භාරකරු තොරතුරු', 'ta': 'பெற்றோர்/பாதுகாவலர் தகவல்'},
    'tellUsAboutParent': {'en': 'Tell us about your parent/guardian', 'si': 'ඔබේ දෙමාපියන්/භාරකරු ගැන අපට පවසන්න', 'ta': 'உங்கள் பெற்றோர்/பாதுகாவலர் பற்றி சொல்லுங்கள்'},
    'parentGuardianName': {'en': 'Parent/Guardian Name', 'si': 'දෙමාපිය/භාරකරුගේ නම', 'ta': 'பெற்றோர்/பாதுகாவலர் பெயர்'},
    'emailAddress': {'en': 'Email Address (Optional)', 'si': 'ඊමේල් ලිපිනය (විකල්ප)', 'ta': 'மின்னஞ்சல் முகவரி (விருப்பமானால்)'},
    'phoneNumber': {'en': 'Phone Number', 'si': 'දුරකථන අංකය', 'ta': 'தொலைபேசி எண்'},
    'includeCountryCode': {'en': 'Include country code (e.g., +94)', 'si': 'රටේ කේතය ඇතුළත් කරන්න (උදා: +94)', 'ta': 'நாட்டின் குறியீட்டைச் சேர்க்கவும் (எ.கா: +94)'},
    'relationship': {'en': 'Relationship to Child', 'si': 'දරුවාට ඇති සම්බන්ධතාවය', 'ta': 'குழந்தையுடன் உறவு'},
    'backText': {'en': 'Back', 'si': 'ආපසු', 'ta': 'பின் செல்ல'},
    'continueText': {'en': 'Continue', 'si': 'ඉදිරියට', 'ta': 'தொடர்க'},
    'safeAndSecure': {'en': 'Safe & Secure', 'si': 'ආරක්ෂිත සහ සුරක්ෂිත', 'ta': 'பாதுகாப்பான மற்றும் உறுதியான'},
    'infoHelpsReport': {'en': 'This info helps us send you the report', 'si': 'මෙම ත শহরතuru ඔබට වාර්තාව යැවීමට උපකාරී වේ', 'ta': 'இந்தத் தகவல் உங்களுக்கு அறிக்கை அனுப்ப உதவும்'},
    'calibrationTitle': {'en': 'Calibration', 'si': 'ක්‍රමාංකනය', 'ta': 'அளவீடு'},
    'lookAtTheDot': {'en': 'Look at the dot:', 'si': 'තිත දෙස බලන්න:', 'ta': 'புள்ளியைப் பார்க்கவும்:'},
    'nextButton': {'en': 'Next', 'si': 'මීළඟ', 'ta': 'அடுத்து'},
    'startGames': {'en': 'Start Games', 'si': 'ක්‍රීඩා අරඹන්න', 'ta': 'விளையாட்டுகளைத் தொடங்கு'},
    'bubblePopGame': {'en': 'Bubble Pop Game', 'si': 'බුබුලු පුපුරවන ක්‍රීඩාව', 'ta': 'குமிழி வெடிக்கும் விளையாட்டு'},
    'howToPlayGame': {'en': 'How to Play', 'si': 'සෙල්ලම් කරන්නේ කොහොමද', 'ta': 'எப்படி விளையாடுவது'},
    'seeTheBubbles': {'en': 'See the bubbles', 'si': 'බුබුලු බලන්න', 'ta': 'குமிழிகளைப் பார்க்கவும்'},
    'bubblesFloat': {'en': 'Colorful bubbles will float on screen', 'si': 'වර්ණවත් බුබුලු තිරය මත පාවෙනවා ඇත', 'ta': 'வண்ணமயமான குமிழிகள் திரையில் மிதக்கும்'},
    'tapToPop': {'en': 'Tap to pop!', 'si': 'පුපුරන්න තට්ටු කරන්න!', 'ta': 'வெடிக்கத் தட்டவும்!'},
    'touchBubblesPop': {'en': 'Touch the bubbles to pop them!', 'si': 'බුබුලු පුපුරවන්න ඒවා ස්පර්ශ කරන්න!', 'ta': 'குமிழிகளை வெடிக்கச் செய்ய அவற்றைத் தொடவும்!'},
    'haveFun': {'en': 'Have fun!', 'si': 'විනෝද වෙන්න!', 'ta': 'மகிழுங்கள்!'},
    'popAsMany': {'en': 'Pop as many bubbles as you can!', 'si': 'ඔබට හැකි පමණ බුබුලු පුපුරවන්න!', 'ta': 'உங்களால் முடிந்தவரை குமிழிகளை வெடிக்கவும்!'},
    'thirtySeconds': {'en': '30 seconds', 'si': 'තත්පර 30', 'ta': '30 விநாடிகள்'},
    'gameLasts30': {'en': 'The game lasts 30 seconds', 'si': 'ක්‍රීඩාව තත්පර 30 ක් පවතී', 'ta': 'விளையாட்டு 30 விநாடிகள் நீடிக்கும்'},
    'startGameBtn': {'en': 'Start Game', 'si': 'ක්‍රීඩාව අරඹන්න', 'ta': 'விளையாட்டைத் தொடங்கு'},
    'butterflyGame': {'en': 'Butterfly Game', 'si': 'සමනල ක්‍රීඩාව', 'ta': 'பட்டாம்பூச்சி விளையாட்டு'},
    'watchButterfly': {'en': 'Watch the butterfly', 'si': 'සමනලයා දෙස බලන්න', 'ta': 'பட்டாம்பூச்சியைக் கவனியுங்கள்'},
    'butterflyFlyAround': {'en': 'A colorful butterfly will fly around', 'si': 'වර්ණවත් සමනලයෙක් වටේ පියාසර කරයි', 'ta': 'ஒரு வண்ணமயமான பட்டாம்பூச்சி சுற்றி பறக்கும்'},
    'followEyes': {'en': 'Follow with your eyes', 'si': 'ඔබේ ඇස්වලින් අනුගමනය කරන්න', 'ta': 'உங்கள் கண்களால் பின்தொடரவும்'},
    'tryLookWhere': {'en': 'Try to look at where it goes', 'si': 'එය යන තැන බැලීමට උත්සාහ කරන්න', 'ta': 'அது எங்கே செல்கிறது என்பதைப் பார்க்க முயற்சிக்கவும்'},
    'visitFlowers': {'en': 'Visit the flowers', 'si': 'මල් බලන්න යන්න', 'ta': 'பூக்களைப் பார்க்கச் செல்லுங்கள்'},
    'butterflyLovesFlowers': {'en': 'The butterfly loves flowers!', 'si': 'සමනලයා මල් වලට හරිම ආසයි!', 'ta': 'பட்டாம்பூச்சிக்கு பூக்கள் பிடிக்கும்!'},
    'fifteenSeconds': {'en': '15 seconds', 'si': 'තත්පර 15', 'ta': '15 விநாடிகள்'},
    'gameLasts15': {'en': 'The game lasts 15 seconds', 'si': 'ක්‍රීඩාව තත්පර 15 ක් පවතී', 'ta': 'விளையாட்டு 15 விநாடிகள் நீடிக்கும்'},
    'allDone': {'en': 'All Done!', 'si': 'සියල්ල අවසන්!', 'ta': 'எல்லாம் முடிந்தது!'},
    'youDidGreat': {'en': 'You Did Great!', 'si': 'ඔබ විශිෂ්ට ලෙස කළා!', 'ta': 'நீங்கள் சிறப்பாக செய்தீர்கள்!'},
    'amazingJob': {'en': 'Amazing job completing the games!', 'si': 'ක්‍රීඩා සම්පූර්ණ කිරීමෙන් ඔබ පුදුමාකාර කාර්යයක් කළා!', 'ta': 'விளையாட்டுகளை முடித்ததில் சிறப்பான வேலை!'},
    'yourScore': {'en': 'Your Score', 'si': 'ඔබේ ලකුණු', 'ta': 'உங்கள் மதிப்பெண்'},
    'specialReport': {'en': 'Your Special Report', 'si': 'ඔබේ විශේෂ වාර්තාව', 'ta': 'உங்கள் சிறப்பு அறிக்கை'},
    'generatingReportReason': {'en': 'We are creating your amazing report...', 'si': 'අපි ඔබගේ පුදුමාකාර වාර්තාව නිර්මාණය කරමින් සිටිමු...', 'ta': 'உங்கள் அற்புதமான அறிக்கையை உருவாக்குகிறோம்...'},
    'getYourReport': {'en': 'Get Your Report', 'si': 'ඔබේ වාර්තාව ලබා ගන්න', 'ta': 'உங்கள் அறிக்கையைப் பெறுங்கள்'},
    'playAgain': {'en': 'Play Again!', 'si': 'නැවත සෙල්ලම් කරන්න!', 'ta': 'மீண்டும் விளையாடு!'}
}

files = {
    'en': os.path.join(l10n_dir, 'app_en.arb'),
    'si': os.path.join(l10n_dir, 'app_si.arb'),
    'ta': os.path.join(l10n_dir, 'app_ta.arb')
}

for lang, filepath in files.items():
    if os.path.exists(filepath):
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        for key, vals in translations.items():
            data[key] = vals[lang]
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Updated {lang}.arb")
