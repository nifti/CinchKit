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
    
    internal func fetchAccountsMatchingParams(params : [String : AnyObject]?, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        if let accounts = self.rootResources?["accounts"] {
            let serializer = FetchAccountsSerializer()
            
            let start = CACurrentMediaTime()
            request(.GET, accounts.href, parameters: params, encoding : Alamofire.ParameterEncoding.URL)
                .responseCinchJSON(serializer) { (_, _, response, error) in
                    CNHUtils.logResponseTime(start)
                    if(error != nil) {
                        NSLog("Error: \(error)")
                        return completionHandler(nil, error)
                    } else {
                        return completionHandler(response, nil)
                    }
            }
            
        } else {
            return completionHandler(nil, clientNotConnectedError())
        }
    }
}
