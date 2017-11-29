//
//  OrdersApi.swift
//  OrderEntry
//
//  Created by TechReviews on 11/6/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation

class OrdersApi {
    
    static func getOrder(forOrderId orderId: Int64) throws -> NSMutableDictionary {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/\(orderId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        
        let ret = NSMutableDictionary()
        if let elem = webServiceResult as? [String: Any] {
            ret["id"] = elem["id"] as! Int64
            ret["userId"] = elem["userId"] as! Int64
            ret["createDate"] = Helper.formatDate(fromDateString: elem["createDate"] as! String)
            ret["updateDate"] = Helper.formatDate(fromDateString: elem["updateDate"] as! String)
            var lineItems = [NSMutableDictionary]()
            if let lineItemsSource = elem["lineItems"] as? [[String: Any]] {
                for lineItemElem in lineItemsSource {
                    lineItems.append(loadLineItem(from: lineItemElem))
                }
            }
            ret["lineItems"] = lineItems
        }
        return ret
    }
    
    static func getOrders(forUserId userId: Int64) throws -> Any? {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/user/\(userId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        return webServiceResult
    }
    
    static func getOrderLineItems(forOrderId orderId: Int64) throws -> [NSMutableDictionary] {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/lineItems/\(orderId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        //print("webServiceResult = \(webServiceResult)")
        var ret = [NSMutableDictionary]()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                ret.append(loadLineItem(from: elem))
            }
        }
        //ret["productID"] = dict!["productId"]
        
        return ret
    }
    
    private static func loadLineItem(from source: [String: Any]) -> NSMutableDictionary {
        let lineItem = NSMutableDictionary()
        lineItem["id"] = source["id"] as! Int64
        lineItem["productId"] = source["productId"] as! Int64
        lineItem["productName"] = source["productName"] as! String
        lineItem["productImageUri"] = source["productImageUri"] as! String
        lineItem["colorId"] = source["colorId"] as! Int64
        lineItem["colorName"] = source["colorName"] as! String
        lineItem["productTypeId"] = source["productTypeId"] as! Int64
        lineItem["productTypeName"] = source["productTypeName"] as! String
        print("\(lineItem)")
        return lineItem
    }
    
    static func saveOrder(_ order: NSMutableDictionary) throws -> Any? {
        // change the dates to strings since the SwiftyJSON parser doesn't work with Dates
        order["createDate"] = Helper.convertDateToString(fromDate: order["createDate"] as! Date)
        order["updateDate"] = Helper.convertDateToString(fromDate: order["updateDate"] as! Date)
        
        let json = JSON(order)
        let id = json["id"].int64
        if let stringJSON = json.rawString(String.Encoding.utf8, options: []) {
            print(stringJSON)
        }
        let url = "\(try ApiHelper.getBaseUrl())/orderData/save/"

        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "POST", httpBody: json.rawData(options: []))
        return webServiceResult
    }
    
}
