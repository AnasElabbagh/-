# -workflows:
  build-apk:
    name: Build Android APK
    instance_type: mac_mini
    environment:
      flutter: stable
    scripts:
      - name: Build APK
        script: |
          flutter pub get
          flutter build apk --release
    artifacts:
      - build/app/outputs/flutter-apk/app-release.apk
