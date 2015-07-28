//
//  TweetDetailTableViewController.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/23/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import UIKit

class TweetDetailTableViewController: UITableViewController {
    
    private enum TweetMention : Printable
    {
        case Image(MediaItem)
        case URL(Tweet.IndexedKeyword)
        case Hashtag(Tweet.IndexedKeyword)
        case UserMention(Tweet.IndexedKeyword)
        case Author(User)
        
        var label: String {
            get {
                switch self {
                case .Image:
                    return "Images"
                case .URL:
                    return "URLs"
                case .Hashtag:
                    return "Hashtags"
                case .UserMention, .Author:
                    return "Users"
                }
            }
        }
        
        var description : String {
            get {
                switch self {
                case .Image(let mediaItem):
                    return "\(mediaItem.url)"
                case .URL(let indexedKeyword):
                    return indexedKeyword.keyword
                case .Hashtag(let indexedKeyword):
                    return indexedKeyword.keyword
                case .UserMention(let indexedKeyword):
                    return indexedKeyword.keyword
                case .Author(let user):
                    return "@\(user.screenName)"
                }
            }
        }
    }

    private var mentions = [[TweetMention]]()
    
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
            
            if var users = tweet?.userMentions.map({ TweetMention.UserMention($0) }) {
                
                if let author = tweet?.user {
                   users.insert(TweetMention.Author(author), atIndex: 0)
                }
                
                mentions.append(users)
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = tweet?.user.name
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
        static let AuthorCellReuseIdentifier = "AuthorCellReuseIdentifier"
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentionForIndexPath(indexPath)
        
        switch mention {
        case .Image(let mediaItem):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageCellReuseIdentifier, forIndexPath: indexPath) as! ImageTableViewCell
                
                cell.imageURL = mediaItem.url
                return cell
        case .Author:
            //add subtitle to denote who is Author
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.AuthorCellReuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = mention.description
            cell.detailTextLabel?.text = "Author"
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
        case .Image:
            //set it to take up half the height of the tableView
            return tableView.bounds.size.height / 2
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    private struct Segue {
        static let ShowImage = "showImage"
        static let ShowTweets = "showTweetsForMention"
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let mention = mentionForIndexPath(indexPath)
        
        switch mention {
        case .Image:
            performSegueWithIdentifier(Segue.ShowImage, sender: self)
        case .URL:
            if let url = NSURL(string: mention.description) {
                UIApplication.sharedApplication().openURL(url)
            }
        default:
            performSegueWithIdentifier(Segue.ShowTweets, sender: self)
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
                case Segue.ShowTweets:
                    //set search criteria on the destinationController
                    if let tweetController = destinationController as? TweetTableViewController {
                        tweetController.searchText = mention.description
                    }
                case Segue.ShowImage:
                    if let imageController = destinationController as? ImageViewController {
                        switch mention {
                        case .Image(let mediaItem):
                            imageController.imageURL = mediaItem.url
                            imageController.aspectRatio = mediaItem.aspectRatio
                        default: break
                        }
                        
                    }
                default: break
                }
            }
        }
    }

}
