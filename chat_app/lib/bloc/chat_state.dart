import 'package:equatable/equatable.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

abstract class ChatState extends Equatable {}

class ShowChatList extends ChatState {
  final List<Map> chatList;

  ShowChatList(this.chatList);
  @override
  List<Object> get props => [chatList];
}

class ShowChatState extends ChatState {
  final WebSocketChannel channel;

  ShowChatState(this.channel);

  @override
  List<Object> get props => [channel];
}

class LoadingChatsState extends ChatState {
  @override
  List<Object> get props => [];
}

class ShowOptionsState extends ChatState {
  @override
  List<Object> get props => [];
}
