import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vocechat_client/api/lib/admin_user_api.dart';
import 'package:vocechat_client/api/lib/user_api.dart';
import 'package:vocechat_client/api/models/group/group_info.dart';
import 'package:vocechat_client/app.dart';
import 'package:vocechat_client/app_consts.dart';
import 'package:vocechat_client/dao/init_dao/contacts.dart';
import 'package:vocechat_client/dao/init_dao/user_info.dart';
import 'package:vocechat_client/models/ui_models/chat_page_controller.dart';
import 'package:vocechat_client/services/voce_chat_service.dart';
import 'package:vocechat_client/shared_funcs.dart';
import 'package:vocechat_client/ui/app_alert_dialog.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/chats/chat/input_field/app_mentions.dart';
import 'package:vocechat_client/ui/chats/chat/voce_chat_page.dart';
import 'package:vocechat_client/ui/widgets/app_banner_button.dart';
import 'package:vocechat_client/ui/widgets/app_busy_dialog.dart';
import 'package:vocechat_client/ui/widgets/avatar/voce_avatar_size.dart';
import 'package:vocechat_client/ui/widgets/avatar/voce_user_avatar.dart';
import 'package:vocechat_client/ui/widgets/avatar_info_tile.dart';

class ContactDetailPage extends StatefulWidget {
  final UserInfoM userInfoM;
  final GroupInfo? groupInfo;

  late final bool isOwner;

  ContactDetailPage({
    super.key,
    required this.userInfoM,
    this.groupInfo,
  }) {
    isOwner = groupInfo?.owner != null &&
        groupInfo?.owner == App.app.userDb?.userInfo.uid;
  }

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  final ValueNotifier<bool> _isBusy = ValueNotifier(false);

  final ValueNotifier<UserInfoM> _userInfoMNotifier =
      ValueNotifier(UserInfoM());

  final ValueNotifier<bool> enableContact = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();

    _userInfoMNotifier.value = widget.userInfoM;

    enableContact.value =
        App.app.chatServerM.properties.commonInfo?.contactVerificationEnable ==
            true;
    App.app.chatService.subscribeChatServer((chatServerM) async {
      enableContact.value =
          chatServerM.properties.commonInfo?.contactVerificationEnable == true;
    });

