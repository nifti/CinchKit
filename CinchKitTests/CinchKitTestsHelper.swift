//
//  CinchKitTestsHelper.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import CinchKit

class CinchKitTestsHelper {
    
    class func loadJsonData(filename : String) -> NSData? {
        var filepath = NSBundle(forClass: CinchKitTestsHelper.self).pathForResource(filename, ofType: "json")
        return NSData(contentsOfFile: filepath!)
    }
    
    class func validAuthToken() -> CNHAccessTokenData {
        let expires = NSDate().dateByAddingTimeInterval(300)
        
        return CNHAccessTokenData(
            accountID : "123456",
            href : NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com/tokens")!,
            access : "asdfhasjdhfasdf",
            refresh : "rrrrrrrrrrrreeeeeeeeeffffrrrrrrreeeeeeessshhhhhhhhhh",
            type : "Bearer",
            expires : expires
        )
    }
}