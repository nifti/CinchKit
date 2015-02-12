//
//  CinchClient+Polls.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import SwiftyJSON

extension CinchClient {
    
    public func fetchLatestPolls(completionHandler : (CNHPollsResponse?, NSError?) -> ()) {
        
        if let polls = self.rootResources?["polls"] {
            self.fetchPolls(atURL: polls.href, completionHandler: completionHandler)
        } else {
            let err = NSError(domain: CinchKitErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Cinch Client not connected"])
            return completionHandler(nil, err)
        }
    }
    
    public func fetchPolls(atURL url : NSURL, completionHandler : (CNHPollsResponse?, NSError?) -> ()) {
        let start = CACurrentMediaTime()
        let serializer = PollsResponseSerializer()
        
        request(.GET, url)
            .responseCinchJSON(serializer) { (_, _, response, error) in
                self.logResponseTime(start)
                if(error != nil) {
                    NSLog("Error: \(error)")
                    return completionHandler(nil, error)
                } else {
                    return completionHandler(response, nil)
                }
                
        }
    }
}