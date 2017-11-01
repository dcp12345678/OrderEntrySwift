//
//  Helper.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation
import UIKit

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
    
    
    static func callWebService(withUrl url: String, httpMethod: String, httpBody: Data?) -> Promise<Any?> {
        let promise = Promise<Any?>(in: .background, { resolve, reject, _ in
            
            // make sure URL is valid
            guard let webServiceUrl = URL(string: url) else {
                reject(OrderEntryError.invalidUrl(url: url))
                return
            }
            
            // prepare the http request
            var request = URLRequest(url: webServiceUrl)
            request.httpMethod = httpMethod
            if let httpBody = httpBody {
                request.httpBody = httpBody
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            let session = URLSession.shared
            
            // create the task to make the web service call asynchronously
            session.dataTask(with: request) { (data, response, error) in
                if let response = response {
                    print(response)
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                        resolve(json)
                    } catch {
                        print(error)
                        reject(OrderEntryError.webServiceError(msg: "Error serializing JSON result returned from web service"))
                        return
                    }
                }
                
            }.resume()
        })
        return promise;
    }

    static func showError(parentController: UIViewController, errorMessage: String) {
        print("inside showError, errorMesage = \(errorMessage)")
        let controller = UIAlertController(
            title:"Something went wrong!",
            message: errorMessage, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        controller.addAction(cancelAction)
        parentController.present(controller, animated: true, completion: nil)
    }
    

    static func showPleaseWaitOverlay(parentController: UIViewController, waitMessage: String = "Please wait...") {
        pleaseWaitController = UIAlertController(title: nil, message: waitMessage, preferredStyle: .alert)
            
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
            
        pleaseWaitController!.view.addSubview(loadingIndicator)
        parentController.present(pleaseWaitController!, animated: true, completion: nil)
    }
    
    static func hidePleaseWaitOverlay(completion: (() -> Void)?) {
        pleaseWaitController?.dismiss(animated: true, completion: completion)
        pleaseWaitController = nil
    }
    
    static func hidePleaseWaitOverlay() -> Promise<Void> {
        return Promise<Void>(in: .background, { resolve, reject, _ in
            pleaseWaitController?.dismiss(animated: true) { resolve() }
        })
    }
    
    static func testPromise() -> Promise<Int> {
        return Promise<Int>(in: .background, { resolve, reject, _ in
            Thread.sleep(forTimeInterval: 2.0)
            let ret = 42
            //throw OrderEntryError.webServiceError(msg: "this is a test error message")
            resolve(ret)
        })
    }}
