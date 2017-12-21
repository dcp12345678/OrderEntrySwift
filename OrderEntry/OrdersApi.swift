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
            let lineItems = NSMutableArray()
            if let lineItemsSource = elem["lineItems"] as? [[String: Any]] {
                for lineItemElem in lineItemsSource {
                    lineItems.add(loadLineItem(from: lineItemElem))
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
    
    static func getOrderLineItems(forOrderId orderId: Int64) throws -> NSMutableArray {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/lineItems/\(orderId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        //print("webServiceResult = \(webServiceResult)")
        let ret = NSMutableArray()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                ret.add(loadLineItem(from: elem))
            }
        }
        
        return ret
    }
    
    static func getOrderLineItem(orderId: Int64, orderLineItemId: Int64) throws -> NSMutableDictionary {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/orderData/lineItem/\(orderId)/\(orderLineItemId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        //print("webServiceResult = \(webServiceResult)")
        var ret = NSMutableDictionary()
        if let elem = webServiceResult as? [String: Any] {
            ret = loadLineItem(from: elem)
        }
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
    
    static func saveOrder(_ order: NSMutableDictionary) throws -> Int64 {
        // change the dates to strings since the SwiftyJSON parser doesn't work with Dates
        if order["createDate"] != nil {
            order["createDate"] = Helper.convertDateToString(fromDate: order["createDate"] as! Date)
        }
        if order["updateDate"] != nil {
            order["updateDate"] = Helper.convertDateToString(fromDate: order["updateDate"] as! Date)
        }
        
        let json = JSON(order)
        if let stringJSON = json.rawString(String.Encoding.utf8, options: []) {
            print(stringJSON)
        }
        let url = "\(try ApiHelper.getBaseUrl())/orderData/save/"

        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "POST", httpBody: json.rawData(options: []))
        if let elem = webServiceResult as? [String: Any] {
            return elem["orderId"] as! Int64
        }

        return -1
    }
    
}
