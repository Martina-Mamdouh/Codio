#!/bin/bash

# Download newer Flutter (has Dart 3.8+)
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.0-stable.tar.xz
tar xf flutter_linux_3.27.0-stable.tar.xz

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor
flutter config --enable-web

flutter pub get
flutter build web -t lib/main_admin.dart