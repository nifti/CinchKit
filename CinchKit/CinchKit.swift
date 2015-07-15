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
    
    private let manager : Alamofire.Manager
    public let server : CNHServer
    
    internal let responseQueue = dispatch_queue_create("cinchkit.response", DISPATCH_QUEUE_CONCURRENT)
    
    public var rootResources : [String : ApiResource]?
    
    private(set) public var session = CNHSession()
    
    public convenience init() {
        self.init(server: CNHServer.dotComServer())
    }
    
    var authHeader : [String : String]? {
        if self.session.isOpen, let token = self.session.accessTokenData {
            return ["Authorization" : "\(token.type) \(token.access)"]
        } else {
            return nil
        }
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
    
    public func start(completionHandler : ((CNHAccount?) -> ())?) {
        var activeAccount : CNHAccount?
        var ongoing = 2
        
        let handler : ( () -> () ) = { () in
            ongoing--
            
            if ongoing == 0 {
                // when an active account has not been loaded
                // attempt to update the stored href of any existing auth token data
                // if that href was updated then attempt to refresh a session
                if let account = activeAccount {
                    completionHandler?(account)
                } else if self.updateActiveAccessTokenDataHref() {
                    self.refreshSession(includeAccount : true) { (account, _) in
                        completionHandler?(account)
                    }
                } else {
                    completionHandler?(nil)
                }
            }
        }
        
        var queue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)

        dispatch_async(queue) {
            self.refreshSession(includeAccount : true) { (account, _) in
                activeAccount = account
                handler()
            }
        }
        
        dispatch_async(queue) {
            self.refreshRootResource { handler() }
        }
    }
    
    func refreshRootResource(completionHandler : (() -> ())?) {
        let serializer = ApiResourcesSerializer()
        request(.GET, self.server.baseURL, serializer: serializer, completionHandler: { (resources, error) in
            if(error != nil) {
            } else {
                self.rootResources  = resources
            }
            
            completionHandler?()
        })
    }
    
    private func updateActiveAccessTokenDataHref() -> Bool {
        if let token = self.session.accessTokenData, let apiToken = self.rootResources?["tokens"] {
            let updatedToken = CNHAccessTokenData(
                accountID: token.accountID,
                href: apiToken.href,
                access: token.access,
                refresh: token.refresh,
                type: token.type,
                expires: token.expires,
                cognitoId: token.cognitoId,
                cognitoToken: token.cognitoToken
            )
            
            self.session.accessTokenData = updatedToken
            return true
        } else {
            return false
        }
    }
    
    func clientNotConnectedError() -> NSError {
        return NSError(domain: CinchKitErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey : "Cinch Client not connected"])
    }
    
    func clientNotAuthroizedError() -> NSError {
        return NSError(domain: CinchKitErrorDomain, code: 403, userInfo: [NSLocalizedDescriptionKey : "Cinch client not authorized"])
    }
    
    func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, headers : [String : String]? = nil, encoding: Alamofire.ParameterEncoding = .JSON) -> Alamofire.Request {
        
        var path = NSURL(string: URLString.URLString)!
        var mutableURLRequest = NSMutableURLRequest(URL: path)
        mutableURLRequest.HTTPMethod = method.rawValue
        
        if let head = headers {
            for (field, value) in head {
                mutableURLRequest.setValue(value, forHTTPHeaderField: field)
            }    
        }
        
        let finalRequest = encoding.encode(mutableURLRequest, parameters: parameters).0
        
//        mutableURLRequest.setValue("\(token.type) \(token.refresh)", forHTTPHeaderField: "Authorization")

        return manager.request(finalRequest)
    }
    
    func request<T : JSONObjectSerializer>( method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, headers : [String : String]? = nil,  encoding: Alamofire.ParameterEncoding = .JSON, queue: dispatch_queue_t? = nil,
        serializer : T, completionHandler : ((T.ContentType?, NSError?) -> Void)? ) {
            
            let start = CACurrentMediaTime()
            
            request(method, URLString, parameters: parameters, headers: headers, encoding: encoding)
                .responseCinchJSON(queue: queue, serializer: serializer) { (_, httpResponse, response, error) in
                    CNHUtils.logResponseTime(start, response : httpResponse,  message : "response: \(method.rawValue) \(URLString.URLString)")
                    
                    if(error != nil) {
                        NSLog("Error: \(error)")
                        completionHandler?(nil, error)
                    } else {
                        completionHandler?(response, nil)
                    }
            }
    }
    
    func authorizedRequest<T : JSONObjectSerializer>( method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, headers : [String : String]? = nil,  encoding: Alamofire.ParameterEncoding = .JSON, queue: dispatch_queue_t? = nil,
        serializer : T, completionHandler : ((T.ContentType?, NSError?) -> Void)? ) {
            
            if let auth = self.authHeader {
                var finalHeaders : [String : String]
                
                if let h = headers {
                    finalHeaders = h
                } else {
                    finalHeaders = [String : String]()
                }
                
                finalHeaders["Authorization"] = auth["Authorization"]
                request(method, URLString, parameters: parameters, headers: finalHeaders, encoding: encoding, queue: queue, serializer: serializer, completionHandler: completionHandler)
            } else if self.session.sessionState == .Closed {
                self.refreshSession(includeAccount: false) { (_, _) in
                    if self.session.isOpen {
                       self.authorizedRequest(method, URLString, parameters: parameters, headers: headers, encoding: encoding, queue: queue, serializer: serializer, completionHandler: completionHandler)
                    } else {
                        let err = self.clientNotAuthroizedError()
                        completionHandler?(nil, err)
                    }
                }
            } else {
                let err = self.clientNotAuthroizedError()
                completionHandler?(nil, err)
            }
    }
}
