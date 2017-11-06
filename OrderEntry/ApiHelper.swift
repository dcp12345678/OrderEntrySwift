//
//  ApiHelper.swift
//  OrderEntry
//
//  Created by TechReviews on 11/6/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation

class ApiHelper {
    
    static func getBaseUrl() throws -> String {
        let baseUrl:String = (try Helper.getConfigValue(forKey: "restApi.baseUrl", isRequired: true))!
        return baseUrl as String
    }
}
