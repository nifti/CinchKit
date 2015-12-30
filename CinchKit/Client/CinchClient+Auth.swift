//
//  CinchClient+Auth.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Alamofire


extension CinchClient {    
    public func refreshSession(includeAccount : Bool = false, completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
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

    public func createSession(params : [String : AnyObject]? = nil, headers : [String : String]? = nil, completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
        if let tokenURL = self.rootResources?["tokens"]?.href {
            self.createSession(atURL: tokenURL, params: params, headers: headers, completionHandler: completionHandler)
        } else {
           completionHandler?(nil, nil)
        }
    }
    
    public func createSession(atURL url : NSURL, params : [String : AnyObject]? = nil,
        headers : [String : String]? = nil, encoding: Alamofire.ParameterEncoding = .JSON,
        completionHandler : ( (CNHAccount?, NSError?) -> () )? = nil) {
            
        let serializer = TokenResponseSerializer()
        
        request(.POST, url, headers: headers, parameters: params, encoding : encoding, serializer: serializer) { (auth, error) in
            if let err = error where err.code == 401 {
                self.revokeActiveSession()
                completionHandler?(nil, error)
            } else if let _ = error {
                completionHandler?(nil, error)
            } else if let a = auth {
                self.setActiveSession(a.accessTokenData)
                completionHandler?(a.account, nil)
            } else {
                completionHandler?(nil, nil)
            }
        }
    }
    
    public func emailLogin(params : [String : AnyObject]? = nil, completionHandler : ( (String?, NSError?) -> () )? = nil) {
        if let tokenURL = self.rootResources?["tokens"]?.href {
            let serializer = EmptyResponseSerializer()
            request(.POST, tokenURL, parameters: params, serializer: serializer, completionHandler : completionHandler)
        } else {
            completionHandler?(nil, clientNotConnectedError())
        }
    }
        
    internal func setActiveSession(accessTokenData : CNHAccessTokenData) {
        self.session.accessTokenData = accessTokenData
    }
    
    internal func revokeActiveSession() {
        self.session.close()
    }
}
