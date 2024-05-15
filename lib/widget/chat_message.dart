import 'package:flutter/material.dart';
import 'package:qim/utils/date.dart';

class ChatMessage extends StatefulWidget {
  final Map arguments;
  final int uid;

  const ChatMessage({
    super.key,
    required this.arguments,
    required this.uid,
  });

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isSentByMe = widget.uid == widget.arguments['fromId'];

    return Container(
      margin: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !isSentByMe
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    // 聊天对象的头像
                    radius: 25,
                    backgroundImage: NetworkImage(widget.arguments['avatar']),
                  ),
                )
              : Container(),
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(5),
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width * 0.1,
                maxWidth: MediaQuery.of(context).size.width * 0.6,
              ),
              decoration: BoxDecoration(
                color: isSentByMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.arguments['content']['data'] ?? ''}',
                    style: TextStyle(
                      fontSize: 16,
                      color: isSentByMe ? Colors.white : Colors.black,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(widget.arguments['createTime'], customFormat: "MM-dd HH:mm"),
                    style: TextStyle(
                      fontSize: 13,
                      color: isSentByMe ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          isSentByMe
              ? Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    // 聊天对象的头像
                    radius: 25,
                    backgroundImage: NetworkImage(widget.arguments['avatar']),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
