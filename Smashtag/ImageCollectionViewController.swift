//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/28/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UICollectionViewController, ImageCacheDataSource, UICollectionViewDelegateFlowLayout {
    
    //public as set from ImageCollectionViewController
    var tweets = [[Tweet]]()
    
    private var cache = NSCache()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation

    private struct Segue {
        static let ShowTweetDetail = "showTweetDetail"
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationController = segue.destinationViewController as? UIViewController
        
        if let navigationController = destinationController as? UINavigationController {
            destinationController = navigationController.visibleViewController
        }
        
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.ShowTweetDetail:
                if let tweetDetailController = destinationController as? TweetDetailTableViewController {
                    if let indexPath = collectionView?.indexPathsForSelectedItems().first as? NSIndexPath   {
                        tweetDetailController.tweet = tweets[indexPath.section][indexPath.row]
                    }
                }
            default: break
            }
        }

    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return tweets.count
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets[section].count
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "ImageCollectionCell"
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        
        // Configure the cell
        cell.imageCacheDataSource = self
        cell.imageURL = tweets[indexPath.section][indexPath.row].media.first?.url
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = collectionView.bounds.size.width / 4
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    // this value represents the minimum spacing between items in the same row
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // this value represents the minimum spacing between successive rows
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    // MARK: ImageCollectionViewCellDelegate
    func imageForURL(url: NSURL) -> UIImage? {
        if let image = cache.objectForKey(url) as? UIImage
        {
            println("Cache HIT")
            return image
        }
        
        println("Cache MISS")
        return nil
    }
    
    func setImage(image: UIImage, forURL url: NSURL, withSizeInBytes bytes: Int) {
        cache.setObject(image, forKey: url, cost: bytes)
    }

}
