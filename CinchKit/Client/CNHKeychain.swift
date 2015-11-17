//
//  CNHKeychain.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import KeychainAccess

public class CNHKeychain {
    private let keychain = Keychain(service: "com.cinchkit.tokens")
    
    public init() {
        
    }
    
    public func load() -> CNHAccessTokenData? {
        var result : CNHAccessTokenData? = nil

        do {
            let accountID = try keychain.get("accountID")
            let access = try keychain.get("access")
            let refresh = try keychain.get("refresh")
            let type = try keychain.get("type")
            let href = try keychain.get("href")
            let expires = try keychain.get("expires")
            let cognitoId = try keychain.get("cognitoId")
            let cognitoToken = try keychain.get("cognitoToken")

            if let id = accountID, let acc = access, let ref = refresh, let t = type, let url = href, let exp: NSString = expires,
                    let cid = cognitoId, let cogToken = cognitoToken {

                let timestamp = NSDate(timeIntervalSince1970: exp.doubleValue )

                result = CNHAccessTokenData(
                    accountID : id,
                    href : NSURL(string: url)!,
                    access : acc,
                    refresh : ref,
                    type : t,
                    expires : timestamp,
                    cognitoId : cid,
                    cognitoToken : cogToken
                )
            }
        } catch {
            // ...
        }

        return result
    }

    public func save(accessTokenData : CNHAccessTokenData) -> ErrorType? {
        let expiresString = NSString(format: "%f", accessTokenData.expires.timeIntervalSince1970) as String

        do {
            try keychain.set(accessTokenData.accountID, key: "accountID")
            try keychain.set(accessTokenData.access, key: "access")
            try keychain.set(accessTokenData.refresh, key: "refresh")
            try keychain.set(accessTokenData.type, key: "type")
            try keychain.set(accessTokenData.href.absoluteString, key: "href")
            try keychain.set(expiresString, key: "expires")
            try keychain.set(accessTokenData.cognitoId, key: "cognitoId")
            try keychain.set(accessTokenData.cognitoToken, key: "cognitoToken")
        } catch let error {
            print("error: \(error)")
            return error
        }

        return nil
    }
    
    public func clear() {
        do {
            try keychain.removeAll()
        } catch let error {
            print("error: \(error)")
        }
    }
}