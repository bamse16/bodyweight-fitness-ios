import UIKit
import Material
import CoreData
//import Fabric
//import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var mask: CALayer?
    
    var sideNavigationViewController: SideNavigationController?
    
    var sideViewController: UIViewController?
    var mainViewController: UIViewController?
    var calendarViewController: UIViewController?
    var supportViewController: UIViewController?
    var settingsViewController: UIViewController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        Fabric.with([Crashlytics()])

        UITabBar.appearance().backgroundColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        UITabBar.appearance().tintColor = UIColor(red:0, green:0.59, blue:0.53, alpha:1)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sideViewController = storyboard.instantiateViewControllerWithIdentifier("SideViewController")
            as! SideViewController
        
        mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController")
        calendarViewController = storyboard.instantiateViewControllerWithIdentifier("CalendarNavigationController")
        supportViewController = storyboard.instantiateViewControllerWithIdentifier("SupportDeveloperNavigationViewController")
        settingsViewController = storyboard.instantiateViewControllerWithIdentifier("NavigationSettingsController")
        
        sideNavigationViewController = SideNavigationController(
            rootViewController: mainViewController!,
            leftViewController: sideViewController!
        )
        
        sideNavigationViewController?.setLeftViewWidth(260, hidden: false, animated: false)
        sideNavigationViewController?.toggleLeftView()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = sideNavigationViewController!
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
}

