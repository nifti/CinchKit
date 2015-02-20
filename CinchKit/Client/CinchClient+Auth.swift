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
                    completionHandler?(a.account, nil)
                } else {
                    completionHandler?(nil, nil)
                }
            }
        } else {
            completionHandler?(nil, clientNotConnectedError())
        }
    }
    
    internal func fetchAccountsMatchingParams(params : [String : AnyObject]?, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        if let accounts = self.rootResources?["accounts"] {
            let serializer = FetchAccountsSerializer()
            request(.GET, accounts.href, parameters: params, encoding : .URL , serializer: serializer, completionHandler: completionHandler)
        } else {
            return completionHandler(nil, clientNotConnectedError())
        }
    }
}
