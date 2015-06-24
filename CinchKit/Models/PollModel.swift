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
    
    public let links : [String : NSURL]?
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
    public let created : String
    public let updated : String
    public let author : CNHAccount?
    public let candidates : [CNHPollCandidate]
    public let comments : [CNHComment]?
    public let links : [String : NSURL]?
}

public struct CNHPollCandidate {
    public let id: String
    public let href: String
    public let image: String
    public let votes : Int
    public let created : String
    public let voters : [String]?
    public let type : String
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

public struct CNHPollCategory {
    public let id: String
    public let name: String
    public let hideWhenCreating: Bool
    public let links : [String : NSURL]?
    public let icons : [NSURL]?
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

public struct CNHComment {
    public let id: String
    public let href : NSURL
    public let created : NSDate
    
    public let message : String
    public let author : CNHAccount?
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
    
    public let accountFrom : CNHAccount?
    public let accountTo : CNHAccount?
    
    public let resourceId : String
    public let resourceType : String
    
    public let poll : CNHPoll?
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
