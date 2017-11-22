//
//  LookupApi.swift
//  OrderEntry
//
//  Created by TechReviews on 11/17/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation

class LookupApi {
    
    static func getProductTypes() throws -> Any? {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/lookupData/productTypes"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        return webServiceResult
    }
    
}

