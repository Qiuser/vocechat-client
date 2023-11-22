import 'package:equatable/equatable.dart';
import 'package:vocechat_client/feature/avchat_call_in/model/agora_channel_data.dart';

abstract class AvchatCallinEvent extends Equatable {
  const AvchatCallinEvent();
}

class AvchatCallinInfoReceived extends AvchatCallinEvent {
  final AgoraChannelData channelData;

  const AvchatCallinInfoReceived({required this.channelData});

  @override
  List<Object?> get props => [channelData];
}