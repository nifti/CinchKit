//
//  CinchClient+CommonTests.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 26/01/16.
//  Copyright © 2016 cinch. All rights reserved.
//

import Alamofire
import CinchKit
import Nimble
import Quick


class CinchClientCommonSpec: QuickSpec {
    override func spec() {

        describe("fetching deeplinks") {
            let c = CinchClient()

            let d = ApiResource(id: "deeplinks", href: NSURL(string: "http://identity-service-hjvmj2uhdj.elasticbeanstalk.com/deeplinks")!, title: "Deeplinks")
            c.rootResources = ["deeplinks": d]

            it("should fetch deeplinks") {
                waitUntil(timeout: 10) { done in
                    let deeplink = "cinchpolls://users?ids=1234567890"
                    let params: [String: AnyObject] = [
                        "deviceType": UIDevice.currentDevice().model,
                        "osVersion": UIDevice.currentDevice().systemVersion.stringByReplacingOccurrencesOfString(".", withString: "_"),
                        "deviceWidth": CGRectGetWidth(UIScreen.mainScreen().bounds),
                        "deviceHeight": CGRectGetHeight(UIScreen.mainScreen().bounds),
                        "deeplink": deeplink
                    ]

                    Alamofire.request(.POST, d.href.absoluteString, parameters: params).responseJSON { response in
                        print("Response JSON: \(response.result.value)")

                        c.fetchDeeplinks(completionHandler: { (links, error) -> () in
                            expect(error).to(beNil())
                            expect(links).toNot(beEmpty())
                            expect(links?.first!.href.absoluteString).to(equal(deeplink))

                            done()
                        })
                    }
                }
            }
        }
    }
}
