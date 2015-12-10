//
//  CinchClient+Categories.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 23/07/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit


class CinchClientCategoriesSpec: QuickSpec {
    override func spec() {

        describe("fetching categories") {
            let c = CinchClient()

            let r = ApiResource(id: "categories", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/categories")!, title: "poll categories")
            c.rootResources = ["categories" : r]

            it("should fetch categories") {
                waitUntil(timeout: 5) { done in
                    c.fetchCategories(nil, completionHandler: { (categories, error ) in
                        expect(error).to(beNil())
                        expect(categories).toNot(beEmpty())

                        if let cats = categories {
                            expect(cats.first!.icons).toNot(beEmpty())
                            expect(cats.first!.icons?.count).to(equal(3))

                            expect(cats[0].position).to(equal(1))
                            expect(cats[1].position).to(equal(2))
                            expect(cats[2].position).to(equal(3))
                        }

                        done()
                    })
                }
            }
        }

        describe("following categories") {
            let c = CinchClient()
            CinchKitTestsHelper.setTestUserSession(c)

            it("should follow category") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://social-service-xjrfryjqva.elasticbeanstalk.com/categories/44cfc1cf-be28-4f26-9dda-a4e215a98914/followers")
                        c.followCategory(atURL: url!, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())
                            expect(response).to(equal("OK"))

                            done()
                        })
                    }
                }
            }

            it("should unfollow category") {
                waitUntil(timeout: 5) { done in
                    c.refreshSession { (account, error) in
                        let url = NSURL(string: "http://social-service-xjrfryjqva.elasticbeanstalk.com/categories/44cfc1cf-be28-4f26-9dda-a4e215a98914/followers")
                        c.followCategory(atURL: url!, queue: nil, completionHandler: { (response, error) -> () in
                            expect(error).to(beNil())
                            expect(response).to(equal("OK"))

                            done()
                        })
                    }
                }
            }
        }
    }
}