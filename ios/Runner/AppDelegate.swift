import UIKit
import PushKit

@main
@objc class AppDelegate: FlutterAppDelegate {

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
              
        enableSendbirdFlutter(application)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}

