//
//  CNHUtils.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/15/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

internal class CNHUtils {
    
    internal class func logResponseTime(start : CFTimeInterval, response : NSHTTPURLResponse?, message : String?) {
        let end = CACurrentMediaTime()
        var elapsedTime = end - start
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        var prefix = ""
        
        if let msg = message {
           prefix = "\(msg) -"
        }
        
        if let resp = response {
            var latency = "0.000"
            if let time = numberFormatter.stringFromNumber(elapsedTime) {
                latency = time
            }
            
            println("\(prefix) \(resp.statusCode) -  \(latency)s")
        }
    }
}