//
//  CinchServer.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/27/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

public struct CNHServer {
    public let baseURL : NSURL
    public let authServerURL = NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com")!
    
    public init(baseURL : NSURL) {
       self.baseURL = baseURL
    }
    
    static func dotComServer() -> CNHServer {
        return CNHServer(baseURL : NSURL(string : "http://api.us-east-1.niftiws.com")!)
    }
}
