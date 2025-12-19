/// Translations for DCCS (Color-Shape) game
/// Supports English (en), Sinhala (si), and Tamil (ta)
class DccsTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // Game Title
    'game_title': {
      'en': 'Color-Shape Sorting Game',
      'si': 'පාට-හැඩ තෝරන සෙල්ලම',
      'ta': 'நிறம்-வடிவம் வரிசைப்படுத்தும் விளையாட்டு',
    },
    
    // Instructions Screen
    'color_rule_instruction': {
      'en': 'First we play the COLOR game:\nPut the card where the COLOR matches.',
      'si': 'මුලින්ම පාට සෙල්ලම:\nඑකම පාට තියෙන තැනට කාඩ්පත දාන්න.',
      'ta': 'முதலில் நிற விளையாட்டு:\nஅதே நிறம் உள்ள இடத்தில் அட்டையை வை.',
    },
    'shape_rule_instruction': {
      'en': 'Then we play the SHAPE game:\nPut the card where the SHAPE matches.',
      'si': 'ඊට පස්සේ හැඩ සෙල්ලම:\nඑකම හැඩය තියෙන තැනට කාඩ්පත දාන්න.',
      'ta': 'பின் வடிவ விளையாட்டு:\nஅதே வடிவம் உள்ள இடத்தில் அட்டையை வை.',
    },
    
    // Buttons
    'listen': {
      'en': 'Listen',
      'si': 'අහන්න',
      'ta': 'கேள்',
    },
    'start_game': {
      'en': 'START GAME',
      'si': 'සෙල්ලම පටන් ගමු',
      'ta': 'விளையாட்டு தொடங்கு',
    },
    
    // Target boxes
    'left': {
      'en': 'LEFT',
      'si': 'වම',
      'ta': 'இடது',
    },
    'right': {
      'en': 'RIGHT',
      'si': 'දකුණ',
      'ta': 'வலது',
    },
    'red_circle': {
      'en': 'Red Circle',
      'si': 'රතු රවුම',
      'ta': 'சிவப்பு வட்டம்',
    },
    'blue_square': {
      'en': 'Blue Square',
      'si': 'නිල් කොටුව',
      'ta': 'நீல சதுரம்',
    },
    
    // Rule banner
    'color_game': {
      'en': 'COLOR GAME',
      'si': 'පාට සෙල්ලම',
      'ta': 'நிற விளையாட்டு',
    },
    'shape_game': {
      'en': 'SHAPE GAME',
      'si': 'හැඩ සෙල්ලම',
      'ta': 'வடிவ விளையாட்டு',
    },
    
    // Stimulus card
    'tap_matching_box': {
      'en': 'TAP THE MATCHING BOX',
      'si': 'ගැලපෙන පෙට්ටිය ඔබන්න',
      'ta': 'பொருத்தமான பெட்டியைத் தட்டு',
    },
    
    // Stimulus colors/shapes
    'red': {
      'en': 'RED',
      'si': 'රතු',
      'ta': 'சிவப்பு',
    },
    'blue': {
      'en': 'BLUE',
      'si': 'නිල්',
      'ta': 'நீலம்',
    },
    'circle': {
      'en': 'CIRCLE',
      'si': 'රවුම',
      'ta': 'வட்டம்',
    },
    'square': {
      'en': 'SQUARE',
      'si': 'කොටුව',
      'ta': 'சதுரம்',
    },
    
    // Feedback
    'correct': {
      'en': '✓ Correct!',
      'si': '✓ හරි!',
      'ta': '✓ சரி!',
    },
    'try_next': {
      'en': '✗ Try the next one',
      'si': '✗ ඊළඟ එක බලමු',
      'ta': '✗ அடுத்ததைப் பார்',
    },
    
    // Phase indicators
    'practice_round': {
      'en': 'Practice Round',
      'si': 'පුහුණු වටය',
      'ta': 'பயிற்சி சுற்று',
    },
    'color_game_phase': {
      'en': 'Color Game Phase',
      'si': 'පාට සෙල්ලම් අදියර',
      'ta': 'நிற விளையாட்டு கட்டம்',
    },
    'shape_game_phase': {
      'en': 'Shape Game Phase',
      'si': 'හැඩ සෙල්ලම් අදියර',
      'ta': 'வடிவ விளையாட்டு கட்டம்',
    },
    'mixed_phase': {
      'en': 'Mixed Phase',
      'si': 'මිශ්‍ර අදියර',
      'ta': 'கலப்பு கட்டம்',
    },
    
    // Progress
    'trial_of': {
      'en': 'Trial',
      'si': 'අත්හදා බැලීම',
      'ta': 'முயற்சி',
    },
    'of': {
      'en': 'of',
      'si': '/',
      'ta': '/',
    },
    
    // Header
    'dccs_game': {
      'en': 'DCCS Game',
      'si': 'පාට-හැඩ සෙල්ලම',
      'ta': 'நிறம்-வடிவம் விளையாட்டு',
    },
    
    // Language selector
    'select_language': {
      'en': 'Select Language',
      'si': 'භාෂාව තෝරන්න',
      'ta': 'மொழியைத் தேர்ந்தெடு',
    },
    'voice_instructions': {
      'en': 'Select language for voice instructions',
      'si': 'හඬ උපදෙස් සඳහා භාෂාව තෝරන්න',
      'ta': 'குரல் வழிமுறைகளுக்கு மொழியைத் தேர்ந்தெடு',
    },
    'sort_cards': {
      'en': 'Sort cards by COLOR or SHAPE',
      'si': 'පාට හෝ හැඩය අනුව කාඩ්පත් තෝරන්න',
      'ta': 'நிறம் அல்லது வடிவத்தின்படி அட்டைகளை வரிசைப்படுத்து',
    },
  };

  /// Get translated text for a key in the specified language
  static String get(String key, String language) {
    final translations = _translations[key];
    if (translations == null) return key;
    return translations[language] ?? translations['en'] ?? key;
  }

  /// Get color name translated
  static String getColor(String color, String language) {
    return get(color.toLowerCase(), language);
  }

  /// Get shape name translated
  static String getShape(String shape, String language) {
    return get(shape.toLowerCase(), language);
  }

  /// Get stimulus description (color + shape) translated
  static String getStimulusDescription(String color, String shape, String language) {
    return '${getColor(color, language)} ${getShape(shape, language)}';
  }
}






