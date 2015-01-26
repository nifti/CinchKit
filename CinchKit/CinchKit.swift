//
//  CinchKit.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class CinchClient {
    
    let manager : Alamofire.Manager
    public var rootResources : [String : ApiResource]?

    public required init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    public func start() {
        return start(nil)
    }
    
    public func start(completionHandler : (() -> ())?) {
        manager.request(FooBar())
            .responseJSON { (_, _, json, _) in
                var j : JSON = JSON(json!)
                
                if let resources = j["resources"].array?.map(self.decodeResource) {
                    self.rootResources = self.indexById(resources)
                }
                
                completionHandler?()
        }
    }
    
    internal func decodeResource(json : JSON) -> ApiResource {
        return ApiResource(
            id: json["id"].stringValue,
            href: json["href"].stringValue,
            title: json["title"].stringValue
        )
    }
    
    internal func indexById(data : [ApiResource]) -> [String : ApiResource] {
        var result = [String : ApiResource]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
}

class FooBar : URLRequestConvertible {
    let baseURL = "http://api.us-east-1.niftiws.com"
    
    required init() {
    }
    
    var URLRequest: NSURLRequest {
        let URL = NSURL(string: baseURL)!
        let req = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent("/"))
        req.setValue("Bearer Foobar", forHTTPHeaderField: "Authorization")
        req.HTTPMethod = Alamofire.Method.GET.rawValue
        
        return req
//        return Alamofire.ParameterEncoding.JSON.encode(req, parameters: parameters).0
    }
}


