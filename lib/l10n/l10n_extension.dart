import 'package:flutter/widgets.dart';
import 'package:levo/l10n/generated/app_localizations.dart';
export 'package:levo/l10n/generated/app_localizations.dart';

/// Extension to quickly access generated localizations from the BuildContext.
extension BuildContextL10n on BuildContext {
  /// Returns the current locale's generated [AppLocalizations].
  AppLocalizations get l10n => AppLocalizations.of(this);
}
