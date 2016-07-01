//
//  ProfileViewController.swift
//  Tweeter
//
//  Created by Ming Horn on 6/29/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var followersCount: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var tweets: [Tweet]?
    
    var passedUser: User!
    var user: User! {
        didSet {
            setProfile()
            getTweets()
            self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: nil), forCellReuseIdentifier: "tweetCell")
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 200
            tableView.dataSource = self
            tableView.delegate = self
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if passedUser != nil {
            user = passedUser
        }
        
        profileImage.layer.cornerRadius = 10.0
        profileImage.layer.masksToBounds = true
        profileImage.layer.borderColor = UIColor.whiteColor().CGColor
        profileImage.layer.borderWidth = 5.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutClicked(sender: AnyObject) {
        TwitterClient.sharedInstance.logOut()
    }
    
    func setProfile() {
        nameLabel.text = self.user.name
        usernameLabel.text = "@\(self.user.screenname!)"
        descriptionLabel.text = user.tagline
        followersCount.text = String(user.dictionary!["followers_count"]!)
        followingCount.text = String(user.dictionary!["friends_count"]!)
        
        let profileBannerURL = user.dictionary!["profile_banner_url"] as? String
        if(user.profileUrl != nil) {
            profileImage.setImageWithURL((user.profileUrl)!)
        }
        if(profileBannerURL?.characters.count > 0) {
            backgroundImage.setImageWithURL(NSURL(string: profileBannerURL!)!)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let tweets = tweets {
            print(tweets.count)
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
        print("selected")
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        self.performSegueWithIdentifier("detailSegue", sender: cell)
    }
    
    func getTweets() {
        let id = user.dictionary!["id_str"] as! String
        TwitterClient.sharedInstance.userTimeline(id, success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            print(tweets)
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func imageTapped(sender: UITapGestureRecognizer) {
        let imageView = sender.view
        let superView = imageView?.superview?.superview?.superview as? UITableViewCell
        let index = self.tableView.indexPathForCell(superView!)

        
        let profile = ProfileViewController()
        let passedUser = tweets![index!.item].author! as User
        profile.passedUser = passedUser
        self.navigationController?.pushViewController(profile, animated: true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailSegue" {
            let index = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let vc = segue.destinationViewController as? DetailsViewController
            let tweet = tweets![index!.item]
            vc?.cell = tweet
        }
    }

}
