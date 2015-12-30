//
//  CinchClient+Accounts.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 29/12/15.
//  Copyright © 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func fetchAccountsMatchingIds(ids: [String], completionHandler: ([CNHAccount]?, NSError?) -> ()) {
        self.fetchAccountsMatchingParams(["ids": ids], completionHandler: completionHandler)
    }

    public func fetchAccountsMatchingEmail(email : String, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        self.fetchAccountsMatchingParams(["email" : email], completionHandler: completionHandler)
    }

    public func fetchAccountsMatchingUsername(username : String, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        self.fetchAccountsMatchingParams(["username" : username], completionHandler: completionHandler)
    }

    public func createAccount(parameters: [String : AnyObject], completionHandler : ((CNHAccount?, NSError?) -> ())?) {
        let serializer = CreateAccountSerializer()

        if let accounts = self.rootResources?["accounts"] {
            request(.POST, accounts.href, parameters: parameters, serializer: serializer) { (auth, error) in
                if let _ = error {
                    completionHandler?(nil, error)
                } else if let a = auth {
                    self.setActiveSession(a.accessTokenData)
                    completionHandler?(a.account, nil)
                } else {
                    completionHandler?(nil, nil)
                }
            }
        } else {
            completionHandler?(nil, clientNotConnectedError())
        }
    }

    public func updateAccount(atURL url : NSURL, parameters: [String : AnyObject], queue: dispatch_queue_t? = nil, completionHandler : ((CNHAccount?, NSError?) -> ())?) {
        let serializer = AccountsSerializer()

        authorizedRequest(.PUT, url, parameters: parameters, queue: queue, serializer: serializer) { (accounts, error) in
            if let _ = error {
                completionHandler?(nil, error)
            } else if let account = accounts?.first {
                completionHandler?(account, nil)
            } else {
                completionHandler?(nil, nil)
            }
        }
    }

    public func deleteAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        authorizedRequest(.DELETE, url, parameters: nil, queue: queue, serializer: serializer) { (_, error) in
            completionHandler?(nil, error)
        }
    }

    public func checkBlockedAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : (Bool?, NSError?) -> ()) {
        let serializer = FetchAccountsSerializer()

        authorizedRequest(.GET, url, parameters: nil, queue: queue, serializer: serializer) { (accounts, error) in
            var blocked = false
            if accounts != nil {
                blocked = true
            }

            completionHandler(
                error == nil || error!.code == 404 ? blocked : nil,
                error != nil && error!.code != 404 ? error : nil
            )
        }
    }

    public func blockAccount(atURL url : NSURL, accountId: String, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        let params: [String: AnyObject] = ["blockedAccountId": accountId]

        authorizedRequest(.POST, url, parameters: params, queue: queue, serializer: serializer) { (_, error) in
            completionHandler?(nil, error)
        }
    }

    public func unblockAccount(atURL url : NSURL, queue: dispatch_queue_t? = nil, completionHandler : ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        authorizedRequest(.DELETE, url, parameters: nil, queue: queue, serializer: serializer) { (_, error) in
            completionHandler?(nil, error)
        }
    }

    internal func fetchAccountsMatchingParams(var params : [String : AnyObject]?, completionHandler : ([CNHAccount]?, NSError?) -> ()) {
        if let accounts = self.rootResources?["accounts"] {
            var accountsUrl: NSURL = accounts.href

            // Remove ids from query params because of ids should be passed in path
            if let ids = params?["ids"] as? [String] {
                accountsUrl = NSURL(string: accountsUrl.absoluteString + "/" + ids.joinWithSeparator(","))!
                params?.removeValueForKey("ids")
            }

            let serializer = FetchAccountsSerializer()
            request(.GET, accountsUrl, parameters: params, encoding: .URL , serializer: serializer, completionHandler: completionHandler)
        } else {
            return completionHandler(nil, clientNotConnectedError())
        }
    }
}
