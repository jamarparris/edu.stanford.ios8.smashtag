//
//  TweetImageTableViewCell.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/23/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class TweetImageTableViewCell: UITableViewCell {
    
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }

    @IBOutlet weak var tweetMentionImageView: UIImageView!
    
    private func updateUI() {
        
        //reset any existing image on cell
        tweetMentionImageView?.image = nil
        
        if let url = imageURL {
        
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                
                if let imageData = NSData(contentsOfURL: url) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        tweetMentionImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }

}
