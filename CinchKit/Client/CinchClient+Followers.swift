//
//  CinchClient+Followers.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 4/27/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func fetchFollowers(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHFollowersResponse?, NSError?) -> ()) {
        let serializer = FollowersSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func followAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.POST, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func unfollowAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.DELETE, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}