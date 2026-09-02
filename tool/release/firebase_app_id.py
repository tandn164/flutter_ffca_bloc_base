#!/usr/bin/env python3
"""Resolve a Firebase upload target without exposing config contents."""

import json
import os
from pathlib import Path
import plistlib
import re
import sys


def resolve(app_dir, platform, flavor):
    scoped = f"FIREBASE_APP_ID_{platform.upper()}_{flavor.upper()}"
    for name in (scoped, f"FIREBASE_APP_ID_{platform.upper()}"):
        if os.environ.get(name):
            value = os.environ[name]
            break
    else:
        if platform == "ios":
            path = app_dir / f"ios/Runner/Firebase/{flavor}/GoogleService-Info.plist"
            with path.open("rb") as source:
                value = plistlib.load(source)["GOOGLE_APP_ID"]
        else:
            path = app_dir / f"android/app/src/{flavor}/google-services.json"
            config = json.loads(path.read_text())
            package = os.environ.get("ANDROID_APPLICATION_ID")
            if not package:
                # The base scaffold uses literal Kotlin applicationId and flavor suffixes.
                # Custom/dynamic Gradle logic must provide the resolved application ID.
                gradle = (app_dir / "android/app/build.gradle.kts").read_text()
                base = re.search(r'applicationId\s*=\s*"([\w.]+)"', gradle)
                block = re.search(r'create\("' + re.escape(flavor) + r'"\)\s*\{([^{}]*)\}', gradle)
                if not base or not block:
                    raise ValueError("Cannot resolve Android applicationId; set ANDROID_APPLICATION_ID to the final release package name")
                override = re.search(r'applicationId\s*=\s*"([\w.]+)"', block[1])
                suffix = re.search(r'applicationIdSuffix\s*=\s*"([\w.]+)"', block[1])
                package = (override[1] if override else base[1]) + (suffix[1] if suffix else "")
            matches = [c["client_info"]["mobilesdk_app_id"] for c in config["client"]
                       if c.get("client_info", {}).get("android_client_info", {}).get("package_name") == package]
            if len(matches) != 1:
                raise ValueError(f"Expected exactly one Firebase client matching Android package {package} in {path}")
            value = matches[0]
    if not isinstance(value, str) or not re.fullmatch(r"1:[0-9]+:" + platform + r":[A-Za-z0-9]+", value):
        raise ValueError(f"Invalid Firebase App ID for {platform}; expected 1:123456789:{platform}:abc123 (not a bundle/package ID)")
    return value


if __name__ == "__main__":
    try:
        print(resolve(Path(sys.argv[1]), sys.argv[2], sys.argv[3]))
    except (OSError, ValueError, KeyError, TypeError, plistlib.InvalidFileException) as error:
        print(f"Firebase target configuration error: {error}", file=sys.stderr)
        print("Place the Google Service config in the selected flavor folder, or set the platform/flavor FIREBASE_APP_ID override. See tool/release/README.md, First-time Firebase setup.", file=sys.stderr)
        sys.exit(1)
