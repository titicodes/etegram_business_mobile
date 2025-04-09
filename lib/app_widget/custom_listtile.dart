import 'package:etegram_business/utils/widget_extension.dart';
import 'package:flutter/material.dart';

class NxListTile extends StatelessWidget {
  const NxListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.padding,
    this.bgColor,
    this.onTap,
    this.onLongPressed,
    this.trailing,
    this.borderRadius,
    this.leadingFlex,
    this.titleFlex,
    this.trailingFlex,
    this.showBorder = true,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsets? padding;
  final Color? bgColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPressed;
  final BorderRadius? borderRadius;
  final int? leadingFlex;
  final int? titleFlex;
  final int? trailingFlex;
  final bool? showBorder;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPressed,
      child: Container(
        padding: padding ?? EdgeInsets.all(12),
        width: width(context),
        constraints: BoxConstraints(
          maxWidth: width(context),
        ),
        decoration: BoxDecoration(
          color: bgColor ?? Theme.of(context).dialogTheme.backgroundColor,
          borderRadius: borderRadius ?? BorderRadius.circular(0),
          border: showBorder == true
              ? Border.all(
            color: Theme.of(context).dividerColor,
            width: 0.8,
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null)
                    Expanded(flex: leadingFlex ?? 0, child: leading!),
                  if (leading != null && (title != null || subtitle != null))
                    16.0.sbW,
                  Expanded(
                    flex: titleFlex ?? 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null) title!,
                        if (title != null && subtitle != null)
                          4.0.sbH,
                        if (subtitle != null) subtitle!
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) 12.0.sbW,
            if (trailing != null)
              Expanded(
                flex: trailingFlex ?? 0,
                child: trailing!,
              ),
          ],
        ),
      ),
    );
  }
}
