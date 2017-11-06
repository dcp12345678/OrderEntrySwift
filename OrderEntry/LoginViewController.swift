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
            Helper.showPleaseWaitOverlay(parentController: self, waitMessage: "Logging in...") {
                do {
                    try Helper.checkForNilOrEmpty(forField: "login ID", fieldValue: self.loginID.text)
                    try Helper.checkForNilOrEmpty(forField: "password", fieldValue: self.password.text)
                    
                    
                    let baseUrl:String = (try Helper.getConfigValue(forKey: "restApi.baseUrl", isRequired: true))!
                    
                    let parameters = ["username": self.loginID.text!.trim(), "password": self.password.text!.trim()]
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
                        throw OrderEntryError.webServiceError(msg: "Unable to serialize parameters to JSON")
                    }

                    let loginUrl = "\(baseUrl)/auth/login"
                    let loginResult = try Helper.callWebService(withUrl: loginUrl, httpMethod: "POST", httpBody: httpBody)
                    
                    print(loginResult!)

                    Helper.hidePleaseWaitOverlay() {
                        
                        let dict = loginResult as! [String: Any]
                        print("final result = \(dict)")
                        if (dict["result"] as! String == "successful login") {
                            // login was successful, so go to main login screen
                            self.performSegue(withIdentifier: "goToMainScreen", sender: self)
                        } else {
                            // login failed, show the error
                            Helper.showError(parentController: self, errorMessage: dict["result"] as! String,
                                             title: "Login Failed")
                        }
                    }
                } catch OrderEntryError.webServiceError(let msg) {
                    Helper.hidePleaseWaitOverlay() {
                        Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
                    }
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
                        Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
                    }
                }
            }
        }
    }
}
