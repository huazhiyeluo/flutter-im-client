import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    Map arguments = Get.arguments;
    String name = arguments['name'];
    return Text(name);
  }
}
