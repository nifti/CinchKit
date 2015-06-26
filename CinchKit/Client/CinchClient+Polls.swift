//
//  CinchClient+Polls.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import SwiftyJSON

extension CinchClient {
    
//    public func fetchLatestPolls(completionHandler : (CNHPollsResponse?, NSError?) -> ()) {
//        fetchLatestPolls(queue: nil, completionHandler: completionHandler)
//    }
    
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
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func fetchStats(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHAccountStats?, NSError?) -> ()) {
        let serializer = AccountStatsSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func fetchCategories(queue: dispatch_queue_t? = nil, completionHandler : ([CNHPollCategory]?, NSError?) -> ()) {
        
        if let categories = self.rootResources?["categories"] {
            self.fetchCategories(atURL: categories.href, queue: queue, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler(nil, self.clientNotConnectedError())
            })
        }
    }
    
    public func fetchCategories(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ([CNHPollCategory]?, NSError?) -> ()) {
        let serializer = PollCategoriesSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func fetchVotes(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHVotesResponse?, NSError?) -> ()) {
        let serializer = PollVotesSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func voteOnPoll(atURL url : NSURL, candidateId : String, queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.POST, url, parameters: ["id" : candidateId], queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
    
    public func uploadCandidate(photoURL: NSURL, queue: dispatch_queue_t? = nil, completionHandler : ([CNHPhoto]?, NSError?) -> ()) {
        if let photos = self.rootResources?["photos"] {
            self.uploadCandidate(atURL: photos.href, photoURL: photoURL, queue: queue, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler(nil, self.clientNotConnectedError())
            })
        }
    }
    
    public func uploadCandidate(atURL url: NSURL, photoURL: NSURL, queue: dispatch_queue_t? = nil, completionHandler : ([CNHPhoto]?, NSError?) -> ()) {
        let serializer = PhotoSerializer()
        authorizedRequest(.POST, url, parameters: ["url": photoURL.absoluteString!], queue: queue, serializer: serializer, completionHandler: completionHandler)
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
}