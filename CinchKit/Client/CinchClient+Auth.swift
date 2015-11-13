//
//  CinchClient+Auth.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import SwiftyJSON
import Alamofire

extension CinchClient {
    public func fetchAccountsMatchingIds(ids: [String], completionHandler: ([CNHAccount]?, NSError?) -> ()) {
        self.fetchAccountsMatchingParams(["ids": ids], completionHandler: completionHandler)
    }
    
    public func fetchAccountsMatchingEmail(email : String, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        self.fetchAccountsMatchingParams(["email" : email], completionHandler: completionHandler)
    }
    
    public func fetchAccountsMatchingUsername(username : String, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        self.fetchAccountsMatchingParams(["username" : username], completionHandler: completionHandler)
    }
    
    public func createAccount(parameters: [String : AnyObject], completionHandler : ((CNHAccount?, NSError?) -> ())?) {
        let serializer = CreateAccountSerializer()
        
        if let accounts = self.rootResources?["accounts"] {
            request(.POST, accounts.href, parameters: parameters, serializer: serializer) { (auth, error) in
                if let err = error {
                    completionHandler?(nil, error)
                } else if let a = auth {
                    self.setActiveSession(a.accessTokenData)
                    completionHandler?(a.account, nil)
                } else {
                    completionHandler?(nil, nil)
                }
            }
        } else {
            completionHandler?(nil, clientNotConnectedError())
        }
    }
    
    public func refreshSession(includeAccount : Bool = false, completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
        let serializer = TokenResponseSerializer()
        
        if let token = self.session.accessTokenData {
            let headers = ["Authorization" : "\(token.type) \(token.refresh)"]
            var params : [String : AnyObject]?
            
            if includeAccount {
                params = ["include" : "account"]
            }
            
            self.createSession(atURL: token.href, params: params, headers: headers, encoding : CNHUtils.urlencoding(), completionHandler: completionHandler)
        } else {
            completionHandler?(nil, nil)
        }
    }

    public func createSession(var params : [String : AnyObject]? = nil, headers : [String : String]? = nil, completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
        if let tokenURL = self.rootResources?["tokens"]?.href {
            self.createSession(atURL: tokenURL, params: params, headers: headers, completionHandler: completionHandler)
        } else {
           completionHandler?(nil, nil)
        }
    }
    
    public func createSession(atURL url : NSURL, var params : [String : AnyObject]? = nil,
        headers : [String : String]? = nil, encoding: Alamofire.ParameterEncoding = .JSON,
        completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
            
        let serializer = TokenResponseSerializer()
        
        request(.POST, url, headers: headers, parameters: params, encoding : encoding, serializer: serializer) { (auth, error) in
            if let err = error where err.code == 401 {
                self.revokeActiveSession()
                completionHandler?(nil, error)
            } else if let err = error {
                completionHandler?(nil, error)
            } else if let a = auth {
                self.setActiveSession(a.accessTokenData)
                completionHandler?(a.account, nil)
            } else {
                completionHandler?(nil, nil)
            }
        }
    }
    
    public func updateAccount(atURL url : NSURL, parameters: [String : AnyObject], queue: dispatch_queue_t? = nil, completionHandler : ((CNHAccount?, NSError?) -> ())?) {
        let serializer = AccountsSerializer()
        
        authorizedRequest(.PUT, url, parameters: parameters, queue: queue, serializer: serializer) { (accounts, error) in
            if let err = error {
                completionHandler?(nil, error)
            } else if let account = accounts?.first {
                completionHandler?(account, nil)
            } else {
                completionHandler?(nil, nil)
            }
        }
    }

    public func deleteAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()
        
        authorizedRequest(.DELETE, url, parameters: nil, queue: queue, serializer: serializer) { (_, error) in
            completionHandler?(nil, error)
        }
    }

    public func checkBlockedAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (Bool, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()

        authorizedRequest(.GET, url, parameters: nil, queue: queue, serializer: serializer) { (_, error) in
            var blocked = true
            if let err = error where err.code == 404 {
                blocked = false
            }

            completionHandler(blocked, error)
        }
    }

    public func blockAccount(atURL url : NSURL, accountId: String, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        let params: [String: AnyObject] = ["blockedAccountId": accountId]

        authorizedRequest(.POST, url, parameters: params, queue: queue, serializer: serializer) { (_, error) in
            completionHandler?(nil, error)
        }
    }

    public func unblockAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        authorizedRequest(.DELETE, url, parameters: nil, queue: queue, serializer: serializer) { (_, error) in
            completionHandler?(nil, error)
        }
    }

    public func emailLogin(var params : [String : AnyObject]? = nil, completionHandler : ( (String?, NSError?) -> () )? = nil) {
        if let tokenURL = self.rootResources?["tokens"]?.href {
            let serializer = EmptyResponseSerializer()
            request(.POST, tokenURL, parameters: params, serializer: serializer, completionHandler : completionHandler)
        } else {
            completionHandler?(nil, clientNotConnectedError())
        }
    }
    
    internal func fetchAccountsMatchingParams(var params : [String : AnyObject]?, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        if let accounts = self.rootResources?["accounts"] {
            var accountsUrl: NSURL = accounts.href
            
            // Remove ids from query params because of ids should be passed in path
            if let ids = params?["ids"] as? [String] {
                accountsUrl = NSURL(string: accountsUrl.absoluteString! + "/" + ",".join(ids))!
                params?.removeValueForKey("ids")
            }
            
            let serializer = FetchAccountsSerializer()
            request(.GET, accountsUrl, parameters: params, encoding: .URL , serializer: serializer, completionHandler: completionHandler)
        } else {
            return completionHandler(nil, clientNotConnectedError())
        }
    }
    
    internal func setActiveSession(accessTokenData : CNHAccessTokenData) {
        self.session.accessTokenData = accessTokenData
    }
    
    internal func revokeActiveSession() {
        self.session.close()
    }
}
