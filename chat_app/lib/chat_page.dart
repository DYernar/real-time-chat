import 'dart:convert';

import 'package:chat_app/bloc/chat_bloc.dart';
import 'package:chat_app/bloc/chat_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  final WebSocketChannel channel;

  const Chat(this.channel) : super();

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final inputController = TextEditingController();
  List<String> messageList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(5.0),
            child: RaisedButton(
              onPressed: () {
                BlocProvider.of<ChatBloc>(context)
                    .add(LeaveChatEvent(widget.channel));
              },
              child: Text('leave chat'),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: RaisedButton(
                    onPressed: () {
                      if (inputController.text.isNotEmpty) {
                        widget.channel.sink.add(
                          jsonEncode(
                            {
                              "name": "User",
                              "message": inputController.text,
                            },
                          ),
                        );
                        inputController.text = "";
                      }
                    },
                    child: Text(
                      'Send',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var msg = jsonDecode(snapshot.data);
                  messageList.add(msg["message"]);
                }
                return getMessageList();
              },
            ),
          ),
        ],
      ),
    );
  }

  ListView getMessageList() {
    List<Widget> listWidget = [];
    for (String message in messageList) {
      listWidget.add(
        ListTile(
          title: Container(
            child: Padding(
              padding: EdgeInsets.all(
                8.0,
              ),
              child: Text(
                message,
                style: TextStyle(fontSize: 22),
              ),
            ),
            color: Colors.teal[50],
            height: 60.0,
          ),
        ),
      );
    }
    return ListView(
      children: listWidget,
    );
  }
}
