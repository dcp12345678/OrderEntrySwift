//
//  OrdersApi.swift
//  OrderEntry
//
//  Created by TechReviews on 11/6/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation

class OrdersApi {
    
    static func getOrders(forUserID userID: Int64) throws -> Any? {
        let baseUrl:String = try ApiHelper.getBaseUrl()
        
        // call the web service and return the result
        let url = "\(baseUrl)/orderData/user/\(userID)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        return webServiceResult
    }
    
    static func getOrderLineItems(forOrderID orderID: Int64) throws -> [[String: Any]] {
        let baseUrl:String = try ApiHelper.getBaseUrl()
        
        // call the web service and return the result
        let url = "\(baseUrl)/orderData/lineItems/\(orderID)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        //print("webServiceResult = \(webServiceResult)")
        var ret = [[String: Any]]()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                var lineItem = [String: Any]()
                lineItem["id"] = elem["id"] as! Int64
                lineItem["productName"] = elem["productName"] as! String
                lineItem["colorID"] = elem["colorId"] as! Int64
                lineItem["colorName"] = elem["colorName"] as! String
                lineItem["productTypeID"] = elem["productTypeId"] as! Int64
                lineItem["productTypeName"] = elem["productTypeName"] as! String
                print("\(lineItem)")
                ret.append(lineItem)
            }
        }
        //ret["productID"] = dict!["productId"]
        
        return ret
    }
    
}
