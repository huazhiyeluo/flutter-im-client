import 'package:flutter/material.dart';

class EmojiList extends StatefulWidget {
  final int isShowEmoji;
  final double keyboardHeight;
  final Function(String) onEmoji;

  const EmojiList({super.key, required this.isShowEmoji, required this.keyboardHeight, required this.onEmoji});

  @override
  State<EmojiList> createState() => _EmojiListState();
}

class _EmojiListState extends State<EmojiList> {
  final List<String> emojis = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (var i = 0; i <= 124; i++) {
      String temp = i < 10 ? '0$i' : '$i';
      emojis.add('lib/assets/emojis/$temp.gif');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isShowEmoji == 1 ? widget.keyboardHeight : 0,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      color: const Color.fromARGB(255, 237, 237, 237),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 10.0, // 列之间的间距
          mainAxisSpacing: 0.0, // 行之间的间距
          childAspectRatio: 1.2, // 宽高比
        ),
        itemCount: emojis.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onEmoji(emojis[index]);
            },
            child: Image.asset(
              emojis[index],
              scale: 0.75,
            ),
          );
        },
      ),
    );
  }
}
