//
//  CinchClient+CommentsTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 5/1/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit

class CinchClientCommentsSpec: QuickSpec {
    override func spec() {
        
        describe("fetch comments") {
            let c = CinchClient()
            
            it("should fetch comments") {
                let url = NSURL(string: "http://api.us-east-1.niftiws.com/discussions/98df6e53-5859-4ce5-a4bb-b0e48e214969/messages?type=comment")!
                waitUntil(timeout: 5) { done in
                    c.fetchComments(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.comments).toNot(beEmpty())
                        expect(response!.nextLink).toNot(beNil())
                        expect(response!.comments!.first!.author).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }
    }
}
