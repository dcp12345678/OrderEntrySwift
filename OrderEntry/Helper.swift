//
//  Helper.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import Foundation
import UIKit


public extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
    }
    
    func substr(startAt: Int, endAt: Int) -> String {
        let safeEndAt = min(endAt, self.count - 1) // make sure we don't go past end of string!
        let startIndex = self.index(self.startIndex, offsetBy: startAt)
        let endIndex = self.index(self.startIndex, offsetBy: safeEndAt + 1)
        let ret = self[startIndex..<endIndex]
        return String(ret)
    }

    subscript(_ range: NSRange) -> String {
        let start = self.index(self.startIndex, offsetBy: range.lowerBound)
        let end = self.index(self.startIndex, offsetBy: range.upperBound)
        let subString = self[start..<end]
        return String(subString)
    }
}

public extension UIView {
    public func pin(to view: UIView) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -8),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 8),
            topAnchor.constraint(equalTo: view.topAnchor, constant: -8),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8)
        ])
    }
}

public extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

struct Helper {
    
    static let DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    
    static var userId: Int64 = -1
    
    static var wasOrderEdited: Bool = false
    
    private static var pleaseWaitController: UIViewController?
    
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
    
    static func getPicture(fromUrl url: URL, completion: @escaping ((OrderEntryError?, UIImage?) -> Void)) {
        
        let session = URLSession(configuration: .default)
        
        // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
        let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
            // The download has finished.
            if let e = error {
                completion(OrderEntryError.pictureDownloadError(msg: "Error downloading picture: \(e)"), nil)
            } else {
                // No errors found.
                // It would be weird if we didn't have a response, so check for that too.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    if let imageData = data {
                        // Finally convert that Data into an image and do what you wish with it.
                        let image = UIImage(data: imageData)
                        completion(nil, image)
                    } else {
                        completion(OrderEntryError.pictureDownloadError(msg: "Error downloading picture, image is nil"), nil)
                    }
                } else {
                    completion(OrderEntryError.pictureDownloadError(msg: "Error downloading picture, couldn't get response code"), nil)
                }
            }
        }
        
        downloadPicTask.resume()
    }
    
    
    static func callWebService(withUrl url: String, httpMethod: String, httpBody: Data? = nil) throws -> Any? {
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
                if let response = response as? HTTPURLResponse {
                    print(response)
                    print(response.statusCode)
                }
                
                if let data = data {
                    do {
                        json = try JSONSerialization.jsonObject(with: data, options: [])
                        print(json)
                    } catch {
                        print(error)
                        err = OrderEntryError.webServiceError(msg: "Error serializing JSON result returned from web service: \(error)")
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

    static func showMessage(parentController: UIViewController, message: String, title: String = "Info") {
        let controller = UIAlertController(
            title: title,
            message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                         style: .default, handler: nil)
        controller.addAction(okAction)
        parentController.present(controller, animated: true, completion: nil)
    }
    
    static func showYesNoDialog(parentController: UIViewController, message: String, title: String,
                                yesHandler: ((UIAlertAction) -> Void)?, noHandler: ((UIAlertAction) -> Void)? = nil) {
        let controller = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let yesAction = UIAlertAction(title: "Yes", style: .destructive, handler: yesHandler)
        let noAction = UIAlertAction(title: "No", style: .default, handler: noHandler)
        controller.addAction(yesAction)
        controller.addAction(noAction)
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
    
    static func formatDate(fromDateString dateString: String, fromFormat dateFormat: String = DATE_FORMAT) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let date = dateFormatter.date(from: dateString)
        return date
    }
    
    static func convertDateToString(fromDate date: Date, toFormat dateFormat: String = DATE_FORMAT) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: date)
    }
    
    static func saveOrder(order: NSMutableDictionary, parentController: UIViewController, completion: (() -> Void)?) {
        Helper.showPleaseWaitOverlay(parentController: parentController, waitMessage: "Saving order...") {
            do {
                
                //let loginResult = try AuthApi.login(withUsername: self.loginID.text!, andPassword: self.password.text!)
                try OrdersApi.saveOrder(order)
                
                Helper.hidePleaseWaitOverlay(completion: completion)
            } catch OrderEntryError.webServiceError(let msg) {
                Helper.hidePleaseWaitOverlay() {
                    Helper.showError(parentController: parentController, errorMessage: "Error calling web service: msg = \(msg)");
                }
            } catch (OrderEntryError.configurationError(let msg)) {
                Helper.hidePleaseWaitOverlay() {
                    Helper.showError(parentController: parentController, errorMessage: msg, title: "Configuration Error")
                }
            } catch {
                Helper.hidePleaseWaitOverlay() {
                    Helper.showError(parentController: parentController, errorMessage: "Unexpected Error = \(error)");
                }
            }
        }
    }
    
    static func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
