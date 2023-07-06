import UIKit
import Flutter
import flutter_uploader
import Firebase

func registerPlugins(registry: FlutterPluginRegistry) {
    GeneratedPluginRegistrant.register(with: registry)
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    SwiftFlutterUploaderPlugin.registerPlugins = registerPlugins
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
