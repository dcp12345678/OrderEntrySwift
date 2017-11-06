//
//  Helper.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation
import UIKit


extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
}

class Helper {
    
    static var pleaseWaitController: UIViewController?
    
    static func getConfigValue<T>(forKey key: String, isRequired: Bool) throws -> T? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist") else {
            throw OrderEntryError.configurationError(msg: "Error reading from Config.plist. Make sure file is present")
        }
        
        guard let dict = NSDictionary(contentsOfFile: path) else {
            throw OrderEntryError.configurationError(msg: "Error creating dictionary from Config.plist file")
        }

        guard let val = dict[key] as? T else {
            if (isRequired) {
                throw OrderEntryError.configurationError(msg: "Missing or invalid configuration value for key = \(key)")
            }
            return nil
        }
        return val
    }
    
    
    static func callWebService(withUrl url: String, httpMethod: String, httpBody: Data?) throws -> Any? {
        // make sure URL is valid
        guard let webServiceUrl = URL(string: url) else {
            throw OrderEntryError.urlError(url: url)
        }
            
        // prepare the http request
        var request = URLRequest(url: webServiceUrl)
        request.httpMethod = httpMethod
        if let httpBody = httpBody {
            request.httpBody = httpBody
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
            
        let session = URLSession.shared
        
        let group = DispatchGroup()
        group.enter()
        let queue = DispatchQueue.global(qos: .default)
        
        var json: Any = "No Result"
        var err: OrderEntryError? = nil
        
        queue.async {
            // create the task to make the web service call asynchronously
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                        err = OrderEntryError.webServiceError(msg: "Error serializing JSON result returned from web service")
                    }
                }
                
                group.leave()
                
            }.resume()
        }
        
        print("calling group.wait")
        group.wait()
        print("done calling group.wait")
        
        if err != nil {
            throw err!
        }
        
        return json
    }

    static func showError(parentController: UIViewController, errorMessage: String, title: String = "Something went wrong!") {
        print("inside showError, errorMesage = \(errorMessage)")
        let controller = UIAlertController(
            title: title,
            message: errorMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        parentController.present(controller, animated: true, completion: nil)
    }
    

    static func showPleaseWaitOverlay(parentController: UIViewController, waitMessage: String = "Please wait...",
                                      completion: (() -> Void)?) {
        pleaseWaitController = UIAlertController(title: nil, message: waitMessage, preferredStyle: .alert)
            
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        pleaseWaitController!.view.addSubview(loadingIndicator)
        
        parentController.present(pleaseWaitController!, animated: false, completion: completion)
    }
    
    static func hidePleaseWaitOverlay(completion: (() -> Void)? = nil) {
        if pleaseWaitController != nil {
            pleaseWaitController!.dismiss(animated: false, completion: completion)
            pleaseWaitController = nil
        }
    }
    
    static func checkForNilOrEmpty(forField fieldName: String, fieldValue: String?) throws {
        guard let text = fieldValue,
                  !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            throw OrderEntryError.inputValueError(msg: "You must enter a value for \(fieldName)")
        }
    }
}
