import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_base/screens/global/presentation/blocs/global/global_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/widget_util.dart';
import '../../../../../core/widgets/app_navigation_bar.dart';
import '../models/models.dart';
import '../blocs/register_email_bloc.dart';
import '../../login_with_email/models/models.dart';
import '../../../../../injection_container.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/app_elevated_button.dart';
import '../../../../../core/utils/constants.dart';

class RegisterWithEmailScreen extends StatefulWidget {
  const RegisterWithEmailScreen({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterWithEmailScreenState();
}

class _RegisterWithEmailScreenState extends State<RegisterWithEmailScreen> {
  late RegisterEmailBloc _bloc;
  late GlobalBloc _globalBloc;

  final FocusNode _usernameNode = FocusNode();
  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _usernameNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = sl<RegisterEmailBloc>();
    _globalBloc = sl<GlobalBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterEmailBloc>(
      create: (_) => _bloc,
      child: _buildBody(context),
    );
  }

  BlocListener _buildBody(BuildContext context) {
    return BlocListener<RegisterEmailBloc, RegisterEmailState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isRegisterProcess) {
            showLoading();
          } else if (state.status.isRegisterSuccess) {
            hideLoading();
            _globalBloc.add(CheckAuthenticateEvent());
            _globalBloc.add(ChangeTabEvent(index: 0));
            Navigator.of(context).pushNamed(MAIN_ROUTE);
          } else if (state.status.isRegisterFail) {
            hideLoading();
          }
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppNavigationBarVariants.simple(title: l10n.authRegister),
            body: SafeArea(
              maintainBottomViewPadding: true,
              child: _buildTextFields(),
            )));
  }

  Widget _buildTextFields() {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.deferToChild,
          onTap: () {
            _emailNode.unfocus();
            _passwordNode.unfocus();
            _usernameNode.unfocus();
          },
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(top: 20.h),
            child: Center(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.createYourAccount,
                    style: TextStyle(
                        fontSize: 20.sp, 
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[300]),
                  ),
                  SizedBox(height: 36.h),
                  Padding(
                    padding: EdgeInsets.only(bottom: 40.h),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: screenSize.height -
                              padding.bottom -
                              padding.top -
                              200.h),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUsernameTextField(),
                            SizedBox(height: 12.h),
                            _buildEmailTextField(),
                            SizedBox(height: 12.h),
                            _buildPasswordTextField(),
                            SizedBox(height: 28.h),
                            _buildRegisterButton(),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 60.h,
              child: Center(
                  child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: l10n.alreadyHaveAccount,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w400)),
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushReplacementNamed(LOGIN_ROUTE);
                      },
                    text: l10n.signIn,
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700))
              ]))),
            )
          ],
        ),
      ],
    );
  }

  BlocBuilder _buildUsernameTextField() {
    return BlocBuilder<RegisterEmailBloc, RegisterEmailState>(
        buildWhen: (previous, current) => previous.username != current.username,
        builder: (context, state) {
          return AppTextField(
            node: _usernameNode,
            onChanged: (username) => _bloc.add(UsernameChanged(username)),
            validationError: state.username.displayError?.errorMessage,
            hintText: "User name",
          );
        });
  }

  BlocBuilder _buildEmailTextField() {
    return BlocBuilder<RegisterEmailBloc, RegisterEmailState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return AppTextField(
            node: _emailNode,
            onChanged: (email) => _bloc.add(EmailChanged(email)),
            validationError: state.email.displayError?.errorMessage,
            hintText: "Email",
            keyboardType: TextInputType.emailAddress,
          );
        });
  }

  BlocBuilder _buildPasswordTextField() {
    return BlocBuilder<RegisterEmailBloc, RegisterEmailState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return AppTextField(
            node: _passwordNode,
            onChanged: (password) => _bloc.add(PasswordChanged(password)),
            validationError: state.password.displayError?.errorMessage,
            hintText: "Password",
            isSecured: true,
          );
        });
  }

  BlocBuilder _buildRegisterButton() {
    return BlocBuilder<RegisterEmailBloc, RegisterEmailState>(
      buildWhen: (previous, current) =>
          previous.isInfoValid != current.isInfoValid,
      builder: (context, state) {
        return SizedBox(
            height: 44.h,
            child: AppElevatedButton(
              title: l10n.authRegister,
              onTap: state.isInfoValid
                  ? () {
                      _emailNode.unfocus();
                      _passwordNode.unfocus();
                      _usernameNode.unfocus();
                      _bloc.add(const SendEmailSubmitted());
                    }
                  : null,
            ));
      },
    );
  }
}
