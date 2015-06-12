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
        
        var accountID = keychain.get("accountID")
        var access = keychain.get("access")
        var refresh = keychain.get("refresh")
        var type = keychain.get("type")
        var href = keychain.get("href")
        var expires = keychain.get("expires")
        var cognitoId = keychain.get("cognitoId")
        var cognitoToken = keychain.get("cognitoToken")
        
        if let id = accountID, let acc = access, let ref = refresh, t = type , let url = href, let exp : NSString = expires, let cid = cognitoId, let cogToken = cognitoToken {
            var timestamp = NSDate(timeIntervalSince1970: exp.doubleValue )
            
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
        
        return result
    }
    
    public func save(accessTokenData : CNHAccessTokenData) -> NSError? {
        var expiresString = NSString(format: "%f", accessTokenData.expires.timeIntervalSince1970) as String
        
        if let err = keychain.set(accessTokenData.accountID, key: "accountID") {
            return err
        } else if let err = keychain.set(accessTokenData.access, key: "access") {
            return err
        } else if let err = keychain.set(accessTokenData.refresh, key: "refresh") {
            return err
        } else if let err = keychain.set(accessTokenData.type, key: "type") {
            return err
        } else if let err = keychain.set(accessTokenData.href.absoluteString!, key: "href") {
            return err
        } else if let err = keychain.set(expiresString, key: "expires") {
            return err
        } else if let err = keychain.set(accessTokenData.cognitoId, key: "cognitoId") {
            return err
        } else if let err = keychain.set(accessTokenData.cognitoToken, key: "cognitoToken") {
            return err
        } else {
            return nil
        }
    }
    
    public func clear() {
        keychain.removeAll()
    }
}