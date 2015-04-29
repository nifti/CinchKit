//
//  CNHSession.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

public enum CNHSessionState {
    // initial state indicating that no valid cached token was found
    case Created
    
    // state indicating user has logged in or a cached token is available
    case Open
    
    // session state indicating that the session was closed, but the users token
    // remains cached on the device for later use
    case Closed
}

public class CNHSession {
    private let keychain = CNHKeychain()
    
    // backing store for token data
    private var _accessTokenData : CNHAccessTokenData?
    
    public var accessTokenData : CNHAccessTokenData? {
        get {
            return _accessTokenData
        }
        
        set {
            if let data = newValue {
                keychain.save(data)
                _accessTokenData = data
            } else {
                keychain.clear()
                _accessTokenData = nil
            }
        }
    }
    
    public var sessionState : CNHSessionState {
        var result = CNHSessionState.Created
        
        if let tokenData = self.accessTokenData {
            let now = NSDate()
            
            if now.compare(tokenData.expires) == .OrderedAscending {
                result = .Open
            }
        }
        
        return result
    }
    
    public var isOpen : Bool {
        return self.sessionState == .Open
    }
    
    // close active session
    public func close() {
        keychain.clear()
        _accessTokenData = nil
    }
    
    public init() {
        _accessTokenData = keychain.load()
    }
    
}