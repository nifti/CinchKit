//
//  CinchClient+NotificationsTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 5/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit
import Nocilla


class CinchClientNotificationsSpec: QuickSpec {
    override func spec() {
        
        describe("fetch notifications") {
            let client = CinchClient()

            beforeEach {
                LSNocilla.sharedInstance().start()
                LSNocilla.sharedInstance().clearStubs()
            }

            afterEach {
                LSNocilla.sharedInstance().clearStubs()
                LSNocilla.sharedInstance().stop()
            }
            
            it("should fetch notifications") {
                let data = CinchKitTestsHelper.loadJsonData("fetchNotifications")

                let urlStr = "http://notification-service-vpxjdpudmk.elasticbeanstalk.com/accounts/72d25ff9-1d37-4814-b2bd-bc149c222220/notifications"
                let url = NSURL(string: urlStr)!

                stubRequest("GET", urlStr).andReturn(200).withHeader("Content-Type", "application/json").withBody(data)

                waitUntil(timeout: 5) { done in
                    client.fetchNotifications(atURL: url, queue: nil) { (response, error) in
                        expect(error).to(beNil())

                        expect(response).notTo(beNil())
                        expect(response!.nextLink).notTo(beNil())
                        expect(response!.notifications).notTo(beEmpty())
                        expect(response!.notifications?.count).to(equal(6))

                        var note = response!.notifications![0]
                        expect(note.senderAccount).notTo(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.resourcePoll).notTo(beNil())
                        expect(note.resourceAccount).to(beNil())
                        expect(note.resourceCategory).to(beNil())
                        expect(note.action).to(equal("voted"))
                        expect(note.extraCandidate!.id).to(equal("0278e2ed-5d8e-4556-88ef-c9e075524857:YES"))

                        note = response!.notifications![1]
                        expect(note.senderAccount).notTo(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.resourcePoll).notTo(beNil())
                        expect(note.resourceAccount).to(beNil())
                        expect(note.resourceCategory).to(beNil())
                        expect(note.action).to(equal("created"))

                        note = response!.notifications![2]
                        expect(note.senderAccount).notTo(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.resourcePoll).to(beNil())
                        expect(note.resourceAccount).notTo(beNil())
                        expect(note.resourceCategory).to(beNil())
                        expect(note.action).to(equal("following"))

                        note = response!.notifications![5]
                        expect(note.senderAccount).notTo(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.resourcePoll).to(beNil())
                        expect(note.resourceAccount).to(beNil())
                        expect(note.resourceCategory).notTo(beNil())
                        expect(note.action).to(equal("following"))

                        done()
                    }
                }
            }
        }

        describe("sending notifications") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            let n = ApiResource(id: "notifications", href: NSURL(string: "http://notification-service-vpxjdpudmk.elasticbeanstalk.com/notifications")!, title: "Send notifications")
            c.rootResources = ["notifications" : n]

            it("should send notification") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let params = [
                            "recipientId": CinchKitTestsHelper.getTestUserId(),
                            "recipientType": "account",
                            "resourceId": CinchKitTestsHelper.getTestUserId(),
                            "resourceType": "account",
                            "action": "shared"
                        ]

                        c.sendNotification(params, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())

                            done()
                        })
                    }
                }
            }
        }
    }
}