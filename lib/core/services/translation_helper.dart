import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class TranslationHelper {
  // Load AI Bot questions with translations for age 2-3.5
  // Based on M-CHAT-R, ADOS, and other validated screening tools
  static List<Map<String, dynamic>> getAIBotQuestions(String childName, BuildContext? context) {
    final questions = <Map<String, dynamic>>[];
    
    // Use AppLocalizations if context is provided, otherwise use English defaults
    AppLocalizations? localizations;
    if (context != null) {
      localizations = AppLocalizations.of(context);
    }

    // Research-based questions for age 2-3.5 (M-CHAT-R inspired + clinical observations)
    final questionData = [
      {
        'questionKey': 'aiQuestion1',
        'categoryKey': 'aiCategory1',
        'options': ['aiQuestion1Option1', 'aiQuestion1Option2', 'aiQuestion1Option3', 'aiQuestion1Option4', 'aiQuestion1Option5'],
      },
      {
        'questionKey': 'aiQuestion2',
        'categoryKey': 'aiCategory2',
        'options': ['aiQuestion2Option1', 'aiQuestion2Option2', 'aiQuestion2Option3', 'aiQuestion2Option4', 'aiQuestion2Option5'],
      },
      {
        'questionKey': 'aiQuestion3',
        'categoryKey': 'aiCategory3',
        'options': ['aiQuestion3Option1', 'aiQuestion3Option2', 'aiQuestion3Option3', 'aiQuestion3Option4', 'aiQuestion3Option5'],
      },
      {
        'questionKey': 'aiQuestion4',
        'categoryKey': 'aiCategory4',
        'options': ['aiQuestion4Option1', 'aiQuestion4Option2', 'aiQuestion4Option3', 'aiQuestion4Option4', 'aiQuestion4Option5'],
      },
      {
        'questionKey': 'aiQuestion5',
        'categoryKey': 'aiCategory5',
        'options': ['aiQuestion5Option1', 'aiQuestion5Option2', 'aiQuestion5Option3', 'aiQuestion5Option4', 'aiQuestion5Option5'],
      },
      {
        'questionKey': 'aiQuestion6',
        'categoryKey': 'aiCategory6',
        'options': ['aiQuestion6Option1', 'aiQuestion6Option2', 'aiQuestion6Option3', 'aiQuestion6Option4', 'aiQuestion6Option5'],
      },
      {
        'questionKey': 'aiQuestion7',
        'categoryKey': 'aiCategory7',
        'options': ['aiQuestion7Option1', 'aiQuestion7Option2', 'aiQuestion7Option3', 'aiQuestion7Option4', 'aiQuestion7Option5'],
      },
      {
        'questionKey': 'aiQuestion8',
        'categoryKey': 'aiCategory8',
        'options': ['aiQuestion8Option1', 'aiQuestion8Option2', 'aiQuestion8Option3', 'aiQuestion8Option4', 'aiQuestion8Option5'],
      },
      {
        'questionKey': 'aiQuestion9',
        'categoryKey': 'aiCategory9',
        'options': ['aiQuestion9Option1', 'aiQuestion9Option2', 'aiQuestion9Option3', 'aiQuestion9Option4', 'aiQuestion9Option5'],
      },
      {
        'questionKey': 'aiQuestion10',
        'categoryKey': 'aiCategory10',
        'options': ['aiQuestion10Option1', 'aiQuestion10Option2', 'aiQuestion10Option3', 'aiQuestion10Option4', 'aiQuestion10Option5'],
      },
    ];

    for (int i = 0; i < questionData.length; i++) {
      final data = questionData[i];
      final questionKey = data['questionKey'] as String;
      final categoryKey = data['categoryKey'] as String;
      final optionKeys = data['options'] as List<String>;
      
      String question;
      String category;
      
      if (localizations != null) {
        // Use AppLocalizations - questions are methods that take childName
        question = _getLocalizedQuestion(localizations, questionKey, childName);
        category = _getLocalizedCategory(localizations, categoryKey);
      } else {
        // Fallback to English defaults
        question = _getEnglishQuestion(i + 1).replaceAll('{childName}', childName);
        category = _getEnglishCategory(i + 1);
      }
      
      final options = <Map<String, dynamic>>[];
      for (int j = 0; j < optionKeys.length; j++) {
        String optionText;
        if (localizations != null) {
          optionText = _getLocalizedOption(localizations, optionKeys[j]);
        } else {
          optionText = _getEnglishOption(i + 1, j + 1);
        }
        // Option 1 = value 5 (best), Option 5 = value 1 (worst)
        options.add({
          'text': optionText,
          'value': 5 - j,
        });
      }

      questions.add({
        'id': i + 1,
        'question': question,
        'category': category,
        'options': options,
      });
    }

    return questions;
  }

  static String _getLocalizedQuestion(AppLocalizations localizations, String key, String childName) {
    // Questions are methods that take childName as parameter
    switch (key) {
      case 'aiQuestion1': return localizations.aiQuestion1(childName);
      case 'aiQuestion2': return localizations.aiQuestion2(childName);
      case 'aiQuestion3': return localizations.aiQuestion3(childName);
      case 'aiQuestion4': return localizations.aiQuestion4(childName);
      case 'aiQuestion5': return localizations.aiQuestion5(childName);
      case 'aiQuestion6': return localizations.aiQuestion6(childName);
      case 'aiQuestion7': return localizations.aiQuestion7(childName);
      case 'aiQuestion8': return localizations.aiQuestion8(childName);
      case 'aiQuestion9': return localizations.aiQuestion9(childName);
      case 'aiQuestion10': return localizations.aiQuestion10(childName);
      default: return key;
    }
  }

  static String _getLocalizedCategory(AppLocalizations localizations, String key) {
    switch (key) {
      case 'aiCategory1': return localizations.aiCategory1;
      case 'aiCategory2': return localizations.aiCategory2;
      case 'aiCategory3': return localizations.aiCategory3;
      case 'aiCategory4': return localizations.aiCategory4;
      case 'aiCategory5': return localizations.aiCategory5;
      case 'aiCategory6': return localizations.aiCategory6;
      case 'aiCategory7': return localizations.aiCategory7;
      case 'aiCategory8': return localizations.aiCategory8;
      case 'aiCategory9': return localizations.aiCategory9;
      case 'aiCategory10': return localizations.aiCategory10;
      default: return key;
    }
  }

  static String _getLocalizedOption(AppLocalizations localizations, String key) {
    switch (key) {
      case 'aiQuestion1Option1': return localizations.aiQuestion1Option1;
      case 'aiQuestion1Option2': return localizations.aiQuestion1Option2;
      case 'aiQuestion1Option3': return localizations.aiQuestion1Option3;
      case 'aiQuestion1Option4': return localizations.aiQuestion1Option4;
      case 'aiQuestion1Option5': return localizations.aiQuestion1Option5;
      case 'aiQuestion2Option1': return localizations.aiQuestion2Option1;
      case 'aiQuestion2Option2': return localizations.aiQuestion2Option2;
      case 'aiQuestion2Option3': return localizations.aiQuestion2Option3;
      case 'aiQuestion2Option4': return localizations.aiQuestion2Option4;
      case 'aiQuestion2Option5': return localizations.aiQuestion2Option5;
      case 'aiQuestion3Option1': return localizations.aiQuestion3Option1;
      case 'aiQuestion3Option2': return localizations.aiQuestion3Option2;
      case 'aiQuestion3Option3': return localizations.aiQuestion3Option3;
      case 'aiQuestion3Option4': return localizations.aiQuestion3Option4;
      case 'aiQuestion3Option5': return localizations.aiQuestion3Option5;
      case 'aiQuestion4Option1': return localizations.aiQuestion4Option1;
      case 'aiQuestion4Option2': return localizations.aiQuestion4Option2;
      case 'aiQuestion4Option3': return localizations.aiQuestion4Option3;
      case 'aiQuestion4Option4': return localizations.aiQuestion4Option4;
      case 'aiQuestion4Option5': return localizations.aiQuestion4Option5;
      case 'aiQuestion5Option1': return localizations.aiQuestion5Option1;
      case 'aiQuestion5Option2': return localizations.aiQuestion5Option2;
      case 'aiQuestion5Option3': return localizations.aiQuestion5Option3;
      case 'aiQuestion5Option4': return localizations.aiQuestion5Option4;
      case 'aiQuestion5Option5': return localizations.aiQuestion5Option5;
      case 'aiQuestion6Option1': return localizations.aiQuestion6Option1;
      case 'aiQuestion6Option2': return localizations.aiQuestion6Option2;
      case 'aiQuestion6Option3': return localizations.aiQuestion6Option3;
      case 'aiQuestion6Option4': return localizations.aiQuestion6Option4;
      case 'aiQuestion6Option5': return localizations.aiQuestion6Option5;
      case 'aiQuestion7Option1': return localizations.aiQuestion7Option1;
      case 'aiQuestion7Option2': return localizations.aiQuestion7Option2;
      case 'aiQuestion7Option3': return localizations.aiQuestion7Option3;
      case 'aiQuestion7Option4': return localizations.aiQuestion7Option4;
      case 'aiQuestion7Option5': return localizations.aiQuestion7Option5;
      case 'aiQuestion8Option1': return localizations.aiQuestion8Option1;
      case 'aiQuestion8Option2': return localizations.aiQuestion8Option2;
      case 'aiQuestion8Option3': return localizations.aiQuestion8Option3;
      case 'aiQuestion8Option4': return localizations.aiQuestion8Option4;
      case 'aiQuestion8Option5': return localizations.aiQuestion8Option5;
      case 'aiQuestion9Option1': return localizations.aiQuestion9Option1;
      case 'aiQuestion9Option2': return localizations.aiQuestion9Option2;
      case 'aiQuestion9Option3': return localizations.aiQuestion9Option3;
      case 'aiQuestion9Option4': return localizations.aiQuestion9Option4;
      case 'aiQuestion9Option5': return localizations.aiQuestion9Option5;
      case 'aiQuestion10Option1': return localizations.aiQuestion10Option1;
      case 'aiQuestion10Option2': return localizations.aiQuestion10Option2;
      case 'aiQuestion10Option3': return localizations.aiQuestion10Option3;
      case 'aiQuestion10Option4': return localizations.aiQuestion10Option4;
      case 'aiQuestion10Option5': return localizations.aiQuestion10Option5;
      default: return key;
    }
  }

  // English fallback questions (research-based for age 2-3.5)
  static String _getEnglishQuestion(int num) {
    switch (num) {
      case 1: return 'Does {childName} respond when you call their name?';
      case 2: return 'How does {childName} react when their daily routine changes?';
      case 3: return 'When playing with toys, does {childName} switch between different activities or toys?';
      case 4: return 'How often does {childName} make eye contact when you talk to them?';
      case 5: return 'Does {childName} point to objects they want or find interesting?';
      case 6: return 'How does {childName} react to unexpected sounds or sensory experiences?';
      case 7: return 'Does {childName} imitate your actions or words?';
      case 8: return 'How does {childName} play with other children?';
      case 9: return 'Does {childName} show interest when you show them something?';
      case 10: return 'How does {childName} express their needs or wants?';
      default: return 'Question $num';
    }
  }

  static String _getEnglishCategory(int num) {
    switch (num) {
      case 1: return 'Social Responsiveness';
      case 2: return 'Cognitive Flexibility';
      case 3: return 'Cognitive Flexibility';
      case 4: return 'Social Communication';
      case 5: return 'Joint Attention';
      case 6: return 'Sensory Processing';
      case 7: return 'Social Learning';
      case 8: return 'Social Interaction';
      case 9: return 'Joint Attention';
      case 10: return 'Communication';
      default: return 'Category $num';
    }
  }

  static String _getEnglishOption(int questionNum, int optionNum) {
    // This is a simplified fallback - actual options should come from ARB files
    final options = [
      ['Always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
      ['Easily', 'With time', 'Shows distress', 'Very upset', 'Cannot adapt'],
      ['Easily', 'With prompting', 'Reluctant', 'Very difficult', 'Refuses'],
      ['Always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
      ['Frequently', 'Often', 'Occasionally', 'Rarely', 'Never'],
      ['Appropriately', 'Startles', 'Gets upset', 'Very distressed', 'Extreme distress'],
      ['Frequently', 'Often', 'Some', 'Rarely', 'Never'],
      ['Actively', 'Some interaction', 'Parallel play', 'Solitary', 'No interest'],
      ['Always', 'Usually', 'Sometimes', 'Rarely', 'Never'],
      ['Words clearly', 'Gestures and words', 'Mostly gestures', 'Pulls you', 'Cries/tantrums'],
    ];
    if (questionNum <= 10 && optionNum <= 5) {
      return options[questionNum - 1][optionNum - 1];
    }
    return 'Option $optionNum';
  }

  // Load Clinical Reflection questions (ages 3.5-6)
  static List<Map<String, dynamic>> getClinicalReflectionQuestions(BuildContext? context) {
    final questions = <Map<String, dynamic>>[];
    final localizations = context != null ? AppLocalizations.of(context) : null;
    
    final questionIds = ['attention', 'engagement', 'frustration', 'instructions', 'overall'];
    
    for (final id in questionIds) {
      String question;
      String label;
      if (localizations != null) {
        switch (id) {
          case 'attention':
            question = localizations.reflectionQuestionAttention;
            label = localizations.reflectionLabelAttention;
            break;
          case 'engagement':
            question = localizations.reflectionQuestionEngagement;
            label = localizations.reflectionLabelEngagement;
            break;
          case 'frustration':
            question = localizations.reflectionQuestionFrustration;
            label = localizations.reflectionLabelFrustration;
            break;
          case 'instructions':
            question = localizations.reflectionQuestionInstructions;
            label = localizations.reflectionLabelInstructions;
            break;
          case 'overall':
            question = localizations.reflectionQuestionOverall;
            label = localizations.reflectionLabelOverall;
            break;
          default:
            question = 'Question $id';
            label = 'Label $id';
        }
      } else {
        question = 'Question $id';
        label = 'Label $id';
      }
      
      questions.add({
        'id': id,
        'question': question,
        'label': label,
        'icon': _getIconForId(id),
      });
    }

    return questions;
  }

  // Load Manual Task questions (ages 2-3.5) - TODO: Add to ARB files if needed
  static List<Map<String, dynamic>> getManualTaskQuestions(BuildContext? context) {
    final tasks = <Map<String, dynamic>>[];
    // TODO: Implement with AppLocalizations when keys are added to ARB files
    for (int i = 1; i <= 5; i++) {
      tasks.add({
        'id': 'task$i',
        'title': 'Task $i Title',
        'description': 'Task $i Description',
        'label': 'Task $i Label',
        'task': 'Task $i Task',
        'category': 'Task $i Category',
        'icon': _getTaskIcon(i),
      });
    }
    return tasks;
  }

  // Load Behavioral Observation questions (ages 2-3.5) - TODO: Add to ARB files if needed
  static List<Map<String, dynamic>> getBehavioralObservationQuestions(BuildContext? context) {
    final observations = <Map<String, dynamic>>[];
    // TODO: Implement with AppLocalizations when keys are added to ARB files
    final ids = ['rule_switching', 'attention', 'frustration', 'perseveration', 'overall'];
    
    for (final id in ids) {
      observations.add({
        'id': id,
        'question': 'Question $id',
        'label': 'Label $id',
        'category': 'Category $id',
        'icon': _getBehavioralIcon(id),
      });
    }
    return observations;
  }

  // Get scale labels for reflection - TODO: Add to ARB files if needed
  static List<String> getScaleLabels(String type, BuildContext? context) {
    final labels = <String>[];
    // TODO: Implement with AppLocalizations when keys are added to ARB files
    for (int i = 1; i <= 5; i++) {
      labels.add('Scale $type $i');
    }
    return labels;
  }

  static IconData _getIconForId(String id) {
    switch (id) {
      case 'attention':
        return Icons.visibility;
      case 'engagement':
        return Icons.psychology;
      case 'frustration':
        return Icons.mood;
      case 'instructions':
        return Icons.hearing;
      case 'overall':
        return Icons.star;
      default:
        return Icons.help;
    }
  }

  static IconData _getTaskIcon(int taskNum) {
    switch (taskNum) {
      case 1:
        return Icons.swap_horiz;
      case 2:
        return Icons.change_circle;
      case 3:
        return Icons.block;
      case 4:
        return Icons.repeat;
      case 5:
        return Icons.swap_vert;
      default:
        return Icons.task;
    }
  }

  static IconData _getBehavioralIcon(String id) {
    switch (id) {
      case 'rule_switching':
        return Icons.psychology;
      case 'attention':
        return Icons.visibility;
      case 'frustration':
        return Icons.mood;
      case 'perseveration':
        return Icons.repeat;
      case 'overall':
        return Icons.star;
      default:
        return Icons.help;
    }
  }
}

