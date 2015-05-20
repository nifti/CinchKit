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
    
//    public func refreshSession(completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
//        self.refreshSession(includeAccount: false, completionHandler: completionHandler)
//    }
    
    public func refreshSession(includeAccount : Bool = false, completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
        let serializer = TokenResponseSerializer()
        
        if let token = self.session.accessTokenData {
            let headers = ["Authorization" : "\(token.type) \(token.refresh)"]
            var params : [String : AnyObject]?
            
            if includeAccount {
                params = ["include" : "account"]
            }
            
            request(.POST, token.href, headers: headers, parameters: params, encoding : CNHUtils.urlencoding(), serializer: serializer) { (auth, error) in
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
            completionHandler?(nil, nil)
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
}
