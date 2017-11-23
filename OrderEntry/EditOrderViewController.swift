//
//  EditOrderTableViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

class LineItemTableViewCell: UITableViewCell {
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductColor: UILabel!
    @IBOutlet weak var lblProductType: UILabel!
    @IBOutlet weak var lblLineItemID: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    public var lineItem = NSMutableDictionary()
    
    func setCellState(isSelected: Bool) {
        lineItem["isSelected"] = isSelected
        if (lineItem["isSelected"] as! Bool) == true {
            btnSelect.setTitle(String.fontAwesomeIcon(name: .checkCircle), for: .normal)
        } else {
            btnSelect.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
        }
    }
    
    @IBAction func onBtnSelectTapped(_ sender: Any) {
        // toggle the selection state
        setCellState(isSelected: !(lineItem["isSelected"] as! Bool))
    }
}

class EditOrderViewController: UITableViewController {

    @IBOutlet var tblLineItems: UITableView!
    let lineItemCellIdentifier = "LineItem"
    var orderID: Int64 = -1
    var lineItems = [NSMutableDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Order (\(orderID))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            tblLineItems.separatorColor = UIColor.white
            tblLineItems.separatorInset = .zero
            tblLineItems.layoutMargins = .zero

            lineItems = try OrdersApi.getOrderLineItems(forOrderID: self.orderID)
            for lineItem in lineItems {
                lineItem["isSelected"] = false
            }
            tblLineItems.reloadData()
        } catch OrderEntryError.webServiceError(let msg) {
            Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
        } catch {
            Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lineItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: lineItemCellIdentifier, for: indexPath)
            as! LineItemTableViewCell

        // Configure the cell...
        let lineItem = lineItems[indexPath.row]
        cell.lineItem = lineItem
        cell.lblProductName.text = lineItem["productName"] as? String
        cell.lblProductColor.text = "Color: " + (lineItem["colorName"] as! String)
        cell.lblProductType.text = "Type: " + (lineItem["productTypeName"] as! String)
        cell.lblLineItemID.text = "Line Item ID: " + String(describing: (lineItem["id"] as! Int64))
        cell.imgProduct.layer.borderWidth = 2
        cell.imgProduct.layer.borderColor =
            UIColor(red: 0.0 / 255.0, green: 0.0 / 255.0, blue: 157.0 / 255.0, alpha: 1.0).cgColor
        cell.btnSelect.titleLabel?.font = UIFont.fontAwesome(ofSize: 20)
        cell.btnSelect.setTitle(String.fontAwesomeIcon(name: .circleO), for: .normal)
        cell.setCellState(isSelected: lineItem["isSelected"] as! Bool)
        
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
                            Helper.showError(parentController: self, errorMessage: msg)
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
            Helper.showError(parentController: self, errorMessage: "\(error)")
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
