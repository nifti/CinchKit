//
//  PollModel.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

public enum PictureVersion : String {
    case Small = "small", Medium = "medium", Large = "large", Original = "original"
}

public enum AccountRole : String {
    case Admin = "admin", User = "user"
}

public enum PurchaseProduct: String {
    case BumpPoll = "com.clutchretail.cinch.bump"
}

public struct CNHAccount {
    public let id: String
    public let href: String
    public let name: String
    public let username: String?
    public let email: String?
    public let pictures: [PictureVersion : NSURL]?
    public let bio: String?
    public let website: String?
    public let shareLink: String?

    public let instagramId: String?
    public let instagramName: String?
    public let facebookId: String?
    public let facebookName: String?
    public let twitterId: String?
    public let twitterName: String?
    
    public let links : [String : NSURL]?
    public let roles : [AccountRole]?
}

public struct CNHAccountStats {
    public let id: String
//    public let href: String
    public let totalUnread: Int
    public let totalPollsCreated: Int
    public let totalVotes: Int
    public let totalFollowing: Int
    public let totalFollowers: Int
    public let totalGroups: Int
}

public struct CNHPoll {
    public let id: String
    public let href: String
    public let topic: String
    public let type: String
    public let shortLink: NSURL?
    public let votesTotal: Int
    public let messagesTotal: Int
    public let isPublic : Bool
    public let categoryId : String
    public let created : NSDate
    public let updated : NSDate
    public let displayAt : NSDate
    public let author : CNHAccount?
    public let candidates : [CNHPollCandidate]
    public let comments : [CNHComment]?
    public let links : [String : NSURL]?
    public let recentVoters : [CNHAccount]?
}

public struct CNHPollCandidate {
    public let id: String
    public let href: String
    public let image: String
    public let votes : Int
    public let created : NSDate
    public let voters : [String]?
    public let type : String
    public let option : String?
    public let images : [PictureVersion : NSURL]?
}

public struct CNHApiLink {
    public let id : String?
    public let href : NSURL
    public let type : String?
}

public struct CNHPollsResponse {
    public let selfLink : CNHApiLink
    public let nextLink : CNHApiLink?
    public let polls : [CNHPoll]?
}

public struct CNHCategory {
    public let id: String
    public let name: String
    public let hideWhenCreating: Bool
    public let links : [String : NSURL]?
    public let icons : [NSURL]?
    public let position : Int
}

public struct CNHVote {
    public let id: String?
    public let photoURL : NSURL?
    
//    public let href: String
    public let created : NSDate
    public let updated : NSDate
    public let account : CNHAccount?
}

public struct CNHVotesResponse {
    public let selfLink : CNHApiLink
    public let nextLink : CNHApiLink?
    public let votes : [CNHVote]?
}

public struct CNHFollowersResponse {
    public let selfLink : CNHApiLink
    public let nextLink : CNHApiLink?
    public let followers : [CNHAccount]?
}

public enum CNHCommentType : String {
    case Picture = "picture", Comment = "comment"
}

public struct CNHComment {
    public let id: String
    public let href : NSURL
    public let created : NSDate
    
    public let message : String
    public let author : CNHAccount?
    public let type : CNHCommentType
    public let links : [String : NSURL]?
}

public struct CNHCommentsResponse {
    public let selfLink : CNHApiLink
    public let nextLink : CNHApiLink?
    public let comments : [CNHComment]?
}

public struct CNHNotification {
    public let id: String
    public let href : NSURL
    public let created : NSDate
    public let action : String

    public let senderAccount : CNHAccount?
    public let recipientAccount : CNHAccount?

    public let resourcePoll : CNHPoll?
    public let resourceAccount : CNHAccount?
    public let resourceCategory : CNHCategory?

    public let extraCategory : CNHCategory?
    public let extraCandidate : CNHPollCandidate?
    public let extraAccount : CNHAccount?
}

public struct CNHNotificationsResponse {
    public let selfLink : CNHApiLink
    public let nextLink : CNHApiLink?
    public let notifications : [CNHNotification]?
}

public struct CNHPhoto {
    public let id: String
    public let href: String
    public let width: Float
    public let height: Float
}

public struct CNHPurchase {
    public let id: String
    public let product: PurchaseProduct
    public let transactionId: String

    public let account: CNHAccount
    public let poll: CNHPoll?
}