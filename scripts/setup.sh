#!/usr/bin/env bash
set -euo pipefail

# BookinMan project setup — run locally after cloning.
# Requires: Flutter SDK (>=3.22), Dart (>=3.4), Firebase CLI, and `flutterfire`.

echo "==> [1/4] Fetch dependencies"
flutter pub get

echo "==> [2/4] Generate Isar models (codegen)"
flutter pub run build_runner build --delete-conflicting-outputs

echo "==> [3/4] Configure Firebase (interactive; writes lib/firebase_options.dart)"
flutterfire configure \
  --project=loanshark6 \
  --out=lib/firebase_options.dart \
  --ios-bundle-id=com.sudotechweb.bookinman \
  --android-package-name=com.sudotechweb.bookinman

echo "==> [4/4] Static analysis + unit tests"
flutter analyze
flutter test

echo "Done. Run 'flutter run' to launch on a connected device/emulator."
