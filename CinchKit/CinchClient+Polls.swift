//
//  CinchClient+Polls.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import SwiftyJSON

extension CinchClient {
    
    public func fetchLatestPolls(completionHandler : (CNHPollsResponse?) -> ()) {
        
        if let polls = self.rootResources?["polls"] {
            manager.request(.GET, polls.href)
                .responseJSON { (req, res, json, error) in
                    println("done done done")
                    if(error != nil) {
                        NSLog("Error: \(error)")
                        println(req)
                        println(res)
                    } else {
                        var j : JSON = JSON(json!)
                        
                        let polls = self.parsePollsResponse(j)
                        
                        var nextLink : CNHApiLink?
                        
                        if let href = j["links"]["next"].URL {
                            nextLink = CNHApiLink(id: nil, href: href, type: "polls")
                        }
                        
                        var selfLink = CNHApiLink(id: nil, href: j["links"]["self"].URL!, type: "polls")
                        
                        var response = CNHPollsResponse(selfLink : selfLink, nextLink : nextLink, polls: polls)
                        return completionHandler(response)
                    }
                    
            }
        }
    }
    
    func parsePollsResponse(json : JSON) -> [CNHPoll]? {
        var accountIndex : [String : CNHAccount]?
        
        if let accounts = json["linked"]["accounts"].array?.map(self.decodeAccount) {
            accountIndex = self.indexById(accounts)
        }
        
        return json["discussions"].array?.map { self.decodePoll(accountIndex, json: $0) }
    }
    
    func decodePoll(accounts : [String : CNHAccount]?, json : JSON) -> CNHPoll {
        var candidates = json["candidates"].array?.map(self.decodeCandidate)
        var account : CNHAccount?
        
        if let authorId = json["links"]["author"]["id"].string {
            account = accounts?[authorId]
        }
        
        return CNHPoll(
            id: json["id"].stringValue,
            href : json["href"].stringValue,
            topic : json["topic"].stringValue,
            type : json["type"].stringValue,
            shortLink : json["shortLink"].URL,
            votesTotal : json["votesTotal"].intValue,
            messagesTotal : json["messagesTotal"].intValue,
            isPublic : json["public"].boolValue,
            created : json["created"].stringValue,
            updated : json["updated"].stringValue,
            author : account,
            candidates : candidates!
        )
    }
    
    func decodeCandidate(json : JSON) -> CNHPollCandidate {
        
        return CNHPollCandidate(
            id: json["id"].stringValue,
            href : json["href"].stringValue,
            image : json["image"].stringValue,
            votes : json["votes"].intValue,
            created : json["created"].stringValue,
            voters : json["voters"].array?.map({ $0.stringValue }),
            type : json["type"].stringValue
        )
    }
    
    func decodeAccount(json : JSON) -> CNHAccount {
        
        return CNHAccount(
            id: json["id"].stringValue,
            href : json["href"].stringValue,
            name : json["name"].stringValue,
            picture : json["picture"].URL
        )
    }
    
    internal func indexById(data : [CNHAccount]) -> [String : CNHAccount] {
        var result = [String : CNHAccount]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
}