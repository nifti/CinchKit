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
                let r = ApiResource(id: "polls", href: "http://api.us-east-1.niftiws.com/discussions", title: "get and create polls")
                
                c.rootResources = ["polls" : r]
                
                waitUntil(timeout: 3) { done in
                    c.fetchLatestPolls { ( response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.selfLink).toNot(beNil())
                        expect(response!.nextLink).toNot(beNil())
                        expect(response!.nextLink!.href).toNot(beNil())
                        
                        var polls = response!.polls
                        expect(polls!.first!.candidates).toNot(beNil())
                        expect(polls!.first!.author).toNot(beNil())
                        done()
                    }
                }
            }
            
        }
    }
}