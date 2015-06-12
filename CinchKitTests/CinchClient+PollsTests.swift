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
            var client: CinchClient!
            beforeEach {
                client = CinchClient()
            }
            
            it("should return polls") {
                let r = ApiResource(id: "polls", href: NSURL(string: "http://api.us-east-1.niftiws.com/discussions")!, title: "get and create polls")
                
                client.rootResources = ["polls" : r]
                
                waitUntil(timeout: 10) { done in
                    client.fetchLatestPolls { ( response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.selfLink).toNot(beNil())
                        expect(response!.nextLink).toNot(beNil())
                        expect(response!.nextLink!.href).toNot(beNil())
                        
                        var polls = response!.polls
                        var first = polls!.first!
                        expect(first.candidates).toNot(beNil())
                        expect(first.author).toNot(beNil())
                        expect(first.links).toNot(beEmpty())
                        
                        var candidate = first.candidates.first!
                        expect(candidate.image).toNot(beEmpty())
                        expect(candidate.images).toNot(beEmpty())
                        expect(candidate.images![.Medium]).toNot(beNil())
                        
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
        
        describe("fetch stats") {
            let c = CinchClient()
            
            it("should fetch stats") {
                let url = NSURL(string: "http://notificationservice-dev-ypmnhvb6mb.elasticbeanstalk.com//accounts/12738370-1867-407e-bbe4-2a045f755a8a/stats")!
                waitUntil(timeout: 5) { done in
                    c.fetchStats(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }
        
        describe("fetch categories") {
            let c = CinchClient()
            
            let r = ApiResource(id: "categories", href: NSURL(string: "http://api.us-east-1.niftiws.com/categories")!, title: "poll categories")
            c.rootResources = ["categories" : r]
            
            it("should fetch categories") {
                waitUntil(timeout: 5) { done in
                    c.fetchCategories(queue: nil, completionHandler: { (categories, error ) in
                        expect(error).to(beNil())
                        expect(categories).toNot(beEmpty())
                        done()
                    })
                }
            }
        }
        
        describe("fetch votes") {
            let c = CinchClient()
            
            it("should fetch votes") {
                let url = NSURL(string: "http://api.us-east-1.niftiws.com/discussions/041e52d3-42cf-40d3-812f-e9f83bfc10e3/votes")!
                waitUntil(timeout: 5) { done in
                    c.fetchVotes(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }
        
//        describe("vote on poll") {
//            let c = CinchClient()
//            
//            it("should vote on poll") {
//                let token = CNHAccessTokenData(
//                    accountID : "123456",
//                    href : NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com/tokens")!,
//                    access : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiODBjZDI3NGUtYTZkYS00Njk0LWE2YTUtMTgyMWZkY2NlOTAwIiwibmFtZSI6InVuaXQgdGVzdCIsInNjb3BlIjpbInVzZXIiLCJhY2Nlc3N0b2tlbiJdLCJpYXQiOjE0MzQxMjY0MTMsImV4cCI6MTQzNDEzMDAxM30._BxWq-D2tjBhlFI3t7ATj08OfaCv2crx60ThBhSS4Qs",
//                    refresh : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiODBjZDI3NGUtYTZkYS00Njk0LWE2YTUtMTgyMWZkY2NlOTAwIiwic2NvcGUiOlsicmVmcmVzaHRva2VuIl0sImlhdCI6MTQzNDEyNjQxM30.T0cL4oVt-2_L5mQpzzl4hVNlDQIdeBRFC9DoPDcY62o",
//                    type : "Bearer",
//                    expires : NSDate().dateByAddingTimeInterval(-300),
//                    cognitoId : "us-east-1:919501dd-5909-4ffd-9014-46a97f914dc9",
//                    cognitoToken : "eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ"
//                )
//                
//                c.session.accessTokenData = token
//                let url = NSURL(string: "http://identityservice-dev-peystnaps3.elasticbeanstalk.com/discussions/5db31c42-3f3a-4f2a-9070-2dac450a98ea/votes")!
//                waitUntil(timeout: 5) { done in
//                    c.voteOnPoll(atURL: url, candidateId: "258b33af-0a8d-4c21-8d89-c9198e64a232", queue: nil) { (msg, error) in
//                        expect(error).to(beNil())
//                        done()
//                    }
//                }
//            }
//        }
    }
}