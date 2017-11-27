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
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/user/\(userID)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        return webServiceResult
    }
    
    static func getOrderLineItems(forOrderID orderID: Int64) throws -> [NSMutableDictionary] {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/lineItems/\(orderID)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        //print("webServiceResult = \(webServiceResult)")
        var ret = [NSMutableDictionary]()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                let lineItem = NSMutableDictionary()
                lineItem["id"] = elem["id"] as! Int64
                lineItem["productID"] = elem["productId"] as! Int64
                lineItem["productName"] = elem["productName"] as! String
                lineItem["productImageUri"] = elem["productImageUri"] as! String
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
    
    static func saveOrder(_ order: NSMutableDictionary) throws -> Any? {
        let url = "\(try ApiHelper.getBaseUrl())/orderData/save/"
        guard let httpBody = try? JSONSerialization.data(withJSONObject: order, options: []) else {
            throw OrderEntryError.webServiceError(msg: "Unable to serialize parameters to JSON")
        }

        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "POST", httpBody: httpBody)
        return webServiceResult
    }
    
}
