import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/app_text_styles.dart';

// ignore: must_be_immutable
class BannerTile extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enableTap;
  final String title;

  /// If set, it's located after title string, forming a row.
  final Widget? titleWidget;
  final bool keepTitle;
  final Widget? trailing;
  final bool keepTrailingArrow;
  final String? header;
  final String? footer;
  final double? height;
  bool showVerticalEdge;

  BannerTile(
      {this.onTap,
      this.enableTap = true,
      required this.title,
      this.titleWidget,
      this.keepTitle = true,
      this.trailing,
      this.keepTrailingArrow = true,
      this.showVerticalEdge = true,
      this.header,
      this.footer,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null && header!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 4),
              child: Text(header!,
                  style: TextStyle(
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w500,
                      fontSize: 14))),
        Container(
          height: height ?? 48,
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: Colors.white,
              border: showVerticalEdge
                  ? Border.symmetric(
                      horizontal: BorderSide(
                          width: 0.5,
                          color: CupertinoColors.systemGroupedBackground))
                  : null),
          child: TextButton(
            onPressed: enableTap ? onTap : null,
            style: ElevatedButton.styleFrom(
              splashFactory: NoSplash.splashFactory,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (keepTitle)
                    Text(title, style: AppTextStyles.listTileTitle),
                  if (titleWidget != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: titleWidget!,
                    ),
                  Spacer(),
                  if (trailing != null) trailing!,
                  if (keepTrailingArrow)
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(Icons.arrow_forward_ios,
                          color: AppColors.labelColorLightTri, size: 16),
                    )
                ],
              ),
            ),
          ),
        ),
        if (footer != null && footer!.isNotEmpty)
          Padding(
              padding: EdgeInsets.only(left: 16, top: 4, bottom: 8),
              child: Text(footer!,
                  style: TextStyle(
                      color: AppColors.grey400,
                      fontWeight: FontWeight.w400,
                      fontSize: 13))),
      ],
    );
  }
}
