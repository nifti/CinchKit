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
                let url = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/98df6e53-5859-4ce5-a4bb-b0e48e214969/messages?type=comment")!
                waitUntil(timeout: 5) { done in
                    c.fetchComments(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.comments).toNot(beEmpty())
                        expect(response!.nextLink).to(beNil())
                        expect(response!.comments!.first!.author).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }

        describe("create & remove comments") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            var newCommentUrl: NSURL?
            let messagesUrl = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/1eb66fe4-fef8-4897-a966-28f206d2e426/messages")!

            it("should create comment") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let params = [
                            "message": "Test test test"
                        ]

                        c.createComment(atURL: messagesUrl, params: params, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())
                            expect(response).notTo(beNil())

                            expect(response!.comments!.count).to(equal(1))

                            newCommentUrl = response!.comments!.first!.href

                            done()
                        })
                    }
                }
            }

            it("should remove comment") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        c.removeComment(atURL: newCommentUrl!, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())

                            done()
                        })
                    }
                }
            }
        }
    }
}
