//
//  CNHUtils.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/15/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

internal class CNHUtils {
    
    internal class func logResponseTime(start : CFTimeInterval) {
        let end = CACurrentMediaTime()
        var elapsedTime = end - start
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        println("Elapsed Time: \(numberFormatter.stringFromNumber(elapsedTime)) sec")
    }
}