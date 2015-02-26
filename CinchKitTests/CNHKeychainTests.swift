//
//  CNHKeychainTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation

import Quick
import Nimble
import CinchKit

class CinchKeychainSpec: QuickSpec {
    private func validAuthToken() -> CNHAccessTokenData {
        let expires = NSDate().dateByAddingTimeInterval(300)
        
         return CNHAccessTokenData(
            accountID : "123456",
            href : NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com/tokens")!,
            access : "asdfhasjdhfasdf",
            refresh : "rrrrrrrrrrrreeeeeeeeeffffrrrrrrreeeeeeessshhhhhhhhhh",
            type : "Bearer",
            expires : expires
        )
    }
    
    override func spec() {
        var keychain : CNHKeychain?
        
        beforeEach {
            keychain = CNHKeychain()
            keychain!.clear()
        }
        
        describe("save") {
            
            it("should save token data") {
                let err = keychain!.save(self.validAuthToken())
                
                expect(err).to(beNil())
            }
            
        }
        
        describe("load") {
            
            it("should load saved token data") {
                let savedToken = self.validAuthToken()
                let err = keychain!.save(savedToken)
                
                expect(err).to(beNil())
                
                var data = keychain!.load()
                expect(data).toNot(beNil())
                
                expect(data!.accountID).to(equal(savedToken.accountID))
                expect(data!.access).to(equal(savedToken.access))
                expect(data!.refresh).to(equal(savedToken.refresh))
                expect(data!.type).to(equal(savedToken.type))
                expect(data!.href).to(equal(savedToken.href))
            }
            
            it("should return nil after clearing keychain") {
                let err = keychain!.save(self.validAuthToken())
                expect(err).to(beNil())
                
                keychain!.clear()
                
                var data = keychain!.load()
                expect(data).to(beNil())
            }
        }
    }
}