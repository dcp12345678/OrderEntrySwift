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
    @IBOutlet weak var lblProductColor: UILabel!
    
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
        
        do {
            if orderLineItem == nil {
                // retrieve the order line item from persistence so we have latest version
                orderLineItem = try OrdersApi.getOrderLineItem(orderId: orderId, orderLineItemId: orderLineItemId)
                if let orderLineItem = orderLineItem {
                    NSLog("orderLineItem = \(orderLineItem)")
                    lblProductType.text = orderLineItem["productTypeName"] as? String
                    lblProduct.text = orderLineItem["productName"] as? String
                    lblProductColor.text = orderLineItem["colorName"] as? String
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
    
    override func viewDidAppear(_ animated: Bool) {
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
                    self.orderLineItem!["productTypeId"] = selectedItem["id"]
                    self.orderLineItem!["productTypeName"] = selectedItem["name"]
                    self.lblProductType.text = selectedItem["name"] as? String
                }
                break
            case "productColor":
                (segue.destination as! PickItemViewController).items = try LookupApi.getColors()
                (segue.destination as! PickItemViewController).setSelectedItem = {
                    (selectedItem: NSMutableDictionary) in
                    self.orderLineItem!["colorId"] = selectedItem["id"]
                    self.orderLineItem!["colorName"] = selectedItem["name"]
                    self.lblProductColor.text = selectedItem["name"] as? String
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
            
            if orderLineItemId == -1 {
                // new line item, so add it
            } else {
                // existing line item, so update it
                var lineItems = order["lineItems"] as! [NSMutableDictionary]
                for i in 0..<(lineItems).count {
                    if (lineItems[i]["id"] as! Int64) == orderLineItemId {
                        // we found the existing line item, so update it with new version
                        lineItems[i] = orderLineItem!
                        print("orderLineItem = \(orderLineItem!)")
                        print("lineItems[\(i)] = \(lineItems[i])")
                        break
                    }
                }
                order["lineItems"] = lineItems
            }
            
            print("\(order)")
            let result = try OrdersApi.saveOrder(order)
            print("\(result)")
        } catch OrderEntryError.webServiceError(let msg) {
            Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
        } catch {
            Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
        }
    }
}
