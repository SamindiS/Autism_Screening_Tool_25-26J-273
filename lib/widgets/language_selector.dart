import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/language_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      tooltip: 'Select Language',
      onSelected: (String languageCode) async {
        await languageProvider.setLocale(Locale(languageCode));
      },
      itemBuilder: (BuildContext context) {
        return languageProvider.supportedLanguages.map((lang) {
          final isSelected = languageProvider.locale.languageCode == lang['code'];
          return PopupMenuItem<String>(
            value: lang['code'],
            child: Row(
              children: [
                if (isSelected)
                  const Icon(Icons.check, color: Colors.teal, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Text(
                  lang['native']!,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.teal : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${lang['name']})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}


