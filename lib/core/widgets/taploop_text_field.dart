import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme_extensions.dart';

class TapLoopTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;

  const TapLoopTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
  });

  @override
  State<TapLoopTextField> createState() => _TapLoopTextFieldState();
}

class _TapLoopTextFieldState extends State<TapLoopTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      maxLines: _obscured ? 1 : widget.maxLines,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      style: TextStyle(fontSize: 15, color: context.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: context.textSecondary,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : widget.suffixIcon,
      ),
    );
  }
}
