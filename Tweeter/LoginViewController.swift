//
//  LoginViewController.swift
//  Tweeter
//
//  Created by Ming Horn on 6/27/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func loginClicked(sender: AnyObject) {
        let twitterClient = TwitterClient.sharedInstance
        
        twitterClient.login({ 
            print("logged in")
            self.performSegueWithIdentifier("loginSegue", sender: nil)
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
        
        
    }

}
