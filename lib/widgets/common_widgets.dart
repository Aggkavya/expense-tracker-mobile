import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Mirrors the StatTile component from FormControls.jsx
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.accent = 'blue',
  });

  final String label;
  final String value;
  final String accent;

  Color _accentColor(BuildContext context) {
    switch (accent) {
      case 'emerald':
        return const Color(0xFF10B981);
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'slate':
        return const Color(0xFF64748B);
      case 'rose':
        return const Color(0xFFF43F5E);
      default:
        return context.appColors.brand;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final accentColor = _accentColor(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: colors.muted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: colors.text,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mirrors SectionCard from FormControls.jsx
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.eyebrow,
    required this.title,
    this.description,
    this.trailing,
    required this.child,
    this.padding,
  });

  final String? eyebrow;
  final String title;
  final String? description;
  final Widget? trailing;
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: padding ?? const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (eyebrow != null)
                        Text(
                          eyebrow!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: colors.brand,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description!,
                          style:
                              TextStyle(fontSize: 13, color: colors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Mirrors StatusBanner from FormControls.jsx
class StatusBanner extends StatelessWidget {
  const StatusBanner({
    super.key,
    required this.tone,
    required this.message,
  });

  final String tone; // 'success' | 'error' | 'warning' | 'info'
  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();

    Color bg, border, textColor;
    IconData icon;

    switch (tone) {
      case 'success':
        bg = const Color(0xFFD1FAE5);
        border = const Color(0xFF6EE7B7);
        textColor = const Color(0xFF064E3B);
        icon = Icons.check_circle_outline_rounded;
      case 'warning':
        bg = const Color(0xFFFEF3C7);
        border = const Color(0xFFFCD34D);
        textColor = const Color(0xFF78350F);
        icon = Icons.warning_amber_rounded;
      case 'error':
        bg = const Color(0xFFFFE4E6);
        border = const Color(0xFFFCA5A5);
        textColor = const Color(0xFF7F1D1D);
        icon = Icons.error_outline_rounded;
      default:
        bg = const Color(0xFFDBEAFE);
        border = const Color(0xFF93C5FD);
        textColor = const Color(0xFF1E3A8A);
        icon = Icons.info_outline_rounded;
    }

    // Dark mode adjustments
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      switch (tone) {
        case 'success':
          bg = const Color(0xFF052E16).withOpacity(0.6);
          border = const Color(0xFF166534).withOpacity(0.6);
          textColor = const Color(0xFF86EFAC);
        case 'warning':
          bg = const Color(0xFF422006).withOpacity(0.6);
          border = const Color(0xFF92400E).withOpacity(0.6);
          textColor = const Color(0xFFFCD34D);
        case 'error':
          bg = const Color(0xFF450A0A).withOpacity(0.6);
          border = const Color(0xFF991B1B).withOpacity(0.6);
          textColor = const Color(0xFFFCA5A5);
        default:
          bg = const Color(0xFF1E3A8A).withOpacity(0.3);
          border = const Color(0xFF1D4ED8).withOpacity(0.4);
          textColor = const Color(0xFF93C5FD);
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}

/// A styled dropdown field
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.muted,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          items: items,
          hint: hint != null
              ? Text(hint!,
                  style: TextStyle(color: colors.muted, fontSize: 14))
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: colors.surfaceSoft,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colors.border),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
          dropdownColor: colors.surface,
          style: TextStyle(color: colors.text, fontSize: 14),
        ),
      ],
    );
  }
}

/// A styled text field
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.placeholder,
    this.validator,
    this.minLines,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.suffix,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? placeholder;
  final String? Function(String?)? validator;
  final int? minLines;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.muted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          enabled: enabled,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          validator: validator,
          style: TextStyle(color: colors.text, fontSize: 14),
          decoration: InputDecoration(
            hintText: placeholder,
            suffixIcon: suffix,
            prefixIcon: prefix,
            filled: true,
            fillColor:
                enabled ? colors.surfaceSoft : colors.surfaceSoft.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

/// Primary action button
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
