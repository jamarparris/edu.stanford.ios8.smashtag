//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/23/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController {
    
    var tweet: Tweet? {
        didSet {
            if let media = tweet?.media.map({ TweetMention.Image($0) }) {
                mentions.append(media)
            }
            
            if let urls = tweet?.urls.map({ TweetMention.URL($0) }) {
                mentions.append(urls)
            }
            
            if let hashtags = tweet?.hashtags.map({ TweetMention.Hashtag($0) }) {
                mentions.append(hashtags)
            }
            
            if let users = tweet?.userMentions.map({ TweetMention.User($0) }) {
                mentions.append(users)
            }
        }
    }
    
    private enum TweetMention : Printable
    {
        case Image(MediaItem)
        case URL(Tweet.IndexedKeyword)
        case Hashtag(Tweet.IndexedKeyword)
        case User(Tweet.IndexedKeyword)
        
        var label: String {
            get {
                switch self {
                case .Image:
                    return "Images"
                case .URL:
                    return "URLs"
                case .Hashtag:
                    return "Hashtags"
                case .User:
                    return "Users"
                }
            }
        }
        
        var description : String {
            get {
                switch self {
                case .Image(let mediaItem):
                    return "\(mediaItem.url)"
                case .URL(let mention):
                    return mention.keyword
                case .Hashtag(let mention):
                    return mention.keyword
                case .User(let mention):
                    return mention.keyword
                }
            }
        }
    }

    private var mentions = [[TweetMention]]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = tweet?.user.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func mentionForIndexPath(indexPath: NSIndexPath) -> TweetMention {
        return mentions[indexPath.section][indexPath.row]
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return count(mentions)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count(mentions[section])
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentions[section].first?.label
    }

    private struct Storyboard {
        static let MentionCellReuseIdentifier = "MentionCellReuseIdentifier"
        static let ImageCellReuseIdentifier = "ImageCellResuseIdentifier"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentionForIndexPath(indexPath)
        
        switch mention {
        case .Image(let mediaItem):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellReuseIdentifier, forIndexPath: indexPath) as! TweetImageTableViewCell
                
                cell.imageURL = mediaItem.url
                return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = mention.description
            return cell
        }

    }
    
   override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentionForIndexPath(indexPath)
        
        switch mention {
        case .Image(let mediaItem):
            //set it to take up half the height of the tableView
            return tableView.bounds.size.height / 2
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    private struct Segue {
        static let ShowImage = "showImage"
        static let Search = "search"
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mention = mentionForIndexPath(indexPath)
        
        switch mention {
        case .Image:
            break
            //performSegueWithIdentifier(Segue.ShowImage, sender: self)
        case .URL(let urlItem):
            if let url = NSURL(string: urlItem.keyword) {
                UIApplication.sharedApplication().openURL(url)
            }
        default:
            performSegueWithIdentifier(Segue.Search, sender: self)
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        var destinationController = segue.destinationViewController as? UIViewController
        
        if let navigationController = destinationController as? UINavigationController {
            destinationController = navigationController.visibleViewController
        }
        
        if let identifier = segue.identifier {
        
            if let indexPath = tableView.indexPathForSelectedRow() {
                //get the mention that the user selected
                let mention = mentionForIndexPath(indexPath)

                //identify what to pass to the destinationController based on identifier
                switch identifier {
                case Segue.Search:
                    //set search criteria on the destinationController
                    if let tweetController = destinationController as? TweetTableViewController {
                        
                        var searchText: String? = nil
                        
                        switch mention {
                        case .Hashtag(let hashtagItem):
                            searchText = hashtagItem.keyword
                        case .User(let userItem):
                            searchText = userItem.keyword
                        default: break
                        }
                        
                        tweetController.searchText = searchText
                    }
                case Segue.ShowImage:
                    fallthrough
                default: break
                }
            }
        }
    }

}
