//
//  LoginViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var loginID: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
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
            try Helper.checkForNilOrEmpty(forField: "login ID", fieldValue: loginID.text)
            try Helper.checkForNilOrEmpty(forField: "password", fieldValue: password.text)
            
            Helper.showPleaseWaitOverlay(parentController: self, waitMessage: "Logging in...")

            let baseUrl:String = (try Helper.getConfigValue(forKey: "restApi.baseUrl", isRequired: true))!
            
            async({ _ -> Any? in
                
                do {
//                    let val = try await(in: .background, Helper.callWebService(withUrl: "https://jsonplaceholder.typicode.com/users",
//                                                                               httpMethod: "GET", httpBody: nil))
                    
                    let parameters = ["username": self.loginID.text!.trim(), "password": self.password.text!.trim()]
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                        throw OrderEntryError.webServiceError(msg: "Unable to serialize parameters to JSON")
                    }

                    let loginUrl = "\(baseUrl)/auth/login"
                    let val2 = try await(in: .background, Helper.callWebService(
                        withUrl: loginUrl, httpMethod: "POST", httpBody: httpBody))
                    
                    print(val2!)
                    
                    return val2
                } catch OrderEntryError.webServiceError(let msg) {
                    print("Error calling web service: msg = \(msg)");
                    return ""
                } catch {
                    print("Got some other error: error = \(error)");
                    return ""
                }
            }).then({res in
                let dict = res as! [String: Any]
                print("final result = \(dict)")
                if (dict["result"] as! String == "successful login") {
                    // login was successful, so go to main login screen
                    Helper.hidePleaseWaitOverlay() { self.performSegue(withIdentifier: "goToMainScreen", sender: self) }
                } else {
                    Helper.hidePleaseWaitOverlay() {
                        Helper.showError(parentController: self, errorMessage: dict["result"] as! String,
                                         title: "Login Failed")
                    }
                }
            })
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.hidePleaseWaitOverlay() {
                Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
            }
        } catch (OrderEntryError.inputValueError(let msg)) {
            Helper.hidePleaseWaitOverlay() {
                Helper.showError(parentController: self, errorMessage: msg, title: "Invalid Input")
            }
        } catch {
            Helper.hidePleaseWaitOverlay() {
                Helper.showError(parentController: self, errorMessage: error as! String, title: "Unexpected error")
            }
        }
    }
}
