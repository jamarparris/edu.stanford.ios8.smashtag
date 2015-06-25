//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 6/24/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    var tweets = [[Tweet]]()
    
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
    }
    
    @IBAction func refresh(sender: UIRefreshControl?) {
        if searchText != nil {
            
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
