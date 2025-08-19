import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_base/core/utils/constants.dart';
import 'package:flutter_bloc_base/core/utils/theme.dart';

import '../../injection_container.dart';
import '../global/presentation/blocs/global/global_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.white,
        ),
        child: _buildBody(context),
      ),
    );
  }

  BlocProvider<GlobalBloc> _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return BlocProvider<GlobalBloc>(
      create: (_) => sl<GlobalBloc>(),
      child: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.all(DEFAULT_PAGE_PADDING),
        child: Column(
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 50)),
            Text(
              "Draft Home",
              style: CustomTheme.mainTheme.textTheme.headlineLarge,
            ),
            const Padding(padding: EdgeInsets.only(top: 50)),
          ],
        ),
      ),
    );
  }
}
