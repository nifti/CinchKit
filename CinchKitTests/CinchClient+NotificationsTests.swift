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
            var client = CinchClient()

            beforeEach {
                LSNocilla.sharedInstance().start()
                LSNocilla.sharedInstance().clearStubs()            }

            afterEach {
                LSNocilla.sharedInstance().clearStubs()
                LSNocilla.sharedInstance().stop()
            }
            
            it("should fetch notifications") {
                var data = CinchKitTestsHelper.loadJsonData("fetchNotifications")

                let urlStr = "http://notification-service-bd2cm278ft.elasticbeanstalk.com/accounts/72d25ff9-1d37-4814-b2bd-bc149c222220/notifications?limit=6"
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
                        expect(note.senderCategory).to(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.recipientCategory).to(beNil())
                        expect(note.resourcePoll).notTo(beNil())
                        expect(note.resourceAccount).to(beNil())
                        expect(note.resourceCategory).to(beNil())

                        note = response!.notifications![2]
                        expect(note.senderAccount).to(beNil())
                        expect(note.senderCategory).notTo(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.recipientCategory).to(beNil())
                        expect(note.resourcePoll).notTo(beNil())
                        expect(note.resourceAccount).to(beNil())
                        expect(note.resourceCategory).to(beNil())

                        note = response!.notifications![4]
                        expect(note.senderAccount).notTo(beNil())
                        expect(note.senderCategory).to(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.recipientCategory).to(beNil())
                        expect(note.resourcePoll).to(beNil())
                        expect(note.resourceAccount).to(beNil())
                        expect(note.resourceCategory).notTo(beNil())

                        note = response!.notifications![5]
                        expect(note.senderAccount).notTo(beNil())
                        expect(note.senderCategory).to(beNil())
                        expect(note.recipientAccount).notTo(beNil())
                        expect(note.recipientCategory).to(beNil())
                        expect(note.resourcePoll).to(beNil())
                        expect(note.resourceAccount).notTo(beNil())
                        expect(note.resourceCategory).to(beNil())

                        done()
                    }
                }
            }
        }
    }
}