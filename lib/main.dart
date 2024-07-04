import 'package:flutter/material.dart';
import 'routes/route.dart';
import 'utils/cache.dart';
import 'package:get/get.dart';

void main() async {
  /// 确保初始化完成
  WidgetsFlutterBinding.ensureInitialized();

  /// sp初始化
  await CacheHelper.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialRoute;

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    String initialRouteData = await initialRoute();
    setState(() {
      _initialRoute = initialRouteData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialRoute == null) {
      return const CircularProgressIndicator(); // 显示加载指示器等待数据初始化完成
    } else {
      return GetMaterialApp(
        title: "QIM",
        theme: ThemeData(
          scaffoldBackgroundColor: const Color.fromRGBO(240, 240, 245, 1.0),
          hintColor: Colors.grey.withOpacity(0.3),
          splashColor: Colors.transparent,
          canvasColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: _initialRoute,
        defaultTransition: Transition.rightToLeft,
        getPages: AppPage.routes,
      );
    }
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: const Text("11"),
//         ),
//         body: NestedScrollView(
//           headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//             return <Widget>[
//               SliverAppBar(
//                 pinned: false,
//                 expandedHeight: 150,
//                 flexibleSpace: FlexibleSpaceBar(
//                   background: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: 50,
//                         padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: '搜索',
//                             prefixIcon: const Icon(Icons.search),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 40,
//                         padding: EdgeInsets.zero,
//                         margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.pushNamed(
//                               context,
//                               '/notice-user',
//                             );
//                           },
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 12.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   '新朋友',
//                                   style: TextStyle(fontSize: 16.0), // 根据需要设置字体大小
//                                 ),
//                                 Icon(Icons.chevron_right),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: 40,
//                         padding: EdgeInsets.zero,
//                         margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
//                         child: InkWell(
//                           onTap: () {
//                             Navigator.pushNamed(
//                               context,
//                               '/notice-group',
//                             );
//                           },
//                           child: const Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 12.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   '群通知',
//                                   style: TextStyle(fontSize: 16.0), // 根据需要设置字体大小
//                                 ),
//                                 Icon(Icons.chevron_right),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _SliverAppBarDelegate(
//                   TabBar(
//                     tabs: const [
//                       Tab(text: '好友'),
//                       Tab(text: '分组'),
//                       Tab(text: '群聊'),
//                     ],
//                     controller: _tabController,
//                     labelColor: Colors.red,
//                     unselectedLabelColor: Colors.grey,
//                   ),
//                 ),
//               ),
//             ];
//           },
//           body: TabBarView(controller: _tabController, children: [
//             Container(
//               color: Colors.blue,
//               height: 200,
//               child: const Center(
//                 child: Text(
//                   'This is a regular container',
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//               ),
//             ),
//             Container(
//               color: Colors.red,
//               height: 200,
//               child: const Center(
//                 child: Text(
//                   'This is a regular container',
//                   style: TextStyle(fontSize: 20, color: Colors.white),
//                 ),
//               ),
//             ),
//             Container(
//               color: Colors.yellow,
//               child: ListView.builder(
//                 itemBuilder: (BuildContext context, int index) {
//                   return ListTile(
//                     title: Text("yellow$index"),
//                   );
//                 },
//                 itemCount: 20,
//               ),
//             )
//           ]),
//         ),
//       ),
//     );
//   }
// }

// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
//   _SliverAppBarDelegate(this._tabBar);

//   final TabBar _tabBar;

//   @override
//   double get minExtent => _tabBar.preferredSize.height;
//   @override
//   double get maxExtent => _tabBar.preferredSize.height;

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: Colors.white,
//       child: _tabBar,
//     );
//   }

//   @override
//   bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
//     return false;
//   }
// }
