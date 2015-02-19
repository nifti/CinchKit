//
//  ApiResource.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

public struct ApiResource {
    public let id: String
    public let href: NSURL
    public let title: String?
    
    public init(id : String, href: NSURL, title : String?) {
        self.id = id
        self.href = href
        self.title = title
    }
}