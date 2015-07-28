//
//  SearchHistory.swift
//  Smashtag
//
//  Created by Jamar Parris on 7/27/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import Foundation

public struct SearchHistory : Printable {
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private struct SearchHistoryConstants {
        static let DefaultsKey = "searchHistory"
    }
    
    //auto-fetch and set searchItems from NSUserDefaults
    public var searchItems: [String] {
        get { return defaults.objectForKey(SearchHistoryConstants.DefaultsKey) as? [String] ?? [] }
        set { defaults.setObject(newValue, forKey: SearchHistoryConstants.DefaultsKey) }
    }
    
    public mutating func addSearchItem(searchItem: String?) {
        
        if let item = searchItem {
        
            //filter out any existing references to new item (case-insensitive)
            searchItems = searchItems.filter {
                $0.lowercaseString != item.lowercaseString
            }
            
            //only 100 items are supported
            if searchItems.count == 100 {
                searchItems.removeLast()
            }
            
            //prepend new item to top of array
            searchItems.insert(item, atIndex: 0)
        }
    }
    
    public var description : String {
        get {
            return "\(searchItems)"
        }
    }
}