/// Maps a provider-independent `path` + `query` payload to an app location.
String? locationFromPayload(Map<String, dynamic> payload) {
  final raw = payload['path'];
  if (raw == null) return null;
  final path = raw.toString().trim();
  if (path.isEmpty || !path.startsWith('/')) return null;

  final query = payload['query'];
  if (query is! Map || query.isEmpty) return path;
  final params = <String, String>{};
  query.forEach((key, value) {
    if (value != null) params[key.toString()] = value.toString();
  });
  if (params.isEmpty) return path;
  return Uri(path: path, queryParameters: params).toString();
}
