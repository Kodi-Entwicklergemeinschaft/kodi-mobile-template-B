// ignore_for_file: unused_field

import 'package:flutter/material.dart';

class CitiesDropDown extends StatefulWidget {
  final ValueSetter<String>? setLocationCallback;
  final List<String>? cityTitlesList;
  final String? hintText;
  final String? selectedOption;

  const CitiesDropDown({
    super.key,
    required this.setLocationCallback,
    required this.cityTitlesList,
    this.hintText,
    this.selectedOption,
  });

  @override
  State<CitiesDropDown> createState() => _CitiesDropDownState();
}

class _CitiesDropDownState extends State<CitiesDropDown> {
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  List<String> filteredCities = [];
  String? _previousSelectedOption;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.selectedOption ?? '';
    filteredCities = widget.cityTitlesList ?? [];
    _previousSelectedOption = widget.selectedOption;
    _controller.addListener(_filterCities);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.removeListener(_filterCities);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _filterCities() {
    setState(() {
      filteredCities = widget.cityTitlesList!
          .where((city) =>
              city.toLowerCase().contains(_controller.text.toLowerCase()))
          .toList();
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _showOverlay() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        double optionHeight = 50.0;
        double maxHeight = 400.0;
        double totalHeight =
            (filteredCities.length * optionHeight).clamp(0.0, maxHeight);

        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 5.0),
            child: Material(
              elevation: 4.0,
              child: Container(
                height: totalHeight,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredCities.length,
                  itemBuilder: (context, index) {
                    final city = filteredCities[index];
                    return ListTile(
                      title: Text(city,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                      onTap: () {
                        setState(() {
                          _controller.text = city;
                          _previousSelectedOption = city;
                        });
                        if (widget.setLocationCallback != null) {
                          widget.setLocationCallback!(city);
                        }
                        _focusNode.unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isExpanded = true);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isExpanded = false);
  }

  @override
  void didUpdateWidget(covariant CitiesDropDown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOption != null &&
        widget.selectedOption != oldWidget.selectedOption) {
      _controller.text = widget.selectedOption!;
      _previousSelectedOption = widget.selectedOption;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onTap: () {
            setState(() {
              _controller.clear();
            });
          },
          decoration: InputDecoration(
            hintText: widget.hintText ?? 'Select Location',
            hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: textColor),
            ),
            filled: true,
            fillColor: isDarkMode ? Colors.black : Colors.white,
            suffixIcon: _focusNode.hasFocus
                ? IconButton(
                    icon: Icon(Icons.clear, color: textColor),
                    onPressed: () {
                      setState(() {
                        _controller.text = _previousSelectedOption ?? "";
                        _focusNode.unfocus();
                      });
                    },
                  )
                : Icon(Icons.arrow_drop_down, color: textColor),
          ),
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}
