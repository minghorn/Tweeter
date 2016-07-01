//
//  TweetCell.swift
//  Tweeter
//
//  Created by Ming Horn on 6/28/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit


class TweetCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetText: UITextView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var retweetLabel: UILabel!
    @IBOutlet weak var likeLabel: UILabel!
    
    
    var cellTweet: Tweet! {
        didSet {
            tweetText.text = cellTweet.text
            timestampLabel.text = formatDate(cellTweet.timestamp!)
            nameLabel.text = cellTweet.author?.name
            retweetLabel.text = String(cellTweet.retweets)
            likeLabel.text = String(cellTweet.favorites)
            screennameLabel.text = "@\((cellTweet.author?.screenname)!)"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Make profile pictures round
        avatar.layer.cornerRadius = 5.0
        avatar.layer.masksToBounds = true
        
        // Add gesture recognizers to each cell
        let rightSwipeRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(TweetCell.swiped))
        let leftSwipeRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(TweetCell.swiped))
        
        rightSwipeRecognizer.direction = .Right
        leftSwipeRecognizer.direction = .Left
        
        self.addGestureRecognizer(rightSwipeRecognizer)
        self.addGestureRecognizer(leftSwipeRecognizer)
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func didRetweet(sender: AnyObject) {
        TwitterClient.sharedInstance.retweet(self.cellTweet!, success: { (Tweet) in
            
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let startPoint = CGPoint(x: screenSize.width/2, y: self.overlayView.center.y)

            self.retweetLabel.text = String(self.cellTweet!.retweets + 1)
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.overlayView.center.x = startPoint.x
            })
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    @IBAction func didFavorite(sender: AnyObject) {
        TwitterClient.sharedInstance.favorite(self.cellTweet!, success: { (Tweet) in
            self.likeLabel.text = String(self.cellTweet!.favorites +
                1)
            let screenSize: CGRect = UIScreen.mainScreen().bounds
            let startPoint = CGPoint(x: screenSize.width/2, y: self.overlayView.center.y)
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.overlayView.center.x = startPoint.x
            })
        }) { (error: NSError) in
            print(error.localizedDescription)
        }
    }
    
    func swiped(sender: UISwipeGestureRecognizer) {

        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let startPoint = CGPoint(x: screenSize.width/2, y: overlayView.center.y)
        
        if sender.direction == .Right {
            //Close
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.overlayView.center.x = startPoint.x
            })
        } else if sender.direction == .Left {
            //Open
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.overlayView.center.x = startPoint.x - 240
            })
        }
    }
    
    func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        
        let calendar = NSCalendar.currentCalendar()
        let now = NSDate()
        if(calendar.isDateInToday(date)) {
            let diffDateComponents = calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date, toDate: now, options: NSCalendarOptions.init(rawValue: 0))
            if diffDateComponents.minute == 0 {
                return "\(diffDateComponents.second)s"
            } else if diffDateComponents.hour == 0 {
                return "\(diffDateComponents.minute)m"
            }
            return "\(diffDateComponents.hour)h"
        }
        return formatter.stringFromDate(date)
    }
    

}
