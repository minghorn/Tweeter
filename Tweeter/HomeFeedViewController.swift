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
    
    @IBOutlet weak var profileButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "tweetCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        //Request tweets and put them into an array
        getTweets()
        
        navigationItem.titleView = UIImageView.init(image: UIImage(named:"Hummingbird-100"))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getTweets() {
        TwitterClient.sharedInstance.homeTimeline({ (tweets:[Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
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
        let tweet = tweets![indexPath.row]
        cell.cellTweet = tweet
        if(tweet.author?.profileUrl != nil) {
            cell.avatar.setImageWithURL((tweet.author?.profileUrl)!)
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            cell.avatar.addGestureRecognizer(tapGestureRecognizer)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier("detailSegue", sender: cell)
    }
    
    
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        getTweets()
        refreshControl.endRefreshing()
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        let imageView = sender.view
        let superView = imageView?.superview?.superview?.superview as? UITableViewCell
        self.performSegueWithIdentifier("profileSegue", sender: superView)
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let index = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let vc = segue.destinationViewController as? DetailsViewController
            let tweet = tweets![index!.item]
            vc?.cell = tweet
        } else if segue.identifier == "profileSegue" {
            let index = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let nav = segue.destinationViewController as? UINavigationController
            let vc = nav?.viewControllers.first as? ProfileViewController
            let user = tweets![index!.item].author! as User
            vc!.passedUser = user
        } else if segue.identifier == "meSegue" {
            let nav = segue.destinationViewController as? UINavigationController
            let vc = nav?.viewControllers.first as? ProfileViewController
            TwitterClient.sharedInstance.currentAccount({ (user: User) in
                vc!.user = user
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }
    }
    
}
