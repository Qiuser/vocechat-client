import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:equatable/equatable.dart';
import 'package:vocechat_client/dao/init_dao/user_info.dart';

import '../../model/agora_token_info.dart';
import '../../model/avchat_user.dart';

abstract class AvchatState extends Equatable {}

// ------------------ AvchatAvailabilityCheckBloc ------------------ //
abstract class AvchatAvailabilityState extends AvchatState {
  @override
  List<Object?> get props => [];
}

class AvchatAvailabilityInitialState extends AvchatAvailabilityState {}

class CheckingAvchatAvailability extends AvchatAvailabilityState {}

class AvchatAvailable extends AvchatAvailabilityState {}

class AvchatUnavailable extends AvchatAvailabilityState {
  final String? message;

  AvchatUnavailable({this.message});
}

class AvchatAvailabilityCheckFail extends AvchatAvailabilityState {
  final Object? error;

  AvchatAvailabilityCheckFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AvchatPermissionCheckBloc ------------------ //
abstract class AvchatPermissionState extends AvchatState {
  @override
  List<Object?> get props => [];
}

class AvchatPermissionEnabled extends AvchatPermissionState {
  final bool isMicPermissionEnabled;
  final bool? isCameraPermissionEnabled;

  AvchatPermissionEnabled(
      {required this.isMicPermissionEnabled, this.isCameraPermissionEnabled});

  @override
  List<Object?> get props =>
      [isMicPermissionEnabled, isCameraPermissionEnabled];
}

class AvchatPermissionDisabled extends AvchatPermissionState {
  final bool isMicPermissionRequired;
  final bool isCameraPermissionRequired;

  AvchatPermissionDisabled(
      {required this.isMicPermissionRequired,
      required this.isCameraPermissionRequired});

  @override
  List<Object?> get props =>
      [isMicPermissionRequired, isCameraPermissionRequired];
}

class AvchatPermissionCheckFail extends AvchatPermissionState {
  final Object? error;

  AvchatPermissionCheckFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AvchatTokenInfoBloc ------------------ //
abstract class AvchatTokenInfoState extends AvchatState {
  @override
  List<Object?> get props => [];
}

class AvchatTokenInfoReceived extends AvchatTokenInfoState {
  final AgoraTokenInfo info;

  AvchatTokenInfoReceived(this.info);

  @override
  List<Object?> get props => [info];
}

class AvchatTokenInfoFail extends AvchatTokenInfoState {
  final Object? error;

  AvchatTokenInfoFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AgoraInitBloc ------------------ //
class AgoraInitState extends AvchatState {
  AgoraInitState();

  @override
  List<Object?> get props => [];
}

class AgoraInitializing extends AgoraInitState {}

class AgoraInitialized extends AgoraInitState {}

class AgoraInitFail extends AgoraInitState {
  final Object? error;
  AgoraInitFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AgoraJoinBloc ------------------ //
class AgoraJoinState extends AvchatState {
  AgoraJoinState();

  @override
  List<Object?> get props => [];
}

class AgoraJoiningChannel extends AgoraJoinState {}

class AgoraSelfJoined extends AgoraJoinState {}

class AgoraSelfJoinFail extends AgoraJoinState {
  final Object? error;

  AgoraSelfJoinFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AgoraCallingInitBloc ------------------ //
/// Calling means on-going call, not the act of calling.
abstract class AgoraCallingState extends AvchatState {
  AgoraCallingState();

  @override
  List<Object?> get props => [];
}

class AgoraCallOnGoing extends AgoraCallingState {
  final int seconds;

  AgoraCallOnGoing(this.seconds);

  @override
  List<Object?> get props => [seconds];
}

/// Only used for one-to-one call.
class AgoraWaitingForPeer extends AgoraCallingState {}

class AgoraGuestJoined extends AgoraJoinState {
  final UserInfoM userInfoM;

  AgoraGuestJoined(this.userInfoM);

  @override
  List<Object?> get props => [userInfoM];
}

class AgoraGuestLeft extends AgoraJoinState {
  final UserInfoM userInfoM;

  AgoraGuestLeft(this.userInfoM);

  @override
  List<Object?> get props => [userInfoM];
}

class AvchatConnectionStateChanged extends AgoraCallingState {
  final int uid;
  final ConnectionStateType state;
  final ConnectionChangedReasonType reason;

  AvchatConnectionStateChanged(
      {required this.uid, required this.state, required this.reason});

  @override
  List<Object?> get props => [uid, state, reason];
}

class AgoraCallingFail extends AgoraCallingState {
  final Object? error;

  AgoraCallingFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AgoraLeaveBloc ------------------ //
abstract class AgoraLeaveState extends AvchatState {
  AgoraLeaveState();

  @override
  List<Object?> get props => [];
}

class AgoraLeftChannel extends AgoraLeaveState {}

class AgoraLeaveFail extends AgoraLeaveState {
  final Object? error;

  AgoraLeaveFail(this.error);

  @override
  List<Object?> get props => [error];
}

// ------------------ AvchatBtnBloc ------------------ //
abstract class AvchatBtnState extends AvchatState {
  AvchatBtnState();

  @override
  List<Object?> get props => [];
}

class AvchatCamBtnState extends AvchatBtnState {
  final bool isCamEnabled;

  AvchatCamBtnState(this.isCamEnabled);

  @override
  List<Object?> get props => [isCamEnabled];
}

class AvchatSpeakerBtnState extends AvchatBtnState {
  final bool isMuted;

  AvchatSpeakerBtnState(this.isMuted);

  @override
  List<Object?> get props => [isMuted];
}

class AvchatMicBtnState extends AvchatBtnState {
  final bool isMuted;

  AvchatMicBtnState(this.isMuted);

  @override
  List<Object?> get props => [isMuted];
}

class AvchatEndCallBtnState extends AvchatBtnState {
  AvchatEndCallBtnState();
}

class AvchatUserChangeState extends AvchatState {
  final Map<int, AvchatUser> users;

  AvchatUserChangeState(this.users);

  @override
  List<Object?> get props => [users];
}