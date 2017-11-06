//
//  AuthApi.swift
//  OrderEntry
//
//  Created by TechReviews on 11/6/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation


class AuthApi {

    static func login(withUsername username: String, andPassword password: String) throws -> Any? {
        let baseUrl:String = try ApiHelper.getBaseUrl()
        
        // build dictionary of parameters to pass to web service
        let parameters = ["username": username.trim(), "password": password.trim()]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            throw OrderEntryError.webServiceError(msg: "Unable to serialize parameters to JSON")
        }
        
        // call the web service and return the result
        let loginUrl = "\(baseUrl)/auth/login"
        let loginResult = try Helper.callWebService(withUrl: loginUrl, httpMethod: "POST", httpBody: httpBody)
        return loginResult
    }
    
}
