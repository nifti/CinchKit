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

        describe("following categories") {
            let c = CinchClient()

            let authServerURL = NSURL(string: "http://auth-service-jgjfpv9gvy.elasticbeanstalk.com/")!
            let accountsResource = ApiResource(id: "accounts", href: NSURL(string: "\(authServerURL)/accounts")!, title: "get and create accounts")
            let tokensResource = ApiResource(id: "tokens", href: NSURL(string: "\(authServerURL)/tokens")!, title: "Create and refresh authentication tokens")
            c.rootResources = ["accounts" : accountsResource, "tokens" : tokensResource]

            let refreshToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNzJkMjVmZjktMWQzNy00ODE0LWIyYmQtYmMxNDljMjIyMjIwIiwic2NvcGUiOlsicmVmcmVzaHRva2VuIl0sImlhdCI6MTQzNzY2NzI1OX0.zqqSGmpcNZz-6lmO_ejTOYZuKLcp__l1yRUtWQcYxYg"
            c.session.accessTokenData = CNHAccessTokenData(accountID: "",
                href: NSURL(string: "http://auth-service-jgjfpv9gvy.elasticbeanstalk.com/tokens")!,
                access: "", refresh: refreshToken, type: "Bearer", expires: NSDate(), cognitoId: "", cognitoToken: ""
            )

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