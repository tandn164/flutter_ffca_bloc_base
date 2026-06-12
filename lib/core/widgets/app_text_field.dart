import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/color_resource.dart';

class AppTextField extends StatefulWidget {
  const AppTextField(
      {Key? key,
      this.height,
      required this.onChanged,
      required this.node,
      required this.validationError,
      this.editingController,
      this.hintText,
      this.isSecured = false,
      this.keyboardType})
      : super(key: key);

  final double? height;
  final Function(String) onChanged;
  final String? validationError;
  final TextEditingController? editingController;
  final String? hintText;
  final bool isSecured;
  final TextInputType? keyboardType;

  final FocusNode node;

  @override
  State<StatefulWidget> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  double? get height => widget.height;
  Function(String) get onChanged => widget.onChanged;
  FocusNode get _node => widget.node;
  String? get _validationError => widget.validationError;
  TextEditingController? get _editingController => widget.editingController;
  String? get _hintText => widget.hintText;
  TextInputType? get _keyboardType => widget.keyboardType;
  late bool _isSecured;

  // Cache borders to avoid recreating on every build
  late final InputBorder _transparentBorder;
  late final InputBorder _redBorder;
  late final InputBorder _greenBorder;

  @override
  void initState() {
    super.initState();
    _isSecured = widget.isSecured;
    
    // Initialize cached borders
    _transparentBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
    
    _redBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
    
    _greenBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.green),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Cache error state to avoid multiple calls
    final isError = _validationError != null;
    
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height ?? 44.h,
            child: TextField(
              obscureText: _isSecured,
              obscuringCharacter: "＊",
              onChanged: onChanged,
              focusNode: _node,
              controller: _editingController,
              keyboardType: _keyboardType,
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: ColorResource.colorF1F1F1),
              decoration: InputDecoration(
                hintText: _hintText,
                hintStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: ColorResource.colorF1F1F1),
                contentPadding: EdgeInsets.only(
                    left: 10.w, right: 10.w, top: 0, bottom: 0),
                focusedBorder: isError ? _redBorder : _greenBorder,
                enabledBorder: isError ? _redBorder : _transparentBorder,
                fillColor: Colors.black,
                filled: true,
                suffixIcon: widget.isSecured
                    ? IconButton(
                        icon: Icon(
                          _isSecured ? Icons.visibility_off : Icons.visibility,
                          color: ColorResource.colorF1F1F1,
                          size: 20.w,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSecured = !_isSecured;
                          });
                        },
                      )
                    : null,
              ),
              cursorColor: Colors.black,
            ),
          ),
          isError
              ? Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    _validationError!,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400),
                  ),
                )
              : const SizedBox.shrink() // Use SizedBox.shrink() instead of Container()
        ]);
  }
}
