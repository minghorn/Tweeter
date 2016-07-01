//
//  ComposeViewController.swift
//  Tweeter
//
//  Created by Ming Horn on 6/30/16.
//  Copyright © 2016 Ming Horn. All rights reserved.
//

import UIKit

class ComposeViewController: UIViewController {

    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var profileButton: UIBarButtonItem!
    @IBOutlet weak var tweetText: UITextField!
    @IBOutlet weak var characterCount: UILabel!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var tweetButtonsView: UIView!
    @IBOutlet weak var keyboardConstraint: NSLayoutConstraint!
    
    var chars = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetButton.layer.cornerRadius  = 5.0
        tweetButton.layer.masksToBounds = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIKeyboardWillChangeFrameNotification, object: nil)
        tweetText.becomeFirstResponder()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextViewTextDidChangeNotification, object: nil)
        
        TwitterClient.sharedInstance.currentAccount({ (user: User) in
            if(user.profileUrl != nil) {
                let imageData = NSData(contentsOfURL: user.profileUrl!)
                let bgImage = UIImage(data: imageData!)
                let resized = self.resizeImage(bgImage!, newWidth: 30)
                let btnName = UIButton()
                btnName.setImage(resized, forState: .Normal)
                btnName.frame = CGRectMake(0, 0, 30, 30)
                btnName.layer.cornerRadius = 5.0
                btnName.layer.masksToBounds = true
                
                //.... Set Right/Left Bar Button item
                let leftBarButton = UIBarButtonItem()
                leftBarButton.customView = btnName
                self.navigationItem.leftBarButtonItem = leftBarButton
            }
        }) { (error: NSError) in
                print(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelClicked(sender: AnyObject) {
        self.performSegueWithIdentifier("tweetSegue", sender: self)
    }

    @IBAction func tweetClicked(sender: AnyObject) {
        if Int(characterCount.text!) > 0 {
            TwitterClient.sharedInstance.tweet(tweetText.text!, success: { (Tweet) in
                self.performSegueWithIdentifier("tweetSegue", sender: self)
                }, failure: { (error: NSError) in
                    print(error.localizedDescription)
            })
        }

    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame?.origin.y >= UIScreen.mainScreen().bounds.size.height {
                self.keyboardConstraint?.constant = 0.0
            } else {
                self.keyboardConstraint?.constant = (endFrame?.size.height)! + 8.0 ?? 0.0
            }
            UIView.animateWithDuration(duration,
                                       delay: NSTimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    func textFieldDidChange(notification: NSNotification) {
        chars = (tweetText.text?.characters.count)!
        characterCount.text = String(140 - chars)
        if(chars > 0) {
            placeholderLabel.hidden = true
        } else {
            placeholderLabel.hidden = false
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
