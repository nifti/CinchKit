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
    
    internal let responseQueue = dispatch_queue_create("cinchkit.response", DISPATCH_QUEUE_CONCURRENT)
    
    public var rootResources : [String : ApiResource]?

    public convenience init() {
        self.init(server: CNHServer.dotComServer())
    }
    
    public required init(server : CNHServer) {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = 20
        manager = Alamofire.Manager(configuration: configuration)
        self.server = server
    }
    
    public func start() {
        return start(nil)
    }
    
    public func start(completionHandler : (() -> ())?) {
        let serializer = ApiResourcesSerializer()
        
        request(.GET, self.server.baseURL)
            .responseCinchJSON(serializer) { (_, _, resources, error) in
                if(error != nil) {
                    NSLog("Error: \(error)")
//                    return completionHandler(nil, error)
                } else {
                   self.rootResources  = resources
                }
                
                completionHandler?()
        }
    }
    
    func logResponseTime(start : CFTimeInterval) {
        let end = CACurrentMediaTime()
        var elapsedTime = end - start
        
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        
        println("Elapsed Time: \(numberFormatter.stringFromNumber(elapsedTime)) sec")
    }
    
    func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .JSON) -> Alamofire.Request {
        println("performing request: method \(method.rawValue) - \(URLString.URLString)")
        
        return manager.request(method, URLString, parameters: parameters, encoding: encoding)
    }

}
