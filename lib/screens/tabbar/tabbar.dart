import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import '../global/presentation/blocs/global/global_bloc.dart';
import '../home/home_screen.dart';
import '../../core/widgets/bottom_navigation.dart';
import '../user/presentation/pages/profile_screen.dart';

class MainTabBar extends StatefulWidget {
  const MainTabBar({super.key});

  @override
  State<StatefulWidget> createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  late PageController _pageController;
  late List<Widget> _screens;
  late GlobalBloc _globalBloc;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _screens = [
      const HomeScreen(),
      Container(),
      Container(),
      Container(),
      const ProfileScreen(),
    ];
    _globalBloc = context.read<GlobalBloc>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black,
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.white,
            statusBarBrightness: Brightness.dark,
          ),
          child: PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            onPageChanged: (index) =>
                _globalBloc.add(ChangeTabEvent(index: index)),
            children: _screens,
          ),
        ),
        bottomNavigationBar: BlocConsumer<GlobalBloc, GlobalState>(
          listenWhen: (previous, current) =>
              previous.tabBarIndex != current.tabBarIndex,
          listener: (context, state) {
            _pageController.jumpToPage(state.tabBarIndex);
          },
          buildWhen: (previous, current) =>
              previous.tabBarIndex != current.tabBarIndex ||
              previous.locale != current.locale,
          builder: (context, state) {
            return BottomNavigation(
              currentIndex: _globalBloc.state.tabBarIndex,
              onItemSelected: (index) {
                _globalBloc.add(ChangeTabEvent(index: index));
              },
            );
          },
        ));
  }
}
