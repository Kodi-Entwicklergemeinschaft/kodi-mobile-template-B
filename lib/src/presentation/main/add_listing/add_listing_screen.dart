import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_delta_from_html/parser/html_to_delta.dart';
import 'package:your_app_name/src/data/model/model_product.dart';
import 'package:your_app_name/src/data/model/model_recurring_rule.dart';
import 'package:your_app_name/src/data/remote/api/matomo_api.dart';
import 'package:your_app_name/src/presentation/cubit/app_bloc.dart';
import 'package:your_app_name/src/presentation/main/add_listing/multiple_selection_city.dart';
import 'package:your_app_name/src/presentation/widget/app_button.dart';
import 'package:your_app_name/src/presentation/widget/app_picker_item.dart';
import 'package:your_app_name/src/presentation/widget/app_text_input.dart';
import 'package:your_app_name/src/presentation/widget/app_upload_image.dart';
import 'package:your_app_name/src/utils/common.dart';
import 'package:your_app_name/src/utils/configs/application.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/configs/routes.dart';
import 'package:your_app_name/src/utils/datetime.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:your_app_name/src/utils/validate.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loggy/loggy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:your_app_name/src/presentation/main/add_listing/add_listing_success/add_recurring_event_widget.dart';

import 'cubit/add_listing_cubit.dart';

class AddListingScreen extends StatefulWidget {
  final ProductModel? item;
  final bool isNewList;
  final int? preselectCategory;
  final int? preselectSubCategory;

  const AddListingScreen(
      {super.key,
      this.item,
      required this.isNewList,
      required this.preselectCategory,
      required this.preselectSubCategory});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final regInt = RegExp('[^0-9]');
  final _textTitleController = TextEditingController();
  final _textTagsController = TextEditingController();
  final _textAddressController = TextEditingController();
  final _textPhoneController = TextEditingController();
  final _textFaxController = TextEditingController();
  final _textEmailController = TextEditingController();
  final _textWebsiteController = TextEditingController(text: 'https://');
  final _textStatusController = TextEditingController();
  final _textPriceController = TextEditingController();
  final _textPriceMinController = TextEditingController();
  final _textPriceMaxController = TextEditingController();
  final _textPlaceController = TextEditingController();
  quill.QuillController _quillController = quill.QuillController.basic();

  final _focusTitle = FocusNode();
  final _focusContent = FocusNode();
  final _focusAddress = FocusNode();
  final _focusZipCode = FocusNode();
  final _focusPhone = FocusNode();
  final _focusFax = FocusNode();
  final _focusEmail = FocusNode();
  final _focusWebsite = FocusNode();
  final _focusPrice = FocusNode();
  String? _errorTitle;
  String? _errorContent;
  String? _errorPhone;
  String? _errorWebsite;
  String? _errorStatus;
  String? _errorSDate;
  String? _errorCategory;
  String? _errorCity;
  int? cityId;
  int? statusId;
  int? villageId;
  int? categoryId;
  int? subCategoryId;
  List listCity = [];
  List listVillage = [];
  List listCategory = [];
  List listSubCategory = [];

  String? _expiryDate;
  String? _startDate;
  String? _endDate;
  TimeOfDay? _expiryTime;
  String? _createdAt;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isExpiryDateEnabled = true;
  String? selectedVillage;
  String? selectedCategory;
  String? selectedSubCategory;
  bool isImageChanged = false;
  bool isLoading = false;
  List<File>? selectedImages = [];
  List<File> downloadedImages = [];
  List<String> _selectedCities = [];

  bool _isRecurringDayEvent = false;

