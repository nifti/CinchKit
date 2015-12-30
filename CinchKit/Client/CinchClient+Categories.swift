//
//  CinchClient+Categories.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 23/07/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func fetchCategories(queue: dispatch_queue_t? = nil, completionHandler : ([CNHCategory]?, NSError?) -> ()) {
        let serializer = CategoriesSerializer()

        if let categories = self.rootResources?["categories"] {
            request(.GET, categories.href, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler(nil, self.clientNotConnectedError())
            })
        }
    }

    public func followCategory(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.POST, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }

    public func unfollowCategory(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (String?, NSError?) -> ()) {
        let serializer = EmptyResponseSerializer()
        authorizedRequest(.DELETE, url, queue: queue, serializer: serializer, completionHandler: completionHandler)
    }
}