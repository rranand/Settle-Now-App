import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextFormFieldInputBorder { underLine, outlineInputBorder, none }

class CustomFormField {
  static InputBorder _inputBorder(
    TextFormFieldInputBorder inputDecoration,
    double? borderRadius,
    Color? borderColor,
  ) {
    switch (inputDecoration) {
      case (TextFormFieldInputBorder.underLine):
        return UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? Colors.black),
        );

      case (TextFormFieldInputBorder.outlineInputBorder):
        return OutlineInputBorder(
          borderSide: BorderSide(color: borderColor ?? Colors.black),
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
    Color? borderColor,
    double? borderRadius,
    TextFormFieldInputBorder inputDecoration = TextFormFieldInputBorder.none,
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
      autofillHints: autofillHints,
      keyboardType: textInputType,
      inputFormatters: inputFormatters,
      validator: validator,
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
        suffixIconConstraints: const BoxConstraints(
          minHeight: 41,
          minWidth: 41,
          maxHeight: 41,
          maxWidth: 41,
        ),
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
    String? labelText,
    Color? borderColor,
    double? borderRadius,
    TextFormFieldInputBorder inputDecoration = TextFormFieldInputBorder.none,
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
        onChanged: onChanged,
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
}
