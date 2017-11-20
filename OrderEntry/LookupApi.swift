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
        let baseUrl:String = try ApiHelper.getBaseUrl()
        
        // call the web service and return the result
        let url = "\(baseUrl)/lookupData/productTypes"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        return webServiceResult
    }
    
}