  late int? currentCity;
  int? _preselectCategory;
  int? _preselectSubCategory;
  List<int> _recurringSchedules = [];
  int _nextRecurringId = 1;
  bool setAddMoreRuleButtonVisibility = false;
  List<RecurrenceRuleModel> prefilledRecurringRules = [];
  bool isEmptyRepeatUntilDate = false;
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );
    final recurrenceRuleMap =
        context.read<AddListingCubit>().recurrenceRuleModelMap;
    if (recurrenceRuleMap.isNotEmpty) {
      context.read<AddListingCubit>().clearRecurrenceRule();
    }
    _preselectCategory = widget.preselectCategory;
    _preselectSubCategory = widget.preselectSubCategory;
    _onProcess();
    if (widget.item != null) {
      _isExpiryDateEnabled = (widget.item?.expiryDate.isNotEmpty == true);
      _loadHtmlToQuill();
      if (widget.item?.recurrenceRules != null &&
          widget.item!.recurrenceRules!.isNotEmpty) {
        prefilledRecurringRules = widget.item!.recurrenceRules!;
        _isRecurringDayEvent = true;
      }
    } else if (widget.item == null) {
      _setDefaultExpiryDate();
      _isExpiryDateEnabled = true;
    }
    if(prefilledRecurringRules.isEmpty) {
      _addRecurringSchedule();
    } else {
      for (final rule in prefilledRecurringRules) {
        _addRecurringSchedule(
          freq: rule.freq,
          interval: rule.interval,
          weekdays: rule.weekdays,
          start: rule.start,
          end: rule.end,
          repeatUntil: rule.repeatUntil,
          exceptionDates:
          rule.exceptions?.map((e) => e.date).toList(),
          dayOrdinal: rule.dayOrdinal,
          // isPrefilledRule: true,
        );
      }
    }
  }

  void _loadHtmlToQuill() {
    final htmlString = widget.item?.description ?? "";

    if (htmlString.isNotEmpty) {
      final deltaOps = HtmlToDelta().convert(htmlString).toList();
      Delta delta = Delta.fromOperations(deltaOps);

      setState(() {
        _quillController = QuillController(
          document: Document.fromDelta(delta),
          selection: const TextSelection.collapsed(offset: 0),
        );
      });
    }
  }

  void _setDefaultExpiryDate() {
    if (widget.item?.expiryDate == null || widget.item?.expiryDate == "") {
      DateTime now = DateTime.now();
      DateTime twoWeeksFromNow = now.add(const Duration(days: 14));
      setState(() {
        _expiryDate = DateFormat('yyyy-MM-dd').format(twoWeeksFromNow);
        _expiryTime = const TimeOfDay(hour: 0, minute: 0);
      });
    }
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    currentCity = await context.read<AddListingCubit>().getCurrentCityId();
    _onProcess();
  }

  String clearedText(String text) {
    var document = parse(text.replaceAll("<br>", "\n"));
    return document.body!.text;
  }

  @override
  void dispose() {
    _textTitleController.dispose();
    _textTagsController.dispose();
    _textAddressController.dispose();
    _textPhoneController.dispose();
    _textFaxController.dispose();
    _textEmailController.dispose();
    _textWebsiteController.dispose();
    _textStatusController.dispose();
    _textPriceController.dispose();
    _textPriceMinController.dispose();
    _textPriceMaxController.dispose();
    _focusTitle.dispose();
    _focusContent.dispose();
    _focusAddress.dispose();
    _focusZipCode.dispose();
    _focusPhone.dispose();
    _focusFax.dispose();
    _focusEmail.dispose();
    _focusWebsite.dispose();
    _focusPrice.dispose();
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String textTitle = Translate.of(context).translate('add_new_listing');
    String textAction = Translate.of(context).translate('add');
    if (widget.item != null) {
      textTitle = Translate.of(context).translate('update_listing');
      textAction = Translate.of(context).translate('update');
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<AddListingCubit>().clearAssets();
              Navigator.pop(context);
            },
          ),
          title: Text(textTitle),
          actions: [
            AppButton(
              textAction,
              onPressed: _onSubmit,
              type: ButtonType.text,
            )
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              _buildContent(),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _onProcess() async {
    setState(() {
      isLoading=true;
    });
    final cubit = context.read<AddListingCubit>();

    final citiesResponse = await cubit.loadCities();
    final categoryResponse = await cubit.loadCategory();
    if (!mounted) return;

    final categories = categoryResponse?.data ?? [];
    listCategory = categories;

    String? selectedCategoryLocal;
    if (categories.isNotEmpty) {
      selectedCategoryLocal = categories.first['name'];

      if (_preselectCategory != null) {
        selectedCategoryLocal = categories.firstWhere(
                (c) => c['id'] == _preselectCategory, orElse: () => null)?['name'] ??
            selectedCategoryLocal;
      }

      if (mounted) {
        final subCategoryResponse =
            await cubit.loadSubCategory(selectedCategoryLocal);
        final subCategories = subCategoryResponse?.data ?? [];
        listSubCategory = subCategories;

        if (subCategories.isNotEmpty) {
          selectedSubCategory = subCategories.last['name'];

          if (_preselectSubCategory != null) {
            selectedSubCategory = subCategories.firstWhere(
                    (s) => s['id'] == _preselectSubCategory,
                    orElse: () => null)?['name'] ??
                selectedSubCategory;
          }
        }
      }
    }

    final cities = citiesResponse?.data ?? [];
    listCity = cities;
    if (currentCity != null && currentCity != 0) {
      final city =
          cities.firstWhere((c) => c['id'] == currentCity, orElse: () => null);
      if (city != null) _selectedCities.add(city['name']);
    }

    selectedCategory = selectedCategoryLocal;

    if (selectedCategory?.toLowerCase() == "news" || selectedCategory == null) {
      await selectSubCategoryOnLaunch(selectedCategory?.toLowerCase());
    }

    if (widget.item != null) {
      await _populateItemData(widget.item!);
    } else {
      if (selectedCategory?.toLowerCase() == "news" ||
          selectedCategory == null) {
        final subCategoryResponse = await cubit.loadSubCategory(
          Translate.of(context)
              .translate(
                _getCategoryTranslation(categories.first['id']),
              )
              .toLowerCase(),
        );
        setState(() {
          listSubCategory = subCategoryResponse?.data ?? [];
        });
      }
    }
    setState(() {
      isLoading=false;
    });

  }

  Future<void> _populateItemData(ProductModel item) async {
    statusId = item.statusId;
    _textTitleController.text = item.title;
    _textAddressController.text = item.address;
    _textPhoneController.text = item.phone ?? '';
    _textEmailController.text = item.email ?? '';
    _textWebsiteController.text = item.website ?? '';
    _createdAt = item.createDate ?? '';

    selectedCategory = listCategory.firstWhere(
      (e) => e["id"] == item.categoryId,
      orElse: () => {},
    )["name"];

    if (selectedCategory?.toLowerCase() == "news" || selectedCategory == null) {
      final subCategoryResponse = await context
          .read<AddListingCubit>()
          .loadSubCategory(selectedCategory);
      listSubCategory = subCategoryResponse?.data ?? [];

      selectedSubCategory = listSubCategory.firstWhere(
        (e) => e["id"] == item.subcategoryId,
        orElse: () => {},
      )["name"];
    }

    _selectedCities = item.allCities
            ?.map((cityId) => listCity.firstWhere((c) => c['id'] == cityId,
                orElse: () => {})['name'])
            .cast<String>()
            .toList() ??
        [];

    _parseDateTimes(item);

    List<File> images = await downloadImages(item.imageLists!);
    setState(() {
      selectedImages?.clear();
      downloadedImages.clear();
      if (images.isNotEmpty && !images[0].path.contains('Defaultimage')) {
        selectedImages?.addAll(images);
      }
      downloadedImages.addAll(images);
    });
  }

  void _parseDateTimes(ProductModel item) {
    if (item.startDate.isNotEmpty) {
      final startParts = item.startDate.split(' ');
      if (startParts.length == 2) {
        _startDate = _convertDate(startParts[0]);
        _startTime = _parseTime(startParts[1]);

        final endParts = item.endDate.split(' ');
        if (endParts.length == 2) {
          _endDate = _convertDate(endParts[0]);
          _endTime = _parseTime(endParts[1]);
        } else {
          _endDate = null;
          _endTime = null;
        }
      }
    }

    if (item.expiryDate.isNotEmpty) {
      final expiryParts = item.expiryDate.split(' ');
      _expiryDate = _convertDate(expiryParts[0]);
      _expiryTime = _parseTime(expiryParts[1]);
    }
  }

  String _convertDate(String date) {
    return DateFormat('yyyy-MM-dd').format(DateFormat('dd.MM.yyyy').parse(date));
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _onShowExpiryDatePicker() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _expiryDate != null
        ? DateFormat('yyyy-MM-dd').parse(_expiryDate!)
        : now.add(const Duration(days: 14));
    final DateTime firstDate = now;
    final DateTime lastDate = DateTime(now.year + 5);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      setState(() {
        _expiryDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<List<File>> downloadImages(List<ImageListModel> imageUrls) async {
    List<File> downloadedImages = [];
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();

    imageUrls.sort((a, b) => a.imageOrder!.compareTo(b.imageOrder as num));
    for (final imageUrl in imageUrls) {
      try {
        var response = await http
            .get(Uri.parse("${Application.picturesURL}${imageUrl.logo}"));
        if (response.statusCode == 200) {
          String savePath =
              '${appDocumentsDirectory.path}/${imageUrl.logo?.replaceAll(RegExp(r'[^\w\s\.]'), '_')}';

          File file = File(savePath);
          await file.writeAsBytes(response.bodyBytes);
          downloadedImages.add(file);
        } else {
          throw Exception('Failed to download image');
        }
      } catch (e) {
        logError('Error downloading image: $e');
      }
    }
    return downloadedImages;
  }

  void _onShowStartDatePicker(String? startDate) async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    if (startDate != null) {
      final parsedDate = dateFormat.parse(startDate);
      final picked = await showDatePicker(
        initialDate: parsedDate,
        firstDate: DateTime(now.year),
        context: context,
        lastDate: DateTime(now.year + 2, now.month, now.day),
      );
      if (picked != null) {
        setState(() {
          _startDate = picked.dateView;
        });
      }
    } else {
      final picked = await showDatePicker(
        initialDate: now,
        firstDate: DateTime(now.year),
        context: context,
        lastDate: DateTime(now.year + 2, now.month, now.day),
      );

      if (picked != null) {
        setState(() {
          _startDate = picked.dateView;
        });
      }
    }
  }

  bool _isEndTimeValid(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes >= startMinutes;
  }


  Future<void> _onShowEndDatePicker(String? endDate) async {
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    DateTime firstAllowedDate =
    _startDate != null ? dateFormat.parse(_startDate!) : DateTime(now.year);

    DateTime initialDate = endDate != null
        ? dateFormat.parse(endDate)
        : firstAllowedDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstAllowedDate,
      lastDate: DateTime(now.year + 2),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked.dateView;

        if (_startDate == _endDate && _startTime != null && _endTime != null) {
          if (!_isEndTimeValid(_startTime!, _endTime!)) {
            _endTime = null;
          }
        }
      });
    }
  }

  Future<void> _onShowExpiryTimePicker() async {
    final TimeOfDay initialTime =
        _expiryTime ?? const TimeOfDay(hour: 0, minute: 0);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _expiryTime = pickedTime;
      });
    }
  }

  Future<void> _onShowEndTimePicker(TimeOfDay? endTime) async {
    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translate.of(context).translate('please_select_start_date'),
          ),
        ),
      );
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: endTime ?? _startTime!,
    );

    if (pickedTime == null) return;

    if (_startDate == _endDate &&
        !isAfter(pickedTime, _startTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translate.of(context).translate('end_time_validation_text'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _endTime = pickedTime;
    });
  }

  Future<void> _onShowStartTimePicker(TimeOfDay? startTime) async {
    if (startTime != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: startTime,
      );

      if (pickedTime != null) {
        setState(() {
          _startTime = pickedTime;
        });
      }
    } else {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _startTime = pickedTime;
        });
      }
    }
  }


  void _onSubmit() async {
    final success = _validData();
    String? errorMsg;
    if (success) {
      final htmlContent = QuillDeltaToHtmlConverter(
        _quillController.document.toDelta().toJson(),
        ConverterOptions(),
      ).convert();

      List<String> allCities = [];
      for (var cityName in _selectedCities) {
        final city = listCity.firstWhere((item) => item['name'] == cityName,
            orElse: () => null);
        allCities.add(city['id'].toString());
      }
      int? selectedCategoryId =
          _getSelectedCategroyIdFromName(selectedCategory);
      int? selectedSubCategoryId;
      if (selectedSubCategory != null) {
        selectedSubCategoryId = _getSelectedSubCategroyId(selectedSubCategory);
      }

      if (widget.item != null) {
        if (isImageChanged) {
          await context
              .read<AddListingCubit>()
              .deleteImage(widget.item?.cityId, widget.item?.id);
          await context
              .read<AddListingCubit>()
              .deletePdf(widget.item?.cityId, widget.item?.id);
        }
        String? submitExpiryDate = _isExpiryDateEnabled ? _expiryDate : null;
        TimeOfDay? submitExpiryTime = _isExpiryDateEnabled ? _expiryTime : null;

        setState(() {
          isLoading = true;
        });
        final website = (_textWebsiteController.text == 'https://')
            ? null
            : _textWebsiteController.text;
        final result = await context.read<AddListingCubit>().onEdit(
            cityId: widget.item?.cityId,
            categoryId: selectedCategoryId,
            listingId: widget.item?.id,
            title: _textTitleController.text,
            place: _textPlaceController.text,
            description: htmlContent,
            address: _textAddressController.text,
            email: _textEmailController.text,
            phone: _textPhoneController.text,
            website: website,
            price: _textPriceController.text,
            expiryDate: submitExpiryDate,
            expiryTime: submitExpiryTime,
            startDate: _startDate,
            endDate: _endDate,
            createdAt: _createdAt,
            startTime: _startTime,
            endTime: _endTime,
            timeless: _isExpiryDateEnabled ? 0 : 1,
            isImageChanged: isImageChanged,
            statusId: statusId,
            imagesList: selectedImages,
            allCities: allCities,
            subCategoryId: selectedSubCategoryId,
            error: (error) {
              errorMsg = error;
            },
            isRecurringDayEvent : _isRecurringDayEvent,
        );
        if (result) {
          await AppBloc.homeCubit.onLoad(false);
          setState(() {
            isLoading = false;
          });
          _onSuccess();
          prefilledRecurringRules = [];
          if (!mounted) return;
          context.read<AddListingCubit>().clearAssets();
        } else {
          setState(() {
            isLoading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg != null
                    ? (errorMsg!)
                    : Translate.of(context).translate('something_went_wrong_text')),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      } else {
        String? submitExpiryDate = _isExpiryDateEnabled ? _expiryDate : null;
        TimeOfDay? submitExpiryTime = _isExpiryDateEnabled ? _expiryTime : null;

        setState(() {
          isLoading = true;
        });
        final website = (_textWebsiteController.text == 'https://')
            ? null
            : _textWebsiteController.text;
        final result = await context.read<AddListingCubit>().onSubmit(
              cityId: cityId ?? 1,
              categoryId: selectedCategoryId,
              subCategoryId: selectedSubCategoryId,
              title: _textTitleController.text,
              city: _selectedCities.first,
              allCities: allCities,
              place: _textPlaceController.text,
              description: htmlContent,
              address: _textAddressController.text,
              email: _textEmailController.text,
              phone: _textPhoneController.text,
              website: website,
              expiryDate: submitExpiryDate,
              startDate: _startDate,
              endDate: _endDate,
              expiryTime: submitExpiryTime,
              timeless: _isExpiryDateEnabled ? 0 : 1,
              startTime: _startTime,
              endTime: _endTime,
              imagesList: selectedImages,
              isImageChanged: isImageChanged,
              error: (error) {
              errorMsg = error;
              },
              isRecurringDayEvent : _isRecurringDayEvent
        );
        if (result != null && result.success) {
          final prefs = await Preferences.openBox();
          final categoryId = prefs.getKeyValue(Preferences.categoryId, '');
          final cityId = int.parse(allCities.first);
          MatomoApi.trackMatomoEvent(context,
              isCategory: false,
              categoryId: categoryId,
              cityId: cityId,
              listingId: result.id,
              listingTitle: _textTitleController.text);
          await AppBloc.homeCubit.onLoad(false);
          setState(() {
            isLoading = false;
          });
          _onSuccess();
          if (!mounted) return;
          context.read<AddListingCubit>().clearImagePath();
          if (!mounted) return;
          context.read<AddListingCubit>().clearAssets();
        } else {
          setState(() {
            isLoading = false;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg != null
                    ? (errorMsg!)
                    : Translate.of(context).translate('something_went_wrong_text')),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      }
    }
  }

  void _onSuccess() {
    if (widget.isNewList) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.submitSuccess,
        (route) =>
            route.isFirst ||
            (route.settings.name != null &&
                route.settings.name != Routes.submit),
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _validData() {
    if(isEmptyRepeatUntilDate) {
      // setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translate.of(context).translate('please_select_repeat_until_time'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    _errorPhone = UtilValidator.validate(
      _textPhoneController.text,
      type: ValidateType.phone,
      allowEmpty: true,
    );

    _errorWebsite = (_textWebsiteController.text == 'https://')
        ? null
        : UtilValidator.validate(
            _textWebsiteController.text,
            allowEmpty: true,
            type: ValidateType.website,
          );

    _errorStatus = UtilValidator.validate(
      _textStatusController.text,
      allowEmpty: true,
    );

    _errorTitle =
        UtilValidator.validate(_textTitleController.text, allowEmpty: false);

    if (_quillController.document.toPlainText().trim().length >= 65535) {
      _errorContent = "value_desc_limit_exceeded";
    } else {
      _errorContent = UtilValidator.validate(
          _quillController.document.toPlainText().trim(),
          allowEmpty: false);
    }

    if (selectedCategory?.toLowerCase() == "events" && !_isRecurringDayEvent) {
      if (_startDate == null || _startDate == "" || _startTime == null) {
        _errorSDate = "value_not_date_empty";
      } else {
        _errorSDate = null;
      }
      if (_endDate != null && _endDate!.isNotEmpty && _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              Translate.of(context).translate('please_select_end_time'),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    if (_selectedCities.isEmpty) {
      _errorCity = "value_not_empty";
    }

    List<String?> errors = [
      _errorTitle,
      _errorContent,
      _errorCategory,
      _errorPhone,
      _errorWebsite,
      _errorStatus,
      _errorSDate,
      _errorCity
    ];

    if (errors.any((element) => element != null)) {
      String errorMessage = "";
      for (var element in errors) {
        if (element != null &&
            !errorMessage.contains(Translate.of(context).translate(element))) {
          errorMessage =
              "$errorMessage${Translate.of(context).translate(element)}, ";
        }
      }
      errorMessage = errorMessage.substring(0, errorMessage.length - 2);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));

      setState(() {});
      return false;
    }
    return true;
  }

  String? _getCategoryTranslation(int id) {
    Map<int, String> categories = {
      1: "category_news",
      3: "category_events",
      4: "category_clubs",
      5: "category_products",
      6: "category_offer_search",
      7: "category_citizen_info",
      9: "category_lost_found",
      10: "category_companies",
      11: "category_public_transport",
      12: "category_offers",
      13: "category_food",
      14: "category_rathaus",
      15: "category_newsletter",
      16: "category_official_notification",
    };
    return categories[id];
  }

  String? _getSubCategoryTranslation(int id) {
    Map<int, String> subCategories = {
      1: "subcategory_newsflash",
      3: "subcategory_politics",
      4: "subcategory_economy",
      5: "subcategory_sports",
      7: "subcategory_local",
      8: "subcategory_club_news",
      9: "subcategory_road",
      10: "subcategory_official_notification",
      11: "subcategory_timeless_news"
    };
    return subCategories[id];
  }

  Widget _buildQuillEditor() {
    return Stack(children: [
      Theme(
        data: Theme.of(context).copyWith(
          iconTheme: IconThemeData(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: quill.QuillSimpleToolbar(
                        controller: _quillController,
                        config: quill.QuillSimpleToolbarConfig(
                          toolbarSize: 7,
                          showBoldButton: true,
                          showItalicButton: true,
                          showUnderLineButton: true,
                          showListNumbers: true,
                          showListBullets: true,
                          showStrikeThrough: true,
                          showLink: false,
                          showHeaderStyle: false,
                          showAlignmentButtons: false,
                          showFontSize: false,
                          showInlineCode: false,
                          showQuote: false,
                          showCodeBlock: false,
                          showBackgroundColorButton: false,
                          showColorButton: false,
                          showSubscript: false,
                          showSuperscript: false,
                          showSearchButton: false,
                          showClipboardCut: false,
                          showClipboardCopy: false,
                          showFontFamily: false,
                          showDirection: false,
                          showRedo: false,
                          showUndo: false,
                          showIndent: false,
                          showListCheck: false,
                          showClipboardPaste: false,
                          showClearFormat: false,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.title,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      tooltip: 'Header Style',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor:
                                  Theme.of(context).dialogBackgroundColor,
                              title: Text(
                                'Select Header Style',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.color,
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    title: Text(
                                      'Header 1',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    onTap: () {
                                      _quillController
                                          .formatSelection(quill.Attribute.h1);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Header 2',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    onTap: () {
                                      _quillController
                                          .formatSelection(quill.Attribute.h2);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  ListTile(
                                    title: Text(
                                      'Header 3',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                    ),
                                    onTap: () {
                                      _quillController
                                          .formatSelection(quill.Attribute.h3);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 2, color: Theme.of(context).dividerColor),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                  config: quill.QuillEditorConfig(
                    placeholder: 'Enter content here...',
                    customStyles: quill.DefaultStyles(
                      paragraph: quill.DefaultTextBlockStyle(
                        TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 16,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(6, 0),
                        const quill.VerticalSpacing(0, 6),
                        null,
                      ),
                      h1: quill.DefaultTextBlockStyle(
                        TextStyle(
                          color:
                              Theme.of(context).textTheme.headlineLarge?.color,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(16, 0),
                        const quill.VerticalSpacing(0, 8),
                        null,
                      ),
                      h2: quill.DefaultTextBlockStyle(
                        TextStyle(
                          color:
                              Theme.of(context).textTheme.headlineMedium?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(14, 0),
                        const quill.VerticalSpacing(0, 6),
                        null,
                      ),
                      h3: quill.DefaultTextBlockStyle(
                        TextStyle(
                          color:
                              Theme.of(context).textTheme.headlineSmall?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        const quill.HorizontalSpacing(0, 0),
                        const quill.VerticalSpacing(12, 0),
                        const quill.VerticalSpacing(0, 4),
                        null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      if (_errorContent != null)
        Positioned(
          left: 12,
          bottom: 0,
          child: Text(
            textAlign: TextAlign.start,
            Translate.of(context).translate(_errorContent),
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Theme.of(context).colorScheme.error),
          ),
        ),
    ]);
  }

  Widget _buildImagePicker() {
    return SizedBox(
      height: 180,
      child: AppUploadImage(
        title: Translate.of(context).translate('upload_feature_image_pdf'),
        image: selectedImages!.isNotEmpty ? selectedImages![0].path : null,
        profile: false,
        forumGroup: false,
        onDelete: () {
          if (selectedImages!.isNotEmpty) {
            setState(() {
              selectedImages?.removeAt(0);
              isImageChanged = true;
            });
          }
        },
        onChange: (result) {
          if (result.isNotEmpty) {
            setState(() {
              selectedImages?.clear();
              if (downloadedImages.isNotEmpty &&
                  !downloadedImages[0].path.contains('Defaultimage')) {
                selectedImages?.addAll(downloadedImages);
              }
              selectedImages?.addAll(result);
            });
          } else {
            setState(() {
              selectedImages?.clear();
            });
          }
          isImageChanged = true;
        },
      ),
    );
  }

  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('title'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_title'),
          errorText: _errorTitle,
          controller: _textTitleController,
          focusNode: _focusTitle,
          textInputAction: TextInputAction.next,
          onChanged: (text) {
            _errorTitle = UtilValidator.validate(
              _textTitleController.text,
            );
          },
          onSubmitted: (text) {
            Utils.fieldFocusChange(
              context,
              _focusTitle,
              _focusContent,
            );
          },
        ),
      ],
    );
  }

  Widget _buildContentEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('input_content'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildQuillEditor(),
      ],
    );
  }

  Widget _buildCategoryAndSubCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('category'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: listCategory.isEmpty
                  ? const LinearProgressIndicator()
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: Theme.of(context).dividerColor, width: 1),
                      ),
                      child: DropdownButton(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        underline: const SizedBox(),
                        isExpanded: true,
                        menuMaxHeight: 200,
                        hint: Text(
                          Translate.of(context).translate('input_category'),
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        value: selectedCategory,
                        items: listCategory.map((category) {
                          return DropdownMenuItem(
                              value: category['name'],
                              child: Text(Translate.of(context).translate(
                                  _getCategoryTranslation(category['id']))));
                        }).toList(),
                        onChanged: (value) async {
                          setState(
                            () {
                              selectedCategory = value as String?;
                              context
                                  .read<AddListingCubit>()
                                  .setCategoryId(selectedCategory?.toLowerCase());
                            },
                          );
                          if (selectedCategory?.toLowerCase() == "news" ||
                              selectedCategory == null) {
                            selectSubCategory(selectedCategory?.toLowerCase());
                            _setDefaultExpiryDate();
                          }
                        },
                      ),
                    ),
            )
          ],
        ),
        if ((selectedCategory?.toLowerCase() == "news" ||
                selectedCategory == null) &&
            selectedSubCategory != null)
          const SizedBox(height: 8),
        if ((selectedCategory?.toLowerCase() == "news" ||
                selectedCategory == null) &&
            selectedSubCategory != null)
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('subCategory'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              children: const <TextSpan>[
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (selectedCategory?.toLowerCase() == "news" &&
                selectedSubCategory != null)
              Expanded(
                child: listSubCategory.isEmpty
                    ? const LinearProgressIndicator()
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                              color: Theme.of(context).dividerColor, width: 1),
                        ),
                        child: DropdownButton(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          borderRadius: BorderRadius.circular(5),
                          isExpanded: true,
                          underline: const SizedBox(),
                          menuMaxHeight: 200,
                          hint: Text(
                            Translate.of(context)
                                .translate('input_subcategory'),
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          value: selectedSubCategory,
                          items: listSubCategory.map((subcategory) {
                            return DropdownMenuItem(
                                value: subcategory['name'],
                                child: Text(Translate.of(context).translate(
                                    _getSubCategoryTranslation(
                                        subcategory['id']))));
                          }).toList(),
                          onChanged: (value) {
                            context
                                .read<AddListingCubit>()
                                .getSubCategoryId(value);
                            setState(() {
                              selectedSubCategory = value as String?;
                              context
                                  .read<AddListingCubit>()
                                  .setSubCategoryId(
                                      selectedSubCategory?.toLowerCase());
                            });
                          },
                        ),
                      ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: Translate.of(context).translate('city'),
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
            children: const <TextSpan>[
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: listCity.isEmpty
                  ? const LinearProgressIndicator()
                  : CitySelection(listCity, _selectedCities, _errorCity,
                      (List<String> selectedCities, List<int> selectedCityIds) {
                      _selectedCities = selectedCities;
                      if (_selectedCities.isNotEmpty && _errorCity != null) {
                        setState(() {
                          _errorCity = null;
                        });
                      }
                    }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpiryDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedCategory?.toLowerCase() == "news")
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Row(
              children: [
                Checkbox(
                  value: _isExpiryDateEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      _isExpiryDateEnabled = value!;
                      if (_isExpiryDateEnabled &&
                          (_expiryDate == null || _expiryTime == null)) {
                        DateTime now = DateTime.now();
                        DateTime twoWeeksFromNow =
                            now.add(const Duration(days: 14));
                        _expiryDate =
                            DateFormat('yyyy-MM-dd').format(twoWeeksFromNow);
                        _expiryTime = const TimeOfDay(hour: 0, minute: 0);
                      }
                    });
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpiryDateEnabled = !_isExpiryDateEnabled;
                      });
                    },
                    child: Text(
                      Translate.of(context).translate('enable_expiry_date'),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Visibility(
          visible: (selectedCategory?.toLowerCase() == "news") &&
              (_isExpiryDateEnabled || widget.item?.timeless == 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text: Translate.of(context).translate('expiry_date'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                  children: const <TextSpan>[
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              AppPickerItem(
                leading: Icon(
                  Icons.calendar_today_outlined,
                  color: Theme.of(context).hintColor,
                ),
                value: _expiryDate,
                title: Translate.of(context).translate(
                  'choose_date',
                ),
                onPressed: () async {
                  _onShowExpiryDatePicker();
                },
              ),
              const SizedBox(height: 8),
              AppPickerItem(
                  leading: Icon(
                    Icons.access_time,
                    color: Theme.of(context).hintColor,
                  ),
                  value: _expiryTime?.format(context),
                  title: Translate.of(context).translate(
                    'choose_exptime',
                  ),
                  onPressed: () async {
                    _onShowExpiryTimePicker();
                  }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextInput(
          hintText: Translate.of(context).translate('input_address'),
          controller: _textAddressController,
          focusNode: _focusAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (text) {
            Utils.fieldFocusChange(
              context,
              _focusAddress,
              _focusZipCode,
            );
          },
          leading: Icon(
            Icons.home_outlined,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_phone'),
          errorText: _errorPhone,
          controller: _textPhoneController,
          focusNode: _focusPhone,
          maxLength: 15,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onChanged: (text) {
            setState(() {
              _errorPhone = UtilValidator.validate(
                _textPhoneController.text,
                type: ValidateType.phone,
                allowEmpty: true,
              );
            });
          },
          onSubmitted: (text) {
            Utils.fieldFocusChange(
              context,
              _focusPhone,
              _focusEmail,
            );
          },
          leading: Icon(
            Icons.phone_outlined,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_email'),
          controller: _textEmailController,
          focusNode: _focusEmail,
          textInputAction: TextInputAction.next,
          onSubmitted: (text) {
            Utils.fieldFocusChange(
              context,
              _focusEmail,
              _focusWebsite,
            );
          },
          leading: Icon(
            Icons.email_outlined,
            color: Theme.of(context).hintColor,
          ),
        ),
        const SizedBox(height: 8),
        AppTextInput(
          hintText: Translate.of(context).translate('input_website'),
          errorText: _errorWebsite,
          controller: _textWebsiteController,
          focusNode: _focusWebsite,
          textInputAction: TextInputAction.done,
          onChanged: (text) {
            setState(() {
              if (_textWebsiteController.text == 'https://') {
                _errorWebsite = null;
              }
              else {
                _errorWebsite = UtilValidator.validate(
                  _textWebsiteController.text,
                  allowEmpty: true,
                  type: ValidateType.website,
                );
              }
            });
          },
          leading: Icon(
            Icons.language_outlined,
            color: Theme.of(context).hintColor,
          ),
        ),
      ],
    );
  }

  Widget _buildEventDates() {
    return Visibility(
      visible: selectedCategory?.toLowerCase() == "events" && !_isRecurringDayEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('start_date'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              children: const <TextSpan>[
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppPickerItem(
            leading: Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).hintColor,
            ),
            value: _startDate,
            title: Translate.of(context).translate(
              'choose_date',
            ),
            onPressed: () async {
              _onShowStartDatePicker(_startDate);
            },
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('start_time'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
              children: const <TextSpan>[
                TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          AppPickerItem(
              leading: Icon(
                Icons.access_time,
                color: Theme.of(context).hintColor,
              ),
              value: _startTime?.format(context),
              title: Translate.of(context).translate(
                'choose_stime',
              ),
              onPressed: () async {
                _onShowStartTimePicker(_startTime);
              }),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('end_date'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          AppPickerItem(
            leading: Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).hintColor,
            ),
            value: _endDate,
            title: Translate.of(context).translate(
              'choose_date',
            ),
            onPressed: () async {
              if(_startDate==null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Translate.of(context).translate('please_select_start_date'))),
                );
              } else {
                _onShowEndDatePicker(_endDate);
              }
            },
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: Translate.of(context).translate('end_time'),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          AppPickerItem(
            leading: Icon(
              Icons.access_time,
              color: Theme.of(context).hintColor,
            ),
            value: _endTime?.format(context),
            title: Translate.of(context).translate(
              'choose_etime',
            ),
            onPressed: () async {
              if(_startDate==null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(Translate.of(context).translate('please_select_start_date'))),
                );
              } else {
                _onShowEndTimePicker(_endTime);
              }
            },
          ),
        ],
      ),
    );
  }

  bool isAfter(TimeOfDay a, TimeOfDay b) {
    return a.hour * 60 + a.minute > b.hour * 60 + b.minute;
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePicker(),
            const SizedBox(height: 16),
            _buildImageList(),
            const SizedBox(height: 16),
            _buildTitleInput(),
            const SizedBox(height: 16),
            _buildContentEditor(),
            const SizedBox(height: 16),
            _buildCategoryAndSubCategory(),
            const SizedBox(height: 8),
            if (selectedCategory?.toLowerCase() == "news" ||
                selectedCategory == null)
              const SizedBox(height: 8),
            Visibility(
              visible: selectedCategory?.toLowerCase() == "events",
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isRecurringDayEvent = !_isRecurringDayEvent;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _isRecurringDayEvent,
                        onChanged: (bool? value) {
                          setState(() {
                            _isRecurringDayEvent = value!;
                          });
                          if(value!=null && !value){
                            _formatRecurringSchedules();
                          }
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isRecurringDayEvent = !_isRecurringDayEvent;
                            });
                            if(_isRecurringDayEvent){
                              _formatRecurringSchedules();
                            }
                          },
                          child: Text(
                            Translate.of(context).translate('recurring_event'),
                            style: Theme.of(context).textTheme.bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isRecurringDayEvent &&
                selectedCategory?.toLowerCase() == "events") ...[
              ..._recurringSchedules.map((id) {
                final rule = context
                    .read<AddListingCubit>()
                    .recurrenceRuleModelMap[id];
                final index = _recurringSchedules.indexOf(id);

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            "${Translate.of(context).translate('recurring_schedule')} #${index + 1}",
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (index != 0)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRecurringSchedule(id),
                          ),
                      ],
                    ),
                    AddRecurringEventWidget(
                      key: ValueKey(id),
                      recurringRuleKey: id,
                      recurrenceRule: rule,
                      addRuleCallback: (status) {
                        setState(() {
                          setAddMoreRuleButtonVisibility = status;
                        });
                      },
                      emptyRepeatUntilTimeCallback: (status) {
                        setState(() {
                          isEmptyRepeatUntilDate = status;
                        });
                      },
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 15),
              Visibility(
                visible: setAddMoreRuleButtonVisibility,
                child: Center(
                  child: AppButton(
                    Translate.of(context).translate('add_recurring_schedule'),
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (prefilledRecurringRules.isNotEmpty) {
                        prefilledRecurringRules = [];
                      }
                      _addRecurringSchedule();
                    },
                    type: ButtonType.outline,
                  ),
                ),
              ),
            ],
            _buildCitySelector(),
            const SizedBox(height: 6),
            _buildExpiryDate(),
            const SizedBox(height: 10),
            _buildContactInfo(),
            _buildEventDates(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return Visibility(
      visible: selectedImages!.length > 1,
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: selectedImages!.length > 1
              ? selectedImages!.length - 1
              : 0,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.rectangle,
                      ),
                      child: Image.file(selectedImages![index + 1],
                          fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red[900],
                      ),
                      onPressed: () {
                        setState(() {
                          isImageChanged = true;
                          if (selectedImages!.isNotEmpty &&
                              selectedImages!.length > 2) {
                            context
                                .read<AddListingCubit>()
                                .removeAssetsByIndex(index);
                          }
                          if (downloadedImages.isNotEmpty) {
                            if (downloadedImages.length > index + 1) {
                              downloadedImages
                                  .remove(downloadedImages[index + 1]);
                            }
                          }
                          selectedImages?.remove(selectedImages?[index + 1]);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> selectSubCategory(String? selectedCategory) async {
    context.read<AddListingCubit>().clearSubCategory();
    selectedSubCategory = null;
    final subCategoryResponse = await context
        .read<AddListingCubit>()
        .loadSubCategory(selectedCategory!.toLowerCase());
    if (!mounted) return;
    context
        .read<AddListingCubit>()
        .setCategoryId(selectedCategory.toLowerCase());
    if (subCategoryResponse?.data.isNotEmpty) {
      context
          .read<AddListingCubit>()
          .setSubCategoryId(subCategoryResponse?.data.last['name']);
    }

    setState(() {
      listSubCategory = subCategoryResponse!.data;

      if (subCategoryResponse.data.isNotEmpty) {
        selectedSubCategory = subCategoryResponse.data.last['name'];
      } else {
        selectedSubCategory = null;
      }
    });
  }

  Future<void> selectSubCategoryOnLaunch(String? selectedCategory) async {
    final subCategoryResponse = await context
        .read<AddListingCubit>()
        .loadSubCategory(selectedCategory!.toLowerCase());
    if (!mounted) return;
    setState(() {
      listSubCategory = subCategoryResponse?.data;
      if (subCategoryResponse?.data?.isNotEmpty == true) {
        selectedSubCategory ??= subCategoryResponse!.data.last['name'];
      }
    });
  }

  int _getSelectedCategroyIdFromName(String? selectedCategory) {
    final firstMatchingCategroy = listCategory.firstWhere((item) =>
        item['name'].toString().toLowerCase() ==
        selectedCategory?.toLowerCase());

    if (firstMatchingCategroy == null) {
      return 1;
    }

    return firstMatchingCategroy['id'];
  }

  int _getSelectedSubCategroyId(String? selectedCategory) {
    final firstMatchingCategroy = listSubCategory.firstWhere((item) =>
        item['name'].toString().toLowerCase() ==
        selectedCategory?.toLowerCase());

    if (firstMatchingCategroy == null) {
      return 1;
    }

    return firstMatchingCategroy['id'];
  }

  void _addRecurringSchedule({
    String? freq,
    int? interval,
    List<String>? weekdays,
    String? start,
    String? end,
    String? repeatUntil,
    List<String>? exceptionDates,
    int? dayOrdinal,
  }) {
    final id = _nextRecurringId++;

    setState(() {
      _recurringSchedules.add(id);
      setAddMoreRuleButtonVisibility = false;
    });

    context.read<AddListingCubit>().addRecurringRule(
      key: id,
      freq: freq,
      interval: interval,
      weekdays: weekdays,
      start: start,
      end: end,
      repeatUntil: repeatUntil,
      exceptionDates: exceptionDates,
      dayOrdinal: dayOrdinal,
    );
  }

  void _deleteRecurringSchedule(int id) {
    setState(() {
      _recurringSchedules.remove(id);
      setAddMoreRuleButtonVisibility = true;
    });
    context.read<AddListingCubit>().deleteRecurringRule(id);
  }

  void _formatRecurringSchedules() {
    setState(() {
      _recurringSchedules.clear();
    });
    context.read<AddListingCubit>().formatRecurringRules();
    _addRecurringSchedule();
  }

}
