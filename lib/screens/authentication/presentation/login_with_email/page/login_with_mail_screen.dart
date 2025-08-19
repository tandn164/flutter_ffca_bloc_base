import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/widget_util.dart';
import '../../../../../core/widgets/app_navigation_bar.dart';
import '../../authentication/blocs/authentication_bloc.dart';
import '../blocs/login_email_bloc.dart';
import '../models/models.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../injection_container.dart';
import '../../../../../core/widgets/app_elevated_button.dart';

class LoginWithEmailScreen extends StatefulWidget {
  const LoginWithEmailScreen({super.key});

  @override
  State<StatefulWidget> createState() => _LoginWithEmailScreenState();
}

class _LoginWithEmailScreenState extends State<LoginWithEmailScreen> {
  late LoginEmailBloc _bloc;
  late AuthenticationBloc _authBloc;

  final FocusNode _emailNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = sl<LoginEmailBloc>();
    _authBloc = context.read<AuthenticationBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginEmailBloc>(
      create: (_) => _bloc,
      child: _buildBody(context),
    );
  }

  BlocListener _buildBody(BuildContext context) {
    return BlocListener<LoginEmailBloc, LoginEmailState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status.isLoginProcess) {
            showLoading();
          } else if (state.status.isLoginSuccess) {
            hideLoading();
            _authBloc.add(CheckAuthenticateEvent());
            Navigator.of(context).pushNamed(MAIN_ROUTE);
          } else if (state.status.isLoginFail) {
            hideLoading();
          }
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppNavigationBarVariants.simple(title: l10n.authLogin),
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
                    l10n.welcomeBack,
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
                            _buildEmailTextField(),
                            SizedBox(height: 12.h),
                            _buildPasswordTextField(),
                            SizedBox(height: 28.h),
                            _buildLoginButton(),
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
                    text: l10n.doNotHaveAccount,
                    style: TextStyle(
                        fontSize: 14.sp, fontWeight: FontWeight.w400)),
                TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.of(context).pushReplacementNamed(REGISTER_ROUTE);
                      },
                    text: l10n.signUp,
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700))
              ]))),
            )
          ],
        ),
      ],
    );
  }

  BlocBuilder _buildEmailTextField() {
    return BlocBuilder<LoginEmailBloc, LoginEmailState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return AppTextField(
            node: _emailNode,
            onChanged: (email) =>
                context.read<LoginEmailBloc>().add(LoginEmailChanged(email)),
            validationError: state.email.displayError?.errorMessage,
            hintText: "Email",
            keyboardType: TextInputType.emailAddress,
          );
        });
  }

  BlocBuilder _buildPasswordTextField() {
    return BlocBuilder<LoginEmailBloc, LoginEmailState>(
        buildWhen: (previous, current) => previous.password != current.password,
        builder: (context, state) {
          return AppTextField(
            node: _passwordNode,
            onChanged: (password) => context
                .read<LoginEmailBloc>()
                .add(LoginPasswordChanged(password)),
            validationError: state.password.displayError?.errorMessage,
            hintText: "Password",
            isSecured: true,
          );
        });
  }

  BlocBuilder _buildLoginButton() {
    return BlocBuilder<LoginEmailBloc, LoginEmailState>(
      buildWhen: (previous, current) => previous.isValid != current.isValid,
      builder: (context, state) {
        return SizedBox(
            height: 44.h,
            child: AppElevatedButton(
              title: l10n.authLogin,
              onTap: state.isValid
                  ? () {
                      _emailNode.unfocus();
                      _passwordNode.unfocus();
                      context
                          .read<LoginEmailBloc>()
                          .add(const LoginSubmitted());
                    }
                  : null,
            ));
      },
    );
  }
}
