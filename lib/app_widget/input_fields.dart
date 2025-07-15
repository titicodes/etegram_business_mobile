import 'package:etegram_business/constants/colors.dart';
import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../constants/style.dart';
import 'app_text.dart';

class AppTextField extends StatefulWidget {
  final String? hintText;
  final String? Function(String?)? validator;
  final String? hint;
  final String? labelText;
  final bool readonly;
  final bool borderless;
  final bool isPassword;
  final Widget? suffixIcon;
  final Widget? errorWidget;
  final EdgeInsets? contentPadding;
  final Widget? label;
  final Widget? prefix;
  final double? textSize;
  final double? borderRadius;
  final Color? hintColor;
  final Color? fillColor;
  final Color? textColor;
  final bool? enabled;
  final bool? overrideIconColor;
  final VoidCallback? onTap;
  final InputBorder? enabledBorder;
  final int? maxLength;
  final int maxHeight;
  final bool? haveText;
  final TextCapitalization? textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onEditingComplete;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final double? boxWidth;
  final void Function(String)? onSubmitted; // Added
  final TextInputAction? textInputAction;

  const AppTextField({
    super.key,
    this.readonly = false,
    this.borderless = false,
    this.isPassword = false,
    this.hintText,
    this.hint,
    this.onSubmitted, // Added
    this.textInputAction, // Added
    this.onChanged,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.validator,
    this.autofillHints,
    this.suffixIcon,
    this.textSize,
    this.haveText,
    this.maxLength,
    this.labelText,
    this.label,
    this.contentPadding,
    this.prefix,
    this.maxHeight = 1,
    this.hintColor,
    this.textColor,
    this.inputFormatters,
    this.errorWidget,
    this.enabled,
    this.fillColor,
    this.overrideIconColor,
    this.enabledBorder,
    this.boxWidth,
    this.borderRadius,
    this.textCapitalization,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(color: ColorValues.whiteColor),
      width: widget.boxWidth ?? size.width,
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.hintText != null
              ? Column(
                  children: [
                    AppText(
                      widget.hintText ?? "",
                      size: widget.textSize ?? 13.5,
                      color: widget.hintColor ?? ColorValues.primaryColor,
                      // isBold: true,
                      align: TextAlign.start,
                    ),
                    10.0.sbH,
                  ],
                )
              : 0.0.sbH,
          TextFormField(
            textAlign: TextAlign.start,
            validator: widget.validator,
            autofillHints: widget.autofillHints,
            onEditingComplete: widget.onEditingComplete,
            onFieldSubmitted: widget.onFieldSubmitted,
            textCapitalization: widget.textCapitalization == null
                ? TextCapitalization.none
                : widget.textCapitalization!,
            maxLines: widget.maxHeight,
            focusNode: _focusNode,
            maxLength: widget.maxLength,
            onChanged: (val) {
              if (widget.onChanged != null) {
                widget.onChanged!(val);
              }
            },
            onTap: widget.onTap,
            readOnly: widget.readonly,
            enabled: widget.enabled,
            obscureText: widget.isPassword ? !isVisible : false,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            controller: widget.controller,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              filled: true, // Add this line to enable filled decoration
              errorMaxLines: 3,
              counter: 0.0.sbH,
              hintText: widget.hint,
              enabled: widget.enabled ?? true,
              fillColor: widget.fillColor ?? Colors.transparent,
              error: widget.errorWidget,
              prefixIconColor: widget.overrideIconColor == true
                  ? null
                  : const Color(0xFFD9D9D9),
              suffixIconColor: widget.overrideIconColor == true
                  ? null
                  : const Color(0xFFD9D9D9),
              prefixIcon: widget.prefix == null
                  ? null
                  : SizedBox(
                      height: 40,
                      width: 100,
                      child: Align(
                          alignment: Alignment.center, child: widget.prefix)),
              suffixIcon: widget.suffixIcon ??
                  (widget.isPassword
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: widget.suffixIcon ??
                              Icon(
                                isVisible ? Iconsax.eye_slash : Iconsax.eye,
                                size: 20,
                              ))
                      : widget.suffixIcon),

              label: widget.label,
              labelText: widget.labelText,
              labelStyle: bodyTextStyle,
              hintStyle: hintStyle.copyWith(
                  color: widget.textColor ?? const Color(0xFFD9D9D9)),
              isDense: true,
              contentPadding: widget.contentPadding ??
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: widget.borderless
                          ? Colors.transparent
                          : ColorValues.primaryColor,
                      width: 0.2),
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 8)),
              enabledBorder: widget.enabledBorder ??
                  OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0.2,
                          color: widget.borderless
                              ? Colors.transparent
                              : Theme.of(context)
                                  .disabledColor
                                  .withValues(alpha: 102)),
                      borderRadius:
                          BorderRadius.circular(widget.borderRadius ?? 8)),
              errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorValues.errorColor, width: 0.8),
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 8)),
              errorStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.borderless ? Colors.transparent : Colors.red),
              ),
              disabledBorder: OutlineInputBorder(
                  borderSide:
                      const BorderSide(color: Colors.transparent, width: 0.8),
                  borderRadius:
                      BorderRadius.circular(widget.borderRadius ?? 8)),
            ),
            keyboardType: widget.keyboardType,
          )
        ],
      ),
    );
  }
}

