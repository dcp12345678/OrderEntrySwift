//
//  LookupApi.swift
//  OrderEntry
//
//  Created by TechReviews on 11/17/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation

class LookupApi {
    
    static func getProductTypes() throws -> [NSMutableDictionary]? {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/lookupData/productTypes"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        var ret = [NSMutableDictionary]()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                let productType = NSMutableDictionary()
                productType["id"] = elem["id"] as! Int64
                productType["name"] = elem["name"] as! String
                ret.append(productType)
            }
        }
        return ret
    }
    
    static func getProductsForProductType(productTypeId: Int64) throws -> [NSMutableDictionary]? {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/lookupData/products/\(productTypeId)"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        var ret = [NSMutableDictionary]()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                let product = NSMutableDictionary()
                product["id"] = elem["id"] as! Int64
                product["name"] = elem["name"] as! String
                ret.append(product)
            }
        }
        return ret
    }

    static func getColors() throws -> [NSMutableDictionary]? {
        // call the web service and return the result
        let url = "\(try ApiHelper.getBaseUrl())/lookupData/colors"
        let webServiceResult = try Helper.callWebService(withUrl: url, httpMethod: "GET")
        var ret = [NSMutableDictionary]()
        if let arr = webServiceResult as? [Any] {
            for case let elem as [String: Any] in arr {
                let color = NSMutableDictionary()
                color["id"] = elem["id"] as! Int64
                color["name"] = elem["name"] as! String
                ret.append(color)
            }
        }
        return ret
    }

}

