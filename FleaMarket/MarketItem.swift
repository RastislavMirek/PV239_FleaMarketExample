//
//  MarketItem.swift
//  FleaMarket
//
//  Created by Rastislav Mirek on 4/3/20.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit

struct MarketItem {
    var name = "New Item"
    var price = 1
    var picture: UIImage?
}

extension MarketItem {
    func formatPrice() -> String {
        return "$\(price)"
    }
}
