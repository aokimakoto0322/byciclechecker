import UIKit
import Flutter
import GoogleMaps
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          GADMobileAds.sharedInstance().start(completionHandler: nil)
      })
    } else {
        // Fallback on earlier versions
        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }
    GMSServices.provideAPIKey("AIzaSyDn1zh9lvHFiXq5wp3V6KDjxg7MwLuNMJw")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
