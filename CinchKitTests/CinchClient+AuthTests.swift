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
            
            beforeEach {
                LSNocilla.sharedInstance().start()
                LSNocilla.sharedInstance().clearStubs()
                client = CinchClient()
                accountsResource = ApiResource(id: "accounts", href: NSURL(string: "\(client!.server.authServerURL)/accounts")!, title: "get and create accounts")
                client!.rootResources = ["accounts" : accountsResource!]
            }
            
            afterEach {
                LSNocilla.sharedInstance().clearStubs()
                LSNocilla.sharedInstance().stop()
            }
            
            describe("fetch Accounts matching ids") {
                it("should return single account") {
                    var path : NSString = "\(accountsResource!.href.absoluteString!)/.+"
                    var data = CinchKitTestsHelper.loadJsonData("fetchAccount")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(200).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingIds(["c49ef0c0-8610-491d-9bb2-c494d4a52c5c"]) { (accounts, error) in
                            expect(accounts).toNot(beEmpty())
                            expect(error).to(beNil())
                            
                            if let acc = accounts {
                                expect(acc.count).to(equal(1))
                            }
                            
                            done()
                        }
                    }
                }
                
                it("should return 404 not found error") {
                    waitUntil(timeout: 1) { done in
                        var path : NSString = "\(accountsResource!.href.absoluteString!)/.+"
                        var data = CinchKitTestsHelper.loadJsonData("accountNotFound")
                        
                        stubRequest("GET", path.regex())
                            .andReturn(404).withHeader("Content-Type", "application/json").withBody(data)

                        client!.fetchAccountsMatchingIds(["c49ef0c0-8610-491d-9bb2-c494d4a52c5d"]) { (accounts, error) in
                            expect(accounts).to(beNil())
                            expect(error).toNot(beNil())
                            
                            if let err = error {
                                expect(err.domain).to(equal(CinchKitErrorDomain))
                                expect(err.code).to(equal(404))
                            }
                            
                            
                            done()
                        }
                    }
                }
            }
            
            describe("fetch Accounts matching email") {
                
                it("should return single account") {
                    var path : NSString = "\(accountsResource!.href.absoluteString!)\\?email\\=.*"
                    var data = CinchKitTestsHelper.loadJsonData("fetchAccount")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(200).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingEmail("foo@bar.com") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).toNot(beEmpty())
                            expect(accounts!.count).to(equal(1))
                            expect(accounts!.first!.links!.count).to(equal(3))
                            done()
                        }
                    }
                }
                
                it("should return 404 not found error") {
                    var path : NSString = "\(accountsResource!.href.absoluteString!)\\?email\\=.*"
                    var data = CinchKitTestsHelper.loadJsonData("accountNotFound")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(404).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
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
                    
                    waitUntil(timeout: 1) { done in
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
                    var path : NSString = "\(accountsResource!.href.absoluteString!)\\?username\\=.*"
                    var data = CinchKitTestsHelper.loadJsonData("fetchAccount")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(200).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
                        client!.fetchAccountsMatchingUsername("foobar") { (accounts, error) in
                            expect(error).to(beNil())
                            expect(accounts).toNot(beEmpty())
                            expect(accounts!.count).to(equal(1))
                            done()
                        }
                    }
                }
                
                it("should return 404 not found") {
                    var path : NSString = "\(accountsResource!.href.absoluteString!)\\?username\\=.*"
                    var data = CinchKitTestsHelper.loadJsonData("accountNotFound")
                    
                    stubRequest("GET", path.regex())
                        .andReturn(404).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 1) { done in
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
                    
                    waitUntil(timeout: 5) { done in
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
                
                it("should return created account") {
                    var str : NSString = accountsResource!.href.absoluteString!
                    var data = CinchKitTestsHelper.loadJsonData("createAccount")

                    stubRequest("POST", str).andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.createAccount(["email" : "foo23@bar.com", "username" : "foobar23", "name" : "foobar"]) { (account, error) in
                            expect(error).to(beNil())
                            expect(account).toNot(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            
                            done()
                        }
                    }
                }
            }
            
            describe("refreshSession") {
                
                it("should return new session") {
                    var data = CinchKitTestsHelper.loadJsonData("createToken")

                    var token = CinchKitTestsHelper.validAuthToken()
                    
                    client!.session.accessTokenData = token
                    
                    stubRequest("POST", token.href.absoluteString).withHeader("Authorization", "Bearer \(token.refresh)")
                        .andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.refreshSession { (account, error) in
                            expect(error).to(beNil())
                            expect(account).to(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            expect(client!.session.accessTokenData!.expires.timeIntervalSince1970).to(equal(1425950710.000))
                            
                            done()
                        }
                    }
                }
                
                it("should return new session with account") {
                    var data = CinchKitTestsHelper.loadJsonData("createTokenIncludeAccount")
                    
                    var token = CinchKitTestsHelper.validAuthToken()
                    
                    client!.session.accessTokenData = token
                    
                    var path : NSString = "\(token.href.absoluteString!)?include=account"
                    stubRequest("POST", path).withHeader("Authorization", "Bearer \(token.refresh)")
                        .andReturn(201).withHeader("Content-Type", "application/json").withBody(data)
                    
                    waitUntil(timeout: 2) { done in
                        
                        client!.refreshSession(includeAccount : true) { (account, error) in
                            expect(error).to(beNil())
                            expect(account).toNot(beNil())
                            expect(client!.session.accessTokenData).toNot(beNil())
                            expect(client!.session.accessTokenData!.expires.timeIntervalSince1970).to(equal(1425950710.000))
                            
                            done()
                        }
                    }
                }
            }
        }
    }
}
