// ignore_for_file: unused_local_variable, unused_catch_stack, use_build_context_synchronously

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:your_app_name/src/data/repository/forum_repository.dart';
import 'package:your_app_name/src/data/repository/list_repository.dart';
import 'package:your_app_name/src/presentation/main/add_listing/cubit/add_listing_cubit.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/multiple_gesture_detector.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loggy/loggy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

enum UploadImageType { circle, square }

class AppUploadImage extends StatefulWidget {
  final String? title;
  final String? image;
  final Function(List<File>) onChange;
  final VoidCallback? onDelete;
  final UploadImageType type;
  final bool profile;
  final bool forumGroup;

  const AppUploadImage({
    super.key,
    this.title,
    this.image,
    required this.onChange,
    this.type = UploadImageType.square,
    required this.profile,
    required this.forumGroup,
    this.onDelete,
  });

  @override
  State<AppUploadImage> createState() => _AppUploadImageState();
}

class _AppUploadImageState extends State<AppUploadImage>
    with WidgetsBindingObserver {
  final _picker = ImagePicker();
  File? _file;
  bool isImageUploaded = false;
  bool showAction = false;
  String title = '';
  bool isPermanentlyDenied = false;
  List<File> images = [];
  List<XFile> resultList = <XFile>[];
  List<File> selectedFiles = [];
  List<XFile> selectedAssets = [];
  String? image;
  bool _autoScale = false;

  /// After user opens Settings from limited-access dialog, show snackbar when full access is granted.
  bool _awaitingSettingsAfterLimitedDialog = false;

  @override
  void initState() {
    image = widget.image;
    if (image != null) {
      if (!image!.contains('Defaultimage')) {
        _file = File(image!);
      }
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_awaitingSettingsAfterLimitedDialog || !mounted) return;
    _awaitingSettingsAfterLimitedDialog = false;
    Future<void>.delayed(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      final s = await _photosLibraryStatus();
      if (s.isGranted && !s.isLimited) {
        _showPermissionGrantedSnackBar();
      }
    });
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

  /// Limited library access: do not open gallery until user grants full access in Settings.
  Future<void> _showLimitedAccessDialog() async {
    if (!mounted) return;
    final t = Translate.of(context);
    final openSettings = await showDialog<bool>(
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
    if (openSettings == true) {
      _awaitingSettingsAfterLimitedDialog = true;
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    DecorationImage? decorationImage;
    BorderType borderType = BorderType.RRect;
    Widget circle = Container();
    if (widget.image != null) {
      if (!widget.image!.contains('pdf')) {
        image = widget.image;
        _file = File(image!);
      }
    }
    if (_file != null && !_file!.path.contains(".pdf")) {
      decorationImage = DecorationImage(
        image: FileImage(
          _file!,
        ),
        fit: _autoScale ? BoxFit.cover : BoxFit.contain,
      );
    }

    BoxDecoration decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      image: decorationImage,
    );

    if (widget.type == UploadImageType.circle) {
      borderType = BorderType.Circle;
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        image: decorationImage,
      );
    }

    return InkWell(
      onTap: widget.profile
          ? _uploadImage
          : selectedAssets.length > 1
          ? _selectImagesWithScaleChoice
          : showChooseFileTypeDialog,
      child: SafeArea(
        child: Stack(
          children: [
            DottedBorder(
              borderType: borderType,
              radius: const Radius.circular(8),
              color: Theme.of(context).primaryColor,
              child: Container(
                decoration: decoration,
                alignment: Alignment.center,
                child: _buildContent(),
              ),
            ),
            if (!widget.forumGroup && widget.onDelete!=null)
              Visibility(
                visible: _file != null,
                child: Positioned(
                  top: -10,
                  right: -10,
                  child: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[900],
                    ),
                    onPressed: () {
                      widget.onDelete!();
                      setState(() {
                        image = null;
                        _file = null;
                        images.clear();
                        selectedAssets.clear();
                        context.read<AddListingCubit>().clearAssets();
                        widget.onChange([]);
                      });
                    },
                  ),
                ),
              ),
            Positioned.fill(child: circle),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    PermissionStatus statusImage;
    if (await Permission.storage.isGranted) {
      statusImage = PermissionStatus.granted;
    } else {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          statusImage = await Permission.storage.status;
          statusImage = await Permission.storage.request();
        } else {
          statusImage = await Permission.photos.request();
          statusImage = await Permission.photos.status;
        }
      } else {
        statusImage = await Permission.photos.request();
        statusImage = await Permission.photos.status;
      }
    }

    if (statusImage.isLimited) {
      await _showLimitedAccessDialog();
      return;
    }

    if (showAction) {
      setState(() {
        showAction = false;
      });
      return;
    }
    try {
      if (Platform.isIOS) {
        if (statusImage.isDenied) return;

        if (statusImage.isPermanentlyDenied) {
          await openAppSettings();
          return;
        }

        if (statusImage.isLimited) {
          await _showLimitedAccessDialog();
          return;
        }

        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
        );

        if (pickedFile == null) return;
        if (!mounted) return;

        final file = File(pickedFile.path);

        setState(() {
          isImageUploaded = false;
          _file = file;
        });

        widget.onChange([file]);

        final profile = widget.profile;
        final forumGroup = widget.forumGroup;

        if (!profile) {
          await ListRepository.uploadImage(_file!, profile);
        }

        if (forumGroup) {
          await ForumRepository.uploadImage(_file!, forumGroup);
        } else if (profile) {
          final response = await ListRepository.uploadImage(_file!, profile);

          if (response!.data['status'] == 'success') {
            setState(() {
              isImageUploaded = true;
            });

            // ✅ Use local file (safe)
            widget.onChange([_file!]);

          } else {
            logError('Image Upload Permission Error', response);
          }
        }
      }
      // if(Platform.isIOS) {
      //     final status = await Permission.photos.request();
      //
      //     if (status.isDenied) return;
      //
      //     if (status.isPermanentlyDenied) {
      //       await openAppSettings();
      //       return;
      //     }
      //
      //     final pickedFile = await _picker.pickImage(
      //       source: ImageSource.gallery,
      //     );
      //
      //     if (pickedFile == null) return;
      //     if (!mounted) return;
      //
      //     final file = File(pickedFile.path);
      //
      //     setState(() {
      //       isImageUploaded = false;
      //       _file = file;
      //     });
      //
      //     widget.onChange([file]);
      //
      //     final profile = widget.profile;
      //     final forumGroup = widget.forumGroup;
      //
      //     if (!profile) {
      //       await ListRepository.uploadImage(_file!, profile);
      //     }
      //
      //     if (forumGroup) {
      //       await ForumRepository.uploadImage(_file!, forumGroup);
      //     } else if (profile) {
      //       final response = await ListRepository.uploadImage(_file!, profile);
      //       if (response!.data['status'] == 'success') {
      //         setState(() {
      //           isImageUploaded = true;
      //         });
      //         final item = response.data['data']?['image'];
      //         widget.onChange([File(item)]);
      //       } else {
      //         logError('Image Upload Permission Error', response);
      //       }
      //     }
      //   }
      else {
        statusImage = PermissionStatus.granted;
        final pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
        );
        if (pickedFile == null) return;
        if (!mounted) return;
        setState(() {
          isImageUploaded = false;
          _file = File(pickedFile.path);
          if (_file != null) {
            widget.onChange([_file!]);
          }
        });
        final profile = widget.profile;
        final forumGroup = widget.forumGroup;

        if (!profile) {
          await ListRepository.uploadImage(_file!, profile);
        }
        if (forumGroup) {
          await ForumRepository.uploadImage(_file!, forumGroup);
        } else if (profile) {
          final response = await ListRepository.uploadImage(_file!, profile);
          if (response!.data['status'] == 'success') {
            setState(() {
              isImageUploaded = true;
            });
            final item = response.data['data']?['image'];
            widget.onChange([File(item)]);
          } else {
            logError('Image Upload Permission Error', response);
          }
        }
      }
    } catch (e, stackTrace) {
      logError('Image Upload Permission Error', e);
    }
  }

  Future<void> showChooseFileTypeDialog() async {
    PermissionStatus status;
    if (Platform.isIOS) {
      // On iOS, Permission.storage is not a real permission — request photos directly
      status = await Permission.photos.request();
      status = await Permission.photos.status;
    } else if (await Permission.storage.isGranted) {
      status = PermissionStatus.granted;
    } else {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        status = await Permission.storage.request();
      } else {
        status = await Permission.photos.request();
        status = await Permission.photos.status;
      }
    }

    if (!mounted) return;
    // isLimited means user chose "Selected Photos" — pickMultiImage still works
    if (status.isGranted || status.isLimited) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SimpleDialog(
              title: Text(Translate.of(context).translate('Choose_File_Type')),
              children: [
                SimpleDialogOption(
                  onPressed: () async {
                    FilePickerResult? result =
                    await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null) {
                      final File pdfFile = File(result.files.single.path!);
                      int pdfSizeInBytes = await pdfFile.length();
                      double pdfSizeInMB = pdfSizeInBytes / (1024 * 1024);
                      logError('PDF Size', pdfSizeInMB);

                      if (pdfSizeInMB > 20) {
                        if (!mounted) return;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              Translate.of(context).translate(
                                'file_size_exceed',
                              ),
                            ),
                            content: Text(
                              Translate.of(context).translate(
                                'select_small_file',
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }
                      widget.onChange([]);
                      setState(() {
                        _file = null;
                        images.clear();
                        widget.onChange(images);
                        _file = File(result.files.single.path!);
                        isImageUploaded = false;
                        selectedAssets.clear();
                      });
                      widget.onChange(images);
                      final profile = widget.profile;
                      if (!profile) {
                        await ListRepository.uploadPdf(_file!);
                      }
                      if (!mounted) return;
                      Navigator.pop(context);
                      context.read<AddListingCubit>().clearAssets();
                    }
                  },
                  child: const ListTile(
                    leading: Icon(Icons.picture_as_pdf),
                    title: Text('PDF'),
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () async {
                    if (Platform.isIOS) {
                      PermissionStatus photosStatus =
                          await Permission.photos.status;
                      // Request if not yet asked
                      if (photosStatus.isDenied) {
                        photosStatus = await Permission.photos.request();
                      }
                      if (photosStatus.isGranted || photosStatus.isLimited) {
                        if (!mounted) return;
                        Navigator.pop(context);
                        await _showScaleChoiceDialog();
                        if (!mounted) return;
                        setState(() {
                          selectedAssets = context
                              .read<AddListingCubit>()
                              .getSelectedAssets();
                        });
                        await selectImages();
                        final profile = widget.profile;
                        if (!profile) {
                          if (_file != null) {
                            await ListRepository.uploadImage(_file!, profile);
                          }
                        } else {
                          final response =
                          await ListRepository.uploadImage(_file!, profile);
                          if (response!.data['status'] == 'success') {
                            setState(() {
                              isImageUploaded = true;
                            });
                          }
                        }
                      } else if (photosStatus.isPermanentlyDenied) {
                        await openAppSettings();
                      }
                    } else {
                      if (!mounted) return;
                      Navigator.pop(context);
                      await _showScaleChoiceDialog();
                      if (!mounted) return;
                      selectImages();
                    }
                  },
                  child: ListTile(
                    leading: const Icon(Icons.image),
                    title: Text(Translate.of(context).translate('images')),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Widget? _buildContent() {
    String uniqueKey = UniqueKey().toString();
    if (image != null && _file == null) {
      if (image!.contains(".pdf")) {
        return SizedBox(
            width: double.infinity,
            height: 400,
            child: RawGestureDetector(
              gestures: {
                AllowMultipleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                    AllowMultipleGestureRecognizer>(
                      () => AllowMultipleGestureRecognizer(),
                      (AllowMultipleGestureRecognizer instance) {
                    instance.onTap = () => showChooseFileTypeDialog();
                  },
                )
              },
              child: const PDF().cachedFromUrl(
                "${Application.picturesURL}${image!}?cacheKey=$uniqueKey",
                placeholder: (progress) => Center(child: Text('$progress %')),
                errorWidget: (error) => Center(child: Text(error.toString())),
              ),
            ));
      }
    }
    else if (image != null &&
        image!.contains('profilePic') &&
        !widget.forumGroup) {
      return SizedBox(
          width: double.infinity,
          height: 400,
          child: RawGestureDetector(
              gestures: {
                AllowMultipleGestureRecognizer:
                GestureRecognizerFactoryWithHandlers<
                    AllowMultipleGestureRecognizer>(
                      () => AllowMultipleGestureRecognizer(),
                      (AllowMultipleGestureRecognizer instance) {
                    instance.onTap = () => showChooseFileTypeDialog();
                  },
                )
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(200),
                child: CachedNetworkImage(
                  imageUrl:
                  "${Application.picturesURL}${image!}?cacheKey=$uniqueKey",
                  fit: BoxFit.contain,
                ),
              )));
    } else if (image != null && widget.forumGroup) {
      return SizedBox(
          width: double.infinity,
          height: 400,
          child: RawGestureDetector(
            gestures: {
              AllowMultipleGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                  AllowMultipleGestureRecognizer>(
                    () => AllowMultipleGestureRecognizer(),
                    (AllowMultipleGestureRecognizer instance) {
                  instance.onTap = () => showChooseFileTypeDialog();
                },
              )
            },
            child: CachedNetworkImage(
              imageUrl:
              "${Application.picturesURL}${image!}?cacheKey=$uniqueKey",
              fit: BoxFit.contain,
            ),
          ));
    }
    switch (widget.type) {
      case UploadImageType.circle:
        if (_file == null) {
          return const Icon(
            Icons.add,
            size: 18,
          );
        }

        if (isImageUploaded) {
          return Icon(
            Icons.check_circle,
            size: 18,
            color: Theme.of(context).primaryColor,
          );
        }
        return Container();

      default:
        if (_file == null) {
          Widget title = Container();
          if (widget.title != null) {
            title = Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              title,
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor,
                ),
                child: const Icon(
                  Icons.add,
                  size: 18,
                ),
              ),
            ],
          );
        } else {
          if (isImageUploaded) {
            return Container(
              alignment: Alignment.topRight,
              child: Icon(
                Icons.check_circle,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (_file?.path != null) {
            if (_file!.path.contains(".pdf")) {
              return RawGestureDetector(
                gestures: {
                  AllowMultipleGestureRecognizer:
                  GestureRecognizerFactoryWithHandlers<
                      AllowMultipleGestureRecognizer>(
                        () => AllowMultipleGestureRecognizer(), //constructor
                        (AllowMultipleGestureRecognizer instance) {
                      instance.onTap = () => showChooseFileTypeDialog();
                    },
                  )
                },
                child: PDFView(
                  key: UniqueKey(),
                  filePath: _file?.path,
                  fitPolicy: FitPolicy.WIDTH,
                  onPageChanged: (page, total) {
                    // Do something when the page changes (optional)
                  },
                ),
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 18,
                    ),
                  ),
                ],
              );
            }
          }
        }
    }
    return null;
  }

  Future<PermissionStatus> _photosLibraryStatus() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        return await Permission.storage.status;
      }
      return await Permission.photos.status;
    }
    return await Permission.photos.status;
  }

  Future<void> _showScaleChoiceDialog() async {
    if (!mounted) return;
    final choice = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(Translate.of(context).translate('image_upload_option')),
        content: Text(Translate.of(context).translate('image_upload_option_desc')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(Translate.of(context).translate('auto_scale')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(Translate.of(context).translate('original')),
          ),
        ],
      ),
    );
    if (choice != null && mounted) {
      setState(() {
        _autoScale = choice;
      });
    }
  }

  Future<void> _selectImagesWithScaleChoice() async {
    await _showScaleChoiceDialog();
    if (!mounted) return;
    await selectImages();
  }

  Future<void> selectImages() async {
    if (!mounted) return;

    try {
      setState(() {
        selectedAssets = context.read<AddListingCubit>().getSelectedAssets();
      });

      final picked = await _pickImages(limit: 8 - selectedAssets.length);
      if (picked.isEmpty) return;

      int itemsToPick = 8 - selectedAssets.length;
      if (itemsToPick <= 0){
        _showSizeExceededDialog();
        return;
      } // Already at max capacity

      List<XFile> newPickedAssets = picked.sublist(0, picked.length < itemsToPick ? picked.length : itemsToPick);
      List<XFile> potentialSelection = List.from(selectedAssets)..addAll(newPickedAssets);

      if (await _isValidSelection(potentialSelection)) {
        final validImages = await _validateAndCropImages(newPickedAssets);
        if (validImages.isEmpty) return;
        List<XFile> totalImages = List.from(selectedAssets)..addAll(validImages);
        await _saveAndDisplayImages(totalImages);

      }
      else{
        return;
      }
    } catch (e) {
      logError('Error Selecting Multiple Images', e);
      _showSizeExceededDialog(description: "max_images_selected");
    }
  }


  Future<List<XFile>> _pickImages({required int limit}) async {
    final resultList = await _picker.pickMultiImage(limit: limit);
    if (resultList.isEmpty) return [];

    return resultList.length > limit
        ? resultList.sublist(0, limit)
        : resultList;
  }

  Future<List<XFile>> _validateAndCropImages(List<XFile> files) async {
    List<XFile> validList = [];
    double totalSizeMB = 0;

    for (XFile asset in files) {
      final file = File(asset.path);
      final sizeMB = (await file.length()) / (1024 * 1024);

      if ((totalSizeMB + sizeMB) > 20) {
        await _showSizeExceededDialog();
        break;
      }

      totalSizeMB += sizeMB;
      validList.add(asset);

      if (validList.length >= 8) break;
    }

    return validList;
  }

  Future<void> _saveAndDisplayImages(List<XFile> files) async {
    if (!mounted) return;

    final tempDir = await getTemporaryDirectory();
    final cubit = context.read<AddListingCubit>();

    cubit.clearAssets();
    images.clear();

    for (XFile file in files) {
      final filePath = '${tempDir.path}/${file.name}';
      final savedFile = await File(filePath).writeAsBytes(await file.readAsBytes());
      images.add(savedFile);
    }

    _file = _resolveInitialFile();
    cubit.saveAssets(files);

    setState(() {
      selectedAssets = cubit.getSelectedAssets();
      widget.onChange(images);
    });
  }

  File? _resolveInitialFile() {
    if (image == null || (image!.contains('Defaultimage') || image!.contains('pdf'))) {
      return images.isNotEmpty ? File(images[0].path) : null;
    }
    return File(image!);
  }

  Future<void> _showSizeExceededDialog({String? title, String? description}) async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Translate.of(context).translate(title??'image_size_exceed')),
        content: Text(Translate.of(context).translate(description??'select_small_images')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool> _isValidSelection(List<XFile> assets) async {
    const double maxTotalSizeMB = 20.0;
    const int maxFileCount = 8;

    double totalSizeMB = 0;

    for (int i = 0; i < assets.length && i < maxFileCount; i++) {
      final file = File(assets[i].path);
      final sizeMB = (await file.length()) / (1024 * 1024);

      totalSizeMB += sizeMB;

      if (totalSizeMB > maxTotalSizeMB) {
        await _showSizeExceededDialog();
        return false;
      }
    }

    return true;
  }


}
