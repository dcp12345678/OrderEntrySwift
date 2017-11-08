//
//  OrdersApi.swift
//  OrderEntry
//
//  Created by TechReviews on 11/6/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation

class OrdersApi {
    
    static func getOrders(forUserId userId: Int64) throws -> Any? {
        let baseUrl:String = try ApiHelper.getBaseUrl()
        
        // call the web service and return the result
        let url = "\(baseUrl)/orderData/user/\(userId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        return webServiceResult
    }
    
}
