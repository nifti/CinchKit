//
//  PollsResponseSerializer.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import SwiftyJSON

class PollsResponseSerializer : JSONObjectSerializer {
    let accountsSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHPollsResponse? {
        return self.parseResponse(json)
    }
    
    func parseResponse(json : JSON) -> CNHPollsResponse? {
        let polls = self.parsePollsResponse(json)
        
        var nextLink : CNHApiLink?
        
        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "polls")
        }
        
        var selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "polls")
        
        return CNHPollsResponse(selfLink : selfLink, nextLink : nextLink, polls: polls)
    }
    
    func parsePollsResponse(json : JSON) -> [CNHPoll]? {
        var accountIndex : [String : CNHAccount]?
        
        if let accounts = accountsSerializer.jsonToObject(json["linked"]["accounts"]) {
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
    
    internal func indexById(data : [CNHAccount]) -> [String : CNHAccount] {
        var result = [String : CNHAccount]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
}