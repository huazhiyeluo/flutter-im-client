import 'package:flutter/material.dart';

class PlusList extends StatefulWidget {
  final int isShowPlus;
  final double keyboardHeight;
  final Function(int) onPlus;

  const PlusList({super.key, required this.isShowPlus, required this.keyboardHeight, required this.onPlus});

  @override
  State<PlusList> createState() => _PlusListState();
}

class _PlusListState extends State<PlusList> {
  final List<IconData> icons = [
    Icons.image,
    Icons.camera_alt,
    Icons.call,
    Icons.folder,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.isShowPlus == 1 ? widget.keyboardHeight : 0,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      color: const Color.fromARGB(255, 237, 237, 237),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10.0, // 列之间的间距
          mainAxisSpacing: 0.0, // 行之间的间距
          childAspectRatio: 1.2, // 宽高比
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              widget.onPlus(index);
            },
            child: Icon(icons[index], size: 56),
          );
        },
      ),
    );
  }
}
