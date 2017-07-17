//
//  ViewController.swift
//  Sample
//
//  Created by fingent on 11/02/16.
//  Copyright © 2016 fingent. All rights reserved.
//

import UIKit

class ViewController: UIappViewController {
    
	var reachability:Reachability?

    @IBOutlet weak var networkStatusLabel: UILabel!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		manager.delegate = self

		if(AppManager.sharedInstance.isReachability)
		{
			print("network available")
            self.networkStatusLabel.text = "Network Available"
			//call API from here.

		} else {
			DispatchQueue.main.async {
                self.networkStatusLabel.text = "Network Unavailable"
				print("Network Unavailable")
				//Show Alert
			}
		}
	}
	override func viewWillAppear(_ animated: Bool) {
	}
	override func didReceiveMemoryWarning() {
	}
}

