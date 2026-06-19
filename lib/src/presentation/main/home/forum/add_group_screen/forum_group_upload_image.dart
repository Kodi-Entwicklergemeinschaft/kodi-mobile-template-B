import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart';
import 'package:permission_handler/permission_handler.dart';

class ForumGroupImageUpload extends StatefulWidget {
  final String? image;
  final Function(String?) onChange;
  const ForumGroupImageUpload({
    super.key,
    this.image,
    required this.onChange,
  });
  @override
  State<ForumGroupImageUpload> createState() => _ForumGroupImageUploadState();
}
class _ForumGroupImageUploadState extends State<ForumGroupImageUpload>
    with WidgetsBindingObserver {
  final _picker = ImagePicker();
  String? _image;

  bool _awaitingSettingsAfterLimitedDialog = false;

  Future<PermissionStatus> _getPermissionStatus() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        return await Permission.storage.status;
      }
      return await Permission.photos.status;
    }
    return await Permission.photos.status;
  }

  Future<void> _showLimitedAccessDialog() async {
    if (!mounted) return;
    final t = Translate.of(context);
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(t.translate('Allow_full_access')),
        content: Text(t.translate('limited_photos_upload_hint')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.translate('cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.translate('open_settings')),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      _awaitingSettingsAfterLimitedDialog = true;
      await openAppSettings();
    }
  }

  void _showPermissionGrantedSnackBar() {
    if (!mounted) return;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Translate.of(context).translate('permission_granted_snackbar'),
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onPrimary),
        ),
        backgroundColor: cs.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ForumGroupImageUpload oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state != AppLifecycleState.resumed) return;
    if (!_awaitingSettingsAfterLimitedDialog || !mounted) return;
    _awaitingSettingsAfterLimitedDialog = false;

    final status = await _getPermissionStatus();
    if (status.isGranted) {
      _showPermissionGrantedSnackBar();
    }
  }
  @override
  Widget build(BuildContext context) {
    DecorationImage? decorationImage;
    if (_image != null) {
      decorationImage = DecorationImage(
        image: FileImage(
          File(_image!),
        ),
        fit: BoxFit.cover,
      );
    }
    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      image: decorationImage,
    );
    return InkWell(
      onTap: _uploadImage,
      child: Stack(
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(8),
            color: Theme.of(context).primaryColor,
            child: Container(
              decoration: decoration,
              alignment: Alignment.center,
              child: _buildContent(),
            ),
          ),
          Visibility(
            visible: _image != null,
            child: Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red[900],
                ),
                onPressed: () {
                  setState(() {
                    _image = null;
                    widget.onChange(null);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _uploadImage() async {
    try {
      final status = await _getPermissionStatus();
      PermissionStatus next = status;

      if (status.isDenied) {
        if (Platform.isAndroid) {
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          next = androidInfo.version.sdkInt <= 32
              ? await Permission.storage.request()
              : await Permission.photos.request();
        } else {
          next = await Permission.photos.request();
        }
      }

      if (!next.isGranted && !next.isLimited) {
        // denied path - do nothing
        return;
      }

      if (next.isLimited) {
        await _showLimitedAccessDialog();
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;
      if (!mounted) return;
      setState(() {
        _image = pickedFile.path;
        widget.onChange(_image); // Notify parent widget of the selected file.
      });
    } catch (e) {
      logError('Image Upload Permission Error', e);
    }
  }
  Widget? _buildContent() {
    String uniqueKey = UniqueKey().toString();
    if (_image == null && widget.image == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(Translate.of(context)
              .translate('upload_feature_image')), // Translated text
          const Icon(
            Icons.add,
            size: 24,
          ),
        ],
      );
    } else {
      if (_image == null && widget.image != null) {
        return SizedBox(
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl:
                "${Application.picturesURL}${widget.image!}?cacheKey=$uniqueKey",
            fit: BoxFit.cover,
          ),
        );
      }
      return const SizedBox();
    }
  }
}