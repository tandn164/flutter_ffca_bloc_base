enum ProcessStatus {
  initial,
  processing,
  updating,
  success,
  failure;

  bool get isInitial => this == ProcessStatus.initial;
  bool get isProcessing => this == ProcessStatus.processing;
  bool get isUpdating => this == ProcessStatus.updating;
  bool get isSuccess => this == ProcessStatus.success;
  bool get isFailure => this == ProcessStatus.failure;
  bool get isExecuting =>
      this == ProcessStatus.processing || this == ProcessStatus.updating;
}

enum ListStatus {
  initial,
  refreshing,
  loadingMore,
  updating,
  success,
  failure;

  bool get isInitial => this == ListStatus.initial;
  bool get isRefreshing => this == ListStatus.refreshing;
  bool get isLoadingMore => this == ListStatus.loadingMore;
  bool get isUpdating => this == ListStatus.updating;
  bool get isSuccess => this == ListStatus.success;
  bool get isFailure => this == ListStatus.failure;
  bool get isProcessing =>
      this == ListStatus.refreshing ||
      this == ListStatus.loadingMore ||
      this == ListStatus.updating;
}
