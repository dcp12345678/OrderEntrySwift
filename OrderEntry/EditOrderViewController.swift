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
}


class EditOrderViewController: UITableViewController {

    @IBOutlet var tblLineItems: UITableView!
    let lineItemCellIdentifier = "LineItem"
    var orderID: Int64 = -1
    var lineItems = [[String: Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Order (\(orderID))"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        do {
            lineItems = try OrdersApi.getOrderLineItems(forOrderID: self.orderID)
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
        cell.lblProductName.text = lineItem["productName"] as? String
        cell.lblProductColor.text = "Color: " + (lineItem["colorName"] as! String)
        cell.lblProductType.text = "Type: " + (lineItem["productTypeName"] as! String)
        cell.lblLineItemID.text = "Line Item ID: " + String(describing: (lineItem["id"] as! Int64))
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
