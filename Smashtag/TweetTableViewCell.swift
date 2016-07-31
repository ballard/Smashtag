//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Ivan Lazarev on 20.07.16.
//  Copyright © 2016 Ivan Lazarev. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    @IBOutlet weak var TweetProfileImageView: UIImageView!
    
    var tweet : Twitter.Tweet? {
        didSet{
            updateUI()
        }
    }
    
    private var currentAttributedText = NSMutableAttributedString(string: "")
    
    private var operations = [
        "http://" : Operation.HighlightSubstring(UIColor.grayColor()),
        "https://" : Operation.HighlightSubstring(UIColor.grayColor()),
        "@" : Operation.HighlightSubstring(UIColor.purpleColor()),
        "#" : Operation.HighlightSubstring(UIColor.greenColor())
    ]

    enum Operation {
        case HighlightSubstring(UIColor)
    }
    
    private func calculateRangeOf(symbol: String, forWord word: String, inContent content: String){
        if let operation = operations[symbol]{
            switch operation {
            case .HighlightSubstring (let color):
                currentAttributedText.setAttributes([NSForegroundColorAttributeName : color], range: (content as NSString).rangeOfString(word))
            }
        }
    }
    
    private func updateUI(){
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        TweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        if let tweet = self.tweet{
            let text = tweet.text.stringByReplacingOccurrencesOfString("\n", withString: " ")
            let words = text.componentsSeparatedByString(" ")
            currentAttributedText = NSMutableAttributedString(string: text)
            for word in words{
                for (prefix, _) in operations{
                    if word.hasPrefix(prefix){
                        calculateRangeOf(prefix, forWord:  word, inContent: text)
                    }
                }
            }
            
            tweetTextLabel?.attributedText = currentAttributedText
            if tweetTextLabel.text != nil{
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)"
            tweetScreenNameLabel?.textColor = UIColor.blueColor()
            
            if let profileImageURL = tweet.user.profileImageURL {
                if let imageData = NSData(contentsOfURL: profileImageURL){
                    TweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60{
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
    }    
}
