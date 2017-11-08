//
//  RecentOrdersTableViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit


class OrderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblNumItems: UILabel!
    @IBOutlet weak var lblLastUpdate: UILabel!
}

class RecentOrdersViewController: UITableViewController {
    
    @IBOutlet var ordersTableView: UITableView!
    
    let cellTableIdentifier = "CellTableIdentifier"
    
    var orders: [Any]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        ordersTableView.separatorColor = UIColor.white
        ordersTableView.separatorInset = .zero
        ordersTableView.layoutMargins = .zero
        
        // this step is done to remove the empty cells from end of table view
        ordersTableView.tableFooterView = UIView()
    }
    
    func cellViewTapped(_ sender:UITapGestureRecognizer) {
        let indexPath = NSIndexPath(row: (sender.view?.tag)!, section: 0)
        //Helper.showMessage(parentController: self, message: "inside cellViewTapped, tag = \((sender.view?.tag)!)")
        if let cell = ordersTableView.cellForRow(at: indexPath as IndexPath) as? OrderTableViewCell {
            print("Cell \(cell) has been tapped.")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        do {
            
            let ordersResult = try OrdersApi.getOrders(forUserId: Helper.userId)
            self.orders = ordersResult as? [Any]
            print("final result = \(String(describing: self.orders))")
            self.ordersTableView.reloadData()
            
        } catch OrderEntryError.webServiceError(let msg) {
            Helper.hidePleaseWaitOverlay() {
                Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
            }
        } catch (OrderEntryError.configurationError(let msg)) {
            Helper.hidePleaseWaitOverlay() {
                Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
            }
        } catch {
            Helper.hidePleaseWaitOverlay() {
                Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let orders = orders {
            return orders.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTableIdentifier, for: indexPath)
            as! OrderTableViewCell
        let rowData = orders?[indexPath.row] as? [String: Any]
        let id = rowData?["id"] as! Int64
        cell.lblOrderID.text = "Order: " + String(describing: id)
        let lineItems = rowData?["lineItems"] as! [Any]
        cell.lblNumItems.text = "(" + String(describing: lineItems.count) + " items)"
        cell.cellView.layer.cornerRadius = 10
        cell.contentView.tag = indexPath.row
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.cellViewTapped(_:)))
        cell.contentView.addGestureRecognizer(gesture)
        
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
