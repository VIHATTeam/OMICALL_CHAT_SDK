#!/bin/bash

# Clean and get dependencies
if [ "$1" == "--clean" ]; then
  echo "Cleaning project..."
  flutter clean
  echo "Getting dependencies..."
  flutter pub get
fi

# Build APK
echo "Building APK..."
cd android && ./gradlew assembleDebug && cd ..

# Get first connected Android device ID
DEVICE_ID=$(adb devices | grep -v "List" | grep "device" | head -n 1 | awk '{print $1}')

if [ -z "$DEVICE_ID" ]; then
  echo "No Android device connected!"
  echo "Available devices:"
  adb devices
  exit 1
fi

# Install APK
echo "Installing APK to device $DEVICE_ID..."
adb -s $DEVICE_ID install -r android/app/build/outputs/apk/debug/app-debug.apk

# Start app
echo "Starting app..."
adb -s $DEVICE_ID shell am start -n com.vihat.livetalksdk.livetalk_sdk_example/com.vihat.livetalksdk.livetalk_sdk_example.MainActivity

echo "App started successfully!"
echo "To clean build, run: ./run_android.sh --clean" 