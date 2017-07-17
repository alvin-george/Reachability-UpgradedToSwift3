 The idea is to make the Reachability dependency free in the project.

Xcode 8.3.2 - Swift 3.0

1) https://github.com/ashleymills/Reachability.swift. Download add the Reachability class to the project .

Note: While adding, please make sure 'copy items if needed' is ticked.

2) Make an AppManager.swift class . This class will cater as Public Model class where public methods & data will be added and can be utilised in any VC.

//  AppManager.swift

import UIKit
import Foundation

class AppManager: NSObject{
    var delegate:AppManagerDelegate? = nil
    private var _useClosures:Bool = false
    private var reachability: Reachability?
    private var _isReachability:Bool = false
    private var _reachabiltyNetworkType :String?

    var isReachability:Bool {
        get {return _isReachability}
    }  
   var reachabiltyNetworkType:String {
    get {return _reachabiltyNetworkType! }
   }   




    // Create a shared instance of AppManager
    final  class var sharedInstance : AppManager {
        struct Static {
            static var instance : AppManager?
        }
        if !(Static.instance != nil) {
            Static.instance = AppManager()

        }
        return Static.instance!
    }

    // Reachability Methods
    func initRechabilityMonitor() {
        print("initialize rechability...")
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch ReachabilityError.FailedToCreateWithAddress(let address) {
            print("Unable to create\nReachability with address:\n\(address)")
            return
        } catch {}
        if (_useClosures) {
            reachability?.whenReachable = { reachability in
                self.notifyReachability(reachability)
            }
            reachability?.whenUnreachable = { reachability in
                self.notifyReachability(reachability)
            }
        } else {
            self.notifyReachability(reachability!)
        }

        do {
            try reachability?.startNotifier()
        } catch {
            print("unable to start notifier")
            return
        }


    }        
    private func notifyReachability(reachability:Reachability) {
        if reachability.isReachable() {
            self._isReachability = true

//Determine Network Type 
      if reachability.isReachableViaWiFi() {   
        self._reachabiltyNetworkType = CONNECTION_NETWORK_TYPE.WIFI_NETWORK.rawValue
      } else {
        self._reachabiltyNetworkType = CONNECTION_NETWORK_TYPE.WWAN_NETWORK.rawValue
      }

        } else {
            self._isReachability = false
self._reachabiltyNetworkType = CONNECTION_NETWORK_TYPE.OTHER.rawValue

        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
    }
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        dispatch_async(dispatch_get_main_queue()) {
            if (self._useClosures) {
                self.reachability?.whenReachable = { reachability in
                    self.notifyReachability(reachability)
                }
                self.reachability?.whenUnreachable = { reachability in
                    self.notifyReachability(reachability)
                }
            } else {
                self.notifyReachability(reachability)
            }
            self.delegate?.reachabilityStatusChangeHandler(reachability)
        }
    }
    deinit {
        reachability?.stopNotifier()
        if (!_useClosures) {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        }
    }
}
3) Make a Delegate Class. I use delegate method to notify the connectivity status.

//  Protocols.swift

import Foundation
@objc protocol AppManagerDelegate:NSObjectProtocol {

    func reachabilityStatusChangeHandler(reachability:Reachability)
}
4) Make Parent class of UIViewController (Inheritance method). The parent class have methods which are accessible all child VCs.

//  UIappViewController.swift

    import UIKit

    class UIappViewController: UIViewController,AppManagerDelegate {
        var manager:AppManager = AppManager.sharedInstance

        override func viewDidLoad() {
            super.viewDidLoad()
            manager.delegate = self
        }
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
        func reachabilityStatusChangeHandler(reachability: Reachability) {
            if reachability.isReachable() {
                print("isReachable")
            } else {
                print("notReachable")
            }
        }
    }
5) Start Real time Internet Connectivity Monitoring in AppDelegate.

func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    AppManager.sharedInstance.initRechabilityMonitor()
return true
}
6) I have added a Swift File Name AppReference to store constant enum values.

//  AppReference.swift

import Foundation

enum CONNECTION_NETWORK_TYPE : String {

  case WIFI_NETWORK = "Wifi"
  case WWAN_NETWORK = "Cellular"
  case OTHER = "Other"

}
7) On ViewController (ex. You want to call an API only if network is available)

//  ViewController.swift

        import UIKit

class ViewController: UIappViewController {
  var reachability:Reachability?

  override func viewDidLoad() {
    super.viewDidLoad()
    manager.delegate = self

    if(AppManager.sharedInstance.isReachability)
    {
      print("net available")
      //call API from here.

    } else {
      dispatch_async(dispatch_get_main_queue()) {
        print("net not available")
        //Show Alert
      }
    }


    //Determine Network Type
    if(AppManager.sharedInstance.reachabiltyNetworkType == "Wifi")
    {
      print(".Wifi")
    }
    else if (AppManager.sharedInstance.reachabiltyNetworkType == "Cellular")
    {
      print(".Cellular")
    }
    else {
      dispatch_async(dispatch_get_main_queue()) {
        print("Network not reachable")
      }
