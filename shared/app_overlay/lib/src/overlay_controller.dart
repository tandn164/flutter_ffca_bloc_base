import 'package:app_connectivity/app_connectivity.dart';
import 'package:flutter/widgets.dart';
import 'package:tutorial_engine/tutorial_engine.dart';

import 'loading_handle.dart';
import 'overlay_feedback.dart';
import 'page_policy.dart';
import 'toast_queue.dart';

class OverlayController extends ChangeNotifier implements OverlayFeedback {
  OverlayController({
    required this.connectivity,
    this.defaultPageConfig = const PageConfig(
      noInternet: NoInternetMode.banner,
    ),
    TutorialController? tutorialController,
  }) : tutorialController = tutorialController ?? TutorialController() {
    connectivity.addListener(notifyListeners);
    _toasts = ToastQueue(notifyListeners);
  }

  final ConnectivityHint connectivity;
  final PageConfig defaultPageConfig;
  final TutorialController tutorialController;

  late final ToastQueue _toasts;
  final Map<Object, PageConfig> _pages = {};
  final Map<int, LoadingContentBuilder?> _loading = {};
  final List<LoadingHandle> _legacyLoading = [];
  Object? _activePage;
  int _nextLoadingId = 0;

  List<ToastItem> get toasts => _toasts.items;
  int get queuedToastCount => _toasts.length;
  bool get isLoading => _loading.isNotEmpty;
  int get loadingCount => _loading.length;
  LoadingContentBuilder? get loadingContentBuilder =>
      _loading.isEmpty ? null : _loading.values.last;

  PageConfig get pageConfig => _pages[_activePage] ?? defaultPageConfig;

  NoInternetMode get effectiveNoInternet {
    final mode = pageConfig.noInternet;
    return mode == NoInternetMode.inherit ? defaultPageConfig.noInternet : mode;
  }

  bool get showBanner =>
      connectivity.isSureOffline &&
      effectiveNoInternet == NoInternetMode.banner;
  bool get showBlock =>
      connectivity.isSureOffline && effectiveNoInternet == NoInternetMode.block;

  void activatePage(Object owner, PageConfig config) {
    final resolved = config.resolve(defaultPageConfig);
    final same = _activePage == owner && _pages[owner] == resolved;
    _pages[owner] = resolved;
    _activePage = owner;
    if (!same) notifyListeners();
  }

  void deactivatePage(Object owner) {
    _pages.remove(owner);
    if (_activePage != owner) return;
    _activePage = _pages.isEmpty ? null : _pages.keys.last;
    notifyListeners();
  }

  void setPageConfig(PageConfig config) =>
      activatePage(_manualPageOwner, config);
  static final Object _manualPageOwner = Object();

  LoadingHandle showLoading({LoadingContentBuilder? contentBuilder}) {
    final id = _nextLoadingId++;
    _loading[id] = contentBuilder;
    notifyListeners();
    return _LoadingHandle(() {
      final existed = _loading.containsKey(id);
      _loading.remove(id);
      if (existed) {
        notifyListeners();
      }
    });
  }

  @override
  void pushLoading() {
    _legacyLoading.add(showLoading());
  }

  @override
  void popLoading() {
    if (_legacyLoading.isEmpty) return;
    _legacyLoading.removeLast().close();
  }

  @override
  void showToast({
    required ToastType type,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? dedupeKey,
  }) {
    _toasts.show(
      type: type,
      message: message,
      duration: duration,
      dedupeKey: dedupeKey,
    );
  }

  void dismissToast(String id) => _toasts.dismiss(id);

  bool startTutorial(String tourId, {bool force = false}) =>
      tutorialController.start(tourId, force: force);
  Future<void> endTutorial() => tutorialController.complete();
  void cancelTutorial() => tutorialController.cancel();
  void bindSpotlight(GlobalKey? key) => tutorialController.bindSpotlight(key);
  String? get tutorialTourId => tutorialController.activeTourId;
  TutorialStore get tutorialStore => tutorialController.store;

  @override
  void dispose() {
    connectivity.removeListener(notifyListeners);
    _toasts.dispose();
    tutorialController.dispose();
    super.dispose();
  }
}

class _LoadingHandle implements LoadingHandle {
  _LoadingHandle(this._onClose);

  final void Function() _onClose;
  bool _closed = false;

  @override
  bool get isClosed => _closed;

  @override
  void close() {
    if (_closed) return;
    _closed = true;
    _onClose();
  }
}
