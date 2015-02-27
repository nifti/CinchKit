//
//  ErrorResponseSerializer.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/19/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation


import SwiftyJSON

class ErrorResponseSerializer : JSONObjectSerializer {
    func jsonToObject(json: SwiftyJSON.JSON) -> NSError? {
        let statusCode = json["statusCode"].intValue
        
        var userInfo = [String : String]()
        
        if let err = json["error"].string {
           userInfo[NSLocalizedDescriptionKey] = err
        }
        
        if let message = json["message"].string {
            userInfo[NSLocalizedFailureReasonErrorKey] = message
        }
        
        return NSError(domain: CinchKitErrorDomain, code: statusCode, userInfo: userInfo)
    }
}