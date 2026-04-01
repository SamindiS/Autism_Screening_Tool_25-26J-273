/// RRB Module Configuration
class RrbConfig {
  // ML Service URL (Flask server on port 5000)
  static const String mlServiceUrl = 'http://localhost:5000/api/v1';

  // API Endpoints
  static const String detectRRBEndpoint = '/detect';

  // Video Configuration
  static const int maxVideoDurationSeconds = 300; // 5 minutes
  static const int minVideoDurationSeconds = 10; // 10 seconds

  // Detection Configuration
  static const double confidenceThreshold = 0.70;
  static const double minDetectionDuration = 3.0; // seconds

  // RRB Categories
  static const List<String> rrbCategories = [
    'Hand Flapping',
    'Head Banging',
    'Head Nodding',
    'Spinning',
    'Atypical Hand Movements',
    'Normal',
  ];

  // Colors for each category
  static const Map<String, int> categoryColors = {
    'Hand Flapping': 0xFFE74C3C,
    'Head Banging': 0xFFE67E22,
    'Head Nodding': 0xFFF39C12,
    'Spinning': 0xFF9B59B6,
    'Atypical Hand Movements': 0xFF3498DB,
    'Normal': 0xFF2ECC71,
  };

  // Clinical descriptions for each behavior category
  static const Map<String, String> behaviorDescriptions = {
    'Hand Flapping':
        'Rapid, repetitive up-and-down or side-to-side movement of the hands '
            'and arms. Often triggered by excitement, anxiety, or sensory overload. '
            'This is one of the most commonly observed RRBs in children with ASD.',
    'Head Banging':
        'Repetitive striking of the head against a surface such as a wall, floor, '
            'or furniture. May serve as self-stimulation or a response to pain, '
            'frustration, or sensory dysregulation.',
    'Head Nodding':
        'Rhythmic, repetitive bobbing or nodding of the head that is not '
            'associated with communication or agreement. May indicate vestibular '
            'sensory-seeking behavior or neurological patterns.',
    'Spinning':
        'Repetitive spinning of the body or objects. Often a vestibular '
            'sensory-seeking behavior that provides proprioceptive input. '
            'Children may spin in place or rotate objects repeatedly.',
    'Atypical Hand Movements':
        'Unusual, repetitive hand or finger movements including finger-flicking, '
            'hand-wringing, complex hand posturing, or other stereotyped motor '
            'patterns. These movements differ from typical developmental hand play.',
    'Normal':
        'No significant restricted or repetitive behaviors were detected during '
            'the observation period. The child\'s movements appeared within the '
            'expected range for their developmental stage.',
  };

  // Clinical recommendations / instructions for each behavior
  static const Map<String, String> behaviorInstructions = {
    'Hand Flapping':
        '• Consult an Occupational Therapist for sensory integration therapy\n'
            '• Identify and document specific triggers (excitement, stress, overload)\n'
            '• Introduce alternative sensory outlets such as fidget tools or stress balls\n'
            '• Use visual schedules to prepare the child for transitions\n'
            '• Share frequency and context observations with the clinical team',
    'Head Banging': '• Ensure the child\'s physical safety with protective padding if necessary\n'
        '• Request a Functional Behavior Assessment (FBA) from a behavior analyst\n'
        '• Investigate potential pain, discomfort, or otitis media as triggers\n'
        '• Implement structured sensory breaks and calming strategies throughout the day\n'
        '• Monitor frequency and refer to pediatric neurology if persistent',
    'Head Nodding':
        '• Rule out neurological causes with a pediatric neurology consultation\n'
            '• Track frequency, duration, and situational triggers carefully\n'
            '• Incorporate vestibular activities in the therapy plan (e.g., swings, rocking)\n'
            '• Assess hearing to rule out auditory processing difficulties\n'
            '• Share observation data with the child\'s multidisciplinary team',
    'Spinning':
        '• Provide structured vestibular input through therapy (swings, balance boards)\n'
            '• Work with an Occupational Therapist to develop a sensory diet\n'
            '• Create safe, designated spinning spaces to redirect behavior\n'
            '• Monitor for dizziness, disorientation, or risk of falls\n'
            '• Introduce graded proprioceptive activities to reduce spinning urge',
    'Atypical Hand Movements':
        '• Engage in fine motor therapy and purposeful hand skill activities\n'
            '• Consult an Occupational Therapist for hand-based intervention planning\n'
            '• Use visual and tactile activity schedules to redirect hand movements\n'
            '• Evaluate for Stereotyped Movement Disorder with the clinical team\n'
            '• Document patterns and intensity for diagnostic clarification',
    'Normal': '• Continue routine developmental monitoring and scheduled reviews\n'
        '• Maintain observation logs for any emerging or new behaviors\n'
        '• Support healthy sensory, social, and cognitive development\n'
        '• Conduct follow-up screening in 6 months or as clinically indicated\n'
        '• Encourage play-based interactions to support overall development',
  };

  // Icons for each category (using icon codepoints)
  static const Map<String, int> behaviorIcons = {
    'Hand Flapping': 0xe5cf, // back_hand
    'Head Banging': 0xe836, // crisis_alert
    'Head Nodding': 0xe627, // 360
    'Spinning': 0xe863, // autorenew
    'Atypical Hand Movements': 0xe3ae, // gesture
    'Normal': 0xe86c, // check_circle
  };
}
