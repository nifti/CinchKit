//
//  CinchClient+Purchases.swift
//  CinchKit
//
//  Created by Mikhail Vetoshkin on 10/12/15.
//  Copyright © 2015 cinch. All rights reserved.
//


extension CinchClient {
    public func createPurchase(product: CNHPurchaseProduct, metadata: [String: AnyObject]?, queue: dispatch_queue_t? = nil, completionHandler: ((CNHPurchase?, NSError?) -> ())?) {
        let serializer = PurchaseSerializer()

        if let purchases = self.rootResources?["purchases"] {
            var params: [String: AnyObject] = ["productId": product.rawValue]
            if let md = metadata {
                params["metadata"] = md
            }

            authorizedRequest(.POST, purchases.href, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler?(nil, self.clientNotConnectedError())
            })
        }
    }

    public func updatePurchase(receipt: String, sandbox: Bool = false, queue: dispatch_queue_t? = nil, completionHandler: ((CNHPurchase?, NSError?) -> ())?) {
        let serializer = PurchaseSerializer()

        if let purchases = self.rootResources?["purchases"] {
            let params: [String: AnyObject] = [
                "receipt": receipt,
                "sandbox": sandbox
            ]
            authorizedRequest(.PUT, purchases.href, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler?(nil, self.clientNotConnectedError())
            })
        }
    }

    public func deletePurchase(product: CNHPurchaseProduct, queue: dispatch_queue_t? = nil, completionHandler: ((String?, NSError?) -> ())?) {
        let serializer = EmptyResponseSerializer()

        if let purchases = self.rootResources?["purchases"] {
            let params: [String: AnyObject] = ["productId": product.rawValue]
            authorizedRequest(.DELETE, purchases.href, parameters: params, queue: queue, serializer: serializer, completionHandler: completionHandler)
        } else {
            dispatch_async(queue ?? dispatch_get_main_queue(), {
                completionHandler?(nil, self.clientNotConnectedError())
            })
        }
    }
}