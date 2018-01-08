//
//  OrderSearchCriteria.swift
//  OrderEntry
//
//  Created by TechReviews on 1/3/18.
//  Copyright © 2018 TechReviews. All rights reserved.
//

import Foundation

struct OrderSearchCriteria {
    
    var showRecentOrders: Bool
    var createDateStart: String
    var createDateEnd: String
    var orderId: Int64
    
    init() {
        showRecentOrders = false
        createDateStart = ""
        createDateEnd = ""
        orderId = -1
    }
}
