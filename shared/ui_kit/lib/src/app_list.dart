import 'package:flutter/material.dart';

import 'skeletons.dart';

/// List with first-load skeleton, pull-to-refresh, reload, and load-more.
///
/// Parent owns data (BLoC / hook). This widget only maps flags → UI + triggers.
class AppList<T> extends StatefulWidget {
  const AppList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.loading = false,
    this.loadingMore = false,
    this.hasMore = false,
    this.error,
    this.onRefresh,
    this.onReload,
    this.onLoadMore,
    this.skeletonBuilder,
    this.skeletonCount = 6,
    this.loadMoreSkeletonCount = 2,
    this.loadMoreThreshold = 320,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 16),
    this.separatorBuilder,
    this.empty,
    this.controller,
    this.reloadLabel = 'Reload',
    this.emptyLabel = 'No items',
  });

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// First page, no rows yet → skeleton list (not OverlayHost).
  final bool loading;

  /// Next page in flight → skeleton rows at the bottom.
  final bool loadingMore;
  final bool hasMore;
  final String? error;

  final Future<void> Function()? onRefresh;
  final VoidCallback? onReload;
  final VoidCallback? onLoadMore;

  final Widget Function(BuildContext context, int index)? skeletonBuilder;
  final int skeletonCount;
  final int loadMoreSkeletonCount;
  final double loadMoreThreshold;
  final EdgeInsetsGeometry padding;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final Widget? empty;
  final ScrollController? controller;
  final String reloadLabel;
  final String emptyLabel;

  @override
  State<AppList<T>> createState() => _AppListState<T>();
}

class _AppListState<T> extends State<AppList<T>> {
  late final ScrollController _controller;
  var _ownsController = false;
  var _loadMoreScheduled = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void didUpdateWidget(covariant AppList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loadingMore && !widget.loadingMore) {
      _loadMoreScheduled = false;
    }
    if (oldWidget.items.length != widget.items.length) {
      _loadMoreScheduled = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadMore());
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    _maybeLoadMore(notification.metrics);
    return false;
  }

  void _maybeLoadMore([ScrollMetrics? metrics]) {
    if (!mounted) return;
    if (widget.onLoadMore == null || !widget.hasMore) return;
    if (widget.loading || widget.loadingMore || _loadMoreScheduled) return;
    if (widget.items.isEmpty) return;

    final pos =
        metrics ?? (_controller.hasClients ? _controller.position : null);
    if (pos == null) return;
    if (pos.maxScrollExtent > 0 && pos.extentAfter > widget.loadMoreThreshold) {
      return;
    }

    _loadMoreScheduled = true;
    widget.onLoadMore!();
  }

  Widget _skeleton(BuildContext context, int index) {
    return widget.skeletonBuilder?.call(context, index) ??
        SkeletonTile(delay: Duration(milliseconds: index * 80));
  }

  Widget _separator(BuildContext context, int index) {
    return widget.separatorBuilder?.call(context, index) ??
        const SizedBox(height: 10);
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.loading && widget.items.isEmpty
        ? _itemList(skeletonCount: widget.skeletonCount)
        : widget.error != null && widget.items.isEmpty
            ? _statusList(
                message: widget.error!,
                action: widget.onReload,
              )
            : widget.items.isEmpty
                ? _statusList(
                    message: widget.emptyLabel,
                    action: widget.onReload,
                    body: widget.empty,
                  )
                : _itemList(
                    skeletonCount: (widget.hasMore || widget.loadingMore)
                        ? widget.loadMoreSkeletonCount
                        : 0,
                  );

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: widget.onRefresh == null
          ? child
          : RefreshIndicator(
              color: Theme.of(context).colorScheme.primary,
              onRefresh: widget.onRefresh!,
              child: child,
            ),
    );
  }

  Widget _itemList({required int skeletonCount}) {
    final dataCount =
        widget.loading && widget.items.isEmpty ? 0 : widget.items.length;
    final count = dataCount + skeletonCount;
    return ListView.separated(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      itemCount: count,
      separatorBuilder: _separator,
      itemBuilder: (context, index) {
        if (index >= dataCount) {
          return _skeleton(context, index - dataCount);
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }

  Widget _statusList({
    required String message,
    VoidCallback? action,
    Widget? body,
  }) {
    return ListView(
      controller: _controller,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      children: [
        const SizedBox(height: 96),
        body ??
            Text(
              message,
              textAlign: TextAlign.center,
            ),
        if (action != null) ...[
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonal(
              onPressed: action,
              child: Text(widget.reloadLabel),
            ),
          ),
        ],
      ],
    );
  }
}
