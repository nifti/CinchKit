//
//  CinchClient+Votes.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 29/12/15.
//  Copyright © 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func fetchVotes(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHVotesResponse?, NSError?) -> ()) {
        let serializer = PollVotesSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }

    public func voteOnPoll(atURL url : NSURL, candidateId : String, queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.POST, url, parameters: ["id" : candidateId], queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}
