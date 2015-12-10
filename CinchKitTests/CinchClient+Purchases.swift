//
//  CinchClient+Purchases.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 10/12/15.
//  Copyright © 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit


class CinchClientPurchasesSpec: QuickSpec {
    override func spec() {
        let c = CinchClient()

        let r = ApiResource(id: "purchases", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/purchases")!, title: "purchases")
        c.rootResources = ["purchases" : r]

        describe("create purchase") {
            it("should create a purchase") {
                waitUntil(timeout: 5) { done in
                    c.createPurchase("com.clutchretail.cinch.bump", metadata: ["pollId": "12345"], queue: nil, completionHandler: { (_, error) -> () in
                        expect(error).to(beNil())
                        done()
                    })
                }
            }
        }

        describe("update purchase") {
            it("should update a purchase") {
                waitUntil(timeout: 5) { done in
                    c.updatePurchase("1111111111", queue: nil, completionHandler: { (_, error) -> () in
                        expect(error).to(beNil())
                        done()
                    })
                }
            }
        }
    }
}
