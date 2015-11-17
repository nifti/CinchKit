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
    
    
    /**
    Adds a handler to be called once the request has finished.
    
    - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
    
    - returns: The request.
    */
    public func responseCinchJSON<T : JSONObjectSerializer>(serializer : T, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T.ContentType?, NSError?) -> Void) -> Self {
        return responseCinchJSON(nil, serializer : serializer, options:NSJSONReadingOptions.AllowFragments, completionHandler:completionHandler)
    }

    
    /**
    Adds a handler to be called once the request has finished.
    
    - parameter queue: The queue on which the completion handler is dispatched.
    - parameter options: The JSON serialization reading options. `.AllowFragments` by default.
    - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 4 arguments: the URL request, the URL response, if one was received, the SwiftyJSON enum, if one could be created from the URL response and data, and any error produced while creating the SwiftyJSON enum.
    
    - returns: The request.
    */
    
    public func responseCinchJSON<T : JSONObjectSerializer>(queue: dispatch_queue_t? = nil, serializer : T, options: NSJSONReadingOptions = .AllowFragments, completionHandler: (NSURLRequest, NSHTTPURLResponse?, T.ContentType?, NSError?) -> Void) -> Self {

        return response(queue: queue, responseSerializer: Request.JSONResponseSerializer(options: options), completionHandler: { (response) -> Void in
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                var errorResponse : NSError?
                var responseJSON: JSON
                var decodedObject : T.ContentType?

                if response.result.error != nil || response.result.value == nil{
                    errorResponse = response.result.error
                    responseJSON = JSON.null
                } else if response.response?.statusCode >= 400 {
                    let errSerializer = ErrorResponseSerializer()
                    responseJSON = JSON.null
                    errorResponse = errSerializer.jsonToObject(SwiftyJSON.JSON(response.result.value!))
                } else {
                    responseJSON = SwiftyJSON.JSON(response.result.value!)
                    decodedObject = serializer.jsonToObject(responseJSON)
                }
                
                dispatch_async(queue ?? dispatch_get_main_queue(), {
                    completionHandler(self.request!, self.response, decodedObject, errorResponse)
                })
            })
        })
    }
}