    App.app.chatService.subscribeUsers(_onUser);
  }

  @override
  void dispose() {
    super.dispose();

    App.app.chatService.unsubscribeUsers(_onUser);
    App.app.chatService.unsubscribeChatServer((chatServerM) async {
      enableContact.value =
          chatServerM.properties.commonInfo?.contactVerificationEnable == true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.pageBg,
        appBar: _buildBar(context),
        body: SafeArea(
            child: Stack(
          children: [
            ValueListenableBuilder<UserInfoM>(
                valueListenable: _userInfoMNotifier,
                builder: (context, userInfoM, _) {
                  return ListView(
                    children: [
                      _buildUserInfo(userInfoM),
                      _buildSettings(userInfoM, context)
                    ],
                  );
                }),
            BusyDialog(busy: _isBusy)
          ],
        )));
  }

  AppBar _buildBar(BuildContext context) {
    return AppBar(
      toolbarHeight: barHeight,
      elevation: 0,
      backgroundColor: AppColors.barBg,
      leading: CupertinoButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios_new, color: AppColors.grey97)),
    );
  }

  Widget _buildUserInfo(UserInfoM userInfoM) {
    final userInfo = userInfoM.userInfo;
    final showEmail = widget.groupInfo == null ||
        isAdmin() ||
        widget.isOwner ||
        widget.groupInfo?.showEmail == true;

    return AvatarInfoTile(
      avatar: VoceUserAvatar.user(
          userInfoM: userInfoM,
          size: VoceAvatarSize.s84,
          enableOnlineStatus: true),
      title: userInfo.name,
      subtitle: showEmail ? userInfo.email : null,
    );
  }

  Widget _buildSettings(UserInfoM userInfoM, BuildContext context) {
    final titleText = userInfoM.contactStatusStr != ContactStatus.blocked.name
        ? AppLocalizations.of(context)!.sendMessage
        : AppLocalizations.of(context)!.viewChatHistory;

    final enableAddFriend = widget.groupInfo == null ||
        isAdmin() ||
        widget.isOwner ||
        widget.groupInfo?.addFriend == true;

    final enableDm = widget.groupInfo == null ||
        isAdmin() ||
        widget.isOwner ||
        widget.groupInfo?.dmToMember == true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          if (enableDm)
            AppBannerButton(
                title: titleText,
                textColor: AppColors.primaryBlue,
                onTap: () {
                  onTapDm(userInfoM, context);
                }),
          if (enableAddFriend)
            ValueListenableBuilder<bool>(
                valueListenable: enableContact,
                builder: (context, enableContact, _) {
                  if (enableContact) {
                    return _buildRemoveBtn(context);
                  } else {
                    return SizedBox.shrink();
                  }
                }),
          if (enableDm)
            ValueListenableBuilder<bool>(
                valueListenable: enableContact,
                builder: (context, enableContact, _) {
                  if (enableContact) {
                    return _buildBlockBtn(context);
                  } else {
                    return SizedBox.shrink();
                  }
                }),
          if (isAdmin())
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: AppBannerButton(
                  title: AppLocalizations.of(context)!.removeFromServer,
                  textColor: AppColors.systemRed,
                  onTap: () {
                    onTapRemoveUserFromServer(userInfoM, context);
                  }),
            ),
        ],
      ),
    );
  }

  bool isAdmin() {
    return App.app.userDb?.userInfo.isAdmin == true;
  }

  Widget _buildBlockBtn(BuildContext context) {
    if (_showBlockBtn) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: AppBannerButton(
            title: AppLocalizations.of(context)!.block,
            textColor: AppColors.systemRed,
            onTap: () {
              onTapBlock(context);
            }),
      );
    } else if (_showUnblockBtn) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: AppBannerButton(
            title: AppLocalizations.of(context)!.unblock,
            textColor: AppColors.systemRed,
            onTap: () {
              onTapUnblock(context);
            }),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildRemoveBtn(BuildContext context) {
    if (_showRemoveBtn) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: AppBannerButton(
            title: AppLocalizations.of(context)!.removeContact,
            textColor: AppColors.systemRed,
            onTap: () {
              onTapRemove(context);
            }),
      );
    } else if (_showAddBtn) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: AppBannerButton(
            title: AppLocalizations.of(context)!.addContact,
            textColor: AppColors.primaryBlue,
            onTap: () {
              onTapAdd(context);
            }),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  bool get _showBlockBtn =>
      (!SharedFuncs.isSelf(_userInfoMNotifier.value.uid)) &&
      _userInfoMNotifier.value.contactStatusStr != ContactStatus.blocked.name;

  bool get _showUnblockBtn =>
      (!SharedFuncs.isSelf(_userInfoMNotifier.value.uid)) &&
      _userInfoMNotifier.value.contactStatusStr == ContactStatus.blocked.name;

  bool get _showRemoveBtn =>
      (!SharedFuncs.isSelf(_userInfoMNotifier.value.uid)) &&
      _userInfoMNotifier.value.contactStatusStr == ContactStatus.added.name;

  bool get _showAddBtn =>
      !SharedFuncs.isSelf(_userInfoMNotifier.value.uid) &&
      _userInfoMNotifier.value.contactStatusStr == ContactStatus.none.name;

  void onTapDm(UserInfoM userInfoM, BuildContext context) async {
    GlobalKey<AppMentionsState> mentionsKey = GlobalKey<AppMentionsState>();
    ChatPageController controller =
        ChatPageController.user(userInfoMNotifier: _userInfoMNotifier);
    controller.prepare().then((value) {
      Navigator.push(
          context,
          MaterialPageRoute<String?>(
              builder: (context) => VoceChatPage.user(
                  mentionsKey: mentionsKey,
                  controller: controller))).then((value) async {
        final draft = mentionsKey.currentState?.controller?.text.trim();

        await UserInfoDao()
            .updateProperties(_userInfoMNotifier.value.uid, draft: draft)
            .then((updatedUserInfoM) {
          if (updatedUserInfoM != null) {
            App.app.chatService
                .fireUser(updatedUserInfoM, EventActions.update, true);
          }
        });
        controller.dispose();
      });
    });
  }

  void onTapRemoveUserFromServer(
      UserInfoM userInfoM, BuildContext context) async {
    await showAppAlert(
        context: context,
        title: AppLocalizations.of(context)!.removeFromServer,
        content: AppLocalizations.of(context)!.removeFromServerWarning,
        actions: [
          AppAlertDialogAction(
              text: AppLocalizations.of(context)!.cancel,
              action: () {
                Navigator.pop(context);
              }),
        ],
        primaryAction: AppAlertDialogAction(
            text: AppLocalizations.of(context)!.continueStr,
            isDangerAction: true,
            action: () async {
              removeContactFromServer(userInfoM);
            }));
  }

  void removeContactFromServer(UserInfoM userInfoM) async {
    showBusyDialog();

    await AdminUserApi().deleteUser(userInfoM.uid).then((res) async {
      if (res.statusCode == 200) {
        await UserInfoDao().removeByUid(userInfoM.uid).then((_) {
          App.app.chatService.fireUser(userInfoM, EventActions.delete, true);
          dismissBusyDialog();
          Navigator.pop(context);
        });
      } else {
        dismissBusyDialog();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.networkError)));
      }
    }).onError((error, stackTrace) {
      App.logger.severe(error);
      dismissBusyDialog();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)));
    });
  }

  void showBusyDialog() {
    _isBusy.value = true;
  }

  void dismissBusyDialog() {
    _isBusy.value = false;
  }

  /// Blocks contact and also remove contact from contact list.
  ///
  /// The contact cannot chat with you once he/she is blocked.
  void onTapBlock(BuildContext context) async {
    await showAppAlert(
      context: context,
      title: AppLocalizations.of(context)!.block,
      content: AppLocalizations.of(context)!.blockWarning,
      actions: [
        AppAlertDialogAction(
            text: AppLocalizations.of(context)!.cancel,
            action: () {
              Navigator.pop(context);
            }),
      ],
      primaryAction: AppAlertDialogAction(
          text: AppLocalizations.of(context)!.continueStr,
          isDangerAction: true,
          action: () async {
            Navigator.pop(context);
            await blockContact();
          }),
    );
  }

  /// Blocks contact and also remove contact from contact list.
  ///
  /// The contact cannot chat with you once he/she is blocked.
  void onTapUnblock(BuildContext context) async {
    await unblockContact();
  }

  /// Only remove contact from contact list.
  ///
  /// All messages will be kept.
  /// Still can chat with this contact.
  void onTapRemove(BuildContext context) async {
    await showAppAlert(
        context: context,
        title: AppLocalizations.of(context)!.removeContact,
        content: AppLocalizations.of(context)!.removeContactWarning,
        actions: [
          AppAlertDialogAction(
              text: AppLocalizations.of(context)!.cancel,
              action: () {
                Navigator.pop(context);
              }),
        ],
        primaryAction: AppAlertDialogAction(
            text: AppLocalizations.of(context)!.continueStr,
            isDangerAction: true,
            action: () async {
              Navigator.pop(context);
              await removeContact();
            }));
  }

  /// Adds contact to contact list.
  ///
  /// Do not need alert for now.
  void onTapAdd(BuildContext context) async {
    await addContact();
  }

  Future<void> blockContact() async {
    // Remove contact from contact list.
    // All messages will be kept.
    showBusyDialog();

    await UserApi()
        .updateContactStatus(
            _userInfoMNotifier.value.uid, ContactUpdateAction.block)
        .then((res) async {
      if (res.statusCode == 200) {
        await ContactDao()
            .updateContact(_userInfoMNotifier.value.uid, ContactStatus.blocked)
            .then((upatedContactM) async {
          dismissBusyDialog();
        });
      } else {
        dismissBusyDialog();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.networkError)));
      }
    }).onError((error, stackTrace) {
      App.logger.severe(error);
      dismissBusyDialog();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)));
    });
  }

  Future<void> unblockContact() async {
    showBusyDialog();

    await UserApi()
        .updateContactStatus(
            _userInfoMNotifier.value.uid, ContactUpdateAction.unblock)
        .then((res) async {
      if (res.statusCode == 200) {
        await ContactDao()
            .updateContact(_userInfoMNotifier.value.uid, ContactStatus.none)
            .then((upatedContactM) async {
          dismissBusyDialog();
        });
      } else {
        dismissBusyDialog();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.networkError)));
      }
    }).onError((error, stackTrace) {
      App.logger.severe(error);
      dismissBusyDialog();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)));
    });
  }

  Future<void> removeContact() async {
    // Remove contact from contact list.
    // All messages will be kept.
    showBusyDialog();

    await UserApi()
        .updateContactStatus(
            _userInfoMNotifier.value.uid, ContactUpdateAction.remove)
        .then((res) async {
      if (res.statusCode == 200) {
        await ContactDao()
            .updateContact(_userInfoMNotifier.value.uid, ContactStatus.none)
            .then((upatedContactM) async {
          dismissBusyDialog();
        });
      } else {
        dismissBusyDialog();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.networkError)));
      }
    }).onError((error, stackTrace) {
      App.logger.severe(error);
      dismissBusyDialog();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)));
    });
  }

  Future<void> addContact() async {
    showBusyDialog();

    await UserApi()
        .updateContactStatus(
            _userInfoMNotifier.value.uid, ContactUpdateAction.add)
        .then((res) async {
      if (res.statusCode == 200) {
        await ContactDao()
            .updateContact(_userInfoMNotifier.value.uid, ContactStatus.added)
            .then((upatedContactM) async {
          dismissBusyDialog();
        });
      } else {
        dismissBusyDialog();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context)!.networkError)));
      }
    }).onError((error, stackTrace) {
      App.logger.severe(error);
      dismissBusyDialog();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.networkError)));
    });
  }

  Future<void> _onUser(
      UserInfoM userInfoM, EventActions action, bool afterReady) async {
    if (userInfoM.uid != widget.userInfoM.uid) {
      return;
    }

    if (action == EventActions.delete) {
      Navigator.pop(context);
      return;
    }

    _userInfoMNotifier.value = userInfoM;

    if (mounted) {
      setState(() {});
    }
  }
}
