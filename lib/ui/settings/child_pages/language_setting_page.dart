import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vocechat_client/app.dart';
import 'package:vocechat_client/app_consts.dart';
import 'package:vocechat_client/helpers/shared_preference_helper.dart';
import 'package:vocechat_client/main.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/app_icons_icons.dart';
import 'package:vocechat_client/ui/app_text_styles.dart';
import 'package:vocechat_client/ui/widgets/banner_tile/banner_tile.dart';

class LanguageSettingPage extends StatefulWidget {
  @override
  State<LanguageSettingPage> createState() => _LanguageSettingPageState();
}

class _LanguageSettingPageState extends State<LanguageSettingPage> {
  // Please keep Locale consistant with the ones in main.dart
  final List<LanguageItem> languageList = [
    LanguageItem(language: "简体中文", locale: Locale('zh', '')),
    LanguageItem(language: "English", locale: Locale('en', ''))
  ];

  final ValueNotifier<bool> _isUpdatingLanguage = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(AppLocalizations.of(context)!.language,
                  style: AppTextStyles.titleLarge,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _isUpdatingLanguage,
              builder: (context, value, child) {
                if (value) {
                  return Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: CupertinoActivityIndicator());
                } else {
                  return SizedBox.shrink();
                }
              },
            )
          ],
        ),
        toolbarHeight: barHeight,
        elevation: 0,
        backgroundColor: AppColors.barBg,
        leading: CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey97)),
        // actions: [
        //   CupertinoButton(
        //       onPressed: _onSubmit,
        //       child: Text(AppLocalizations.of(context)!.done,
        //           style: TextStyle(
        //               fontWeight: FontWeight.w400,
        //               fontSize: 17,
        //               color: AppColors.primaryBlue)))
        // ],
      ),
      body: SafeArea(
          child: ValueListenableBuilder<bool>(
              valueListenable: _isUpdatingLanguage,
              builder: (context, isUpdating, _) {
                return AbsorbPointer(
                    absorbing: isUpdating, child: _buildLanguages());
              })),
    );
  }

  Widget _buildLanguages() {
    return ListView(
      children: List.generate(languageList.length, (index) {
        final lang = languageList[index];
        final appLocale = Localizations.localeOf(context);

        final selected = appLocale == lang.locale;

        return BannerTile(
          title: lang.language,
          keepTrailingArrow: false,
          trailing: selected
              ? Icon(AppIcons.select, color: AppColors.primaryBlue)
              : SizedBox.shrink(),
          onTap: () => _onTapLanguage(lang.locale),
        );
      }),
    );
  }

  void _onTapLanguage(Locale locale) async {
    _isUpdatingLanguage.value = true;

    try {
      await SharedPreferenceHelper.setString("locale", locale.languageCode)
          .then((value) {
        VoceChatApp.of(context)?.setUILocale(locale);
      });
    } catch (e) {
      App.logger.severe(e);
    }

    _isUpdatingLanguage.value = false;
  }
}

class LanguageItem {
  final String language;
  final Locale locale;

  LanguageItem({required this.language, required this.locale});
}
