//
//  ApiHelper.swift
//  OrderEntry
//
//  Created by TechReviews on 11/6/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation
import UIKit

class ApiHelper {
    
    private static var baseUrl: String = ""
    
    static var imageCache = [String: UIImage]()

    static func getBaseUrl() throws -> String {
        if baseUrl == "" {
            baseUrl = (try Helper.getConfigValue(forKey: "restApi.baseUrl", isRequired: true))!
        }
        return baseUrl as String
    }
}
