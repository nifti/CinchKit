//
//  AccountsSerializer.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import SwiftyJSON

class LinksSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> [String : NSURL]? {
        var result = [String : NSURL]()
        
        for (key: String, subJson: JSON) in json {
            if let str = subJson.string {
                if let url = NSURL(string: str) {
                    result[key] = url
                }
            } else {
                if let href = subJson["href"].URL {
                    result[key] = href
                }
            }
        }
        
        return result
    }
}

public class AccountsSerializer : JSONObjectSerializer {
    public init() {}
    
    public func jsonToObject(json: SwiftyJSON.JSON) -> [CNHAccount]? {
        var accounts = json.array?.map(self.decodeAccount)
        return accounts
    }
    
    func decodeAccount(json : JSON) -> CNHAccount {
        let linkSerializer = LinksSerializer()
        
        var pictures = [PictureVersion : NSURL]()
        
        if let url = json["smallPicture"].URL {
           pictures[.Small] = url
        } else if let url = json["metadata"]["smallPictureUrl"].URL {
           pictures[.Small] = url
        }
        
        if let url = json["mediumPicture"].URL {
            pictures[.Medium] = url
        } else if let url = json["metadata"]["mediumPictureUrl"].URL {
           pictures[.Medium] = url
        }
        
        if let url = json["picture"].URL {
            pictures[.Large] = url
        } else if let url = json["metadata"]["mediumPictureUrl"].URL {
            pictures[.Large] = url
        }
        
        var accountRoles = [AccountRole]()
        
        if let roles = json["roles"].array {
            for role in roles {
                if let r = AccountRole(rawValue: role.stringValue) {
                    accountRoles.append(r)
                }
            }
        }
        
        var links = linkSerializer.jsonToObject(json["links"])
        
        return CNHAccount(
            id: json["id"].stringValue,
            href : json["href"].stringValue,
            name : json["name"].stringValue,
            
            // optionals
            username : json["username"].string,
            email : json["email"].string,
            pictures : pictures,
            bio : json["metadata"]["bio"].string,
            website : json["metadata"]["website"].string,
            shareLink : json["metadata"]["shortLink"].string,
            links : links,
            roles : accountRoles
        )
    }
}

class TokensSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHAccessTokenData]? {
        return json.array?.map(self.decodeToken)
    }
    
    private func decodeToken(json : JSON) -> CNHAccessTokenData {
        var exp = json["expires"].doubleValue
        var expires = NSDate(timeIntervalSince1970: (exp / 1000) )
        
        return CNHAccessTokenData(
            accountID : json["links"]["account"]["id"].stringValue,
            href : json["links"]["self"].URL!,
            access : json["access"].stringValue,
            refresh : json["refresh"].stringValue,
            type : json["type"].stringValue,
            expires : expires,
            cognitoId : json["cognitoId"].stringValue,
            cognitoToken : json["cognitoToken"].stringValue
        )
    }
}

class FetchAccountsSerializer : JSONObjectSerializer {
    let accountSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHAccount]? {
        return accountSerializer.jsonToObject(json["accounts"])
    }
}

class CreateAccountSerializer : JSONObjectSerializer {
    let accountSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHAuthResponse? {
        var result : CNHAuthResponse?
        
        if let account = accountSerializer.jsonToObject(json["accounts"])?.first {
            
            let tokensSerializer = TokensSerializer()
            
            if let token = tokensSerializer.jsonToObject(json["linked"]["tokens"])?.first {
                result = CNHAuthResponse(account : account, accessTokenData : token)
            }
        }
        
        return result
    }
}

class TokenResponseSerializer : JSONObjectSerializer {
    let tokensSerializer = TokensSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHAuthResponse? {
        var result : CNHAuthResponse?
        
        if let token = tokensSerializer.jsonToObject(json["tokens"])?.first {
            
            let accountSerializer = AccountsSerializer()
            
            if let account = accountSerializer.jsonToObject(json["linked"]["accounts"])?.first {
                result = CNHAuthResponse(account : account, accessTokenData : token)
            } else {
                result = CNHAuthResponse(account : nil, accessTokenData : token)
            }
        }
        
        return result
    }
}

class AccountStatsSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHAccountStats? {
        return json["statistics"].array?.map(self.decodeStats).first
    }
    
    private func decodeStats(json : JSON) -> CNHAccountStats {
        return CNHAccountStats(
            id: json["accountId"].stringValue,
            totalUnread: json["unreadCount"].intValue,
            totalPollsCreated: json["totalPollsCreated"].intValue,
            totalVotes: json["totalVotes"].intValue,
            totalFollowing: json["totalFollowing"].intValue,
            totalFollowers: json["totalFollowers"].intValue,
            totalGroups: json["totalGroups"].intValue
        )
    }
}

class PhotoSerializer: JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHPhoto]? {
        return json["photos"].array?.map(self.decodePhoto)
    }
    
    private func decodePhoto(json: JSON) -> CNHPhoto {
        return CNHPhoto(
            id: json["id"].stringValue,
            href: json["href"].stringValue,
            width: json["width"].floatValue,
            height: json["height"].floatValue
        )
    }
}