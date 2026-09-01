/// Reads a translation CSV (key,en,ja,...) and merges into lib/l10n/*.arb.
/// Extra keys already in ARB are kept. Exits 1 if ja is missing any en key.
///
/// Not imported by lib/. Sheet ID stays in CI env, not in Dart app code.
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final root = Directory.current;
  final csvPath = args.isEmpty ? 'tool/l10n/translations.csv' : args.first;
  final csvFile = File(csvPath);
  if (!csvFile.existsSync()) {
    stderr.writeln('missing $csvPath');
    exit(1);
  }

  final rows = parseCsv(csvFile.readAsStringSync());
  if (rows.isEmpty) {
    stderr.writeln('empty CSV');
    exit(1);
  }

  final header = rows.first.map((c) => c.trim()).toList();
  final keyIdx = header.indexOf('key');
  if (keyIdx < 0) {
    stderr.writeln('CSV needs a key column');
    exit(1);
  }

  final locales = <String, int>{};
  for (var i = 0; i < header.length; i++) {
    if (i == keyIdx) continue;
    locales[header[i]] = i;
  }

  final byLocale = <String, Map<String, String>>{
    for (final locale in locales.keys) locale: {},
  };
  for (final row in rows.skip(1)) {
    if (row.isEmpty || row[keyIdx].trim().isEmpty) continue;
    final key = row[keyIdx].trim();
    for (final e in locales.entries) {
      if (e.value >= row.length) continue;
      final value = row[e.value];
      if (value.isEmpty) continue;
      byLocale[e.key]![key] = value;
    }
  }

  const localeFiles = {'en': 'intl_en.arb', 'ja': 'intl_ja.arb'};
  for (final e in localeFiles.entries) {
    final file = File('${root.path}/lib/l10n/${e.value}');
    final existing = file.existsSync()
        ? Map<String, dynamic>.from(
            jsonDecode(file.readAsStringSync()) as Map,
          )
        : <String, dynamic>{};
    final incoming = byLocale[e.key] ?? {};
    for (final kv in incoming.entries) {
      existing[kv.key] = kv.value;
    }
    existing.remove('@@locale');
    final ordered = <String, dynamic>{'@@locale': e.key};
    for (final kv in existing.entries) {
      if (kv.key.startsWith('@') && kv.key != '@@locale') {
        ordered[kv.key] = kv.value;
      }
    }
    for (final kv in existing.entries) {
      if (kv.key.startsWith('@')) continue;
      ordered[kv.key] = kv.value;
    }
    file.writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(ordered)}\n');
    stdout.writeln('${file.path} ← ${incoming.length} CSV keys');
  }

  final en = jsonDecode(File('${root.path}/lib/l10n/intl_en.arb').readAsStringSync())
      as Map<String, dynamic>;
  final ja = jsonDecode(File('${root.path}/lib/l10n/intl_ja.arb').readAsStringSync())
      as Map<String, dynamic>;
  final missing = en.keys
      .where((k) => !k.startsWith('@') && !ja.containsKey(k))
      .toList();
  if (missing.isNotEmpty) {
    stderr.writeln('intl_ja.arb missing keys: $missing');
    exit(1);
  }
}

List<List<String>> parseCsv(String source) {
  final rows = <List<String>>[];
  var row = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < source.length; i++) {
    final ch = source[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < source.length && source[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        cell.write(ch);
      }
    } else if (ch == '"') {
      inQuotes = true;
    } else if (ch == ',') {
      row.add(cell.toString());
      cell.clear();
    } else if (ch == '\n') {
      row.add(cell.toString());
      cell.clear();
      if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
      row = [];
    } else if (ch != '\r') {
      cell.write(ch);
    }
  }
  if (cell.isNotEmpty || row.isNotEmpty) {
    row.add(cell.toString());
    if (row.any((c) => c.trim().isNotEmpty)) rows.add(row);
  }
  return rows;
}
