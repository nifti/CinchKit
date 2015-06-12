//
//  CNHSessionsTests.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation


import Foundation

import Quick
import Nimble
import CinchKit

class CinchSessionsSpec: QuickSpec {
    override func spec() {
        describe("isOpen") {
            
            it("should return false for session without access token data") {
                let session = CNHSession()
                
                expect(session.isOpen).to(beFalse())
            }
            
            it("should return true for session with access token data") {
                let expires = NSDate().dateByAddingTimeInterval(300)
                
                let tokenData = CNHAccessTokenData(
                    accountID : "123456",
                    href : NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com/tokens")!,
                    access : "asdfhasjdhfasdf",
                    refresh : "rrrrrrrrrrrreeeeeeeeeffffrrrrrrreeeeeeessshhhhhhhhhh",
                    type : "Bearer",
                    expires : expires,
                    cognitoId : "us-east-1:919501dd-5909-4ffd-9014-46a97f914dc9",
                    cognitoToken : "eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ"
                )
                
                let session = CNHSession()
                session.accessTokenData = tokenData
                
                expect(session.isOpen).to(beTrue())
            }
            
        }
    }
}