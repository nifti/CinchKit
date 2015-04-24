//
//  NSDate+ISO.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 4/24/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

internal extension NSDate {
    class func ISOStringFromDate(date: NSDate) -> String {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.stringFromDate(date).stringByAppendingString("Z")
    }
    
    class func dateFromISOString(string: String) -> NSDate {
        var dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.localTimeZone()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.dateFromString(string) {
            return date
        } else {
            return NSDate()
        }
    }
}