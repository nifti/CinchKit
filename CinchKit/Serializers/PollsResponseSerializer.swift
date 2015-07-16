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
    let commentsSerializer = CommentsSerializer()
    
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
        
        let comments = commentsSerializer.jsonToObject(json["recentComments"])
        
        if candidates == nil {
            candidates = []
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
            categoryId: json["category"].stringValue,
            created : json["created"].stringValue,
            updated : json["updated"].stringValue,
            author : account,
            candidates : candidates!,
            comments : comments,
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
            option : json["option"].string,
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
            created : CinchKitDateTools.dateFromISOString(json["created"].stringValue),
            updated : CinchKitDateTools.dateFromISOString(json["updated"].stringValue),
            account : account
        )
    }
}


class FollowersSerializer : JSONObjectSerializer {
    let accountsSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHFollowersResponse? {
        var nextLink : CNHApiLink?
        
        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "followers")
        }
        
        var selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "followers")
        
        let accounts = accountsSerializer.jsonToObject(json["accounts"])
        
        return CNHFollowersResponse(selfLink : selfLink, nextLink : nextLink, followers : accounts)
    }
}

class CommentsSerializer : JSONObjectSerializer {
    let accountsSerializer = AccountsSerializer()
    let linkSerializer = LinksSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHComment]? {
        return json.array?.map(self.decodeComment)
    }
    
    func decodeComment(json : JSON) -> CNHComment {
        let author = accountsSerializer.decodeAccount(json["author"])
        
        let type : CNHCommentType
        
        if let t = CNHCommentType(rawValue: json["type"].stringValue) {
            type = t
        } else {
            type = CNHCommentType.Comment
        }
        
        var links = linkSerializer.jsonToObject(json["links"])
        
        return CNHComment(
            id: json["id"].stringValue,
            href: json["href"].URL!,
            created :CinchKitDateTools.dateFromISOString(json["created"].stringValue),
            message : json["message"].stringValue,
            author : author,
            type : type,
            links : links
        )
    }
}


class CommentsResponseSerializer : JSONObjectSerializer {
    let commentsSerializer = CommentsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHCommentsResponse? {
        var nextLink : CNHApiLink?
        
        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "comments")
        }
        
        var selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "comments")
        
        let comments = commentsSerializer.jsonToObject(json["messages"])
        
        return CNHCommentsResponse(selfLink : selfLink, nextLink : nextLink, comments : comments)
    }
}

class NotificationsResponseSerializer : JSONObjectSerializer {
    let accountsSerializer = AccountsSerializer()
    let pollsSerializer = PollsResponseSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHNotificationsResponse? {
        var nextLink : CNHApiLink?
        
        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "notifications")
        }
        
        var selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "notifications")
        
        var accountIndex : [String : CNHAccount]?
        
        if let accounts = accountsSerializer.jsonToObject(json["linked"]["accounts"]) {
            accountIndex = self.indexById(accounts)
        }
        
        var pollIndex : [String : CNHPoll]?
        if let polls = json["linked"]["polls"].array?.map( { self.pollsSerializer.decodePoll(accountIndex, json: $0) } ) {
            pollIndex = self.indexById(polls)
        }
        
        let notifications =  json["notifications"].array?.map { self.decodeNotification(accountIndex, polls : pollIndex, json: $0) }
        
        return CNHNotificationsResponse(selfLink : selfLink, nextLink : nextLink, notifications : notifications)
    }
    
    func decodeNotification(accounts : [String : CNHAccount]?, polls: [String : CNHPoll]?, json : JSON) -> CNHNotification {
        var accountFrom : CNHAccount?
        var accountTo : CNHAccount?
        
        if let accId = json["accountFrom"].string {
            accountFrom = accounts?[accId]
        }
        
        if let accId = json["accountTo"].string {
            accountTo = accounts?[accId]
        }
        
        var poll : CNHPoll?
        if json["resourceType"].stringValue == "poll", let p = polls?[json["resourceId"].stringValue] {
            poll = p
        }
        
        return CNHNotification(
            id: json["id"].stringValue,
            href : json["href"].URL!,
            created : CinchKitDateTools.dateFromISOString(json["createdAt"].stringValue),
            action : json["action"].stringValue,
            accountFrom : accountFrom,
            accountTo : accountTo,
            resourceId : json["resourceId"].stringValue,
            resourceType : json["resourceType"].stringValue,
            poll : poll
        )
    }
    
    internal func indexById(data : [CNHAccount]) -> [String : CNHAccount] {
        var result = [String : CNHAccount]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
    
    internal func indexById(data : [CNHPoll]) -> [String : CNHPoll] {
        var result = [String : CNHPoll]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
}

class EmptyResponseSerializer : JSONObjectSerializer {
    
    func jsonToObject(json: SwiftyJSON.JSON) -> String? {
        return "OK"
    }
}