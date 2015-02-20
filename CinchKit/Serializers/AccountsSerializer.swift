//
//  AccountsSerializer.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import SwiftyJSON

class AccountsSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHAccount]? {
        var accounts = json.array?.map(self.decodeAccount)
        return accounts
    }
    
    private func decodeAccount(json : JSON) -> CNHAccount {
        return CNHAccount(
            id: json["id"].stringValue,
            href : json["href"].stringValue,
            name : json["name"].stringValue,
            picture : json["picture"].URL
        )
    }
}

class TokensSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHToken]? {
        return json.array?.map(self.decodeToken)
    }
    
    private func decodeToken(json : JSON) -> CNHToken {
        var exp = json["expires"].doubleValue
        var expires = NSDate(timeIntervalSince1970: (exp / 1000) )
        
        return CNHToken(
            href : json["href"].stringValue,
            access : json["acces"].stringValue,
            refresh : json["refresh"].stringValue,
            type : json["type"].stringValue,
            expires : expires
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
    let tokensSerializer = TokensSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHAuthResponse? {
        var result : CNHAuthResponse?
        
        if let account = accountSerializer.jsonToObject(json["accounts"])?.first {
            if let token = tokensSerializer.jsonToObject(json["linked"]["tokens"])?.first {
                result = CNHAuthResponse(account : account, token : token)
            }
        }
        
        return result
    }
}