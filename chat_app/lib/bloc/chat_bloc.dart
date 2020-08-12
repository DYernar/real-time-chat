import 'dart:convert';

import 'package:chat_app/bloc/chat_event.dart';
import 'package:chat_app/bloc/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

const chatListUrl = "https://glacial-ocean-33079.herokuapp.com/";
const websocketUrl = "ws://glacial-ocean-33079.herokuapp.com/ws";

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(null);

  @override
  Stream<ChatState> mapEventToState(ChatEvent event) async* {
    if (event is ShowOptionsEvent) {
      yield ShowOptionsState();
    }
    if (event is LoadChatsEvent) {
      yield LoadingChatsState();
      var chats = await _getChats();
      yield ShowChatList(chats);
    }

    if (event is JoinChatEvent) {
      print(websocketUrl + "?id=${event.chatID}");
      var channel =
          IOWebSocketChannel.connect(websocketUrl + "?id=${event.chatID}");
      yield ShowChatState(channel);
    }

    if (event is CreateChatEvent) {
      var channel = IOWebSocketChannel.connect(websocketUrl);
      yield ShowChatState(channel);
    }

    if (event is LeaveChatEvent) {
      event.channel.sink.close();
      yield ShowOptionsState();
    }
  }

  Future<List<Map>> _getChats() async {
    var response = await http.get(chatListUrl);
    print("response body: " + jsonDecode(response.body).toString());

    var objs = jsonDecode(response.body);

    List<Map> ret = [];

    objs.forEach((element) {
      ret.add({"id": element["id"], "name": element["string"]});
    });
    return ret;
  }
}
