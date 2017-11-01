//
//  LoginViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func loginOnPress(_ sender: Any) {
        
        do {
            
            Helper.showPleaseWaitOverlay(parentController: self)

            let baseUrl:String? = try Helper.getConfigValue(forKey: "restApi.baseUrl", isRequired: true)
            
            async({ _ -> Any? in
                
                do {
                    let val = try await(in: .background, Helper.callWebService(withUrl: "https://jsonplaceholder.typicode.com/users",
                                                                               httpMethod: "GET", httpBody: nil))
                    
                    let parameters = ["username": "@joey", "tweet": "HelloWorld"]
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                        throw OrderEntryError.webServiceError(msg: "Unable to serialize parameters to JSON")
                    }
                    
                    let val2 = try await(in: .background, Helper.callWebService(withUrl: "https://jsonplaceholder.typicode.com/posts",
                                                                                httpMethod: "POST", httpBody: httpBody))
                    
                    print(val!)
                    print(val2!)
                    return val
                } catch OrderEntryError.testError(let msg) {
                    print("Got OrderEntryError.testError: msg = \(msg)");
                    return ""
                } catch {
                    print("Got some other error: error = \(error)");
                    return ""
                }
            }).then({res in
                print("final result = \(res)")
                Helper.hidePleaseWaitOverlay() { self.performSegue(withIdentifier: "goToMainScreen", sender: self) }
                
            })
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.hidePleaseWaitOverlay(completion: nil)
            Helper.showError(parentController: self, errorMessage: "Configuration error: \(msg)")
        } catch {
            Helper.hidePleaseWaitOverlay(completion: nil)
            Helper.showError(parentController: self, errorMessage: "Unexpected error: \(error)")
        }
        
        
        
    }
}
