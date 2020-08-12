import 'package:equatable/equatable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class ChatEvent extends Equatable {}

class ShowOptionsEvent extends ChatEvent {
  @override
  List<Object> get props => [];
}

class LoadChatsEvent extends ChatEvent {
  @override
  List<Object> get props => [];
}

class JoinChatEvent extends ChatEvent {
  final int chatID;

  JoinChatEvent(this.chatID);

  @override
  List<Object> get props => [];
}

class CreateChatEvent extends ChatEvent {
  @override
  List<Object> get props => [];
}

class LeaveChatEvent extends ChatEvent {
  final WebSocketChannel channel;

  LeaveChatEvent(this.channel);
  @override
  List<Object> get props => [channel];
}
