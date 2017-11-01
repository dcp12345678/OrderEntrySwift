//
//  OrderEntryError.swift
//  OrderEntry
//
//  Created by TechReviews on 10/31/17.
//  Copyright © 2017 TechReviews. All rights reserved.
//

import UIKit

enum OrderEntryError: Error {
    case configurationError(msg: String)
    case webServiceError(msg: String)
    case urlError(url: String)
    case inputValueError(msg: String)
    case testError(msg: String)
}
