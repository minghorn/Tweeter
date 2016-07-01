//
//  DetailsViewController.swift
//  Tweeter
//
//  Created by Ming Horn on 6/29/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var retweetsCount: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    var cell: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = 5.0
        profileImage.layer.masksToBounds = true
        
        tweetLabel.text = cell.text
        timestampLabel.text = formatDate(cell.timestamp!)
        nameLabel.text = cell.author?.name
        retweetsCount.text = String(cell.retweets)
        likesCount.text = String(cell.favorites)
        usernameLabel.text = "@\((cell.author?.screenname)!)"
        if(cell.author?.profileUrl != nil) {
            profileImage.setImageWithURL((cell.author?.profileUrl)!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didReply(sender: AnyObject) {
    }
    
    @IBAction func didRetweet(sender: AnyObject) {
    }
    
    @IBAction func didLike(sender: AnyObject) {
    }
    
    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .ShortStyle
        
        return formatter.stringFromDate(date)
    }

}
