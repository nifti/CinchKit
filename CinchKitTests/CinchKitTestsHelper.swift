//
//  CinchKitTestsHelper.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/26/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import CinchKit

class CinchKitTestsHelper {
    
    class func loadJsonData(filename : String) -> NSData? {
        let filepath = NSBundle(forClass: CinchKitTestsHelper.self).pathForResource(filename, ofType: "json")
        return NSData(contentsOfFile: filepath!)
    }
    
    class func validAuthToken() -> CNHAccessTokenData {
        let expires = NSDate().dateByAddingTimeInterval(300)
        
        return CNHAccessTokenData(
            accountID : "123456",
            href : NSURL(string: "http://cinchauth-dev-krttxjjzkv.elasticbeanstalk.com/tokens")!,
            access : "asdfhasjdhfasdf",
            refresh : "rrrrrrrrrrrreeeeeeeeeffffrrrrrrreeeeeeessshhhhhhhhhh",
            type : "Bearer",
            expires : expires,
            cognitoId : "us-east-1:919501dd-5909-4ffd-9014-46a97f914dc9",
            cognitoToken : "eyJraWQiOiJ1cy1lYXN0LTExIiwidHlwIjoiSldTIiwiYWxnIjoiUlM1MTIifQ"
        )
    }

    class func setTestUserSession(client: CinchClient) -> Void {
        let authServerURL = NSURL(string: "http://auth-service-jgjfpv9gvy.elasticbeanstalk.com/")!
        let accountsResource = ApiResource(id: "accounts", href: NSURL(string: "\(authServerURL)/accounts")!, title: "get and create accounts")
        let tokensResource = ApiResource(id: "tokens", href: NSURL(string: "\(authServerURL)/tokens")!, title: "Create and refresh authentication tokens")
        client.rootResources = ["accounts" : accountsResource, "tokens" : tokensResource]

        let refreshToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyIjoiNzJkMjVmZjktMWQzNy00ODE0LWIyYmQtYmMxNDljMjIyMjIwIiwic2NvcGUiOlsicmVmcmVzaHRva2VuIl0sImlhdCI6MTQzNzY2NzI1OX0.zqqSGmpcNZz-6lmO_ejTOYZuKLcp__l1yRUtWQcYxYg"
        client.session.accessTokenData = CNHAccessTokenData(accountID: "",
            href: NSURL(string: "http://auth-service-jgjfpv9gvy.elasticbeanstalk.com/tokens")!,
            access: "", refresh: refreshToken, type: "Bearer", expires: NSDate(), cognitoId: "", cognitoToken: ""
        )
    }

    class func getTestUserId() -> String {
        return "72d25ff9-1d37-4814-b2bd-bc149c222220"
    }
}