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

/// CinchKit errors
public let CinchKitErrorDomain = "com.cinchkit.error"

public class CinchClient {
    
    let manager : Alamofire.Manager
    let server : CNHServer
    public var rootResources : [String : ApiResource]?

    public convenience init() {
        self.init(server: CNHServer.dotComServer())
    }
    
    public required init(server : CNHServer) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        manager = Alamofire.Manager(configuration: configuration)
        self.server = server
    }
    
    public func start() {
        return start(nil)
    }
    
    public func start(completionHandler : (() -> ())?) {
        manager.request(.GET, self.server.baseURL)
            .responseJSON { (_, _, json, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
//                    return completionHandler(nil, error)
                } else {
                   self.rootResources  = self.decodeResources(JSON(json!))
                }
                
                completionHandler?()
        }
    }
    
    internal func decodeResources(json : JSON) -> [String : ApiResource]? {
        if let resources = json["resources"].array?.map(self.decodeResource) {
            return self.indexById(resources)
        } else {
            return nil
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