class PhoneField extends StatefulWidget {
  final String? hintText;
  final String? Function(String?)? validator;
  final String? hint;
  final String? labelText;
  final bool readonly;
  final bool borderless;
  final bool isPassword;
  final Widget? suffixIcon;
  final EdgeInsets? contentPadding;
  final Widget? label;
  final Widget? prefix;
  final double? textSize;
  final Color? hintColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final int? maxLength;
  final int maxHeight;
  final bool? haveText;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onEditingComplete;
  final Function(String)? onFieldSubmitted;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatter;

  const PhoneField(
      {Key? key,
      this.readonly = false,
      this.borderless = false,
      this.isPassword = false,
      this.hintText,
      this.hint,
      this.onChanged,
      this.controller,
      this.keyboardType = TextInputType.text,
      this.onTap,
      this.onEditingComplete,
      this.onFieldSubmitted,
      this.inputFormatter,
      this.validator,
      this.autofillHints,
      this.suffixIcon,
      this.textSize,
      this.haveText,
      this.maxLength,
      this.labelText,
      this.label,
      this.contentPadding,
      this.prefix,
      this.maxHeight = 1,
      this.hintColor,
      this.textColor,
      this.inputFormatters})
      : super(key: key);

  @override
  State<PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<PhoneField> {
  final FocusNode _focusNode = FocusNode();
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isVisible = false;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.hintText != null
              ? Column(
                  children: [
                    AppText(
                      widget.hintText ?? "",
                      size: widget.textSize ?? 13.5,
                      color: widget.hintColor ?? ColorValues.primaryColor,
                      // isBold: true,
                      align: TextAlign.start,
                    ),
                    10.0.sbH,
                  ],
                )
              : 0.0.sbH,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IntrinsicHeight(
                child: Container(
                  padding: widget.contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 0.8,
                        color: widget.borderless
                            ? ColorValues.primaryColor.withValues(
                                alpha:
                                    51) // Replace 0.2 with alpha value (0.2 * 255 = 51)
                            : Theme.of(context)
                                .disabledColor
                                .withValues(alpha: 128),
                      )), // Replace 0.5 with alpha value (0.5 * 255 = 128)
                  child: Container(
                    height: 24,
                  ),
                ),
              ),
              10.0.sbW,
              Expanded(
                child: TextFormField(
                  textAlign: TextAlign.start,
                  validator: widget.validator,
                  autofillHints: widget.autofillHints,
                  onEditingComplete: widget.onEditingComplete,
                  onFieldSubmitted: widget.onFieldSubmitted,
                  maxLines: widget.maxHeight,
                  focusNode: _focusNode,
                  maxLength: widget.maxLength,
                  onChanged: (val) {
                    if (widget.onChanged != null) {
                      widget.onChanged!(val);
                    }
                  },
                  onTap: widget.onTap,
                  readOnly: widget.readonly,
                  obscureText: widget.isPassword ? !isVisible : false,
                  textInputAction: TextInputAction.next,
                  controller: widget.controller,
                  inputFormatters: widget.inputFormatters,
                  decoration: InputDecoration(
                    errorMaxLines: 3,
                    counter: 0.0.sbH,
                    hintText: widget.hint,
                    prefixIconColor: const Color(0xFFD9D9D9),
                    suffixIconColor: const Color(0xFFD9D9D9),
                    prefixIcon: widget.prefix == null
                        ? null
                        : SizedBox(
                            height: 40,
                            width: 40,
                            child: Align(
                                alignment: Alignment.center,
                                child: widget.prefix)),
                    suffixIcon: widget.suffixIcon ??
                        (widget.isPassword
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    isVisible = !isVisible;
                                  });
                                },
                                icon: widget.suffixIcon ??
                                    Icon(
                                      isVisible
                                          ? Iconsax.eye_slash
                                          : Iconsax.eye,
                                      size: 20,
                                    ))
                            : widget.suffixIcon),
                    label: widget.label,
                    labelText: widget.labelText,
                    labelStyle: bodyTextStyle,
                    hintStyle: hintStyle.copyWith(
                        color: widget.textColor ?? const Color(0xFFD9D9D9)),
                    isDense: true,
                    contentPadding: widget.contentPadding ??
                        const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: widget.borderless
                                ? ColorValues.primaryColor.withValues(alpha: 51)
                                : ColorValues.primaryColor,
                            width: 0.8),
                        borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 0.8,
                            color: widget.borderless
                                ? ColorValues.primaryColor.withValues(alpha: 51)
                                : Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 128)),
                        borderRadius: BorderRadius.circular(8)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: ColorValues.errorColor, width: 0.8),
                        borderRadius: BorderRadius.circular(8)),
                    errorStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w400),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: widget.borderless
                              ? Colors.transparent
                              : Colors.red),
                    ),
                  ),
                  keyboardType: widget.keyboardType,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class CustomInputText extends StatelessWidget {
  const CustomInputText({
    Key? key,
    this.inputType = TextInputType.text,
    this.textColor,
    this.color,
    this.prefix,
    this.label,
    this.onChangeVal,
    this.suffix,
    this.obscure,
    this.onChange,
    this.maxLine,
    required this.hintText,
    this.controller,
    this.validator,
    this.style,
    this.autovalidateMode,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.contentPadding,
  }) : super(key: key);
  final Widget? prefix;
  final AutovalidateMode? autovalidateMode;
  final Widget? suffix;
  final Color? color;
  final Color? textColor;
  final String? label;
  final String hintText;
  final EdgeInsetsGeometry? contentPadding;
  final bool? obscure;
  final bool readOnly;
  final Function(String)? onChanged;
  final String? onChangeVal;
  final TextInputType inputType;
  final TextEditingController? controller;
  final Function? onChange;
  final VoidCallback? onTap;
  final int? maxLine;
  final TextStyle? style;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction;

    final fontSize = style?.fontSize == null
        ? 16 / MediaQuery.textScaleFactorOf(context)
        : style!.fontSize! / MediaQuery.textScaleFactorOf(context);
    return TextFormField(
      style:
          bodyTextStyle.copyWith(color: textColor).copyWith(fontSize: fontSize),
      keyboardType: inputType,
      obscureText: obscure ?? false,
      validator: validator,
      autovalidateMode: autovalidateMode,
      textInputAction: TextInputAction.next,
      controller: controller,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      cursorColor: textColor,
      // maxLines: 1 ?? 1 ,
      decoration: InputDecoration(
        contentPadding: contentPadding ??
            const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
        prefixIcon: prefix,
        suffixIcon: suffix,
        label: label == null
            ? null
            : Text(
                textScaleFactor: 1.0,
                "$label",
                style: bodyTextStyle.copyWith(),
              ),
        hintStyle: TextStyle(color: ColorValues.primaryColor.withOpacity(.4))
            .copyWith(fontSize: fontSize),
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: color ?? ColorValues.primaryColor.withOpacity(.4),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: color ?? ColorValues.primaryColor.withValues(alpha: 102),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: color ?? ColorValues.primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(
            color: color ?? ColorValues.errorColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class CustomPhoneInputText extends StatelessWidget {
  final Function? onChange;
  final TextInputType inputType;
  final Color? borderColor;
  final Function? onSubmit;
  final Function(PhoneNumber)? onSaved;
  final Function(PhoneNumber)? onInputChanged;
  final String? isoCode;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLine;
  const CustomPhoneInputText(
      {super.key,
      this.onChange,
      this.inputType = TextInputType.text,
      this.borderColor,
      this.maxLine,
      this.validator,
      this.controller,
      this.onSubmit,
      this.onSaved,
      this.onInputChanged,
      this.isoCode,
      this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 10.0.padH,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              width: 0.8,
              color: ColorValues.primaryColor.withValues(alpha: 102))),
      child: InternationalPhoneNumberInput(
        onInputChanged: (PhoneNumber number) => onInputChanged!(number),
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        initialValue: PhoneNumber(
          isoCode:
              'NG', // Set the default country using its ISO code (e.g., 'US' for United States)
        ),
        cursorColor: ColorValues.appTextColor,
        onSaved: (PhoneNumber number) => {onSaved!(number)},
        onSubmit: () => onSubmit!(),
        textFieldController: controller,
        validator: validator,
        selectorConfig: const SelectorConfig(
          selectorType: PhoneInputSelectorType.DIALOG,
        ),
        inputDecoration: InputDecoration(
          errorMaxLines: 3,
          border: InputBorder.none,
          isDense: true,
          hintText: hint ?? "Phone Number",
          hintStyle: TextStyle(color: Theme.of(context).disabledColor),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.circular(8)),
          errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.circular(8)),
          errorStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
        ),
      ),
    );
  }
}

