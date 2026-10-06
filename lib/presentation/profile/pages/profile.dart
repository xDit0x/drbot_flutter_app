import 'package:flutter/material.dart';

import 'package:flutter_learning/presentation/profile/models/profile_tab.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int currentPageIndex = 1;
  // ProfileDestination selectedProfileDestinations;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Column(
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            indicatorWeight: 1,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsetsGeometry.fromLTRB(20, 0, 20, 3.5),
            tabs: [for (final t in ProfileTab.profileTabs) Tab(text: t.label)],
          ),
          Expanded(
            child: TabBarView(
              children: [for (final t in ProfileTab.profileTabs) t.page],
            ),
          ),
        ],
      ),
    );
  }
}
