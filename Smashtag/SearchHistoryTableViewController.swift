//
//  SearchHistoryTableViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/27/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class SearchHistoryTableViewController: UITableViewController {
    
    private var searchHistory =  SearchHistory()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Search History"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //reload tableView with latest changes whenever we appear on screen
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.searchItems.count
    }
    
    private func searchItemForIndexPath(indexPath: NSIndexPath) -> String? {
        return searchHistory.searchItems[indexPath.row]
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "SearchHistoryCellReuseIdentifier"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = searchItemForIndexPath(indexPath)
        return cell
    }
    
    // MARK: - Navigation
    
    private struct Segue {
        static let ShowTweets = "showTweetsForMention"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destinationController = segue.destinationViewController as? UIViewController
        
        if let navigationController = destinationController as? UINavigationController {
            destinationController = navigationController.visibleViewController
        }
        
        if let identifier = segue.identifier {
            
            if let indexPath = tableView.indexPathForSelectedRow() {
                
                switch identifier {
                case Segue.ShowTweets:
                    //set search criteria on the destinationController
                    if let tweetController = destinationController as? TweetTableViewController {
                        tweetController.searchText = searchItemForIndexPath(indexPath)
                    }
                default: break
                }
            }
        }

    }

}
