// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app_name/src/data/model/model_forum_group.dart';
import 'package:your_app_name/src/presentation/main/home/forum/add_group_screen/cubit/add_group_cubit.dart';
import 'package:your_app_name/src/presentation/main/home/forum/add_group_screen/forum_group_upload_image.dart';
import 'package:your_app_name/src/presentation/widget/app_button.dart';
import 'package:your_app_name/src/presentation/widget/app_text_input.dart';
import 'package:your_app_name/src/utils/common.dart';
import 'package:your_app_name/src/utils/configs/preferences.dart';
import 'package:your_app_name/src/utils/translate.dart';
import 'package:your_app_name/src/utils/validate.dart';

import '../../../add_listing/multiple_selection_city.dart';

class AddGroupScreen extends StatefulWidget {
  final ForumGroupModel? item;
  final bool isNewGroup;

  const AddGroupScreen({
    super.key,
    this.item,
    required this.isNewGroup,
  });

  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final regInt = RegExp('[^0-9]');
  final _textTitleController = TextEditingController();
  final _textContentController = TextEditingController();
  final _focusTitle = FocusNode();
  final _focusContent = FocusNode();

  bool _processing = false;
  bool _isSubmitting = false;
  String? _errorTitle;
  String? _errorContent;
  String? selectedCity;
  List<int> _selectedCityIds = [];
  List<String> _selectedCities = [];
  List listCity = [];
  String? _errorCity;

  String? _featureImage;
  String? selectedPrivacy;
  String? _selectedImagePath;

