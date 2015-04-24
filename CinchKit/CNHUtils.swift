//
//  CNHUtils.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/15/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import Alamofire

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
    
    internal class func urlencoding() -> ParameterEncoding {
        let encodingClosure: (URLRequestConvertible, [String: AnyObject]?) -> (NSURLRequest, NSError?) = { (URLRequest, parameters) in
            var mutableURLRequest: NSMutableURLRequest! = URLRequest.URLRequest.mutableCopy() as! NSMutableURLRequest
            var error: NSError? = nil
            
            if let URLComponents = NSURLComponents(URL: mutableURLRequest.URL!, resolvingAgainstBaseURL: false) {
                URLComponents.percentEncodedQuery = (URLComponents.percentEncodedQuery != nil ? URLComponents.percentEncodedQuery! + "&" : "") + self.query(parameters!)
                mutableURLRequest.URL = URLComponents.URL
            }
            
            return (mutableURLRequest, error)
        }
        
        return ParameterEncoding.Custom(encodingClosure)
    }
    
    private class func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in sorted(Array(parameters.keys), <) {
            let value: AnyObject! = parameters[key]
            components += queryComponents(key, value)
        }
        
        return join("&", components.map{"\($0)=\($1)"} as [String])
    }
    
    private class func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.extend([(escape(key), escape("\(value)"))])
        }
        
        return components
    }
    
    class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
}