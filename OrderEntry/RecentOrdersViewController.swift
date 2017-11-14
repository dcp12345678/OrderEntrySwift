//
//  RecentOrdersTableViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit


class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var rootStackView: UIStackView!    
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var lblNumItems: UILabel!
    @IBOutlet weak var lblLastUpdate: UILabel!
    @IBOutlet weak var detailStackView: UIStackView!
    var isExpanded: Bool = false
    @IBOutlet weak var productListTable: ProductListTable!
}

class ProductInfo {
    var name: String = ""
    var count: Int = -1
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

let productInfoArray = [ ProductInfo(name: "Car", count: 3),
                         ProductInfo(name: "Truck", count: 3),
                         ProductInfo(name: "Motorcycle", count: 2)]


class ProductInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productCountLabel: UILabel!
}

class ProductListTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    let productInfoIdentifier = "ProductInfo"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: productInfoIdentifier, for: indexPath)
            as! ProductInfoTableViewCell
        
        let row = indexPath.row
        cell.productNameLabel?.text = productInfoArray[row].name
        cell.productCountLabel?.text = String(describing: productInfoArray[row].count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        print(productInfoArray[row])
    }
}

class RecentOrdersViewController: UITableViewController {
    
    @IBOutlet var ordersTableView: UITableView!
    
    let mainViewIdentifier = "MainView"
    let expandedView = "ExpandedView"
    
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
        
        ordersTableView.rowHeight = UITableViewAutomaticDimension
        ordersTableView.estimatedRowHeight = 120
    }
    
    func cellViewTapped(_ sender:UITapGestureRecognizer) {
        let indexPath = NSIndexPath(row: (sender.view?.tag)!, section: 0)
        //Helper.showMessage(parentController: self, message: "inside cellViewTapped, tag = \((sender.view?.tag)!)")
        if let cell = ordersTableView.cellForRow(at: indexPath as IndexPath) as? OrderTableViewCell {
            print("Cell \(cell) has been tapped.")
            
            if !cell.isExpanded {
                // we need to expand the cell
                let rowData = orders?[indexPath.row] as? [String: Any]
                let id = rowData?["id"] as! Int64
                
                UIView.animate(withDuration: 0.2) {
                    cell.detailStackView.isHidden = false;
                }
                
                
                //var view = SideBySideLabels.instanceFromNib()
                //cell.itemsStackView.addArrangedSubview(view)
                //label.pin(to: cell.itemsStackView)
                
                //view = SideBySideLabels.instanceFromNib()
                //cell.itemsStackView.addArrangedSubview(view)
                //label.pin(to: cell.itemsStackView)
                
            } else {
                cell.detailStackView.isHidden = true;
            }
            
            cell.isExpanded = !cell.isExpanded
            ordersTableView.beginUpdates()
            ordersTableView.endUpdates()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: mainViewIdentifier, for: indexPath)
            as! OrderTableViewCell
        let rowData = orders?[indexPath.row] as? [String: Any]
        let id = rowData?["id"] as! Int64
        cell.lblOrderID.text = "Order: " + String(describing: id)
        let lineItems = rowData?["lineItems"] as! [Any]
        cell.lblNumItems.text = "(" + String(describing: lineItems.count) + " items)"
        //cell.mainDetailView.layer.cornerRadius = 10
        cell.contentView.tag = indexPath.row
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.cellViewTapped(_:)))
        cell.contentView.addGestureRecognizer(gesture)
        //cell.mainView.layer.cornerRadius = 10
        
        let backgroundView: UIView = {
            let view = UIView()
            let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
            view.backgroundColor = color
            view.layer.cornerRadius = 10.0
            return view
        }()
        
        pinBackground(backgroundView, to: cell.rootStackView)
        if !cell.isExpanded {
            cell.detailStackView.isHidden = true
        }
        
        return cell
    }
    
    @IBAction func onBtnEditTapped(_ sender: Any) {
    }
    
    private func pinBackground(_ view: UIView, to stackView: UIStackView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        stackView.insertSubview(view, at: 0)
        view.pin(to: stackView)
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
