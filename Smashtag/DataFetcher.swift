//
//  DataFetcher.swift
//  Smashtag
//
//  Created by Jamar Parris on 8/1/15.
//  Copyright (c) 2015 Jamar Parris. All rights reserved.
//

import Foundation

struct DataFetcher {
    func getAsyncNSDataForURL(url: NSURL?, callback: (NSData) -> Void) {
        
        if url != nil {
            let qos = Int(QOS_CLASS_USER_INITIATED.value)
            dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
                if let data = NSData(contentsOfURL: url!) {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        callback(data)
                    }
                }
            }
        }
        
        
    }
}
