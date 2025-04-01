#!/bin/bash

# Clean project
echo "Cleaning project..."
flutter clean

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Get first Android device ID
echo "Looking for Android devices..."
ANDROID_DEVICE=$(flutter devices | grep "android" | head -n 1 | awk '{print $2}' | tr -d '•' | xargs)

if [ -n "$ANDROID_DEVICE" ]; then
    echo "Found Android device: $ANDROID_DEVICE"
    echo "Running on Android device..."
    flutter run -d "$ANDROID_DEVICE"
else
    echo "No Android device found. Available devices:"
    flutter devices
fi 