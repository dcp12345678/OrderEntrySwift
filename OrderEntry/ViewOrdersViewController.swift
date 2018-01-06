//
//  RecentOrdersTableViewController.swift
//  OrderEntry
//
//  Created by TechReviews on 10/27/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

enum CellExpandedState {
    case Expanded
    case Collapsed
}

class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var rootStackView: UIStackView!    
    @IBOutlet weak var lblOrderId: UILabel!
    @IBOutlet weak var lblNumItems: UILabel!
    @IBOutlet weak var lblLastUpdate: UILabel!
    @IBOutlet weak var detailView: UIStackView!
    var isExpanded: Bool = false
    @IBOutlet weak var productListTable: ProductListTable!
    @IBOutlet weak var productListTableHeight: NSLayoutConstraint!
    @IBOutlet weak var btnEdit: UIButton!
}

class ProductInfo {
    var name: String = ""
    var count: Int = -1
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
    }
}

class ProductInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var lblProductName: UILabel!
    @IBOutlet weak var lblProductCount: UILabel!
}

class ProductListTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    var productInfoArray = [ProductInfo]()
    
    let productInfoCellIdentifier = "ProductInfo"
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: productInfoCellIdentifier, for: indexPath)
            as! ProductInfoTableViewCell
        
        let row = indexPath.row
        cell.lblProductName?.text = productInfoArray[row].name
        cell.lblProductCount?.text = String(describing: productInfoArray[row].count)
        
        let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
        cell.backgroundColor = color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productInfoArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        print(productInfoArray[row])
    }
}

class ViewOrdersViewController: UITableViewController {
    
    @IBOutlet var ordersTableView: UITableView!
    
    var searchCriteria = OrderSearchCriteria()
    
    let mainViewCellIdentifier = "MainView"
    
    var orders: NSMutableArray? = nil
    var expandedOrderIds = Set<Int64>()

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
        
        // create button for order search
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self,
                                                                action: #selector(searchOnPress))

