import 'package:chopper/chopper.dart';
import 'package:flutter_bloc_base/interceptor/auth_interceptor.dart';
import 'package:flutter_bloc_base/interceptor/app_authenticator.dart';
import 'package:flutter_bloc_base/screens/authentication/data/datasources/authentication_datasource.dart';
import 'package:flutter_bloc_base/screens/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/repositories/authentication_repository.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/usecase/login_usecase.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/usecase/register_email_usecase.dart';
import 'package:flutter_bloc_base/screens/authentication/presentation/login_with_email/blocs/login_email_bloc.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/usecase/logout_usecase.dart';
import 'package:flutter_bloc_base/screens/authentication/domain/usecase/token_usecase.dart';
import 'package:flutter_bloc_base/screens/authentication/presentation/register_with_email/blocs/register_email_bloc.dart';
import 'package:flutter_bloc_base/screens/global/presentation/blocs/global/global_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/network/rest_client_service.dart';

final sl = GetIt.instance;

//Dependency injection
Future<void> init() async {
  //Blocs
  sl.registerFactory(
        () => GlobalBloc(checkTokenUseCase: sl(), logoutUseCase: sl()),
  );
  sl.registerFactory(
        () => LoginEmailBloc(loginUseCase: sl()),
  );
  sl.registerFactory(
        () => RegisterEmailBloc(registerEmailUseCase: sl()),
  );

  //Use cases
  sl.registerLazySingleton(() => TokenUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(repository: sl()));
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterEmailUseCase(repository: sl()));

  //Repositories
  sl.registerLazySingleton<AuthenticationRepository>(
        () => AuthenticationRepositoryImpl(dataSource: sl(), networkInfo: sl()),
  );

  //Data sources
  sl.registerLazySingleton<AuthenticationDataSource>(
        () => AuthenticationDataSourceImpl(restClientService: sl(), sharedPreferences: sl()),
  );

  //Core
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(internetConnectionChecker: sl()),
  );

  //External
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  final client = ChopperClient(
    interceptors: [
      CurlInterceptor(),
      HttpLoggingInterceptor(),
      AuthInterceptor(sharedPreferences: sharedPreferences),
    ],
    authenticator: AppAuthenticator(sharedPreferences: sharedPreferences),
  );
  sl.registerLazySingleton(() => RestClientService.create(client));
}
