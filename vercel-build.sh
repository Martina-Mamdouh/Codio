#!/bin/bash

# Fix git ownership issues
git config --global --add safe.directory '*'

# Download Flutter 3.41.4 (prebuilt)
curl -L -o flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.41.4-stable.tar.xz
tar xf flutter.tar.xz

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Enable web support
flutter config --enable-web

# Clean previous builds (optional but safe)
flutter clean

# Fetch dependencies
flutter pub get

# Build your admin entry
flutter build web -t lib/main_admin.dart