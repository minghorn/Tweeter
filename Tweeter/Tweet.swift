//
//  Tweet.swift
//  Tweeter
//
//  Created by Ming Horn on 6/27/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var text: String?
    var timestamp: NSDate?
    var retweets: Int = 0
    var favorites: Int = 0
    var author: User?
    var tweetId: String!
    
    init(dict: NSDictionary) {
        text = dict["text"] as? String
        retweets = (dict["retweet_count"] as? Int) ?? 0
        favorites = (dict["favorite_count"] as? Int) ?? 0
        tweetId = dict["id_str"] as? String
        
        let userDict = dict["user"] as! NSDictionary
        author = User(dict: userDict)
        let timestampString = dict["created_at"] as? String
        
        if let timestampString = timestampString {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timestamp = formatter.dateFromString(timestampString)
        }
        
    }
    
    class func tweetsFromArray(dicts: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dictionary in dicts {
            let tweet = Tweet(dict: dictionary)
            tweets.append(tweet)
        }
        return tweets
    }
    
    func getDateString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        return formatter.stringFromDate(date)
    }
}
