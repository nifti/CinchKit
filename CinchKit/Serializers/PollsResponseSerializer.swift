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
        
        let selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "polls")
        
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
        
        let links = linkSerializer.jsonToObject(json["links"])
        
        let comments = commentsSerializer.jsonToObject(json["recentComments"])
        
        if candidates == nil {
            candidates = []
        }
        
        let displayAt : NSDate
        
        if let displayStr = json["displayAt"].string {
            displayAt = CinchKitDateTools.dateFromISOString(displayStr)
        } else {
            displayAt = CinchKitDateTools.dateFromISOString(json["created"].stringValue)
        }

        // -----

        var recentVoters = [CNHAccount]()
        if let accs = accounts, let arr = json["recentVoters"].array {
            for acc in arr {
                if let voter = accs[acc.stringValue] {
                    recentVoters.append(voter)
                }
            }
        }

        // -----

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
            created : CinchKitDateTools.dateFromISOString(json["created"].stringValue),
            updated : CinchKitDateTools.dateFromISOString(json["updated"].stringValue),
            displayAt : displayAt,
            author : account,
            candidates : candidates!,
            comments : comments,
            links : links,
            recentVoters : recentVoters
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
            created : CinchKitDateTools.dateFromISOString(json["created"].stringValue),
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
        
        let selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "votes")
        
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
        
        let selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "followers")
        
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
        
        let links = linkSerializer.jsonToObject(json["links"])
        
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
        
        let selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "comments")
        
        let comments = commentsSerializer.jsonToObject(json["messages"])
        
        return CNHCommentsResponse(selfLink : selfLink, nextLink : nextLink, comments : comments)
    }
}

class NotificationsResponseSerializer : JSONObjectSerializer {
    let accountsSerializer = AccountsSerializer()
    let pollsSerializer = PollsResponseSerializer()
    let categoriesSerializer = CategoriesSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHNotificationsResponse? {
        var nextLink : CNHApiLink?
        
        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "notifications")
        }
        
        let selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "notifications")
        
        var accountIndex : [String : CNHAccount]?
        if let accounts = accountsSerializer.jsonToObject(json["linked"]["accounts"]) {
            accountIndex = self.indexById(accounts)
        }
        
        var pollIndex : [String : CNHPoll]?
        if let polls = json["linked"]["polls"].array?.map( { self.pollsSerializer.decodePoll(accountIndex, json: $0) } ) {
            pollIndex = self.indexById(polls)
        }

        var categoryIndex : [String : CNHCategory]?
        if let categories = categoriesSerializer.jsonToObject(json["linked"]) {
            categoryIndex = self.indexById(categories)
        }

        let notifications = json["notifications"].array?.map {
            self.decodeNotification(accountIndex, polls : pollIndex, categories: categoryIndex, json: $0)
        }
        
        return CNHNotificationsResponse(selfLink : selfLink, nextLink : nextLink, notifications : notifications)
    }
    
    func decodeNotification(accounts : [String : CNHAccount]?, polls : [String : CNHPoll]?, categories : [String : CNHCategory]?, json : JSON) -> CNHNotification {
        var senderAccount : CNHAccount?
        var recipientAccount : CNHAccount?

        var resourcePoll : CNHPoll?
        var resourceAccount : CNHAccount?
        var resourceCategory : CNHCategory?

        var extraCategory : CNHCategory?
        var extraCandidate : CNHPollCandidate?
        var extraAccount : CNHAccount?

        if let acc = accounts?[json["senderId"].stringValue] {
            senderAccount = acc
        }

        if let acc = accounts?[json["recipientId"].stringValue] {
            recipientAccount = acc
        }

        if json["resourceType"].stringValue == "poll", let poll = polls?[json["resourceId"].stringValue] {
            resourcePoll = poll

            if let extra = json["extra"].dictionaryObject, let candId = extra["candidateId"] as? String {
                for candidate in poll.candidates {
                    if candidate.id == candId {
                        extraCandidate = candidate
                    }
                }
            }
        } else if json["resourceType"].stringValue == "account", let acc = accounts?[json["resourceId"].stringValue] {
            resourceAccount = acc
        } else if json["resourceType"].stringValue == "category", let cat = categories?[json["resourceId"].stringValue] {
            resourceCategory = cat
        }

        if let extra = json["extra"].dictionaryObject {
            if let catId = extra["categoryId"] as? String, let cat = categories?[catId] {
                extraCategory = cat
            }

            if let accId = extra["accountId"] as? String, let acc = accounts?[accId] {
                extraAccount = acc
            }
        }

        return CNHNotification(
            id: json["id"].stringValue,
            href : json["href"].URL!,
            created : CinchKitDateTools.dateFromISOString(json["createdAt"].stringValue),
            action : json["action"].stringValue,

            senderAccount : senderAccount,
            recipientAccount : recipientAccount,

            resourcePoll : resourcePoll,
            resourceAccount : resourceAccount,
            resourceCategory : resourceCategory,

            extraCategory : extraCategory,
            extraCandidate : extraCandidate,
            extraAccount : extraAccount
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

    internal func indexById(data : [CNHCategory]) -> [String : CNHCategory] {
        var result = [String : CNHCategory]()

        for item in data {
            result[item.id] = item
        }

        return result
    }
}

class CategoriesSerializer : JSONObjectSerializer {
    let linkSerializer = LinksSerializer()

    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHCategory]? {
        return json["categories"].array?.map(self.decodeCategory)
    }

    private func decodeCategory(json : JSON) -> CNHCategory {
        let links = linkSerializer.jsonToObject(json["links"])

        var icons = [NSURL]()
        for iconLink in json["images"].arrayValue {
            icons.append(iconLink.URL!)
        }

        return CNHCategory(
            id: json["id"].stringValue,
            name: json["name"].stringValue,
            hideWhenCreating: json["hideWhenCreating"].boolValue,
            links: links,
            icons: icons,
            position: json["position"].intValue
        )
    }
}

