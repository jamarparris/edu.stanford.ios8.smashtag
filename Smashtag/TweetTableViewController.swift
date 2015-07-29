//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 6/24/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    private var tweets = [[Tweet]]()
    
    private var searchHistory = SearchHistory()
    
    //default value is carnegieMellon
    var searchText: String? = "#carnegieMellon" {
        didSet {
            //set to nil whenever the search text changes so it uses the new value
            lastSuccessfulRequest = nil
            
            //if someone updates searchText programmatically
            //ensure searchTextField updated as well
            searchTextField?.text = searchText
            
            //clear out tweets
            tweets.removeAll()
            
            //reload empty table view
            tableView.reloadData()
            
            refresh()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set estimated row height to default height in table view
        tableView.estimatedRowHeight = tableView.rowHeight
        
        //now make actual row height automatically calculated
        tableView.rowHeight = UITableViewAutomaticDimension
        
        refresh()
        
    }
    
    var lastSuccessfulRequest: TwitterRequest?
    
    var nextRequestToAttempt: TwitterRequest? {
        
        //if no request in past, then use default request
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
            
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    func refresh() {
        refreshControl?.beginRefreshing()
        
        //call IBAction to handle everything
        refresh(refreshControl)
        
        //update title with whatever value is in searchText
        self.title = searchText
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            
            //add item searchHistory. do here instead of willSet 
            //to account for default value of searchText being in history
            
            searchHistory.addSearchItem(searchText)
            //println("search History: \(searchHistory)")
            
            //use the nextRequestToAttempt computed property
            if let request = nextRequestToAttempt {
                
                //use trailing syntax for the closure that fetchTweets expects
                request.fetchTweets { (newTweets) -> Void in
                    
                    //given that fetch is async, must ensure UI updates called on main queue
                    dispatch_async(dispatch_get_main_queue()) {
                        if newTweets.count > 0 {
                            
                            self.lastSuccessfulRequest = request
                            
                            //add tweets to top
                            self.tweets.insert(newTweets, atIndex: 0)
                            
                            //reload entire tableView given new data
                            self.tableView.reloadData()
                        }
                        
                        sender?.endRefreshing()
                    }
                }
            }
            
        } else {
            sender?.endRefreshing()
        }
    }

    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if textField == searchTextField {
            //dismiss keyboard
            textField.resignFirstResponder()
            searchText = textField.text
        }
        
        return true
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell

        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    private struct Segue {
        static let ShowTweetDetail = "showTweetDetail"
        static let ShowImages = "showImages"
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationController = segue.destinationViewController as? UIViewController
        
        if let navigationController = destinationController as? UINavigationController {
            destinationController = navigationController.visibleViewController
        }
        
        if let identifier = segue.identifier {
            switch identifier {
            case Segue.ShowTweetDetail:
                if let tweetDetailController = destinationController as? TweetDetailTableViewController {
                    if let indexPath = tableView.indexPathForSelectedRow() {
                        tweetDetailController.tweet = tweets[indexPath.section][indexPath.row]
                    }
                }
            case Segue.ShowImages:
                if let imageCollectionController = destinationController as? ImageCollectionViewController {
                    
                    //filter out tweets with no media
                    imageCollectionController.tweets = tweets.map {
                        return $0.filter {
                            return $0.media.count > 0
                        }
                    }
                    
                }
            default: break
            }
        }
        
    }

}