  late int? currentCity;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _onProcess();
  }

  @override
  void dispose() {
    _textTitleController.dispose();
    _textContentController.dispose();
    _focusTitle.dispose();
    _focusContent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String textTitle = Translate.of(context).translate('add_new_group');
    String textAction = Translate.of(context).translate('add');
    if (!widget.isNewGroup) {
      textTitle = Translate.of(context).translate('update_group');
      textAction = Translate.of(context).translate('update');
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(textTitle),
          actions: [
            AppButton(
              textAction,
              onPressed: _isSubmitting ? ()=>{} : _onSubmit,
              type: ButtonType.text,
            )
          ],
        ),
        body: Stack(
          children: [
            SafeArea(
              child: _buildContent(),
            ),
            if (_isSubmitting)
              const Opacity(
                opacity: 0.5,
                child: ModalBarrier(
                  dismissible: false,
                  color: Colors.black,
                ),
              ),
            if (_isSubmitting)
              const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    currentCity = await context.read<AddGroupCubit>().getCurrentCityId();
    _onProcess();
  }

  void _onProcess() async {
    final loadCitiesResponse = await context.read<AddGroupCubit>().loadCities();
    if (!mounted) return;
    final prefs = await Preferences.openBox();
    final cityIdPref = prefs.getKeyValue(Preferences.cityId, 0);

    if (widget.item != null) {
      _selectedCities = widget.item!.cityIds!
          .map((cityId) {
            final cityDetail = loadCitiesResponse!.firstWhere(
                (element) => element['id'] == cityId,
                orElse: () => null);
            return cityDetail != null ? cityDetail['name'] as String : null;
          })
          .where((cityName) => cityName != null)
          .cast<String>()
          .toList();

      if (!mounted) return;
      _textTitleController.text = widget.item!.forumName ?? '';
      _textContentController.text = widget.item!.description ?? '';
      _featureImage = widget.item?.image;
      _selectedCityIds = widget.item?.cityIds ?? [];
      selectedPrivacy = widget.item!.isPrivate == 1 ? 'private' : 'public';
    } else {
      final cityDetail = loadCitiesResponse?.firstWhere(
          (element) => element['id'] == cityIdPref,
          orElse: () => loadCitiesResponse.first);
      _selectedCities = [
        cityDetail?['name'] ?? loadCitiesResponse?.first['name']
      ];
      _selectedCityIds = [cityDetail?['id'] ?? loadCitiesResponse?.first['id']];
      selectedPrivacy = 'public';
    }
    setState(() {
      listCity = loadCitiesResponse!;
      _processing = true;
    });

    Map<String, dynamic> params = {};
    if (widget.item != null) {
      params['post_id'] = widget.item!.id;
    }

    if (currentCity != null && currentCity != 0 && widget.item == null) {
      for (var cityData in loadCitiesResponse!) {
        if (cityData['id'] == currentCity) {
          _selectedCities = [cityData['name']];
          break;
        }
      }
    } else {
      // selectedCity = loadCitiesResponse?.first['name'];
    }

    setState(() {
      _processing = false;
    });
  }

  void _onSubmit() async {
    final success = _validData();
    if (success) {
      setState(() {
        _isSubmitting = true;
      });
      try {
        if (widget.item == null) {
          final result = await context.read<AddGroupCubit>().onSubmit(
              cityIds: _selectedCityIds,
              title: _textTitleController.text.trim(),
              cities: _selectedCities,
              description: _textContentController.text,
              type: selectedPrivacy,
              selectedImagePath: _selectedImagePath);
          if (result) {
            if (!mounted) return;
            Navigator.pop(
                context, true); // Return true to indicate refresh needed
          }
          else{
            if (mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(Translate.of(context).translate('error_message'))),
              );
            }
          }
        } else {
          final result = await context.read<AddGroupCubit>().onEditForum(
              _textTitleController.text.trim(),
              _textContentController.text,
              selectedPrivacy,
              _selectedImagePath,
              widget.item!.id,
              widget.item!.createdAt);
          if (result) {
            if (!mounted) return;
            Navigator.pop(context, true);
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  bool _validData() {
    final title = _textTitleController.text.trim();
    _errorTitle = UtilValidator.validate(title, allowEmpty: false);

    _errorContent =
        UtilValidator.validate(_textContentController.text, allowEmpty: false);


    List<String> errorKeys = [];
    if (_errorTitle != null) {
      errorKeys.add(_errorTitle!);
    }
    if (_errorContent != null) {
      errorKeys.add(_errorContent!);
    }
    if(_selectedCityIds.isEmpty){
      errorKeys.add(Translate.of(context).translate('select_city'));
    }

    if (errorKeys.isNotEmpty) {
      final errorMessage = errorKeys
          .toSet()
          .map((key) => Translate.of(context).translate(key))
          .join(', ');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );

      setState(() {});
      return false;
    }

    return true;
  }

  Widget _buildContent() {
    if (_processing) {
      return const Center(
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: ForumGroupImageUpload(
                image: _featureImage,
                onChange: (result) {
                  setState(() {
                    _selectedImagePath = result;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
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
            AppTextInput(
              maxLines: 3,
              hintText: Translate.of(context).translate('input_content'),
              errorText: _errorContent,
              controller: _textContentController,
              focusNode: _focusContent,
              textInputAction: TextInputAction.done,
              onChanged: (text) {
                _errorContent = UtilValidator.validate(
                  _textContentController.text,
                );
              },
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                text: Translate.of(context).translate('select_privacy'),
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
                  child: DropdownButton(
                    isExpanded: true,
                    menuMaxHeight: 200,
                    hint:
                        Text(Translate.of(context).translate('select_privacy')),
                    value: selectedPrivacy,
                    items: [
                      DropdownMenuItem(
                        value: 'private',
                        child: Text(Translate.of(context).translate('private')),
                      ),
                      DropdownMenuItem(
                        value: 'public',
                        child: Text(Translate.of(context).translate('public')),
                      ),
                    ],
                    onChanged: widget.item == null
                        ? (value) {
                            setState(() {
                              selectedPrivacy = value as String;
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
                          (List<String> selectedCities,
                              List<int> selectedCityIds) {
                          _selectedCities = selectedCities;
                          _selectedCityIds = selectedCityIds;
                          if (_selectedCities.isNotEmpty &&
                              _errorCity != null) {
                            setState(() {
                              _errorCity = null;
                            });
                          }
                        }),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
