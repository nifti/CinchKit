//
//  CinchClient+PollsTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 1/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit

class CinchClientPollsSpec: QuickSpec {
    override func spec() {
        describe("fetch latest polls") {
            
            it("should return polls") {
                let c = CinchClient()
                
                let r = ApiResource(id: "polls", href: NSURL(string: "http://api.us-east-1.niftiws.com/discussions")!, title: "get and create polls")
                
                c.rootResources = ["polls" : r]
                
                waitUntil(timeout: 10) { done in
                    c.fetchLatestPolls { ( response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.selfLink).toNot(beNil())
                        expect(response!.nextLink).toNot(beNil())
                        expect(response!.nextLink!.href).toNot(beNil())
                        
                        var polls = response!.polls
                        expect(polls!.first!.candidates).toNot(beNil())
                        expect(polls!.first!.author).toNot(beNil())
                        
                        expect(NSThread.isMainThread()).to(equal(true))
                        
                        done()
                    }
                }
            }
            
            it("should return on specific queue") {
                let c = CinchClient()
                
                let r = ApiResource(id: "polls", href: NSURL(string: "http://api.us-east-1.niftiws.com/discussions")!, title: "get and create polls")
                
                c.rootResources = ["polls" : r]
                
                waitUntil(timeout: 10) { done in
                    var queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    
                    c.fetchLatestPolls(queue: queue) { ( response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        
                        expect(NSThread.isMainThread()).to(equal(false))
                        
                        done()
                    }
                }
            }
            
            it("should return error when polls resource doesnt exist") {
                let c = CinchClient()
                
                waitUntil(timeout: 10) { done in
                    c.fetchLatestPolls { ( response, error ) in
                        expect(error).toNot(beNil())
                        expect(error!.domain).to(equal(CinchKitErrorDomain))
                        expect(response).to(beNil())
                        
                        done()
                    }
                }
            }
            
        }
    }
}