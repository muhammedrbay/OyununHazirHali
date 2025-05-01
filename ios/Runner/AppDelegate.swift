// import UIKit
// import Flutter
// import FirebaseCore  // Firebase'i import et

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     // Firebase başlatılıyor
//     FirebaseApp.configure()

//     GeneratedPluginRegistrant.register(with: self)

//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

import UIKit
import Flutter
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  lazy var flutterEngine = FlutterEngine(name: "my flutter engine")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()

    flutterEngine.run()
    GeneratedPluginRegistrant.register(with: flutterEngine)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}