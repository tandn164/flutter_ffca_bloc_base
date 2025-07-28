import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_base/core/utils/constants.dart';
import 'package:flutter_bloc_base/core/utils/theme.dart';
import 'package:flutter_bloc_base/core/widgets/custom_snak_bar.dart';
import 'package:flutter_bloc_base/screens/home/presentation/blocs/log_out/bloc.dart';

import '../../../../injection_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  late CustomSnackBar _snackBar;

  @override
  Widget build(BuildContext context) {
    _snackBar = CustomSnackBar(key: const Key("snackbar"), scaffoldKey: _scaffoldKey);
    return Scaffold(
      key: _scaffoldKey,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: CustomColor.statusBarColor,
        ),
        child: _buildBody(context),
      ),
    );
  }

  BlocProvider<LogOutBloc> _buildBody(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return BlocProvider<LogOutBloc>(
      create: (_) => sl<LogOutBloc>(),
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
                  child: _buildChangePasswordButton(),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                ),
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
    return BlocBuilder<LogOutBloc, LogOutState>(
      buildWhen: (prevState, currState) {
        print(currState);
        if (currState is LoggedOutState) {
          _snackBar.hideAll();
          Navigator.pushNamedAndRemoveUntil(context, LOGIN_ROUTE, (r) => false);
        }
        return currState is! LoggedOutState;
      },
      builder: (context, state) {
        if (state is LoggedInState || state is ErrorState) {
          if (state is ErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _snackBar.hideAll();
              _snackBar.showErrorSnackBar(state.message);
            });
          }
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0),
              ),
              backgroundColor: CustomColor.logoBlue,
            ),
            onPressed: () {
              BlocProvider.of<LogOutBloc>(context).add(UserLogOutEvent());
            },
            child: Text(
              "SIGN OUT",
              style: CustomTheme.mainTheme.textTheme.displayMedium,
            ),
          );
        } else if (state is LoadingState) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _snackBar.hideAll();
            _snackBar.showLoadingSnackBar();
          });
          return Container();
        }
        return Container();
      },
    );
  }

  ElevatedButton _buildChangePasswordButton() {
    return ElevatedButton(
      key: const Key("changePassword"),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        backgroundColor: CustomColor.logoBlue,
      ),
      onPressed: () {
        Navigator.pushNamed(context, CHANGE_PASSWORD_ROUTE);
      },
      child: Text(
        "CHANGE PASSWORD",
        style: CustomTheme.mainTheme.textTheme.bodySmall,
      ),
    );
  }
}
