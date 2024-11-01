import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vocechat_client/api/models/msg/reaction_info.dart';
import 'package:vocechat_client/app.dart';
import 'package:vocechat_client/app_consts.dart';
import 'package:vocechat_client/dao/init_dao/chat_msg.dart';
import 'package:vocechat_client/ui/app_colors.dart';
import 'package:vocechat_client/ui/chats/chat/msg_actions/msg_action_tile.dart';

class MsgActionsSheet extends StatelessWidget {
  // final Widget msgTile;
  final void Function(String reaction) onReaction;
  final List<MsgActionTile> actions;
  final Set<ReactionInfo>? existingReactions;
  final ChatMsgM chatMsgM;

  late final Set<String> _reactions = {};

  final _emojiList = ["👍", "👎", "😄", "🎉", "🙁", "❤️", "🚀", "👀"];
  final double _iconSize = 36;
  final double _emojiSize = 24;

  MsgActionsSheet(
      {
      // required this.msgTile,
      required this.onReaction,
      required this.actions,
      required this.existingReactions,
      required this.chatMsgM}) {
    if (existingReactions != null) {
      for (var react in existingReactions!) {
        if (react.fromUid == App.app.userDb!.uid) {
          _reactions.add(react.emoji);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8))),
      child: SafeArea(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // msgTile,
            _buildTopBar(),
            // _buildTextCopyBubble(),
            if (chatMsgM.statusStr == MsgStatus.success.name)
              _buildReactions(context),
            if (chatMsgM.statusStr == MsgStatus.success.name) const Divider(),
            _buildActions()
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
        height: 24,
        child: Center(
          child: Container(
              width: 48,
              height: 6,
              decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(25))),
        ));
  }

  Widget _buildReactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(8, (index) {
              final emoji = _emojiList[index];
              final svgPath = "assets/images/react_${index + 1}.svg";
              final isSelected = _reactions.contains(emoji);
              return _emojiIcon(isSelected, svgPath, emoji, context);
            }),
          ),
        ),
      ),
    );
  }

  Widget _emojiIcon(
      bool isSelected, String svgPath, String emoji, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: _iconSize,
        width: _iconSize,
        decoration: BoxDecoration(
            color: isSelected
                ? AppColors.coolGrey500.withAlpha(150)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10)),
        child: IconButton(
            onPressed: () {
              // Navigator.pop(context);
              onReaction(emoji);
            },
            icon: SvgPicture.asset(
              svgPath,
              width: _emojiSize,
              height: _emojiSize,
            )),
      ),
    );
  }

  Widget _buildActions() {
    return SingleChildScrollView(child: Column(children: actions));
  }
}
