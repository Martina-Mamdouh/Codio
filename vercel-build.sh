#!/bin/bash

# install flutter
git clone https://github.com/flutter/flutter.git --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

flutter config --enable-web
flutter pub get

# 👇 build admin entry
flutter build web -t lib/main_admin.dart