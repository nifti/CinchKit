//
//  CinchClient+FollowersTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 4/27/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit

class CinchClientFollowersSpec: QuickSpec {
    override func spec() {
        
        describe("fetch followers") {
            let c = CinchClient()
            
            it("should fetch followers") {
                let url = NSURL(string: "http://social-service-xjrfryjqva.elasticbeanstalk.com/accounts/f6704e5b-2206-4f85-b694-df08dc0d731d/followers")!
                waitUntil(timeout: 5) { done in
                    c.fetchFollowers(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.followers).toNot(beEmpty())
                        expect(response!.nextLink).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }
    }
}