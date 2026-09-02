#!/usr/bin/env python3
"""Upgrade a freshly created feature using the base's checked-in templates."""
from pathlib import Path
import sys


def generate(root, name, app, wire):
    pascal = ''.join(word.capitalize() for word in name.split('_'))
    feature = root / 'features' / name
    templates = root / 'tool/scaffold/templates/generated'

    def write(path, content):
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content.replace('__name__', name).replace('__Pascal__', pascal))

    def render(template, path):
        write(path, (templates / template).read_text())

    def deps(path, section, values):
        content = path.read_text()
        lines = ''.join(f'  {key}: {value}\n' for key, value in values.items()
                        if f'  {key}:' not in content)
        if f'\n{section}:\n' not in content:
            content += f'\n{section}:\n'
        path.write_text(content.replace(f'\n{section}:\n', f'\n{section}:\n{lines}', 1))

    domain, data, presentation = [feature / f'{name}_{layer}' for layer in ('domain', 'data', 'presentation')]
    for package in (domain, data, presentation):
        deps(package / 'pubspec.yaml', 'dependencies', {'freezed_annotation': '^3.1.0'})
        deps(package / 'pubspec.yaml', 'dev_dependencies', {'build_runner': '^2.4.13', 'freezed': '3.0.6'})
    deps(data / 'pubspec.yaml', 'dependencies', {'json_annotation': '^4.9.0'})
    deps(data / 'pubspec.yaml', 'dev_dependencies', {'json_serializable': '6.9.5'})
    deps(presentation / 'pubspec.yaml', 'dependencies', {'flutter_bloc': '^9.1.1'})
    render('domain_item.dart.template', domain / f'lib/src/{name}_item.dart')
    render('data_dto.dart.template', data / f'lib/src/{name}_item_dto.dart')
    render('presentation_bloc.dart.template', presentation / f'lib/src/{name}_bloc.dart')
    render('presentation_page.dart.template', presentation / f'lib/src/{name}_page.dart')
    for package, extra in ((domain, 'item'), (data, 'item_dto'), (presentation, 'bloc')):
        barrel = package / f'lib/{package.name}.dart'
        barrel.write_text(barrel.read_text() + f"export 'src/{name}_{extra}.dart';\n")

    write(domain / f'lib/src/{name}_repository.dart', """import '__name___item.dart';
abstract class __Pascal__Repository {
  Future<List<__Pascal__Item>> listItems();
}
""")
    use_cases = domain / f'lib/src/{name}_use_cases.dart'
    use_cases.write_text(f"import '{name}_item.dart';\n" + use_cases.read_text().replace('List<String>', f'List<{pascal}Item>'))
    repository = data / f'lib/src/{name}_repository_impl.dart'
    repository.write_text(repository.read_text().replace('List<String>', f'List<{pascal}Item>'))
    write(domain / f'test/{name}_use_cases_test.dart', """import 'package:__name___domain/__name___domain.dart';
import 'package:test/test.dart';
class _Repository implements __Pascal__Repository {
  @override
  Future<List<__Pascal__Item>> listItems() async => const [__Pascal__Item(id: '1', title: 'Sample')];
}
void main() {
  test('use case delegates; generated equality and copyWith work', () async {
    final items = await List__Pascal__Items(_Repository())();
    expect(items.single.copyWith(title: 'Changed'), const __Pascal__Item(id: '1', title: 'Changed'));
  });
}
""")
    write(data / f'test/{name}_dto_test.dart', """import 'package:__name___data/__name___data.dart';
import 'package:test/test.dart';
void main() {
  test('DTO JSON round-trip and explicit entity mapping', () {
    const dto = __Pascal__ItemDto(id: '1', title: 'Sample');
    expect(__Pascal__ItemDto.fromJson(dto.toJson()), dto);
    expect(dto.toEntity().id, '1');
  });
}
""")
    write(presentation / f'test/{name}_page_test.dart', """import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:__name___domain/__name___domain.dart';
import 'package:__name___presentation/__name___presentation.dart';
class _Repository implements __Pascal__Repository {
  @override
  Future<List<__Pascal__Item>> listItems() async => const [__Pascal__Item(id: '1', title: 'Loaded item')];
}
void main() {
  testWidgets('UI loads items through BLoC and use case', (tester) async {
    await tester.pumpWidget(MaterialApp(home: __Pascal__Page(
      createBloc: () => __Pascal__Bloc(List__Pascal__Items(_Repository())),
    )));
    await tester.pumpAndSettle();
    expect(find.text('Loaded item'), findsOneWidget);
  });
}
""")
    if wire:
        app_dir = root / 'apps' / app
        deps(app_dir / 'pubspec.yaml', 'dependencies', {'injectable': '^2.5.0'})
        deps(app_dir / 'pubspec.yaml', 'dev_dependencies', {
            'build_runner': '^2.4.13', 'injectable_generator': '^2.7.0', 'go_router_builder': '2.8.2'})
        render('app_di.dart.template', app_dir / f'lib/app/features/{name}/{name}_di.dart')
        render('app_feature.dart.template', app_dir / f'lib/app/features/{name}_feature.dart')

    write(feature / 'README.md', """# __Pascal__ feature

## Generated conventions

- Domain: Freezed immutable item, repository contract, use case; no DI or JSON.
- Data: Freezed + json_serializable DTO, explicit `toEntity`, repository implementation.
- Presentation: Freezed state, BLoC, injected page; no data/GetIt imports.
- App (when wired): explicit feature DI initializer via Injectable, typed route helper.

The initial repository returns an empty list. Replace its data source with your
API/database; no production fake is registered. The widget test supplies a test
double to verify the UI-to-use-case path.

## Generate and test

Run `make codegen APP=__app__` after editing models, bindings, or route annotations.
Use `make codegen-watch PACKAGE=features/__name__/__name___data` during development.
Do not edit generated `.freezed.dart`, `.g.dart`, or `.config.dart` files; commit them.
Run `make test APP=__app__` and `make codegen-check APP=__app__` before submitting.

## Enable / disable

When wired, the app manifest chooses this feature's dependency initializer and
routes. Keep registration explicit; do not scan/register every feature globally.
For `WIRE=0`, packages are created without app imports or registrations.
""".replace('__app__', app))


if __name__ == '__main__':
    generate(Path(sys.argv[1]), sys.argv[2], sys.argv[3], sys.argv[4] == '1')
