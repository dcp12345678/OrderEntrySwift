//
//  EditOrderLineItemViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 12/7/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

class EditOrderLineItemViewController: UITableViewController {

    @IBOutlet var tblOrderLineItem: UITableView!
    @IBOutlet weak var productTypeCell: UITableViewCell!
    @IBOutlet weak var productCell: UITableViewCell!
    @IBOutlet weak var productColorCell: UITableViewCell!
    
    @IBOutlet weak var lblProductType: UILabel!
    @IBOutlet weak var lblProduct: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    
    var orderId: Int64 = -1
    var orderLineItemId: Int64 = -1
    var orderLineItem: NSMutableDictionary?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let chevron = UIImage(named: "chevron2")!
        let resizedImage = Helper.resizeImage(image: chevron, targetSize: CGSize(width:20, height: 20))
        productTypeCell.accessoryView = UIImageView(image: resizedImage)
        productCell.accessoryView = UIImageView(image: resizedImage)
        productColorCell.accessoryView = UIImageView(image: resizedImage)
        
        tblOrderLineItem.separatorColor = UIColor.white
        tblOrderLineItem.separatorInset = .zero
        tblOrderLineItem.layoutMargins = .zero
        
        self.title = (orderLineItemId == -1 ? "Add" : "Edit") + " Line Item"
        
        // create button for cancelling the edit
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self,
                                                                action: #selector(cancelOnPress))

        do {
            if orderLineItem == nil {
                if orderLineItemId == -1 {
                    // new order line item
                    lblProductType.text = ""
                    lblProduct.text = ""
                    lblColor.text = ""
                    orderLineItem = NSMutableDictionary()
                    orderLineItem!["productTypeId"] = -1
                    orderLineItem!["productId"] = -1
                    orderLineItem!["colorId"] = -1
                } else {
                    // retrieve the order line item from persistence so we have latest version
                    orderLineItem = try OrdersApi.getOrderLineItem(orderId: orderId, orderLineItemId: orderLineItemId)
                    if let orderLineItem = orderLineItem {
                        NSLog("orderLineItem = \(orderLineItem)")
                        lblProductType.text = orderLineItem["productTypeName"] as? String
                        lblProduct.text = orderLineItem["productName"] as? String
                        lblColor.text = orderLineItem["colorName"] as? String
                    }
                }
            }

        } catch OrderEntryError.webServiceError(let msg) {
            Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
        } catch {
            Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
        }

    }
    
    @objc func cancelOnPress() {
        //Helper.showMessage(parentController: self, message: "Cancel button tapped!")
        self.navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide save button unless all values have been entered
        btnSave.isHidden = lblProductType.text == "" || lblProduct.text == "" || lblColor.text == ""
        
        if orderLineItem?["productTypeId"] as! Int64 == -1 {
            // no product type was selected yet, so hide product and color cells since those
            // aren't applicable until a product type is selected
            productCell.isHidden = true
            productColorCell.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        do {
            switch segue.identifier! {
            case "product":
                (segue.destination as! PickItemViewController).items = try LookupApi.getProductsForProductType(productTypeId: orderLineItem!["productTypeId"] as! Int64)
                (segue.destination as! PickItemViewController).setSelectedItem = {
                    (selectedItem: NSMutableDictionary) in
                        self.orderLineItem!["productId"] = selectedItem["id"]
                        self.orderLineItem!["productName"] = selectedItem["name"]
                        self.lblProduct.text = selectedItem["name"] as? String
                }
                break
            case "productType":
                (segue.destination as! PickItemViewController).items = try LookupApi.getProductTypes()
                (segue.destination as! PickItemViewController).setSelectedItem = {
                    (selectedItem: NSMutableDictionary) in
                        if self.orderLineItem!["productTypeId"] as! Int64 != selectedItem["id"] as! Int64 {
                            // product type was changed, so clear product and color selections since they
                            // are no longer applicable (e.g. if user changed product type from Car to Truck,
                            // then "Honda Accord" isn't a valid product for product type Truck)
                            self.orderLineItem!["productId"] = -1
                            self.orderLineItem!["productName"] = ""
                            self.orderLineItem!["colorId"] = -1
                            self.orderLineItem!["colorName"] = ""
                            self.lblProduct.text = ""
                            self.lblColor.text = ""
                        }
                        self.orderLineItem!["productTypeId"] = selectedItem["id"]
                        self.orderLineItem!["productTypeName"] = selectedItem["name"]
                        self.lblProductType.text = selectedItem["name"] as? String
                    
                        // now that a product type has been selected, we can show the product and color cells
                        self.productCell.isHidden = false
                        self.productColorCell.isHidden = false
                }
                break
            case "productColor":
                (segue.destination as! PickItemViewController).items = try LookupApi.getColors()
                (segue.destination as! PickItemViewController).setSelectedItem = {
                    (selectedItem: NSMutableDictionary) in
                        self.orderLineItem!["colorId"] = selectedItem["id"]
                        self.orderLineItem!["colorName"] = selectedItem["name"]
                        self.lblColor.text = selectedItem["name"] as? String
                }
                break
            default:
                break
            }
        } catch OrderEntryError.webServiceError(let msg) {
            Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
        } catch {
            Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
        }
    }

    @IBAction func saveOnPress(_ sender: Any) {
        do {
            // fetch existing order from persistence
            let order = try OrdersApi.getOrder(forOrderId: self.orderId)
            let lineItems = order["lineItems"] as! NSMutableArray

            if orderLineItemId == -1 {
                // new line item, so add it
                let lastItem = lineItems.sorted(by: { (item1: Any, item2: Any) -> Bool in
                    if let item1 = item1 as? NSMutableDictionary, let item2 = item2 as? NSMutableDictionary {
                        return (item1["id"] as! Int64) < (item2["id"] as! Int64)
                    }
                    return true
                }).last as! NSMutableDictionary
                orderLineItem!["id"] = (lastItem["id"] as! Int64) + 1
                lineItems.add(orderLineItem!)
                
            } else {
                // existing line item, so update it - we need to find line item in the existing
                // line item array then load the updated line item
                for i in 0..<(lineItems).count {
                    let lineItem = lineItems[i] as! NSMutableDictionary
                    if (lineItem["id"] as! Int64) == orderLineItemId {
                        // we found the existing line item, so update it with new version
                        lineItems[i] = orderLineItem!
                        print("orderLineItem = \(orderLineItem!)")
                        print("lineItems[\(i)] = \(lineItems[i])")
                        break
                    }
                }
            }
            
            print("\(order)")
            let result = try OrdersApi.saveOrder(order)
            print("\(result)")
            
            self.navigationController?.popViewController(animated: true)

        } catch OrderEntryError.webServiceError(let msg) {
            Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
        } catch {
            Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
        }
    }
}
