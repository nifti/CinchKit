//
//  CNHTokenData.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

public struct CNHAccessTokenData {
    public let accountID: String
    public let href: NSURL
    public let access: String
    public let refresh: String
    public let type: String
    public let expires: NSDate
    public let cognitoId: String
    public let cognitoToken: String
    
    public init(accountID : String, href : NSURL, access: String, refresh : String, type : String, expires : NSDate, cognitoId : String, cognitoToken : String) {
        self.accountID = accountID
        self.href = href
        self.access = access
        self.refresh = refresh
        self.type = type
        self.expires = expires
        self.cognitoId = cognitoId
        self.cognitoToken = cognitoToken
    }
}

public struct CNHAuthResponse {
    public let account : CNHAccount?
    public let accessTokenData : CNHAccessTokenData
}