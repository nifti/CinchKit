//
//  CinchClient+Polls.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func fetchLatestPolls(queue: dispatch_queue_t? = nil, completionHandler : (CNHPollsResponse?, NSError?) -> ()) {
        if let polls = self.rootResources?["polls"] {
            self.fetchPolls(atURL: polls.href, queue: queue, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler(nil, self.clientNotConnectedError())
            })
        }
    }
    
    public func fetchPolls(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHPollsResponse?, NSError?) -> ()) {
        let serializer = PollsResponseSerializer()
        
        // when user is logged in we want to send auth headers when fetching polls
        if self.session.isOpen || self.session.sessionState == .Closed {
            authorizedRequest(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
        }
    }
        
    public func createPoll(params: [String: AnyObject], queue: dispatch_queue_t? = nil, completionHandler : (CNHPollsResponse?, NSError?) -> ()) {
        let serializer = PollsResponseSerializer()
        if let polls = self.rootResources?["polls"] {
            authorizedRequest(.POST, polls.href, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler(nil, self.clientNotConnectedError())
            })
        }
    }

    public func bumpPoll(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((CNHPollsResponse?, NSError?) -> ())?) {
        let serializer = PollsResponseSerializer()
        let params: [String: AnyObject] = [
            "recentPosition": 0
        ]
        authorizedRequest(.PUT, url, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }

    public func changePollCategory(atURL url : NSURL, categoryId: String, queue: dispatch_queue_t? = nil, completionHandler : ((CNHPollsResponse?, NSError?) -> ())?) {
        let serializer = PollsResponseSerializer()
        let params: [String: AnyObject] = [
            "category": categoryId
        ]
        authorizedRequest(.PUT, url, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }

    public func makePollPrivate(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()
        let params: [String: AnyObject] = [
            "public": false
        ]
        authorizedRequest(.PUT, url, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }

    public func deletePoll(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.DELETE, url, parameters: nil, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}