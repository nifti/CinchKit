//
//  ApiResourcesSerializer.swift
//  CinchKit
//
//  Created by Ryan Fitzgerald on 2/12/15.
//  Copyright (c) 2015 cinch. All rights reserved.
//

import Foundation
import SwiftyJSON

class ApiResourcesSerializer : JSONObjectSerializer {
    
    func jsonToObject(json: SwiftyJSON.JSON) -> [String : ApiResource]? {
        return self.decodeResources(json)
    }

    internal func decodeResources(json : JSON) -> [String : ApiResource]? {
        if let resources = json["resources"].array?.map(self.decodeResource) {
            return self.indexById(resources)
        } else {
            return nil
        }
    }
    
    internal func decodeResource(json : JSON) -> ApiResource {
        return ApiResource(
            id: json["id"].stringValue,
            href: json["href"].URL!,
            title: json["title"].stringValue
        )
    }
    
    internal func indexById(data : [ApiResource]) -> [String : ApiResource] {
        var result = [String : ApiResource]()
        
        for item in data {
            result[item.id] = item
        }
        
        return result
    }
}