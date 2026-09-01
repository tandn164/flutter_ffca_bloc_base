import 'package:equatable/equatable.dart';
import 'package:feed_domain/feed_domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FeedNoticeKind { success, error }

class FeedNotice extends Equatable {
  const FeedNotice({
    required this.message,
    required this.kind,
    required this.id,
  });

  final String message;
  final FeedNoticeKind kind;
  final int id;

  @override
  List<Object?> get props => [message, kind, id];
}

sealed class FeedEvent extends Equatable {
  const FeedEvent();
  @override
  List<Object?> get props => [];
}

class FeedStarted extends FeedEvent {
  const FeedStarted();
}

class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

class FeedLoadMore extends FeedEvent {
  const FeedLoadMore();
}

class FeedCreated extends FeedEvent {
  const FeedCreated(this.title);
  final String title;
  @override
  List<Object?> get props => [title];
}

class FeedToggled extends FeedEvent {
  const FeedToggled(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

class FeedRenamed extends FeedEvent {
  const FeedRenamed(this.id, this.title);
  final String id;
  final String title;
  @override
  List<Object?> get props => [id, title];
}

class FeedDeleted extends FeedEvent {
  const FeedDeleted(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}

sealed class FeedState extends Equatable {
  const FeedState({this.notice});

  final FeedNotice? notice;
}

class FeedLoading extends FeedState {
  const FeedLoading({super.notice});

  @override
  List<Object?> get props => [notice];
}

class FeedData extends FeedState {
  const FeedData(
    this.items, {
    this.hasMore = false,
    this.loadingMore = false,
    this.page = 1,
    this.generation = 0,
    super.notice,
  });

  final List<FeedItem> items;
  final bool hasMore;
  final bool loadingMore;
  final int page;
  final int generation;

  FeedData copyWith({
    List<FeedItem>? items,
    bool? hasMore,
    bool? loadingMore,
    int? page,
    int? generation,
    FeedNotice? notice,
  }) {
    return FeedData(
      items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      generation: generation ?? this.generation,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [items, hasMore, loadingMore, page, generation, notice];
}

class FeedError extends FeedState {
  const FeedError(this.message, {super.notice});
  final String message;

  @override
  List<Object?> get props => [message, notice];
}

class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc({
    required GetFeed getFeed,
    required CreateFeedItem createItem,
    required UpdateFeedItem updateItem,
    required DeleteFeedItem deleteItem,
  })  : _getFeed = getFeed,
        _createItem = createItem,
        _updateItem = updateItem,
        _deleteItem = deleteItem,
        super(const FeedLoading()) {
    on<FeedStarted>(_load);
    on<FeedRefreshed>(_refresh);
    on<FeedLoadMore>(_loadMore);
    on<FeedCreated>(_create);
    on<FeedToggled>(_toggle);
    on<FeedRenamed>(_rename);
    on<FeedDeleted>(_delete);
  }

  final GetFeed _getFeed;
  final CreateFeedItem _createItem;
  final UpdateFeedItem _updateItem;
  final DeleteFeedItem _deleteItem;
  int _generation = 0;
  int _noticeId = 0;

  FeedNotice _notice(String message, FeedNoticeKind kind) {
    return FeedNotice(message: message, kind: kind, id: ++_noticeId);
  }

  Future<void> _load(FeedStarted event, Emitter<FeedState> emit) async {
    emit(const FeedLoading());
    final result = await _getFeed.execute();
    result.fold(
      ok: (chunk) => emit(FeedData(
        chunk.items,
        hasMore: chunk.hasMore,
        page: 1,
        generation: ++_generation,
      )),
      err: (f) => emit(FeedError(
        f.message,
        notice: _notice(f.message, FeedNoticeKind.error),
      )),
    );
  }

  Future<void> _refresh(FeedRefreshed event, Emitter<FeedState> emit) async {
    final result = await _getFeed.execute(forceNetwork: true);
    result.fold(
      ok: (chunk) => emit(FeedData(
        chunk.items,
        hasMore: chunk.hasMore,
        page: 1,
        generation: ++_generation,
      )),
      err: (f) {
        final current = state;
        if (current is FeedData) {
          emit(current.copyWith(notice: _notice(f.message, FeedNoticeKind.error)));
        } else {
          emit(FeedError(f.message, notice: _notice(f.message, FeedNoticeKind.error)));
        }
      },
    );
  }

  Future<void> _loadMore(FeedLoadMore event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedData || !current.hasMore || current.loadingMore) return;
    emit(current.copyWith(loadingMore: true));
    final page = current.page + 1;
    final result = await _getFeed.execute(page: page);
    if (emit.isDone) return;
    result.fold(
      ok: (chunk) {
        final seen = {for (final e in current.items) e.id};
        emit(FeedData(
          [...current.items, for (final e in chunk.items) if (seen.add(e.id)) e],
          hasMore: chunk.hasMore,
          page: page,
          generation: ++_generation,
        ));
      },
      err: (f) {
        emit(current.copyWith(
          loadingMore: false,
          notice: _notice(f.message, FeedNoticeKind.error),
        ));
      },
    );
  }

  Future<void> _create(FeedCreated event, Emitter<FeedState> emit) async {
    final result = await _createItem.execute(title: event.title);
    if (emit.isDone) return;
    result.fold(
      ok: (item) {
        final current = state;
        if (current is FeedData) {
          final without = [for (final e in current.items) if (e.id != item.id) e];
          emit(current.copyWith(
            items: [item, ...without],
            generation: ++_generation,
            notice: _notice('Task added', FeedNoticeKind.success),
          ));
        } else {
          emit(FeedLoading(notice: _notice('Task added', FeedNoticeKind.success)));
          add(const FeedRefreshed());
        }
      },
      err: (f) {
        final current = state;
        if (current is FeedData) {
          emit(current.copyWith(notice: _notice(f.message, FeedNoticeKind.error)));
        }
      },
    );
  }

  Future<void> _toggle(FeedToggled event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedData) return;
    final index = current.items.indexWhere((e) => e.id == event.id);
    if (index < 0) return;
    final previous = current.items[index];
    final next = previous.copyWith(done: !previous.done);
    emit(current.copyWith(
      items: [...current.items]..[index] = next,
      generation: ++_generation,
    ));
    final result = await _updateItem.execute(id: event.id, done: next.done);
    if (emit.isDone) return;
    result.fold(
      ok: (item) {
        final latest = state;
        if (latest is! FeedData) return;
        final i = latest.items.indexWhere((e) => e.id == item.id);
        if (i < 0) return;
        emit(latest.copyWith(
          items: [...latest.items]..[i] = item,
          generation: ++_generation,
        ));
      },
      err: (f) {
        final latest = state;
        if (latest is FeedData) {
          final i = latest.items.indexWhere((e) => e.id == event.id);
          if (i >= 0) {
            emit(latest.copyWith(
              items: [...latest.items]..[i] = previous,
              generation: ++_generation,
              notice: _notice(f.message, FeedNoticeKind.error),
            ));
            return;
          }
        }
      },
    );
  }

  Future<void> _rename(FeedRenamed event, Emitter<FeedState> emit) async {
    final result = await _updateItem.execute(id: event.id, title: event.title);
    if (emit.isDone) return;
    result.fold(
      ok: (item) {
        final current = state;
        if (current is! FeedData) return;
        final i = current.items.indexWhere((e) => e.id == item.id);
        if (i < 0) return;
        emit(current.copyWith(
          items: [...current.items]..[i] = item,
          generation: ++_generation,
          notice: _notice('Task updated', FeedNoticeKind.success),
        ));
      },
      err: (f) {
        final current = state;
        if (current is FeedData) {
          emit(current.copyWith(notice: _notice(f.message, FeedNoticeKind.error)));
        }
      },
    );
  }

  Future<void> _delete(FeedDeleted event, Emitter<FeedState> emit) async {
    final current = state;
    if (current is! FeedData) return;
    final remaining = [for (final e in current.items) if (e.id != event.id) e];
    emit(current.copyWith(items: remaining, generation: ++_generation));
    final result = await _deleteItem.execute(id: event.id);
    if (emit.isDone) return;
    result.fold(
      ok: (_) {},
      err: (f) {
        emit(current.copyWith(notice: _notice(f.message, FeedNoticeKind.error)));
        add(const FeedRefreshed());
      },
    );
  }
}