class PurchaseSerializer: JSONObjectSerializer {

    let accountsSerializer = AccountsSerializer()
    let pollsSerializer = PollsResponseSerializer()

    func jsonToObject(json: SwiftyJSON.JSON) -> CNHPurchase? {
        var accountIndex = [String: CNHAccount]()
        if let accounts = accountsSerializer.jsonToObject(json["linked"]["accounts"]) {
            accountIndex = self.indexById(accounts)
        }

        var pollIndex = [String: CNHPoll]()
        if let polls = json["linked"]["polls"].array?.map({ self.pollsSerializer.decodePoll(accountIndex, json: $0) }) {
            pollIndex = self.indexById(polls)
        }

        return json["purchases"].array?.map({ self.decodePurchase(accountIndex, polls: pollIndex, json: $0) }).first
    }

    private func decodePurchase(accounts: [String: CNHAccount], polls: [String: CNHPoll], json: JSON) -> CNHPurchase {
        var poll: CNHPoll?

        let product = CNHPurchaseProduct(rawValue: json["productId"].stringValue)!
        let account: CNHAccount = accounts[json["accountId"].stringValue]!

        if product == CNHPurchaseProduct.BumpPoll {
            poll = polls[json["metadata"]["pollId"].stringValue]
        }

        return CNHPurchase(
            id: json["id"].stringValue,
            product: product,
            transactionId: json["transactionId"].stringValue,

            account: account,
            poll: poll
        )
    }

    internal func indexById(data: [CNHAccount]) -> [String: CNHAccount] {
        var result = [String: CNHAccount]()

        for item in data {
            result[item.id] = item
        }

        return result
    }

    internal func indexById(data: [CNHPoll]) -> [String: CNHPoll] {
        var result = [String: CNHPoll]()

        for item in data {
            result[item.id] = item
        }

        return result
    }
}

// -----

class LeaderboardSerializer: JSONObjectSerializer {

    let accountsSerializer = AccountsSerializer()

    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHLeaderAccount]? {
        var accountIndex = [String: CNHAccount]()
        if let accounts = accountsSerializer.jsonToObject(json["linked"]["accounts"]) {
            accountIndex = self.indexById(accounts)
        }

        return json["leaders"].array?.map({ self.decodeLeader(accountIndex, json: $0) })
    }

    private func decodeLeader(accounts: [String: CNHAccount], json: JSON) -> CNHLeaderAccount {
        return CNHLeaderAccount(
            account: accounts[json["id"].stringValue]!,
            rank: json["rank"].intValue,
            votesTotal: json["votesTotal"].intValue,
            movement: CNHLeaderMovement(rawValue: json["movement"].stringValue) ?? CNHLeaderMovement.Up
        )
    }

    internal func indexById(data: [CNHAccount]) -> [String: CNHAccount] {
        var result = [String: CNHAccount]()

        for item in data {
            result[item.id] = item
        }

        return result
    }
}

class LeaderboardResponseSerializer: JSONObjectSerializer {

    let leaderboardSerializer = LeaderboardSerializer()

    func jsonToObject(json: SwiftyJSON.JSON) -> CNHLeaderboardResponse? {
        var nextLink : CNHApiLink?

        if let href = json["links"]["next"].URL {
            nextLink = CNHApiLink(id: nil, href: href, type: "leaderboard")
        }

        let selfLink = CNHApiLink(id: nil, href: json["links"]["self"].URL!, type: "leaderboard")
        let leaders = leaderboardSerializer.jsonToObject(json)

        return CNHLeaderboardResponse(selfLink: selfLink, nextLink: nextLink, leaders: leaders)
    }
}

// -----

class EmptyResponseSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> String? {
        return "OK"
    }
}
