//
//  WatchKitInfo.swift
//  PlayThatSong
//
//  Created by Craig Martin on 4/19/15.
//  Copyright (c) 2015 MadKitty. All rights reserved.
//

import Foundation

let key = "FunctionRequestKey"

class WatchKitInfo {
    
    
    var replyBlock: [NSObject : AnyObject]! -> Void
    var playerRequest: String?
    
    init (playerDictionary : [NSObject : AnyObject], reply: ([NSObject : AnyObject]!)-> Void) {
        if let playerDictionary = playerDictionary as? [String:String] {
            playerRequest = playerDictionary[key]
        } else {
            println("No information error")
        }
    
        replyBlock = reply
    
    }
}