class CustomInputText2 extends StatelessWidget {
  final String hintText;
  final Function? onChange;
  final TextInputType inputType;
  final Color? borderColor;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final int? maxLine;
  const CustomInputText2(
      {super.key,
      required this.hintText,
      this.onChange,
      this.inputType = TextInputType.text,
      this.borderColor,
      this.maxLine,
      this.validator,
      this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLine,
      cursorColor: ColorValues.appTextColor,
      textInputAction: TextInputAction.next,
      keyboardType: inputType,
      onChanged: (value) {
        onChange!(value);
      },
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.only(bottom: 10, left: 10, right: 10, top: 10),
        hintText: hintText,
        label: AppText(hintText),
        labelStyle: bodyTextStyle.copyWith(fontSize: 15),
        hintStyle: TextStyle(color: ColorValues.greyColor),
        enabledBorder: UnderlineInputBorder(
            //<-- SEE HERE
            borderSide: BorderSide(
          width: 1.5,
          color: borderColor ?? ColorValues.greyColor.withValues(alpha: 76.5),
        )),
        focusedBorder: UnderlineInputBorder(
            //<-- SEE HERE
            borderSide: BorderSide(
                width: 1.5,
                color: borderColor ??
                    ColorValues.greyColor.withValues(alpha: 76.5))),
      ),
    );
  }
}

