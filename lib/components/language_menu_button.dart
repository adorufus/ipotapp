import 'package:flutter/material.dart';
import 'package:ipotapp/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/locale_provider.dart';
import '../utils/color_utils.dart';

class LanguageMenuButton extends ConsumerWidget {
  const LanguageMenuButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate_outlined, color: AppColors.neutral),
      tooltip: l10n.languageMenuTooltip,
      onSelected: (value) {
        switch (value) {
          case 'system':
            ref.read(appLocaleProvider.notifier).setLocale(null);
            break;
          case 'en':
            ref.read(appLocaleProvider.notifier).setLocale(const Locale('en'));
            break;
          case 'zh':
            ref.read(appLocaleProvider.notifier).setLocale(const Locale('zh'));
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'system', child: Text(l10n.languageSystem)),
        PopupMenuItem(value: 'en', child: Text(l10n.languageEnglish)),
        PopupMenuItem(value: 'zh', child: Text(l10n.languageChinese)),
      ],
    );
  }
}
