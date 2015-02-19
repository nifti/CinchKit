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

class FetchAccountsSerializer : JSONObjectSerializer {
    let accountSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> [CNHAccount]? {
        return accountSerializer.jsonToObject(json["accounts"])
    }
}

class CreateAccountSerializer : JSONObjectSerializer {
    let accountSerializer = AccountsSerializer()
    
    func jsonToObject(json: SwiftyJSON.JSON) -> CNHAccount? {
        return accountSerializer.jsonToObject(json["accounts"])?.first
    }
}