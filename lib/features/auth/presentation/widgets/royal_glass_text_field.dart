import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Figma input: height 56, radius 16, glass gradient + blur, gold border.
class RoyalGlassTextField extends StatefulWidget {
  const RoyalGlassTextField({
    super.key,
    required this.icon,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.textInputAction,
  });

  final IconData icon;
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  State<RoyalGlassTextField> createState() => _RoyalGlassTextFieldState();
}

class _RoyalGlassTextFieldState extends State<RoyalGlassTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _obscure = widget.obscureText;
  }

  void _onFocusChange() {
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        _focused ? AppColors.accentGold : AppColors.goldBorder;
    final iconColor = _focused ? AppColors.accentGold : AppColors.creamDim;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(1, 50, 32, 0.5),
                Color.fromRGBO(13, 17, 23, 0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: _focused
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(212, 175, 55, 0.12),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsetsDirectional.only(
            start: 16,
            end: widget.obscureText ? 8 : 16,
          ),
          child: Row(
            children: [
              Icon(widget.icon, size: 18, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText && _obscure,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textCream,
                        fontSize: 14,
                      ),
                  cursorColor: AppColors.accentGold,
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.hintText,
                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textCream.withValues(alpha: 0.45),
                          fontSize: 14,
                        ),
                  ),
                ),
              ),
              if (widget.obscureText)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    size: 18,
                    color: AppColors.creamDim,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
