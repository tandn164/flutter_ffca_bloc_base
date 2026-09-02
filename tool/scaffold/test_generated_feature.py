"""Scaffold regression checks without network access or repository mutations."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class GeneratedFeatureTest(unittest.TestCase):
    def test_two_tabs_and_unwired_feature(self):
        source = Path(__file__).resolve().parents[2]
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            shutil.copytree(source / 'tool/scaffold', root / 'tool/scaffold')
            (root / 'tool/codegen_all.sh').write_text('#!/bin/sh\nexit 0\n')
            (root / 'pubspec.yaml').write_text('name: fixture\nworkspace:\n  - apps/sample_app\ndev_dependencies:\n  test: ^1.25.0\n')
            app = root / 'apps/sample_app'
            (app / 'lib/app/features').mkdir(parents=True)
            (app / 'pubspec.yaml').write_text('name: sample_app\ndependencies:\n  get_it: ^8.0.3\n  go_router: ^14.6.2\ndev_dependencies:\n  test: ^1.25.0\n')
            manifest = app / 'lib/app/features/sample_features.dart'
            shutil.copyfile(source / 'apps/sample_app/lib/app/features/sample_features.dart', manifest)
            bin_dir = root / 'bin'
            bin_dir.mkdir()
            fvm = bin_dir / 'fvm'
            fvm.write_text('#!/bin/sh\nexit 0\n')
            fvm.chmod(0o755)
            env = dict(os.environ, PATH=f'{bin_dir}:{os.environ["PATH"]}', APP='sample_app', ROUTE_KIND='tab')
            for name, wire in [('order_history', '1'), ('inventory', '1'), ('detached', '0')]:
                result = subprocess.run(['bash', str(root / 'tool/scaffold/new_feature.sh')],
                                        env=dict(env, NAME=name, WIRE=wire), capture_output=True, text=True)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                dto = root / f'features/{name}/{name}_data/lib/src/{name}_item_dto.dart'
                self.assertIn('@freezed', dto.read_text())
                self.assertNotIn('__name__', dto.read_text())
            self.assertIn('createOrderHistoryBranch(sl)', manifest.read_text())
            workspace = (root / 'pubspec.yaml').read_text()
            self.assertLess(workspace.index('  - features/order_history/'), workspace.index('dev_dependencies:'))
            self.assertIn('createInventoryBranch(sl)', manifest.read_text())
            self.assertNotIn('detached', manifest.read_text())
            self.assertFalse((app / 'lib/app/features/detached_feature.dart').exists())
            di = app / 'lib/app/features/order_history/order_history_di.dart'
            self.assertIn("generateForDir: ['lib/app/features/order_history']", di.read_text())


if __name__ == '__main__':
    unittest.main()
