import 'package:flutter/material.dart';

class DialogConfirm extends StatelessWidget {
  final String? title;
  final Widget content;
  final VoidCallback onConfirm;
  final String? onConfirmText;
  final VoidCallback onCancel;
  final String? onCancelText;

  const DialogConfirm({
    super.key,
    this.title,
    required this.content,
    required this.onConfirm,
    required this.onConfirmText,
    required this.onCancel,
    required this.onCancelText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text(title!) : null,
      content: content,
      contentPadding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextButton(
              onPressed: () {
                onCancel();
                Navigator.of(context).pop();
              },
              child: Text(onCancelText != null ? onCancelText! : "取消"),
            ),
            TextButton(
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
              child: Text(
                onConfirmText != null ? onConfirmText! : "确认",
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

Future<void> showCustomDialog({
  required BuildContext context,
  String? title,
  required Widget content,
  required VoidCallback onConfirm,
  String? onConfirmText,
  required VoidCallback onCancel,
  String? onCancelText,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return DialogConfirm(
        title: title,
        content: content,
        onConfirm: onConfirm,
        onConfirmText: onConfirmText,
        onCancel: onCancel,
        onCancelText: onCancelText,
      );
    },
  );
}
