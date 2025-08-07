import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_base/core/utils/constants.dart';
import 'package:flutter_bloc_base/core/utils/theme.dart';
import 'package:flutter_bloc_base/core/widgets/custom_snak_bar.dart';

import '../../injection_container.dart';
import '../global/presentation/blocs/global/global_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late CustomSnackBar _snackBar;
  late GlobalBloc _globalBloc;

  @override
  void initState() {
    super.initState();
    _globalBloc = context.read<GlobalBloc>();
  }

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), scaffoldKey: _scaffoldKey);
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
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: _buildSignOutButton(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BlocBuilder _buildSignOutButton() {
    return BlocBuilder<GlobalBloc, GlobalState>(
      buildWhen: (prevState, currState) {
        print(currState);
        if (currState.isGuest) {
          _snackBar.hideAll();
          Navigator.pushNamedAndRemoveUntil(context, AUTH_ROUTE, (r) => false);
        }
        return currState.isUser;
      },
      builder: (context, state) {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            backgroundColor: Colors.blue,
          ),
          onPressed: () {
            BlocProvider.of<GlobalBloc>(context).add(LogoutEvent());
          },
          child: Text(
            "SIGN OUT",
            style: CustomTheme.mainTheme.textTheme.displayMedium,
          ),
        );
      },
    );
  }
}
