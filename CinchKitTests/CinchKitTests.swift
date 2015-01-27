//
//  CinchKitTests.swift
//  CinchKitTests
//
//  Created by Ryan Fitzgerald on 1/25/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import UIKit
import XCTest
import Nimble
import CinchKit

class CinchKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStartWithCallback() {
        let client = CinchClient()
        let expectation = expectationWithDescription("GET root resources")

        client.start({
            expect(client.rootResources).toNot(beNil())
            expectation.fulfill()
            return
        })
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testCreateClientWithServer() {
        let s = CNHServer(baseURL : NSURL(string: "http://api.us-east-1.niftiws.com")!)
        
        let client = CinchClient(server: s)
        let expectation = expectationWithDescription("GET root resources")
        
        client.start({
            expect(client.rootResources).toNot(beNil())
            expectation.fulfill()
            return
        })
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
