//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/23/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        
        //reset any existing image on cell
        imgView?.image = nil
        
        if let url = imageURL {
            
            DataFetcher().getAsyncNSDataForURL(url) {
                //ensure URL hasn't been updated since
                if url == self.imageURL {
                    let imageData = $0
                    self.imgView?.image = UIImage(data: imageData)
                }
            }
        }
    }

}
