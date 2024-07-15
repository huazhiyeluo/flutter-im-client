import 'package:flutter/material.dart';

class PlusList extends StatefulWidget {
  final int isShowPlus;
  final double keyboardHeight;
  final bool isneedphone;
  final Function(int) onPlus;

  const PlusList({
    super.key,
    required this.isShowPlus,
    required this.keyboardHeight,
    required this.isneedphone,
    required this.onPlus,
  });

  @override
  State<PlusList> createState() => _PlusListState();
}

class _PlusListState extends State<PlusList> {
  final List<Map<String, dynamic>> icons = [
    {"val": 1, "icon": Icons.image},
    {"val": 2, "icon": Icons.camera_alt},
    {"val": 4, "icon": Icons.audio_file},
    {"val": 5, "icon": Icons.videocam},
    {"val": 6, "icon": Icons.folder},
  ];

  @override
  void initState() {
    if (widget.isneedphone) {
      icons.add({"val": 3, "icon": Icons.call});
      icons.sort((a, b) {
        return a['val'].compareTo(b['val']);
      });
    }
    super.initState();
  }

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
              widget.onPlus(icons[index]['val']);
            },
            child: Icon(icons[index]['icon'], size: 56),
          );
        },
      ),
    );
  }
}
