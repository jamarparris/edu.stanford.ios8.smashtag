//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/28/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UICollectionViewController {
    
    //public as set from ImageCollectionViewController
    var tweets = [[Tweet]]()

    
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
        cell.imageURL = tweets[indexPath.section][indexPath.row].media.first?.url
    
        return cell
    }

    // MARK: UICollectionViewDelegate

}
