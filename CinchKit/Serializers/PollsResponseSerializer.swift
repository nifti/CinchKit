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
    let linkSerializer = LinksSerializer()
    
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
        
        var links = linkSerializer.jsonToObject(json["links"])
        
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
            candidates : candidates!,
            links : links
        )
    }
    
    func decodeCandidate(json : JSON) -> CNHPollCandidate {
        
        var images : [PictureVersion : NSURL]?
        
        if let imgArray = json["images"].array {
            images = self.decodePollImages(imgArray)
        }
        
        return CNHPollCandidate(
            id: json["id"].stringValue,
            href : json["href"].stringValue,
            image : json["image"].stringValue,
            votes : json["votes"].intValue,
            created : json["created"].stringValue,
            voters : json["voters"].array?.map({ $0.stringValue }),
            type : json["type"].stringValue,
            images : images
        )
    }
    
    private func decodePollImages(images : [JSON]) -> [PictureVersion : NSURL] {
        return images.reduce([PictureVersion : NSURL](), combine: { (memo, json) -> [PictureVersion : NSURL] in
            var result = memo
            
            if let url = json["url"].URL {
                if let version = PictureVersion(rawValue: json["name"].stringValue) {
                    result[version] = url
                }
            }
            
            return result
        })
    }
    
    internal func indexById(data : [CNHAccount]) -> [String : CNHAccount] {
        var result = [String : CNHAccount]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
}

class PollVotesSerializer : JSONObjectSerializer {
    let accountsSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHVotesResponse? {
        var nextLink : CNHApiLink?
        
        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "votes")
        }
        
        var selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "votes")
        
        let votes = json["votes"].array?.map(self.decodeVote)
        
        return CNHVotesResponse(selfLink : selfLink, nextLink : nextLink, votes : votes)
    }
    
    private func decodeVote(json : JSON) -> CNHVote {
        
        let account = accountsSerializer.decodeAccount(json["account"])
        
        return CNHVote(
            id: json["photoId"].string,
            photoURL: json["photoURL"].URL,
            created : NSDate.dateFromISOString(json["created"].stringValue),
            updated : NSDate.dateFromISOString(json["updated"].stringValue),
            account : account
        )
    }
}