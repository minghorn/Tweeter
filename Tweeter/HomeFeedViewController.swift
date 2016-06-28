//
//  HomeFeedViewController.swift
//  Tweeter
//
//  Created by Ming Horn on 6/27/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class HomeFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        
        //Request tweets and put them into an array
        TwitterClient.sharedInstance.homeTimeline({ (tweets:[Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLogOut(sender: AnyObject) {
        TwitterClient.sharedInstance.logOut()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetCell
        return cell
    }
    
}
