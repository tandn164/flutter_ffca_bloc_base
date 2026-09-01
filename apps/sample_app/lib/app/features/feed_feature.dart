import 'package:chopper/chopper.dart';
import 'package:app_overlay/app_overlay.dart';
import 'package:feed_data/feed_data.dart';
import 'package:feed_domain/feed_domain.dart';
import 'package:feed_presentation/feed_presentation.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../network/fake/fake_api_handler.dart';
import '../network/fake/fake_demo_store.dart';
import '../network/fake/fake_feed_handler.dart';
import 'feature_feedback.dart';

FeedApi createFeedApiService() => FeedApi.create();

FakeApiHandler createFeedFakeHandler(FakeDemoStore store) {
  return FakeFeedHandler(store);
}

void registerFeedDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<FeedApi>(
      () => sl<ChopperClient>().getService<FeedApi>(),
    )
    ..registerLazySingleton<FeedRepository>(
      () => FeedRepositoryImpl(gateway: sl()),
    )
    ..registerLazySingleton(() => GetFeed(sl<FeedRepository>()))
    ..registerLazySingleton(() => CreateFeedItem(sl<FeedRepository>()))
    ..registerLazySingleton(() => UpdateFeedItem(sl<FeedRepository>()))
    ..registerLazySingleton(() => DeleteFeedItem(sl<FeedRepository>()));
}

StatefulShellBranch createFeedBranch(GetIt sl) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: '/home',
        builder: (context, _) => FeedPage(
          createBloc: () => FeedBloc(
            getFeed: sl<GetFeed>(),
            createItem: sl<CreateFeedItem>(),
            updateItem: sl<UpdateFeedItem>(),
            deleteItem: sl<DeleteFeedItem>(),
          )..add(const FeedStarted()),
          onNotice: (context, notice) {
            showFeatureToast(
              context,
              type: notice.kind == FeedNoticeKind.error
                  ? ToastType.error
                  : ToastType.success,
              message: notice.message,
            );
          },
        ),
      ),
    ],
  );
}
