//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/28/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

protocol ImageCacheDataSource: class {
    func imageForURL(url: NSURL) -> UIImage?
    func setImage(image: UIImage, forURL: NSURL, withSizeInBytes: Int)
}

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    
    weak var imageCacheDataSource: ImageCacheDataSource?
    
    var imageURL: NSURL? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        
        //reset any existing image on cell
        imgView?.image = nil
        
        if let url = imageURL {
            
            if let image = imageCacheDataSource?.imageForURL(url) {
                //cache hit
                imgView?.image = image
            } else {
                
                //cache miss, load from URL
                DataFetcher().getAsyncNSDataForURL(url) {
                    if url == self.imageURL {
                        let imageData = $0
                        if let image = UIImage(data: imageData) {
                            //write to cache and set image
                            self.imageCacheDataSource?.setImage(image, forURL: url, withSizeInBytes: imageData.length)
                            self.imgView?.image = image
                        }
                    }
                }
            }
        }
    }

}
