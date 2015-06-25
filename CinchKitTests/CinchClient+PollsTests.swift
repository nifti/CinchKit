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
                let r = ApiResource(id: "polls", href: NSURL(string: "http://identityservice-dev-peystnaps3.elasticbeanstalk.com/discussions")!, title: "get and create polls")
                
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
                        
                        if let candidate = first.candidates.first {
                            expect(candidate.image).toNot(beEmpty())
                            expect(candidate.images).toNot(beEmpty())
                            expect(candidate.images![.Medium]).toNot(beNil())
                        }
                        
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
                        
                        expect(categories!.first!.icons).toNot(beEmpty())
                        expect(categories!.first!.icons?.count).to(equal(3))
                        
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
        
//        describe("upload photo") {
//            let c = CinchClient()
//            
//            let r = ApiResource(id: "photos", href: NSURL(string: "http://api.us-east-1.niftiws.com/photos")!, title: "View photos")
//            c.rootResources = ["photos": r]
//            
//            let token = CNHAccessTokenData(
//                accountID : "72d25ff9-1d37-4814-b2bd-bc149c222220",
//                href : NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com/tokens")!,
//                access : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNzJkMjVmZjktMWQzNy00ODE0LWIyYmQtYmMxNDljMjIyMjIwIiwibmFtZSI6Im1pa2hhaWwgdmV0b3Noa2luIiwic2NvcGUiOlsidXNlciIsImFjY2Vzc3Rva2VuIl0sImlhdCI6MTQzNTA4NTEyNCwiZXhwIjoxNDM1MDg4NzI0fQ.3MQ3KbIMwUpato_AbzocRSaTk8h7sSebw8hkNv_LX-4",
//                refresh : "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNzJkMjVmZjktMWQzNy00ODE0LWIyYmQtYmMxNDljMjIyMjIwIiwic2NvcGUiOlsicmVmcmVzaHRva2VuIl0sImlhdCI6MTQzNTA4NTEyNH0.QiYTIKMfH28FrHI7l5ADugj0G4a_dH_cBHQGd-_TIBk",
//                type : "Bearer",
//                expires : NSDate(timeIntervalSince1970: 1435093753),
//                cognitoId : "us-east-1:e155b672-cda1-4ddb-aedb-f814002fada1",
//                cognitoToken : "eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ.eyJzdWIiOiJ1cy1lYXN0LTE6ZTE1NWI2NzItY2RhMS00ZGRiLWFlZGItZjgxNDAwMmZhZGExIiwiYXVkIjoidXMtZWFzdC0xOjExNGM1NDBhLTk4YmItNDM5Ni1hMmZlLTJkMWQxYWU2OGJkNyIsImFtciI6WyJhdXRoZW50aWNhdGVkIiwibG9naW4uY2x1dGNocmV0YWlsLmNpbmNoIl0sImlzcyI6Imh0dHBzOi8vY29nbml0by1pZGVudGl0eS5hbWF6b25hd3MuY29tIiwiZXhwIjoxNDM1MDg2MDI0LCJpYXQiOjE0MzUwODUxMjR9.Hl7-B9jEYmxozN8mVqkBwArA-Kl615ndt2wPKr0jVEVBxYcZxT76thBTPezk6RZSrz6B7IYIW2AFztH-6AG7X35YjooQDo3Hr7lRd92L3po1eg4Egt9zaVuLi-JGrWIoNjA24LD2rzJ5MSYg-mGCGsP5bYTxafAzkNRd5lURORxq8pjNIRPWVZo67GYiwWbN1sv63oiaahMXevxXF1S6F9_7Fm8x-W9BehQzTuau-FbPSqHED9LgFQWW5boUfcqafIDrDI3YO6TkSWR0qab5oXzq1d0nG_9rzYMFGfk4HtMpdM6PGxfbe8BfziMBicUU7UJigADJLnK3OGr6LFJm9w"
//            )
//
//            c.session.accessTokenData = token
//            
//            it("should return single photo") {
//                waitUntil(timeout: 3) { done in
//                    let pURL = NSURL(string: "https://s3.amazonaws.com/cognito.dev.cinch.com/us-east-1:f0e72bd0-3529-4212-b852-cd0f7ebb68d2/8248E972-5DCD-4C42-AA5A-D137AADE91E0")
//                    c.uploadCandidate(pURL!, queue: nil, completionHandler: { (photos, error) -> () in
//                        expect(error).to(beNil())
//                        expect(photos).toNot(beNil())
//                        
//                        expect(photos!.count).to(equal(1))
//                        
//                        done()
//                    })
//                }
//            }
//        }
        
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