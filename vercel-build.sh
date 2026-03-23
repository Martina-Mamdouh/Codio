#!/bin/bash

# Fix git ownership issue
git config --global --add safe.directory '*'

# Download NEW Flutter (important: Dart 3.8+)
curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.0-stable.tar.xz
tar xf flutter.tar.xz

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor
flutter config --enable-web

# Clean install deps
flutter clean
flutter pub get

# Build admin entry
flutter build web -t lib/main_admin.dart