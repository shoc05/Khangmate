import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    //  Correct placement of your Google Maps API key
    GMSServices.provideAPIKey("AIzaSyBH0kz5frgWst3mTtvQiLdkYqK6sgKXnPw")

    // Registers Flutter plugins
    GeneratedPluginRegistrant.register(with: self)

    // Must return super to complete initialization
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
