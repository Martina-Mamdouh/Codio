#!/bin/bash

# Clone full Flutter repo (NOT shallow)
git clone https://github.com/flutter/flutter.git
cd flutter

# Checkout stable version (important!)
git checkout 3.24.0  # or latest stable

cd ..

export PATH="$PATH:`pwd`/flutter/bin"

flutter doctor
flutter config --enable-web

# Clean + get packages
flutter clean
flutter pub get

# Build your admin app
flutter build web -t lib/main_admin.dart