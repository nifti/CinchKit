//
//  CinchClient+Notifications.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 5/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import SwiftyJSON

extension CinchClient {
    public func fetchNotifications(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (CNHNotificationsResponse?, NSError?) -> ()) {
        let serializer = NotificationsResponseSerializer()
        request(.GET, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}
