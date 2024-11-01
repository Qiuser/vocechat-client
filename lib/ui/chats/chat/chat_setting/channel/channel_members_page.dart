import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocechat_client/app_consts.dart';
import 'package:vocechat_client/ui/app_text_styles.dart';
import 'package:vocechat_client/dao/init_dao/group_info.dart';
import 'package:vocechat_client/dao/init_dao/user_info.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/contact/contact_detail_page.dart';
import 'package:vocechat_client/ui/contact/contact_list.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vocechat_client/ui/widgets/avatar/voce_avatar_size.dart';

class ChannelMembersPage extends StatelessWidget {
  final GroupInfoM groupInfoM;

  const ChannelMembersPage(
    this.groupInfoM, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: barHeight,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.members,
            style: AppTextStyles.titleLarge),
        centerTitle: true,
        leading: CupertinoButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey97)),
      ),
      body: FutureBuilder<List<UserInfoM>?>(
        future: GroupInfoDao().getUserListByGid(groupInfoM.gid,
            groupInfoM.isPublic, groupInfoM.groupInfo.members ?? []),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ContactList(
                initUserList: snapshot.data!,
                avatarSize: VoceAvatarSize.s36,
                ownerUid: groupInfoM.groupInfo.owner,
                onlyShowInitList: true,
                onTap: (user) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ContactDetailPage(
                        userInfoM: user,
                        groupInfo: groupInfoM.groupInfo,
                      ),
                    ),
                  );
                  ;
                });
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
