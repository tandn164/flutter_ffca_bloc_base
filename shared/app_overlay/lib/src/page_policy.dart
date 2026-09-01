enum NoInternetMode { inherit, banner, block, off }

class PageConfig {
  const PageConfig({this.noInternet = NoInternetMode.inherit});

  final NoInternetMode noInternet;

  static const splash = PageConfig(noInternet: NoInternetMode.off);
  static const inherit = PageConfig();

  PageConfig resolve(PageConfig parent) {
    if (noInternet != NoInternetMode.inherit) return this;
    return PageConfig(noInternet: parent.noInternet);
  }

  @override
  bool operator ==(Object other) =>
      other is PageConfig && other.noInternet == noInternet;

  @override
  int get hashCode => noInternet.hashCode;
}
