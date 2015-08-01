//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Jamar Parris on 6/24/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell
{
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    func updateUI() {
        //reset any existing Tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        //load new information from our tweet (if any)
        if let tweet = self.tweet {
            
            //create attributed string from tweet text
            var tweetTextAttributedString = NSMutableAttributedString(string: tweet.text)
            
            //set color attributes on hashtags
            let hashtagColor = UIColor.grayColor()
            for hashtag in tweet.hashtags {
                tweetTextAttributedString.setAttributes([NSForegroundColorAttributeName: hashtagColor], range: hashtag.nsrange)
            }
            
            //set color attributes on URLs
            let urlColor = UIColor.blueColor()
            for url in tweet.urls {
                tweetTextAttributedString.setAttributes([NSForegroundColorAttributeName: urlColor], range: url.nsrange)
            }
            
            //set color attributes on mentioned users
            let userMentionColor = UIColor.redColor()
            for userMention in tweet.userMentions {
                tweetTextAttributedString.setAttributes([NSForegroundColorAttributeName: userMentionColor], range: userMention.nsrange)
            }
            
            //set attributedText property
            tweetTextLabel?.attributedText = tweetTextAttributedString
            
            tweetScreenNameLabel?.text = "\(tweet.user)" //tweet.user.description
            
            if let profileImageURL = tweet.user.profileImageURL {
                
                //fetch imageData on another thread to not block UI
                DataFetcher().getAsyncNSDataForURL(profileImageURL) {
                    
                    if profileImageURL == tweet.user.profileImageURL {
                    
                        let imageData = $0
                        self.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }
        
    }
}
