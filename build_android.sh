#!/bin/bash
cd example/android && ./gradlew --stacktrace clean && cd .. && flutter clean && cd .. && flutter clean && cd example && flutter pub get && flutter build apk --debug
