//
//  CinchClient+AuthTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit

class CinchClientAuthSpec: QuickSpec {
    override func spec() {
        describe("Cinch Client Auth") {
            var client: CinchClient?
            
            beforeEach {
                client = CinchClient()
                let r = ApiResource(id: "accounts", href: NSURL(string: "\(client!.server.authServerURL)/accounts")!, title: "get and create accounts")
                client!.rootResources = ["accounts" : r]
            }
            
            describe("fetch Accounts matching email") {
                
                it("should return single account") {
                    waitUntil(timeout: 10) { done in
                        client!.fetchAccountsMatchingEmail("foo@bar.com") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).toNot(beEmpty())
                            expect(accounts!.count).to(equal(1))
                            done()
                        }
                    }
                }
                
                it("should return nil") {
                    waitUntil(timeout: 10) { done in
                        client!.fetchAccountsMatchingEmail("asdfasdfasdf") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).to(beNil())
                            done()
                        }
                    }
                }
                
                it("should return error when accounts resource doesnt exist") {
                    let c = CinchClient()
                    
                    waitUntil(timeout: 10) { done in
                        c.fetchAccountsMatchingEmail("foo@bar.com") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(error!.domain).to(equal(CinchKitErrorDomain))
                            expect(accounts).to(beNil())
                            
                            done()
                        }
                    }
                }
            }
            
            describe("fetch Accounts matching username") {
                
                it("should return single account") {
                    waitUntil(timeout: 10) { done in
                        client!.fetchAccountsMatchingUsername("foobar") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).toNot(beEmpty())
                            expect(accounts!.count).to(equal(1))
                            done()
                        }
                    }
                }
                
                it("should return nil") {
                    waitUntil(timeout: 10) { done in
                        client!.fetchAccountsMatchingUsername("asdfasdfasdf") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).to(beNil())
                            done()
                        }
                    }
                }
                
                it("should return error when accounts resource doesnt exist") {
                    let c = CinchClient()
                    
                    waitUntil(timeout: 10) { done in
                        c.fetchAccountsMatchingUsername("foobar") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(error!.domain).to(equal(CinchKitErrorDomain))
                            expect(accounts).to(beNil())
                            
                            done()
                        }
                    }
                }
            }
        }
    }
}
