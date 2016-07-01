//
//  User.swift
//  Tweeter
//
//  Created by Ming Horn on 6/27/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class User: NSObject {
    
    //Stored Properties
    var name: String?
    var screenname: String?
    var profileUrl: NSURL?
    var tagline: String?
    var dictionary: NSDictionary?
    static let userDidLogout = "userDidLogout"
    
    init(dict: NSDictionary) {
        self.dictionary = dict
        name = dict["name"] as? String
        screenname = dict["screen_name"] as? String
        
        let profileUrlString = dict["profile_image_url_https"] as? String
        if var profileUrlString = profileUrlString {
            profileUrlString = profileUrlString.stringByReplacingOccurrencesOfString("_normal", withString: "")
            profileUrl = NSURL(string: profileUrlString)
        }
        
        tagline = dict["description"] as? String
    }
    
    //Computed Property
    static var _currentUser: User?
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let defaults = NSUserDefaults.standardUserDefaults()
                let userData = defaults.objectForKey("currentUser") as? NSData
                if let userData = userData {
                    let userDict = try! NSJSONSerialization.JSONObjectWithData(userData, options: []) as! NSDictionary
                    _currentUser = User(dict: userDict)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let user = user {
                let currentUserData = try! NSJSONSerialization.dataWithJSONObject(user.dictionary!, options: [])
                defaults.setObject(currentUserData, forKey: "currentUser")
            } else {
                defaults.setObject(nil, forKey: "currentUser")
            }
            defaults.synchronize()
        }
    }
}
