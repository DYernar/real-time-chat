import 'package:chat_app/bloc/chat_bloc.dart';
import 'package:chat_app/bloc/chat_event.dart';
import 'package:chat_app/bloc/chat_state.dart';
import 'package:chat_app/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = ChatBloc();
    _chatBloc.add(ShowOptionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => _chatBloc,
        child: Scaffold(
            appBar: AppBar(
              title: Text("Chat"),
            ),
            body: BlocBuilder<ChatBloc, ChatState>(builder: (context, state) {
              if (state is ShowOptionsState) {
                return Container(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        RaisedButton(
                          onPressed: () {
                            BlocProvider.of<ChatBloc>(context)
                                .add(LoadChatsEvent());
                          },
                          child: Text('Join chat'),
                        ),
                        RaisedButton(
                          onPressed: () {
                            BlocProvider.of<ChatBloc>(context)
                                .add(CreateChatEvent());
                          },
                          child: Text('Create chat'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state is ShowChatList) {
                return ChatList(state.chatList);
              }

              if (state is LoadingChatsState) {
                return Container(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is ShowChatState) {
                return Chat(state.channel);
              }
              return Container();
            })),
      ),
    );
  }
}

class ChatList extends StatefulWidget {
  final List<Map> chatList;
  ChatList(this.chatList) : super();

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView.builder(
          itemCount: widget.chatList.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  BlocProvider.of<ChatBloc>(context)
                      .add(JoinChatEvent(widget.chatList[index]["id"]));
                },
                child: Container(
                  height: 40.0,
                  width: 300.0,
                  color: Colors.grey[200],
                  child: Center(
                    child: Text(widget.chatList[index]["name"]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
