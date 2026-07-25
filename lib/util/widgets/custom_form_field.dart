import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settlenow/constant/constant_core.dart';
import 'package:settlenow/util/util_core.dart';

class CustomFormField {
  static InputBorder _inputBorder(
    TextFormFieldInputBorder inputDecoration,
    double? borderRadius,
    Color? borderColor,
  ) {
    switch (inputDecoration) {
      case (TextFormFieldInputBorder.underLine):
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? Colors.transparent),
        );

      case (TextFormFieldInputBorder.outlineInputBorder):
        return OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        );

      default:
        return InputBorder.none;
    }
  }

  static Widget textFormField(
    TextEditingController textController, {
    TextStyle? style,
    TextInputType textInputType = TextInputType.text,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function()? onTap,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    TextStyle? hintStyle,
    String? labelText,
    bool readOnly = false,
    FocusNode? focusNode,
    Color? borderColor,
    double? borderRadius,
    TextFormFieldInputBorder inputDecoration = TextFormFieldInputBorder.none,
    int minLines = 1,
    int maxLines = 1,
    TextAlignVertical? textAlignVertical,
    bool filled = false,
    Color? hoverColor,
    Color? fillColor,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool isPassword = false,
    int? maxLength,
  }) {
    return TextFormField(
      readOnly: readOnly,
      obscureText: isPassword,
      obscuringCharacter: "*",
      controller: textController,
      focusNode: focusNode,
      autofillHints: autofillHints,
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      textAlignVertical: textAlignVertical,
      style: style,
      onChanged: onChanged,
      onTap: onTap,
      maxLength: maxLength,
      decoration: InputDecoration(
        isDense: true,
        focusedBorder: _inputBorder(inputDecoration, borderRadius, borderColor),
        enabledBorder: _inputBorder(inputDecoration, borderRadius, borderColor),
        border: _inputBorder(inputDecoration, borderRadius, borderColor),
        hintText: hintText,
        hintStyle: hintStyle,
        errorText: null,
        labelText: labelText,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        filled: filled,
        hoverColor: hoverColor,
        fillColor: fillColor,
        counterText: "",
      ),
    );
  }

  static Widget textFormFieldWithAutoFillGroup(
    TextEditingController textController, {
    TextStyle? style,
    bool readOnly = false,
    TextInputType textInputType = TextInputType.text,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
    void Function(String?)? onChanged,
    void Function()? onTap,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    TextStyle? hintStyle,
    FocusNode? focusNode,
    String? labelText,
    Color? borderColor,
    double? borderRadius,
    TextFormFieldInputBorder inputDecoration = TextFormFieldInputBorder.none,
    int minLines = 1,
    int maxLines = 1,
    TextAlignVertical? textAlignVertical,
    bool filled = false,
    Color? hoverColor,
    Color? fillColor,
    Widget? suffixIcon,
    Widget? prefixIcon,
    bool isPassword = false,
    int? maxLength,
  }) {
    return AutofillGroup(
      child: textFormField(
        textController,
        readOnly: readOnly,
        textInputType: textInputType,
        autofillHints: autofillHints,
        inputFormatters: inputFormatters,
        validator: validator,
        hintText: hintText,
        labelText: labelText,
        focusNode: focusNode,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        borderColor: borderColor,
        borderRadius: borderRadius,
        inputDecoration: inputDecoration,
        hintStyle: hintStyle,
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        onTap: onTap,
        filled: filled,
        hoverColor: hoverColor,
        fillColor: fillColor,
        style: style,
        isPassword: isPassword,
        maxLength: maxLength,
      ),
    );
  }

  static Widget searchBar(
    String hintText,
    ValueNotifier<bool> isSearchEnabled,
    TextEditingController searchController,
  ) {
    return ValueListenableBuilder(
      valueListenable: isSearchEnabled,
      builder: (BuildContext context, bool _, Widget? _) {
        return Visibility(
          visible: isSearchEnabled.value,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: .5 * UiConstant.spaceBetweenSection,
            ),
            child: CustomFormField.textFormField(
              searchController,
              hintText: hintText,
              prefixIcon: Icon(Icons.search),
              inputDecoration: TextFormFieldInputBorder.outlineInputBorder,
              borderColor:
                  Theme.of(context).inputDecorationTheme.outlineBorder!.color,
              borderRadius: 30,
              filled: true,
              fillColor: Colors.black.withAlpha(10),
            ),
          ),
        );
      },
    );
  }
}
