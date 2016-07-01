//
//  TwitterClient.swift
//  Tweeter
//
//  Created by Ming Horn on 6/27/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {

    static let sharedInstance = TwitterClient(baseURL: NSURL(string: "https://api.twitter.com"), consumerKey: "ZxAxc2dfZJthyMDGZFX5inUBR", consumerSecret: "CNeq5ZlG4TkPz9xXkr24V7Vd1xGrbuX1QjRnvDUO66UuGS1bur")
    
    var loginSuccess: (() -> ())?
    var loginFailure: (NSError -> ())?
    
    
    func homeTimeline(success: ([Tweet]) -> (), failure: NSError -> ()) {
        GET("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dict = response as! [NSDictionary]
            let tweets = Tweet.tweetsFromArray(dict)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            })
        
    }
    
    func userTimeline(id: String, success: ([Tweet]) -> (), failure: NSError -> ()) {
        GET("1.1/statuses/user_timeline.json?user_id=\(id)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let dict = response as! [NSDictionary]
            let tweets = Tweet.tweetsFromArray(dict)
            success(tweets)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
        
    }
    
    func retweet(tweet: Tweet, success: Tweet -> (), failure: NSError -> ()) {
        POST("1.1/statuses/retweet/\(tweet.tweetId!).json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseTweetDict = response as! NSDictionary
            let responseTweet = Tweet(dict: responseTweetDict)
            success(responseTweet)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
            })
    }
    
    func favorite(tweet: Tweet, success: Tweet -> (), failure: NSError -> ()) {
        POST("1.1/favorites/create.json?id=\(tweet.tweetId!)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseTweetDict = response as! NSDictionary
            let responseTweet = Tweet(dict: responseTweetDict)
            success(responseTweet)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
    }
    
    func tweet(text: String, success: Tweet -> (), failure: NSError -> ()) {
        POST("1.1/statuses/update.json?status=\(text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            let responseTweetDict = response as! NSDictionary
            let responseTweet = Tweet(dict: responseTweetDict)
            success(responseTweet)
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) in
                failure(error)
        })
        print(text.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!)
    }

    func currentAccount(success: (User) -> (), failure: (NSError) -> ()) {
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: NSURLSessionDataTask, response: AnyObject?) -> Void in
            print("account \(response)")
            let userDict = response as! NSDictionary
            let user = User(dict: userDict)
            
            success(user)
            
            }, failure: { (task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
    }
    
    func login(success: () -> (), failure: NSError -> ()) {
        loginSuccess = success
        loginFailure = failure
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "tweeter://oauth"), scope: nil, success: {(requestToken: BDBOAuth1Credential!) -> Void in
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")!
            UIApplication.sharedApplication().openURL(url)
        }) { (error: NSError!) -> Void in
            self.loginFailure?(error)
        }
    }
    
    func logOut() {
        User.currentUser = nil
        deauthorize()
        NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogout, object: nil)
    }
    
    func handleOpenUrl(url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: {(accessToken: BDBOAuth1Credential!) -> Void in
            
            self.currentAccount({ (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
            }, failure: { (error: NSError) -> () in
                self.loginFailure?(error)
            })
            
        }) { (error: NSError!) in
            print(error.localizedDescription)
            self.loginFailure?(error)
        }
    }
    
}
