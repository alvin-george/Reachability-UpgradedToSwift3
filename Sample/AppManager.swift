//
//  AppManager.swift
//  ReachOut
//
//  Created by FTS-MAC-017 on 07/01/16.
//  Copyright © 2016 Fingent Technology Solutions. All rights reserved.
//

import UIKit
import Foundation

class AppManager: NSObject{
    
	var delegate:AppManagerDelegate? = nil
    fileprivate var _useClosures:Bool = false
    fileprivate var reachability: Reachability?
    fileprivate var _isReachability:Bool = false

    var isReachability:Bool {
        get {return _isReachability}
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

    // Reachability Methods--------------------------------------------------------------------------------//
    func initRechabilityMonitor() {
        print("initialize rechability...")
        do {
            let reachability = try Reachability.reachabilityForInternetConnection()
            self.reachability = reachability
        } catch ReachabilityError.failedToCreateWithAddress(let address) {
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
    
    fileprivate func notifyReachability(_ reachability:Reachability) {
        if reachability.isReachable() {
            self._isReachability = true
        } else {
            self._isReachability = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppManager.reachabilityChanged(_:)), name: NSNotification.Name(rawValue: ReachabilityChangedNotification), object: reachability)
    }
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        DispatchQueue.main.async {
			self.delegate?.reachabilityStatusChangeHandler(reachability)

        }
    }
    deinit {
        reachability?.stopNotifier()
        if (!_useClosures) {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: ReachabilityChangedNotification), object: nil)
        }
    }
}
