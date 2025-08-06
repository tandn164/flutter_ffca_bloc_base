import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/color_resource.dart';
import '../utils/app_assets.dart';

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

  @override
  void initState() {
    super.initState();
    _isSecured = widget.isSecured;
  }

  InputBorder _textFieldBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: color,
      ),
      borderRadius: BorderRadius.all(Radius.circular(10.r)),
    );
  }

  bool _isError() {
    return _validationError != null;
  }

  @override
  Widget build(BuildContext context) {
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
                focusedBorder: _textFieldBorder(
                    _isError() ? Colors.red : Colors.green),
                enabledBorder: _textFieldBorder(
                    _isError() ? Colors.red : Colors.transparent),
                fillColor: Colors.black,
                filled: true,
                suffixIcon: widget.isSecured
                    ? IconButton(
                        icon: _isSecured
                            ? SvgPicture.asset(
                                AppAssets.icEye,
                                width: 20.w,
                                height: 20.w,
                              )
                            : SvgPicture.asset(
                                AppAssets.icEyeSlash,
                                width: 20.w,
                                height: 20.w,
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
          _isError()
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
              : Container()
        ]);
  }
}
