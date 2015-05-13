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

class CinchClientNotificationsSpec: QuickSpec {
    override func spec() {
        
        describe("fetch notifications") {
            let c = CinchClient()
            
            it("should fetch notifications") {
                let url = NSURL(string: "http://notificationservice-dev-ypmnhvb6mb.elasticbeanstalk.com/accounts/84dec47c-9c47-4e32-ae9f-081233dda5f4/notifications")!
                waitUntil(timeout: 5) { done in
                    c.fetchNotifications(atURL: url, queue: nil) { (response, error ) in
                        expect(error).to(beNil())
                        expect(response).toNot(beNil())
                        expect(response!.notifications).toNot(beEmpty())
                        expect(response!.nextLink).toNot(beNil())
                        
                        let note = response!.notifications!.first!
                        expect(note.accountFrom).toNot(beNil())
                        expect(note.accountTo).toNot(beNil())
//                        expect(note.poll).toNot(beNil())
                        
                        done()
                    }
                }
            }
        }
    }
}