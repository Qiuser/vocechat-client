import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocechat_client/api/lib/group_api.dart';
import 'package:vocechat_client/app.dart';
import 'package:vocechat_client/app_alert_dialog.dart';
import 'package:vocechat_client/app_text_styles.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:voce_widgets/voce_widgets.dart';
import 'package:vocechat_client/ui/chats/chats/new/invite_email_page.dart';
import 'package:vocechat_client/ui/widgets/sheet_app_bar.dart';

class InviteUserPage extends StatefulWidget {
  @override
  State<InviteUserPage> createState() => _InviteUserPageState();
}

class _InviteUserPageState extends State<InviteUserPage> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SheetAppBar(
            title: Text(
              "Invite People",
              style: AppTextStyles.titleLarge,
            ),
            leading: CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close, color: AppColors.grey97)),
            // actions: [_buildAddBtn()],
          ),
          Flexible(child: _buildInvitationChoices())
          // Flexible(child: _buildMembersTab())
        ],
      ),
    );
  }

  Widget _buildInvitationChoices() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          /*
          VoceButton(
            width: double.maxFinite,
            contentColor: Colors.white,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8)),
            normal: Text(
              "Invite by Email",
              style: TextStyle(color: Colors.white),
            ),
            action: () async {
              Navigator.of(context).pop();
              final route = PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    InviteEmailPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(0.0, 1.0);
                  const end = Offset.zero;
                  const curve = Curves.fastOutSlowIn;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              );
              await Navigator.push(context, route);
              return true;
            },
          ),
          SizedBox(height: 18),
          */
          VoceButton(
            width: double.maxFinite,
            contentColor: Colors.white,
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8)),
            normal: Text(
              "Copy Invitation Link",
              style: TextStyle(color: Colors.white),
            ),
            action: () async {
              _shareInvitationLink();
              return true;
            },
          ),
          SizedBox(height: 4),
          Text("Link expires in 1 hour. For single use only.",
              style: AppTextStyles.labelMedium)
        ],
      ),
    );
  }

  void _shareInvitationLink() async {
    final link = await _generateInvitationMagicLink();
    if (link == null || link.isEmpty) {
      showAppAlert(
          context: context,
          title: "Unable to generate link",
          content: "Please try later or contact server admins for help.",
          actions: [
            AppAlertDialogAction(
                text: "OK", action: () => Navigator.of(context).pop())
          ]);
    } else {
      Share.share(link);
    }

    Navigator.of(context).pop();
  }

  Future<String?> _generateInvitationMagicLink() async {
    final groupApi = GroupApi(App.app.chatServerM.fullUrl);
    final res = await groupApi.getRegMagicLink();

    if (res.statusCode == 200) {
      return res.data as String;
    }
    return null;
  }
}
