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
                client.session.close()
                let r = ApiResource(id: "polls", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions")!, title: "get and create polls")
                
                client.rootResources = ["polls" : r]
                
                waitUntil(timeout: 10) { done in
                    client.fetchLatestPolls { ( response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.selfLink).toNot(beNil())
                        expect(response!.nextLink).toNot(beNil())
                        expect(response!.nextLink!.href).toNot(beNil())
                        
                        let polls = response!.polls
                        let first = polls!.first!
                        expect(first.candidates).toNot(beNil())
                        expect(first.author).toNot(beNil())
                        expect(first.links).toNot(beEmpty())
                        
                        expect(first.categoryId).toNot(beNil())
                        
                        if let candidate = first.candidates.first {
                            expect(candidate.image).toNot(beEmpty())
                        }
                        
                        expect(NSThread.isMainThread()).to(equal(true))
                        
                        done()
                    }
                }
            }
            
            it("should return on specific queue") {
                let c = CinchClient()
                
                let r = ApiResource(id: "polls", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions")!, title: "get and create polls")
                
                c.rootResources = ["polls" : r]
                
                waitUntil(timeout: 10) { done in
                    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    
                    c.fetchLatestPolls(queue) { ( response, error ) in
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
                let url = NSURL(string: "http://notification-service-vpxjdpudmk.elasticbeanstalk.com/accounts/12738370-1867-407e-bbe4-2a045f755a8a/stats")!
                waitUntil(timeout: 5) { done in
                    c.fetchStats(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        
                        done()
                    }
                }
            }

            it("should set stats") {
                let c = CinchClient()
                CinchKitTestsHelper.setTestUserSession(c)

                let url = NSURL(string: "http://notification-service-vpxjdpudmk.elasticbeanstalk.com/accounts/\(CinchKitTestsHelper.getTestUserId())/stats")!
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        c.setStats(atURL: url, params: ["unreadCount": 0], queue: nil) { (response, error ) in
                            expect(error).to(beNil())

                            done()
                        }
                    }
                }
            }
        }
        
        describe("fetch votes") {
            let c = CinchClient()
            
            it("should fetch votes") {
                let url = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/041e52d3-42cf-40d3-812f-e9f83bfc10e3/votes")!
                waitUntil(timeout: 5) { done in
                    c.fetchVotes(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }

        describe("bump poll") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            it("should bump the poll") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/3f277983-e3bc-479a-be3f-4d0dfb3a95ef")!
                        c.bumpPoll(atURL: url, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())
                            expect(response).notTo(beNil())

                            done()
                        })
                    }
                }
            }
        }

        describe("change category") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            it("should change poll's category") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/01084044-15fc-4705-b595-4ef33baafdf9")!
                        c.changePollCategory(atURL: url, categoryId: "9221b63d-9dad-44bc-97fd-47a2042bdbbc", queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())
                            expect(response).notTo(beNil())

                            done()
                        })
                    }
                }
            }
        }

        describe("report poll") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            let r = ApiResource(id: "complaints", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/complaints")!, title: "send complaint")
            c.rootResources = ["complaints" : r]

            it("should report poll from user") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let params = [
                            "resourceId": "1234567890",
                            "type": "poll",
                            "reason": "Test"
                        ]

                        c.sendComplaint(params, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())

                            done()
                        })
                    }
                }
            }
        }

        describe("make poll private") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            it("should make poll private") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/42ec38f3-5658-4708-8c20-0c70414b7c6f")!
                        c.makePollPrivate(atURL: url, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())

                            done()
                        })
                    }
                }
            }
        }

        describe("remove from featured") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            it("should remove poll from featured feed") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions/42ec38f3-5658-4708-8c20-0c70414b7c6f")!
                        c.removeFromFeatured(atURL: url, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())

                            done()
                        })
                    }
                }
            }
        }

        describe("leaderboard") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            let r = ApiResource(id: "leaderboard", href: NSURL(string: "http://polls.cinchws.net/leaderboard")!, title: "leaderboard")
            c.rootResources = ["leaderboard" : r]

            it("should get the leaderboard") {
                waitUntil(timeout: 5) { done in
                    c.getLeaderboard(nil, completionHandler: { (_, error) -> () in
                        expect(error).to(beNil())
                        done()
                    })
                }
            }
        }
        
//        describe("upload photo") {
//            let c = CinchClient()
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
//                    let uUrl = NSURL(string: "http://api.us-east-1.niftiws.com/accounts/72d25ff9-1d37-4814-b2bd-bc149c222220/photos")
//                    let pUrl = NSURL(string: "https://s3.amazonaws.com/cognito.dev.cinch.com/us-east-1:f0e72bd0-3529-4212-b852-cd0f7ebb68d2/8248E972-5DCD-4C42-AA5A-D137AADE91E0")
//                    c.uploadCandidate(atURL: uUrl!, photoURL: pUrl!, queue: nil, completionHandler: { (photos, error) -> () in
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
        
//        describe("creating a poll") {
//            let c = CinchClient()
//            
//            let r = ApiResource(id: "polls", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/discussions")!, title: "get and create polls")
//            c.rootResources = ["polls" : r]
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
//            it("should return the poll") {
//                waitUntil(timeout: 5) { done in
//                    let params = [
//                        "topic": "Test...",
//                        "public": true,
//                        "type": "multiple",
//                        "photos": ["5acf28d6-d183-430a-9515-072abee49952", "7fc474ba-e208-4fd2-aa69-af68a1584e1d"]
//                    ]
//                    
//                    c.createPoll(params as! [String : AnyObject], queue: nil, completionHandler: { (response, error) -> () in
//                        expect(error).to(beNil())
//                        expect(response).toNot(beNil())
//                        expect(response!.selfLink).toNot(beNil())
//                        
//                        var polls = response!.polls
//                        var first = polls!.first!
//                        expect(first.candidates).toNot(beNil())
//                        expect(first.links).toNot(beEmpty())
//                        expect(first.author).toNot(beNil())
//                        
//                        if let candidate = first.candidates.first {
//                            expect(candidate.image).toNot(beEmpty())
//                        }
//                        
//                        expect(NSThread.isMainThread()).to(equal(true))
//
//                        done()
//                    })
//                }
//            }
//        }
    }
}