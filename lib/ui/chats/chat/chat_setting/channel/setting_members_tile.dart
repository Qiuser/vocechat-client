import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vocechat_client/app.dart';
import 'package:vocechat_client/dao/init_dao/group_info.dart';
import 'package:vocechat_client/dao/init_dao/user_info.dart';
import 'package:vocechat_client/services/voce_chat_service.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/chats/chat/chat_setting/channel/channel_members_page.dart';
import 'package:vocechat_client/ui/chats/chat/chat_setting/channel/owner_transfer_page.dart';
import 'package:vocechat_client/ui/chats/chat/chat_setting/invite/member_add_page.dart';
import 'package:vocechat_client/ui/chats/chat/chat_setting/invite/member_remove_page.dart';
import 'package:vocechat_client/ui/contact/contact_detail_page.dart';
import 'package:vocechat_client/ui/widgets/avatar/voce_avatar_size.dart';
import 'package:vocechat_client/ui/widgets/avatar/voce_user_avatar.dart';
import 'package:vocechat_client/ui/widgets/banner_tile/banner_tile.dart';

class SettingMembersTile extends StatefulWidget {
  final ValueNotifier<GroupInfoM> groupInfoMNotifier;

  const SettingMembersTile({super.key, required this.groupInfoMNotifier});

  @override
  State<SettingMembersTile> createState() => _SettingMembersTileState();
}

class _SettingMembersTileState extends State<SettingMembersTile> {
  late ValueNotifier<Set<UserInfoM>> memberSetNotifier = ValueNotifier({});
  late ValueNotifier<int> memberCountNotifier = ValueNotifier(0);

  late int serverUserCount =
      widget.groupInfoMNotifier.value.groupInfo.members?.length ?? 0;

  @override
  void initState() {
    super.initState();
    prepareMemberCount();
    prepareMembers();
    App.app.chatService.subscribeGroups(_onGroup);
  }

  @override
  void dispose() {
    App.app.chatService.unsubscribeGroups(_onGroup);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isOwner =
        App.app.userDb?.uid == widget.groupInfoMNotifier.value.groupInfo.owner;
    bool isAdmin = App.app.userDb?.userInfo.isAdmin ?? false;

    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border.symmetric(
              horizontal:
                  BorderSide(color: CupertinoColors.systemGroupedBackground))),
      child: Column(
        children: [
          BannerTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return ChannelMembersPage(widget.groupInfoMNotifier.value);
                },
              ));
            },
            showVerticalEdge: widget.groupInfoMNotifier.value.isPublic,
            title: AppLocalizations.of(context)!.members,
            trailing: ValueListenableBuilder<int>(
                valueListenable: memberCountNotifier,
                builder: (context, memberCount, _) {
                  return Text(min(serverUserCount, memberCount).toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 17,
                          color: AppColors.labelColorLightSec));
                }),
          ),
          if (!widget.groupInfoMNotifier.value.isPublic)
            const Divider(indent: 16),
          if (!widget.groupInfoMNotifier.value.isPublic)
            Column(
              children: [
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ValueListenableBuilder<Set<UserInfoM>>(
                      valueListenable: memberSetNotifier,
                      builder: (context, memberSet, _) {
                        // Max num. of items the widget could contain.
                        // 52 = paddings * 2 + size = 8 * 2 + 36
                        int count =
                            ((MediaQuery.of(context).size.width - 16) / 52)
                                .floor();

                        List<UserInfoM> memberList;
                        MainAxisAlignment align;
                        int actionButtonCount = (isAdmin || isOwner) ? 2 : 1;

                        if (memberSet.length + actionButtonCount >= count) {
                          memberList = memberSet
                              .toList()
                              .sublist(0, count - actionButtonCount);
                          align = MainAxisAlignment.spaceAround;
                        } else {
                          memberList = memberSet.toList();
                          align = MainAxisAlignment.start;
                        }

                        return Row(
                          mainAxisAlignment: align,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List<Widget>.generate(
                              memberList.length + actionButtonCount, (index) {
                            // Add (invite) button.
                            if (index == memberList.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8))),
                                        builder: (sheetContext) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.9,
                                            child: MemberAddPage(
                                                widget.groupInfoMNotifier),
                                          );
                                        });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.5,
                                            color: AppColors.grey400),
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: Icon(
                                      Icons.add,
                                      size: 33,
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ),
                              );
                            } else if ((isAdmin || isOwner) &&
                                index == memberList.length + 1) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(8),
                                                topRight: Radius.circular(8))),
                                        builder: (sheetContext) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.9,
                                            child: MemberRemovePage(
                                                widget.groupInfoMNotifier),
                                          );
                                        });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1.5,
                                            color: AppColors.grey400),
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    child: Icon(
                                      Icons.remove_outlined,
                                      size: 33,
                                      color: AppColors.grey400,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final user = memberList[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ContactDetailPage(
                                        userInfoM: user,
                                        groupInfo: widget.groupInfoMNotifier
                                            .value.groupInfo),
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: VoceUserAvatar.user(
                                    userInfoM: user, size: VoceAvatarSize.s36),
                              ),
                            );
                          }),
                        );
                      }),
                )
              ],
            ),
          if (!widget.groupInfoMNotifier.value.isPublic && (isAdmin || isOwner))
            const Divider(indent: 16),
          if (!widget.groupInfoMNotifier.value.isPublic && (isAdmin || isOwner))
            BannerTile(
                showVerticalEdge: false,
                title: AppLocalizations.of(context)!.transferOwnership,
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OwnerTransferPage(
                          groupInfoM: widget.groupInfoMNotifier.value)));
                })
        ],
      ),
    );
  }

  Future<void> _onGroup(
      GroupInfoM groupInfoM, EventActions action, bool afterReady) async {
    if (groupInfoM.gid != widget.groupInfoMNotifier.value.gid) {
      return;
    }

    if (action == EventActions.update) {
      if (groupInfoM.isPublic) {
        memberCountNotifier.value = await UserInfoDao().getUserCount();
      } else {
        memberCountNotifier.value = groupInfoM.groupInfo.members?.length ?? 0;
      }
      int count = ((MediaQuery.of(context).size.width - 16) / 52).floor();
      final users = (await GroupInfoDao().getUserListByGid(groupInfoM.gid,
              groupInfoM.isPublic, groupInfoM.groupInfo.members ?? [],
              batchSize: count - 1)) ??
          [];

      // print(groupInfoM.groupInfo.members);
      memberSetNotifier.value = Set.from(users);
    }
    return;
  }

  void prepareMemberCount() async {
    serverUserCount = await UserInfoDao().getUserCount();
    if (widget.groupInfoMNotifier.value.groupInfo.isPublic) {
      memberCountNotifier.value = serverUserCount;
    } else {
      memberCountNotifier.value = min(serverUserCount,
          widget.groupInfoMNotifier.value.groupInfo.members?.length ?? 0);
    }
  }

  void prepareMembers() async {
    final members = (await GroupInfoDao().getUserListByGid(
            widget.groupInfoMNotifier.value.gid,
            widget.groupInfoMNotifier.value.groupInfo.isPublic,
            widget.groupInfoMNotifier.value.groupInfo.members ?? [],
            batchSize: 6)) ??
        [];

    memberSetNotifier.value = Set.from(members);
  }
}
