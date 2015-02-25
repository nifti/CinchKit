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
            var accountsResource : ApiResource?
            
//            beforeSuite {
//                LSNocilla.sharedInstance().start()
//            }
//            
//            afterSuite {
//                LSNocilla.sharedInstance().stop()
//            }
            
            beforeEach {
                client = CinchClient()
                accountsResource = ApiResource(id: "accounts", href: NSURL(string: "\(client!.server.authServerURL)/accounts")!, title: "get and create accounts")
                client!.rootResources = ["accounts" : accountsResource!]
            }
            
            afterEach {
//                LSNocilla.sharedInstance().clearStubs()
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
                
                it("should return 404 not found error") {
                    waitUntil(timeout: 10) { done in
                        client!.fetchAccountsMatchingEmail("asdfasdfasdf") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(accounts).to(beNil())
                            
                            expect(error!.code).to(equal(404))
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
                
                it("should return 404 not found") {
                    waitUntil(timeout: 10) { done in
                        client!.fetchAccountsMatchingUsername("asdfasdfasdf") { (accounts, error) in
                            expect(error).toNot(beNil())
                            expect(accounts).to(beNil())
                            
                            expect(error!.code).to(equal(404))
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
            
            describe("create account") {
                
                beforeEach {
                    LSNocilla.sharedInstance().start()
                }
                
                afterEach {
                    LSNocilla.sharedInstance().clearStubs()
                    LSNocilla.sharedInstance().stop()
                }
                
                it("should return created account") {
                    var str : NSString = accountsResource!.href.absoluteString!
                    
                    var filepath = NSBundle(forClass: CinchClientAuthSpec.self).pathForResource("createAccount", ofType: "json")
                    var data = NSData(contentsOfFile: filepath!)

                    stubRequest("POST", str).andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 10) { done in
                        
                        client!.createAccount(["email" : "foo23@bar.com", "username" : "foobar23", "name" : "foobar"]) { (account, error) in
                            expect(error).to(beNil())
                            expect(account).toNot(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            
                            done()
                        }
                    }
                }
            }
            
        }
    }
}
