#!/bin/bash

git config --global --add safe.directory '*'

# 🔥 Use a newer Flutter (contains Dart 3.8+)
curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.32.0-stable.tar.xz
tar xf flutter.tar.xz

export PATH="$PATH:`pwd`/flutter/bin"

flutter config --enable-web

flutter clean
flutter pub get

flutter build web -t lib/main_admin.dart