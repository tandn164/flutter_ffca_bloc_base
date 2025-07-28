import 'package:chopper/chopper.dart';
import 'package:flutter_bloc_base/screens/change_password/data/datasources/change_password_local_datasource.dart';
import 'package:flutter_bloc_base/screens/change_password/data/datasources/change_password_remote_datasource.dart';
import 'package:flutter_bloc_base/screens/change_password/data/repositories/change_password_repository_impl.dart';
import 'package:flutter_bloc_base/screens/change_password/domain/repositories/change_password_repository.dart';
import 'package:flutter_bloc_base/screens/change_password/domain/usecases/change_password.dart';
import 'package:flutter_bloc_base/screens/change_password/presentation/blocs/change_password/change_password_bloc.dart';
import 'package:flutter_bloc_base/screens/home/data/datasources/home_local_datasource.dart';
import 'package:flutter_bloc_base/screens/home/data/datasources/home_remote_datasource.dart';
import 'package:flutter_bloc_base/screens/home/data/repositories/home_repository_impl.dart';
import 'package:flutter_bloc_base/screens/home/domain/repositories/home_repository.dart';
import 'package:flutter_bloc_base/screens/home/domain/usecases/logout_user.dart';
import 'package:flutter_bloc_base/screens/home/presentation/blocs/log_out/log_out_bloc.dart';
import 'package:flutter_bloc_base/screens/login/data/datasources/login_local_datasource.dart';
import 'package:flutter_bloc_base/screens/login/data/datasources/login_remote_datasource.dart';
import 'package:flutter_bloc_base/screens/login/data/repositories/login_repository_impl.dart';
import 'package:flutter_bloc_base/screens/login/domain/repositories/login_repository.dart';
import 'package:flutter_bloc_base/screens/login/domain/usecases/login_user.dart';
import 'package:flutter_bloc_base/screens/login/presentation/blocs/user_login/user_login_bloc.dart';
import 'package:flutter_bloc_base/screens/login/presentation/blocs/user_login/user_login_event.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/network_info.dart';
import 'core/network/rest_client_service.dart';
import 'core/usecases/fetch_token.dart';

final sl = GetIt.instance;

//Dependency injection
Future<void> init() async {
  //Blocs
  sl.registerFactory(
        () => UserLoginBloc(loginUser: sl(), fetchToken: sl())..add(CheckLoginStatusEvent()),
  );
  sl.registerFactory(
        () => LogOutBloc(
      fetchToken: sl(),
      logoutUser: sl(),
    ),
  );
  sl.registerFactory(
        () => ChangePasswordBloc(
      changePassword: sl(),
    ),
  );

  //Use cases
  sl.registerLazySingleton(() => LoginUser(repository: sl()));
  sl.registerLazySingleton(() => FetchToken(repository: sl()));
  sl.registerLazySingleton(() => LogOutUser(repository: sl()));
  sl.registerLazySingleton(() => ChangePassword(repository: sl()));

  //Repositories
  sl.registerLazySingleton<LoginRepository>(
        () => LoginRepositoryImpl(
      networkInfo: sl(),
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(
    networkInfo: sl(),
    localDataSource: sl(),
    remoteDataSource: sl(),
  ));
  sl.registerLazySingleton<ChangePasswordRepository>(() => ChangePasswordRepositoryImpl(
    networkInfo: sl(),
    localDataSource: sl(),
    remoteDataSource: sl(),
  ));


  //Data sources
  sl.registerLazySingleton<LoginRemoteDataSource>(
        () => LoginRemoteDataSourceImpl(
      restClientService: sl(),
    ),
  );
  sl.registerLazySingleton<LoginLocalDataSource>(
        () => LoginLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(
      restClientService: sl(),
    ),
  );
  sl.registerLazySingleton<HomeLocalDataSource>(
        () => HomeLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );
  sl.registerLazySingleton<ChangePasswordRemoteDataSource>(
        () => ChangePasswordRemoteDataSourceImpl(
      restClientService: sl(),
    ),
  );
  sl.registerLazySingleton<ChangePasswordLocalDataSource>(
        () => ChangePasswordLocalDataSourceImpl(
      sharedPreferences: sl(),
    ),
  );

  //Core
  sl.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(internetConnectionChecker: sl()),
  );

  //External
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
  final client = ChopperClient(interceptors: [
    CurlInterceptor(),
    HttpLoggingInterceptor(),
  ]);
  sl.registerLazySingleton(() => RestClientService.create(client));
}
