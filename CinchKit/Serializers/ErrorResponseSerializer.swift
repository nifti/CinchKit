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
        
        let userInfo = [
            NSLocalizedDescriptionKey : json["error"].stringValue,
            NSLocalizedFailureReasonErrorKey : json["message"].stringValue,
        ]
        
        return NSError(domain: CinchKitErrorDomain, code: statusCode, userInfo: userInfo)
    }
}