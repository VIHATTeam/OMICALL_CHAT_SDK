#!/bin/bash

# Clean project
echo "Cleaning project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build APK
echo "Building APK..."
cd android && ./gradlew assembleDebug && cd ..

DEVICE_ID="26b8391c47217ece"

echo "Using Android device: $DEVICE_ID"
echo "Installing APK..."
adb -s $DEVICE_ID install -r android/app/build/outputs/apk/debug/app-debug.apk
echo "Starting app..."
adb -s $DEVICE_ID shell am start -n com.vihat.livetalksdk.livetalk_sdk_example/com.vihat.livetalksdk.livetalk_sdk_example.MainActivity 