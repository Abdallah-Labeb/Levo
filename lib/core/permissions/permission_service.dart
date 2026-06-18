import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:levo/app/theme/app_colors.dart';
import 'package:levo/app/theme/app_dimensions.dart';
import 'package:levo/app/theme/app_typography.dart';
import 'package:levo/core/widgets/tactile_button.dart';
import 'package:levo/l10n/l10n_extension.dart';

/// A service to centralize permission requests and dialog handling for Levo.
/// Follows lazy-request guidelines, showing a rationale dialog for denied permissions,
/// and an "Open Settings" dialog for permanently denied permissions.
class PermissionService {
  const PermissionService();

  /// Checks and requests microphone permission, showing appropriate UI dialogs if needed.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> checkAndRequestMicrophone(BuildContext context) async {
    final l10n = context.l10n;
    return _checkAndRequest(
      context: context,
      permission: Permission.microphone,
      title: l10n.permissionMicTitle,
      body: l10n.permissionMicBodyDialog,
      permanentlyDeniedBody: l10n.permissionMicDeniedPermanentlyBody,
    );
  }

  /// Checks and requests camera permission, showing appropriate UI dialogs if needed.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> checkAndRequestCamera(BuildContext context) async {
    final l10n = context.l10n;
    return _checkAndRequest(
      context: context,
      permission: Permission.camera,
      title: l10n.permissionCameraTitle,
      body: l10n.permissionCameraBodyDialog,
      permanentlyDeniedBody: l10n.permissionCameraDeniedPermanentlyBody,
    );
  }

  /// Checks and requests location permission, showing appropriate UI dialogs if needed.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> checkAndRequestLocation(BuildContext context) async {
    final l10n = context.l10n;
    return _checkAndRequest(
      context: context,
      permission: Permission.locationWhenInUse,
      title: l10n.permissionLocationTitle,
      body: l10n.permissionLocationBodyDialog,
      permanentlyDeniedBody: l10n.permissionLocationDeniedPermanentlyBody,
    );
  }

  /// Helper to handle the common permission request workflow:
  /// - If already granted: return true
  /// - If denied: show explanation dialog first, then request on allow.
  /// - If permanently denied: show open settings dialog.
  Future<bool> _checkAndRequest({
    required BuildContext context,
    required Permission permission,
    required String title,
    required String body,
    required String permanentlyDeniedBody,
  }) async {
    final status = await permission.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      if (!context.mounted) return false;

      final bool? allowed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final l10n = dialogContext.l10n;
          return AlertDialog(
            backgroundColor: AppColors.kSurface,
            title: Text(
              title,
              style: AppTypography.kTitleL,
            ),
            content: Text(
              body,
              style: AppTypography.kBody,
            ),
            actions: [
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () => Navigator.pop(dialogContext, false),
                text: l10n.commonCancel,
              ),
              const SizedBox(width: AppDimensions.space8),
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                text: l10n.commonAllow,
              ),
            ],
          );
        },
      );

      if (allowed == true) {
        final result = await permission.request();
        return result.isGranted;
      }
      return false;
    }

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final l10n = dialogContext.l10n;
          return AlertDialog(
            backgroundColor: AppColors.kSurface,
            title: Text(
              l10n.permissionPermanentlyDeniedTitle,
              style: AppTypography.kTitleL,
            ),
            content: Text(
              permanentlyDeniedBody,
              style: AppTypography.kBody,
            ),
            actions: [
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () => Navigator.pop(dialogContext),
                text: l10n.commonCancel,
              ),
              const SizedBox(width: AppDimensions.space8),
              TactileButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingM,
                  vertical: AppDimensions.paddingS,
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await openAppSettings();
                },
                text: l10n.commonButtonOpenSettings,
              ),
            ],
          );
        },
      );
      return false;
    }

    // For any other status (restricted, limited, etc.), request it
    final result = await permission.request();
    return result.isGranted;
  }
}
