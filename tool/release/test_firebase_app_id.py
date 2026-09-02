"""Local-only regression tests: python3 -m unittest discover -s tool/release -p 'test_*.py'."""
import json
import os
from pathlib import Path
import plistlib
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from firebase_app_id import resolve


class FirebaseAppIdTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.app = Path(self.tmp.name)
        self.env = patch.dict(os.environ, {}, clear=True)
        self.env.start()
        self.addCleanup(self.env.stop)

    def ios(self):
        path = self.app / 'ios/Runner/Firebase/dev/GoogleService-Info.plist'
        path.parent.mkdir(parents=True)
        path.write_bytes(plistlib.dumps({'GOOGLE_APP_ID': '1:123:ios:abc'}))

    def android(self):
        path = self.app / 'android/app/src/dev/google-services.json'
        path.parent.mkdir(parents=True)
        path.write_text(json.dumps({'client': [
            {'client_info': {'mobilesdk_app_id': app_id,
                             'android_client_info': {'package_name': package}}}
            for package, app_id in [('com.example', '1:123:android:aaa'),
                                    ('com.example.dev', '1:123:android:bbb')]
        ]}))
        (self.app / 'android/app/build.gradle.kts').write_text('''
defaultConfig { applicationId = "com.example" }
productFlavors { create("dev") { applicationIdSuffix = ".dev" } }
''')

    def test_ios_selected_flavor(self):
        self.ios()
        self.assertEqual(resolve(self.app, 'ios', 'dev'), '1:123:ios:abc')
        with self.assertRaises(FileNotFoundError):
            resolve(self.app, 'ios', 'prod')

    def test_override_precedence_without_config(self):
        os.environ.update(FIREBASE_APP_ID_IOS='1:123:ios:aaa', FIREBASE_APP_ID_IOS_DEV='1:123:ios:bbb')
        self.assertEqual(resolve(self.app, 'ios', 'dev'), '1:123:ios:bbb')
        self.assertEqual(resolve(self.app, 'ios', 'prod'), '1:123:ios:aaa')

    def test_reject_wrong_platform_override(self):
        os.environ['FIREBASE_APP_ID_IOS'] = '1:123:android:aaa'
        with self.assertRaises(ValueError):
            resolve(self.app, 'ios', 'dev')

    def test_android_selects_matching_client_not_first(self):
        self.android()
        self.assertEqual(resolve(self.app, 'android', 'dev'), '1:123:android:bbb')

    def test_android_missing_match(self):
        self.android()
        os.environ['ANDROID_APPLICATION_ID'] = 'com.other'
        with self.assertRaises(ValueError):
            resolve(self.app, 'android', 'dev')

    def test_android_explicit_package(self):
        self.android()
        os.environ['ANDROID_APPLICATION_ID'] = 'com.example'
        self.assertEqual(resolve(self.app, 'android', 'dev'), '1:123:android:aaa')

    def test_malformed_plist_has_actionable_error(self):
        self.ios()
        (self.app / 'ios/Runner/Firebase/dev/GoogleService-Info.plist').write_text('broken')
        result = subprocess.run(['/usr/bin/env', 'python3', str(Path(__file__).with_name('firebase_app_id.py')),
                                 str(self.app), 'ios', 'dev'], capture_output=True, text=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('First-time Firebase setup', result.stderr)
        self.assertNotIn('Traceback', result.stderr)

    def release(self, preflight_result='0', **options):
        """Run the real shell orchestration with inert Ruby/Fastlane commands."""
        root = Path(__file__).resolve().parents[2]
        bin_dir = self.app / 'bin'
        bin_dir.mkdir()
        (self.app / 'shims').mkdir()
        version = (root / '.ruby-version').read_text().strip()
        scripts = {
            'rbenv': f'#!/bin/sh\necho {version}\n',
            'fvm': '#!/bin/sh\nexit 0\n',
            'bundle': '''#!/bin/sh
case "$*" in
  *"exec ruby"*) echo PREFLIGHT_CALLED; exit "$PREFLIGHT_RESULT" ;;
  *"exec fastlane"*) echo BUILD_UPLOAD_CALLED ;;
esac
''',
        }
        for name, script in scripts.items():
            path = bin_dir / name
            path.write_text(script)
            path.chmod(0o755)
        import sys
        env = dict(os.environ, PATH=f'{bin_dir}:{Path(sys.executable).parent}:/usr/bin:/bin',
                   RBENV_ROOT=str(self.app), APP='sample_app', PLATFORM='ios', FLAVOR='dev',
                   DESTINATION='firebase', SIGNING='automatic', BUILD_NAME='1.0.0', BUILD_NUMBER='1',
                   FIREBASE_APP_ID_IOS_DEV='1:123:ios:abc', PREFLIGHT_RESULT=preflight_result,
                   CI='1', CONFIRM='1', **options)
        return subprocess.run(['/bin/bash', str(root / 'tool/release.sh')], env=env,
                              input='', capture_output=True, text=True, cwd=root)

    def test_auth_failure_stops_before_build(self):
        result = self.release('1')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('PREFLIGHT_CALLED', result.stdout)
        self.assertNotIn('BUILD_UPLOAD_CALLED', result.stdout)
        self.assertIn('firebase login', result.stderr)
        self.assertIn('FIREBASE_SERVICE_CREDENTIALS_FILE', result.stderr)

    def test_auth_success_proceeds_to_build(self):
        result = self.release()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertLess(result.stdout.index('PREFLIGHT_CALLED'), result.stdout.index('BUILD_UPLOAD_CALLED'))

    def test_dry_run_never_authenticates_or_builds(self):
        result = self.release(DRY_RUN='1')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('PREFLIGHT_CALLED', result.stdout)
        self.assertNotIn('BUILD_UPLOAD_CALLED', result.stdout)

    def test_unreadable_credential_stops_before_preflight(self):
        result = self.release(FIREBASE_SERVICE_CREDENTIALS_FILE=str(self.app / 'missing.json'))
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Cannot read Firebase service-account credential', result.stderr)
        self.assertNotIn('PREFLIGHT_CALLED', result.stdout)


if __name__ == '__main__':
    unittest.main()
