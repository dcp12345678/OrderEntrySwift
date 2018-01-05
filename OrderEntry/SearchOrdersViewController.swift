//
//  SearchOrdersViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 12/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

class SearchOrdersViewController: UIViewController {
    
    @IBOutlet weak var txtCreateDateStart: UITextField!    
    @IBOutlet weak var txtCreateDateEnd: UITextField!
    @IBOutlet weak var txtOrderId: UITextField!
    
    var datePickerView = UIDatePicker()
    
    private func createDatePickerInputView() -> UIView {
        //Create the view
        let inputView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 240))
        
        let datePickerView = UIDatePicker(frame: CGRect(x: 0, y: 40, width: 0, height: 0))
        datePickerView.datePickerMode = UIDatePickerMode.date
        inputView.addSubview(datePickerView) // add date picker to UIView
        
        let doneButton = UIButton(frame: CGRect(x: (self.view.frame.size.width/2) - (100/2), y: 0,
                                                width: 100, height: 50))
        doneButton.setTitle("Done", for: UIControlState.normal)
        doneButton.setTitle("Done", for: UIControlState.highlighted)
        doneButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        doneButton.setTitleColor(UIColor.gray, for: UIControlState.highlighted)
        
        inputView.addSubview(doneButton) // add Button to UIView
        
        doneButton.addTarget(self, action: #selector(doneButton(_:)), for: UIControlEvents.touchUpInside) // set button click event
        datePickerView.addTarget(self, action: #selector((handleDatePicker(_:))), for: UIControlEvents.valueChanged)

        return inputView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //let datePicker = UIDatePicker()
        //txtCreateDateStart.inputView = datePicker
        
        // Create the views for the date pickers
        txtCreateDateStart.inputView = createDatePickerInputView()
        txtCreateDateEnd.inputView = createDatePickerInputView()
    }

    @objc func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if txtCreateDateStart.isFirstResponder {
            txtCreateDateStart.text = dateFormatter.string(from: sender.date)
        } else if txtCreateDateEnd.isFirstResponder {
            txtCreateDateEnd.text = dateFormatter.string(from: sender.date)
        }
    }

    @objc func doneButton(_ sender: UIButton) {
        txtCreateDateStart.endEditing(false)
        txtCreateDateEnd.endEditing(false)
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

    @IBAction func searchOnPress(_ sender: Any) {
        performSegue(withIdentifier: "viewOrdersForSearchCriteria", sender: self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "viewOrdersForSearchCriteria" {
            (segue.destination as! ViewOrdersViewController).title = "Search Orders Results"
            var searchCriteria = OrderSearchCriteria()
            searchCriteria.createDateStart = txtCreateDateStart.text!
            searchCriteria.createDateEnd = txtCreateDateEnd.text!
            searchCriteria.orderId = txtOrderId.text! == "" ? -1 : Int64(txtOrderId.text!)!
            (segue.destination as! ViewOrdersViewController).searchCriteria = searchCriteria

        }
    }

}
