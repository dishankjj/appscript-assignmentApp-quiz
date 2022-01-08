import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterfire_ui/auth.dart' as fireui;
import 'package:quiz/view_modal/login/bloc/login_bloc.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  static WidgetBuilder page() {
    return (context) => BlocProvider(
          create: (context) => LoginBloc(),
          child: const LoginView(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (blocContext, blocState) {
          if (blocState is LoginSuccess) {
            var score = Navigator.of(context).pushNamed('/quiz');
            _getPopData(score, context);
          }
        },
        builder: (blocContext, blocState) {
          if (blocState is LoginInitial || blocState is LogoutSuccess) {
            return _loginProviderScreen(context);
          }
          if (blocState is LoginSuccess) return _loggedScreen(context);

          if (blocState is LoginSuccessScore) {
            return _loggedScreen(context, score: blocState.score);
          }

          return _circularIndi();
        },
      ),
    );
  }

  _getPopData(Future<dynamic> data, BuildContext cont) async {
    Map<String, dynamic> scoreObject = await data;
    // debugPrint(scoreObject['score'].toString());
    cont.read<LoginBloc>().add(LoginScoreRequestedEvent(scoreObject));
  }

  // Widget _loginInitialScreen(BuildContext context) => Center(
  //       child: ElevatedButton(
  //         onPressed: () => context.read<LoginBloc>().add(LoginRequestedEvent()),
  //         child: const Text('Google Signin'),
  //       ),
  //     );
  Widget _loggedScreen(BuildContext context, {int score = 0}) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // if score has some value then show score
            score != 0 ? Text('Your total score is $score') : const SizedBox(),
            const Spacer(),
            ElevatedButton(
              onPressed: () =>
                  context.read<LoginBloc>().add(LoginRequestedEvent()),
              child: const Text('Back To Quiz'),
            ),
            ElevatedButton(
              onPressed: () =>
                  context.read<LoginBloc>().add(LogoutRequestedEvent()),
              child: const Text('Sign out'),
            ),
            const Spacer(),
          ],
        ),
      );
  Widget _circularIndi() => const Center(child: CircularProgressIndicator());

  Widget _loginProviderScreen(BuildContext context) {
    return Center(
      child: fireui.AuthFlowBuilder<fireui.OAuthController>(
        config: const fireui.GoogleProviderConfiguration(
            clientId:
                '763499512736-2rhn4cjlgaqlr5mj2oknoj9u4ifigfot.apps.googleusercontent.com'),
        auth: FirebaseAuth.instance,
        listener: (oldState, newState, controller) {
          if (newState is fireui.SignedIn) {
            context.read<LoginBloc>().add(LoginRequestedEvent());
          }
        },
        builder: (context, state, ctrl, child) {
          if (state is fireui.AuthFailed) {
            return _googleSignInButton(context, state, ctrl);
          }
          return _googleSignInButton(context, state, ctrl);
        },
        onComplete: (credential) {},
      ),
    );
  }

  Widget _googleSignInButton(BuildContext context, fireui.AuthState state,
      fireui.OAuthController ctrl) {
    return ElevatedButton(
      onPressed: () async {
        await ctrl.signInWithProvider(TargetPlatform.android);
      },
      child: const Text('Google Sign-In'),
    );
  }
}
