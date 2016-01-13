//
//  CinchClient+Extension.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 29/12/15.
//  Copyright © 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func uploadCandidate(atURL url: NSURL, photoURL: NSURL, queue: dispatch_queue_t? = nil, completionHandler : ([CNHPhoto]?, NSError?) -> ()) {
        let serializer = PhotoSerializer()
        authorizedRequest(.POST, url, parameters: ["url": photoURL.absoluteString], queue: queue, serializer: serializer, completionHandler: completionHandler)
    }

    public func sendComplaint(params: [String: AnyObject], queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        if let complaints = self.rootResources?["complaints"] {
            authorizedRequest(.POST, complaints.href, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler?(nil, self.clientNotConnectedError())
            })
        }
    }

    public func getLeaderboard(atURL url: NSURL? = nil, queue: dispatch_queue_t? = nil, completionHandler : ((CNHLeaderboardResponse?, NSError?) -> ())?) {
        let serializer = LeaderboardResponseSerializer()

        if let leaderboard = self.rootResources?["leaderboard"] {
            let reqUrl = url ?? leaderboard.href

            if self.session.isOpen || self.session.sessionState == .Closed {
                authorizedRequest(.GET, reqUrl, queue: queue, serializer: serializer, completionHandler: completionHandler)
            } else {
                request(.GET, reqUrl, queue: queue, serializer: serializer, completionHandler: completionHandler)
            }
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler?(nil, self.clientNotConnectedError())
            })
        }
    }
}