        // create button for adding new order
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                action: #selector(addOnPress))

    }
    
    @objc func searchOnPress() {
        //Helper.showMessage(parentController: self, message: "search button tapped!")
        performSegue(withIdentifier: "searchOrders", sender: self)
    }
    
    @objc func addOnPress() {
        //Helper.showMessage(parentController: self, message: "add button tapped!")
        performSegue(withIdentifier: "createOrder", sender: self)
    }
    
    private func expandOrCollapseCell(at indexPath: IndexPath, targetState: CellExpandedState) {
        if let cell = ordersTableView.cellForRow(at: indexPath as IndexPath) as? OrderTableViewCell {
            let rowData = orders?[indexPath.row] as? [String: Any]
            let id = rowData?["id"] as! Int64

            if targetState == .Expanded {
                
                //
                // we need to expand the cell's detail view
                //
                
                cell.isExpanded = true
                expandedOrderIds.insert(id)
                
                do {
                    let lineItems = try OrdersApi.getOrderLineItems(forOrderId: id)
                    
                    var productTypeCounts = [String: Int]()
                    for case let lineItem as NSMutableDictionary in lineItems {
                        let productTypeName = lineItem["productTypeName"] as! String
                        productTypeCounts[productTypeName] = (productTypeCounts[productTypeName] ?? 0) + 1
                    }
                    
                    cell.productListTable.productInfoArray.removeAll()
                    for productTypeCount in productTypeCounts {
                        cell.productListTable.productInfoArray.append(ProductInfo(name: productTypeCount.key, count: productTypeCount.value))
                    }
                    
                    // recalculate the product list table height based on number of rows in productInfoArray
                    cell.productListTableHeight.constant = CGFloat(cell.productListTable.productInfoArray.count) * 40.0
                    
                    // store the row index in the edit button's tag so we know which row they tapped
                    // in the onBtnEditTapped method
                    cell.btnEdit.tag = indexPath.row
                    
                } catch OrderEntryError.webServiceError(let msg) {
                    Helper.showError(parentController: self, errorMessage: "Error calling web service: msg = \(msg)");
                } catch (OrderEntryError.configurationError(let msg)) {
                    Helper.showError(parentController: self, errorMessage: msg, title: "Configuration Error")
                } catch {
                    Helper.showError(parentController: self, errorMessage: "Unexpected Error = \(error)");
                }
                
                cell.productListTable.layer.borderColor = UIColor.white.cgColor
                cell.productListTable.layer.borderWidth = 1.0
                cell.productListTable.separatorInset = UIEdgeInsets.zero // don't inset the cell separator
                
                UIView.animate(withDuration: 0.2) {
                    cell.detailView.isHidden = false;
                }
                
                cell.productListTable.reloadData()
            } else {
                // collapse the cell's detail view
                cell.detailView.isHidden = true;
                expandedOrderIds.remove(id)
                cell.isExpanded = false
            }
        }
    }
    
    @objc func cellViewTapped(_ sender: UITapGestureRecognizer) {
        let indexPath = NSIndexPath(row: (sender.view?.tag)!, section: 0) as IndexPath
        if let cell = ordersTableView.cellForRow(at: indexPath as IndexPath) as? OrderTableViewCell {
            // if cell is expanded, then collapse it, otherwise, expand it
            expandOrCollapseCell(at: indexPath, targetState: cell.isExpanded ? CellExpandedState.Collapsed : CellExpandedState.Expanded)
            ordersTableView.beginUpdates()
            ordersTableView.endUpdates()
        
            // scroll to the row the user tapped
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.middle, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        do {
            if searchCriteria.showRecentOrders {
                // get most recent orders for user
                orders = try OrdersApi.getOrders(forUserId: Helper.userId)
            } else {
                // use the search criteria to get the orders
                orders = try OrdersApi.searchForOrders(searchCriteria: searchCriteria)
            }
            print("final result = \(String(describing: self.orders))")
            self.ordersTableView.reloadData()
            
            // expand or collapse each order as appropriate
            for row in 0..<self.ordersTableView.numberOfRows(inSection: 0) {
                let indexPath = IndexPath(row: row, section: 0)
                let rowData = orders?[indexPath.row] as? [String: Any]
                let id = rowData?["id"] as! Int64
                let targetState = expandedOrderIds.contains(id) ? CellExpandedState.Expanded : CellExpandedState.Collapsed
                expandOrCollapseCell(at: indexPath, targetState: targetState)
            }
            
            // if an order was edited, it will be at the top of the list, so scroll to it so user can see it
            if Helper.wasOrderEdited {
                tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.middle, animated: true)
                Helper.wasOrderEdited = false
            }

            ordersTableView.beginUpdates()
            ordersTableView.endUpdates()

            
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
        let cell = tableView.dequeueReusableCell(withIdentifier: mainViewCellIdentifier, for: indexPath)
            as! OrderTableViewCell
        let rowData = orders?[indexPath.row] as? [String: Any]
        let id = rowData?["id"] as! Int64
        cell.lblOrderId.text = "Order: " + String(describing: id)
        let lineItems = rowData?["lineItems"] as! [Any]
        cell.lblNumItems.text = "(" + String(describing: lineItems.count) + " items)"
        cell.lblLastUpdate.text = "Last Update: " + (rowData?["updateDate"] as! String).substr(startAt: 0, endAt: 9)
        cell.contentView.tag = indexPath.row
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector (self.cellViewTapped(_:)))
        cell.contentView.addGestureRecognizer(gesture)
        
        let backgroundView: UIView = {
            let view = UIView()
            let color = UIColor(red: 82.0 / 255.0, green: 130.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
            view.backgroundColor = color
            view.layer.cornerRadius = 10.0
            return view
        }()
        pinBackground(backgroundView, to: cell.rootStackView)
        
        if !cell.isExpanded {
            cell.detailView.isHidden = true
        }
        
        cell.productListTable.dataSource = cell.productListTable
        cell.productListTable.delegate = cell.productListTable
        
        // this step is done to remove the empty cells from end of table view
        cell.productListTable.tableFooterView = UIView()

        return cell
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "editOrder" {
            if let btn = sender as? UIButton {
                let row = btn.tag
                let rowData = orders?[row] as? [String: Any]
                let id = rowData?["id"] as! Int64
                (segue.destination as! EditOrderViewController).orderId = id
            }
        } else if segue.identifier == "createOrder" {
            (segue.destination as! EditOrderViewController).orderId = -1
        }
    }

}
