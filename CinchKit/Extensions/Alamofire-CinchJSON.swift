//
//  Alamofire-CinchJSON.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/30/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON

public protocol JSONObjectSerializer {
    typealias ContentType
    
    func jsonToObject(json:SwiftyJSON.JSON) -> ContentType?
}

// MARK: - Request for Cinch JSON

extension Request {
    
    public func responseCinchJSON<T : JSONObjectSerializer>(serializer : T, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T.ContentType?, NSError?) -> Void) -> Self {
        return responseCinchJSON(queue:nil, serializer : serializer, options:NSJSONReadingOptions.AllowFragments, completionHandler:completionHandler)
    }
    
    /**
    Adds a handler to be called once the request has finished.
    
    :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
    
    :returns: The request.
    */
    public func responseCinchJSON(completionHandler: (NSURLRequest, NSHTTPURLResponse?, SwiftyJSON.JSON, NSError?) -> Void) -> Self {
        return responseCinchJSON(queue:nil, options:NSJSONReadingOptions.AllowFragments, completionHandler:completionHandler)
    }
    
    /**
    Adds a handler to be called once the request has finished.
    
    :param: queue The queue on which the completion handler is dispatched.
    :param: options The JSON serialization reading options. `.AllowFragments` by default.
    :param: completionHandler A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
    
    :returns: The request.
    */
    public func responseCinchJSON(queue: dispatch_queue_t? = nil, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, JSON, NSError?) -> Void) -> Self {
        
        return response(queue: queue, serializer: Request.JSONResponseSerializer(options: options), completionHandler: { (request, response, object, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                var responseJSON: JSON
                if error != nil || object == nil{
                    responseJSON = JSON.nullJSON
                } else {
                    responseJSON = SwiftyJSON.JSON(object!)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completionHandler(self.request, self.response, responseJSON, error)
                })
            })
        })
    }
    
    public func responseCinchJSON<T : JSONObjectSerializer>(queue: dispatch_queue_t? = nil, serializer : T, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T.ContentType?, NSError?) -> Void) -> Self {
        
        return response(queue: queue, serializer: Request.JSONResponseSerializer(options: options), completionHandler: { (request, response, object, error) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                var responseJSON: JSON
                var decodedObject : T.ContentType?
                
                if error != nil || object == nil{
                    responseJSON = JSON.nullJSON
                } else {
                    responseJSON = SwiftyJSON.JSON(object!)
                    decodedObject = serializer.jsonToObject(responseJSON)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completionHandler(self.request, self.response, decodedObject, error)
                })
            })
        })
    }
}
