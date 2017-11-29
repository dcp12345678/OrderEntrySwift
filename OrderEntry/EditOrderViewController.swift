//
//  EditOrderTableViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

protocol LineItemTableViewCellDelegate {
    func handleSelectionChanged()
}

class LineItemTableViewCell: UITableViewCell {
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductColor: UILabel!
    @IBOutlet weak var lblProductType: UILabel!
    @IBOutlet weak var lblLineItemId: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    public var lineItem = NSMutableDictionary()
    public var delegate: LineItemTableViewCellDelegate?
    
    func setCellState(isSelected: Bool) {
        lineItem["isSelected"] = isSelected
        if (lineItem["isSelected"] as! Bool) == true {
            btnSelect.setTitle(String.fontAwesomeIcon(name: .checkCircle), for: .normal)
        } else {
            btnSelect.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
        }
        
        delegate?.handleSelectionChanged()
    }
    
    @IBAction func onBtnSelectTapped(_ sender: Any) {
        // toggle the selection state
        setCellState(isSelected: !(lineItem["isSelected"] as! Bool))
    }
}

class LineItemTable: UITableView, UITableViewDataSource, UITableViewDelegate {

    weak var parentController: EditOrderViewController!
    let lineItemCellIdentifier = "LineItem"
    var lineItems = [NSMutableDictionary]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: lineItemCellIdentifier, for: indexPath)
            as! LineItemTableViewCell
        
        // Configure the cell...
        let lineItem = lineItems[indexPath.row]
        cell.lineItem = lineItem
        cell.lblProductName.text = lineItem["productName"] as? String
        cell.lblProductColor.text = "Color: " + (lineItem["colorName"] as! String)
        cell.lblProductType.text = "Type: " + (lineItem["productTypeName"] as! String)
        cell.lblLineItemId.text = "Line Item Id: " + String(describing: (lineItem["id"] as! Int64))
        cell.imgProduct.layer.borderWidth = 2
        cell.imgProduct.layer.borderColor =
            UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 157.0 / 255.0, alpha: 1.0).cgColor
        cell.btnSelect.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        cell.btnSelect.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
        cell.setCellState(isSelected: lineItem["isSelected"] as! Bool)
        cell.delegate = parentController
        
        do {
            // get the image from the cache if we can
            let imageURI = lineItem["productImageUri"] as! String
            if ApiHelper.imageCache.keys.contains(imageURI) {
                cell.imgProduct.image = ApiHelper.imageCache[imageURI]
            } else {
                let urlPath = (try ApiHelper.getBaseUrl()) + imageURI
                let imageURL = URL(string: urlPath)!
                Helper.getPicture(fromUrl: imageURL) { err, image in
                    if err != nil {
                        switch err! {
                        case let .pictureDownloadError(msg):
                            Helper.showError(parentController: self.parentController, errorMessage: msg)
                        default:
                            print("unknown error when downloading picture: \(err!)")
                        }
                    } else {
                        // cache the image so if we need the same image later we don't
                        // have to fetch it
                        ApiHelper.imageCache[imageURI] = image
                        
                        // load the image to the cell
                        DispatchQueue.main.async {
                            cell.imgProduct.image = image
                        }
                    }
                }
            }
        } catch {
            Helper.showError(parentController: self.parentController, errorMessage: "\(error)")
        }
        
        return cell
    }
}

class EditOrderViewController: UIViewController, LineItemTableViewCellDelegate, UITabBarDelegate {
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tblLineItems: LineItemTable!
    var orderId: Int64 = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Order (\(orderId))"
    }
    
    func loadLineItemTable() {
        do {
            let lineItems = try OrdersApi.getOrderLineItems(forOrderId: self.orderId)
            tblLineItems.lineItems = lineItems
            for lineItem in tblLineItems.lineItems {
                lineItem["isSelected"] = false
            }
            tblLineItems.dataSource = tblLineItems
            tblLineItems.delegate = tblLineItems
            
            tblLineItems.reloadData()
            
        } catch OrderEntryError.webServiceError(let msg) {
            Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
        } catch {
            Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBar.delegate = self
        
        tblLineItems.separatorColor = UIColor.white
        tblLineItems.separatorInset = .zero
        tblLineItems.layoutMargins = .zero

        tblLineItems.parentController = self

        loadLineItemTable()
    }

    func hideTabBar() {
        var frame = tabBar.frame
        frame.origin.y = self.view.frame.size.height + (frame.size.height)
        UIView.animate(withDuration: 0.35, animations: {
            self.tabBar.frame = frame
        })
    }
    
    func showTabBar() {
        var frame = tabBar.frame
        frame.origin.y = self.view.frame.size.height - (frame.size.height)
        UIView.animate(withDuration: 0.35, animations: {
            self.tabBar.frame = frame
            if self.tabBar.isHidden {
                self.tabBar.isHidden = false
            }
        })
    }
    
    func handleSelectionChanged() {
        var isAtLeastOneSelected = false
        for lineItem in tblLineItems.lineItems {
            if (lineItem["isSelected"] as! Bool) {
                isAtLeastOneSelected = true
                break
            }
        }
        if isAtLeastOneSelected {
            showTabBar()
        } else {
            hideTabBar()
        }
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item.tag  {
        case 0: // edit
            Helper.showMessage(parentController: self, message: "Edit clicked")
            break
        case 1: // delete
            Helper.showYesNoDialog(parentController: self, message: "Are you sure you want to delete these line items?",
                                   title: "Delete Line Items") { action in
                //Helper.showMessage(parentController: self, message: "They said yes!")
                        
                do {
                    // determine which line items were selected, since we need to delete these line items
                    var selectedLineItemIds = Set<Int64>()
                    for lineItem in self.tblLineItems.lineItems {
                        if lineItem["isSelected"] as! Bool {
                            selectedLineItemIds.insert(lineItem["id"] as! Int64)
                        }
                    }
                    
                    // retrieve the order from persistence so we have latest version
                    let order = try OrdersApi.getOrder(forOrderId: self.orderId)
                    
                    // remove any selected line items from the order since the selected line items need
                    // to be deleted
                    if var orderLineItems = order["lineItems"] as? [NSMutableDictionary] {
                        for ndx in stride(from: orderLineItems.count - 1, to: 0, by: -1) {
                            let orderLineItemId = orderLineItems[ndx]["id"] as! Int64
                            if selectedLineItemIds.contains(orderLineItemId) {
                                orderLineItems.remove(at: ndx)
                            }
                        }
                        order["lineItems"] = orderLineItems
                    }
                    
                    // save the order
                    try OrdersApi.saveOrder(order)
                    
                    // reload the line items table to get the updates
                    self.loadLineItemTable()
                    
                } catch OrderEntryError.webServiceError(let msg) {
                    Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
                } catch (OrderEntryError.configurationError(let msg)) {
                    Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
                } catch {
                    Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
                }
            }
            break
        default:
            break
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
