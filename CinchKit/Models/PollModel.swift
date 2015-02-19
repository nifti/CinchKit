//
//  PollModel.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

public struct CNHAccount {
    public let id: String
    public let href: String
    public let name: String
    public let picture: NSURL?
//    public let links : [String : NSURL]?
}

public struct CNHToken {
    public let href: String
    public let access: String
    public let refresh: String
    public let type: String
    public let expires: NSDate
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
}

public struct CNHPollCandidate {
    public let id: String
    public let href: String
    public let image: String
    public let votes : Int
    public let created : String
    public let voters : [String]?
    public let type : String
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

public struct CNHAuthResponse {
    public let account : CNHAccount
    public let token : CNHToken
}
