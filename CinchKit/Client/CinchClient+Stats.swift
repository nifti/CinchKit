//
//  CinchClient+Stats.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 29/12/15.
//  Copyright © 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func fetchStats(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHAccountStats?, NSError?) -> ()) {
        let serializer = AccountStatsSerializer()

        if self.session.isOpen || self.session.sessionState == .Closed {
            authorizedRequest(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
        }
    }

    public func setStats(atURL url : NSURL, params: [String: Int], queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.PUT, url, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}