import 'package:flutter/material.dart';
import '../services/localization_service.dart';

class TranslationHelper {
  // Load AI Bot questions with translations
  static List<Map<String, dynamic>> getAIBotQuestions(String childName) {
    final locale = LocalizationService.currentLocale.languageCode;
    final questions = <Map<String, dynamic>>[];

    for (int i = 1; i <= 10; i++) {
      final questionKey = 'ai_question_$i';
      final categoryKey = 'ai_category_$i';
      
      final question = LocalizationService.translate(questionKey).replaceAll('{childName}', childName);
      final category = LocalizationService.translate(categoryKey);
      
      final options = <Map<String, dynamic>>[];
      for (int j = 1; j <= 5; j++) {
        final optionKey = 'ai_question_${i}_option_$j';
        final optionText = LocalizationService.translate(optionKey);
        // Option 1 = value 5 (best), Option 5 = value 1 (worst)
        options.add({
          'text': optionText,
          'value': 6 - j,
        });
      }

      questions.add({
        'id': i,
        'question': question,
        'category': category,
        'options': options,
      });
    }

    return questions;
  }

  // Load Clinical Reflection questions (ages 3.5-6)
  static List<Map<String, dynamic>> getClinicalReflectionQuestions() {
    final questions = <Map<String, dynamic>>[];
    
    final questionIds = ['attention', 'engagement', 'frustration', 'instructions', 'overall'];
    
    for (final id in questionIds) {
      questions.add({
        'id': id,
        'question': LocalizationService.translate('reflection_question_$id'),
        'label': LocalizationService.translate('reflection_label_$id'),
        'icon': _getIconForId(id),
      });
    }

    return questions;
  }

  // Load Manual Task questions (ages 2-3.5)
  static List<Map<String, dynamic>> getManualTaskQuestions() {
    final tasks = <Map<String, dynamic>>[];
    
    for (int i = 1; i <= 5; i++) {
      tasks.add({
        'id': 'task$i',
        'title': LocalizationService.translate('manual_task_${i}_title'),
        'description': LocalizationService.translate('manual_task_${i}_description'),
        'label': LocalizationService.translate('manual_task_${i}_label'),
        'task': LocalizationService.translate('manual_task_${i}_task'),
        'category': LocalizationService.translate('manual_task_${i}_category'),
        'icon': _getTaskIcon(i),
      });
    }

    return tasks;
  }

  // Load Behavioral Observation questions (ages 2-3.5)
  static List<Map<String, dynamic>> getBehavioralObservationQuestions() {
    final observations = <Map<String, dynamic>>[];
    
    final ids = ['rule_switching', 'attention', 'frustration', 'perseveration', 'overall'];
    
    for (final id in ids) {
      observations.add({
        'id': id,
        'question': LocalizationService.translate('behavioral_question_$id'),
        'label': LocalizationService.translate('behavioral_label_$id'),
        'category': LocalizationService.translate('behavioral_category_$id'),
        'icon': _getBehavioralIcon(id),
      });
    }

    return observations;
  }

  // Get scale labels for reflection
  static List<String> getScaleLabels(String type) {
    final labels = <String>[];
    for (int i = 1; i <= 5; i++) {
      labels.add(LocalizationService.translate('scale_${type}_$i'));
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