class NewDropDownSelect extends StatelessWidget {
  final String? hintText;
  final String? hint;
  final double? height;
  final double? textSize;
  final Color? hintColor;
  final Widget? prefix;
  final String? value;
  final List<String>? items;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String? value)? onChanged;
  const NewDropDownSelect(
      {Key? key,
      this.hintText,
      this.hint,
      this.value,
      this.items,
      this.onChanged,
      this.validator,
      this.inputFormatters,
      this.height,
      this.textSize,
      this.hintColor,
      this.prefix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        hintText == null
            ? 0.0.sbH
            : Column(
                children: [
                  AppText(
                    hintText ?? "",
                    size: textSize ?? 13.5,
                    color: hintColor ?? ColorValues.primaryColor,
                    // isBold: true,
                    align: TextAlign.start,
                  ),
                  10.0.sbH,
                ],
              ),
        Container(
          alignment: Alignment.centerLeft,
          child: DropdownButtonFormField(
            borderRadius: BorderRadius.circular(12),
            icon: const Icon(Icons.keyboard_arrow_down),
            value: value,
            items: items
                ?.map((e) => DropdownMenuItem(
                      value: e,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              softWrap: false,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            isExpanded: true,
            validator: validator,
            decoration: InputDecoration(
              errorMaxLines: 3,
              border: InputBorder.none,
              isDense: true,
              hintText: hint,
              prefix: prefix,
              prefixIconColor: ColorValues.hintTextColor,
              hintStyle: TextStyle(color: Theme.of(context).disabledColor),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: 10.0.padA,
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorValues.primaryColor, width: 0.8),
                  borderRadius: BorderRadius.circular(8)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.8,
                      color: Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 128)),
                  borderRadius: BorderRadius.circular(8)),
              errorBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: ColorValues.errorColor, width: 0.8),
                  borderRadius: BorderRadius.circular(8)),
              errorStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              focusedErrorBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class TextArea extends StatelessWidget {
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;
  final TextAlign? textAlign;
  final TextInputType? keyBoardType;
  final String? Function(String? val)? validationCallback;
  final void Function()? onEdittingComplete;
  final String? formError;
  final String label;
  final String? hintText;
  final FocusNode? focusnode;
  final TextEditingController? controller;
  final String? message;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool? obscureText;
  final Function()? clearForm;
  final Function()? onTap;
  final Function(String)? onChanged;
  final int? maxLength;
  final bool? enabled;
  final InputBorder? border;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final bool? show;
  final Color? fillColor;
  final Color? hintColor;
  final bool? showCursor;
  final bool readOnly;
  final Widget? labelRightItem;
  final TextStyle? labelStyle;
  final int? minLines;
  final int? maxLines;

  const TextArea({
    super.key,
    this.autovalidateMode,
    this.inputFormatters,
    this.textAlign,
    this.keyBoardType,
    this.onEdittingComplete,
    this.validationCallback,
    this.message,
    this.hintText,
    this.label = "",
    this.formError,
    this.focusnode,
    this.controller,
    this.clearForm,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.minLines,
    this.maxLines,
    this.enabled = true,
    this.border,
    this.enabledBorder,
    this.focusedBorder,
    this.fillColor,
    this.hintColor,
    this.showCursor,
    this.readOnly = false,
    this.labelRightItem,
    this.labelStyle,
    this.show,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        label.isEmpty || label == ""
            ? 0.0.sbH
            : AppText(
                label,
                size: 12.sp,
                color: ColorValues.primaryColor,
                align: TextAlign.start,
              ),
        label.isEmpty || label == "" ? 0.0.sbH : 8.0.sbH,
        TextField(
          showCursor: showCursor,
          readOnly: readOnly,
          maxLength: 1000,
          enabled: enabled,
          onTap: onTap,
          minLines: minLines,
          maxLines: 5,
          focusNode: focusnode,
          controller: controller,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            fillColor: show == null
                ? Theme.of(context).dividerColor.withOpacity(0.07)
                : Colors.transparent,
            counterText: '',
            hintStyle: hintStyle.copyWith(fontSize: 13),
            isDense: true,
            hintText: hintText,
            errorText: formError,
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: ColorValues.primaryDarkColor, width: 0.8),
                borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 0.8,
                    color: Theme.of(context).disabledColor.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(8)),
            errorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.deepOrange, width: 0.8),
                borderRadius: BorderRadius.circular(8)),
            errorStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
          ),
          textAlign: textAlign ?? TextAlign.start,
          inputFormatters: inputFormatters,
          keyboardType: keyBoardType,
          onChanged: onChanged,
          onEditingComplete: onEdittingComplete,
          obscureText: obscureText ?? false,
        ),
      ],
    );
  }
}
