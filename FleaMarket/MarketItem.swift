//
//  MarketItem.swift
//  FleaMarket
//
//  Created by Rastislav Mirek on 4/3/20.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit

public struct MarketItem: Codable {
    let itemId: String
    var name = "New Item"
    var price = 1
    var picture: UIImage?
    var currency: Currency = .usDollar
    
    init() {
        itemId = UUID().uuidString
    }
    
    init(itemId: String, name: String, price: Int, currency: Currency) {
        self.itemId = itemId
        self.name = name
        self.price = price
        self.currency = currency
    }
    
    private enum CodingKeys: String, CodingKey {
       case name, price, currency, itemId
   }
}

extension MarketItem {
    func formatPrice() -> String {
       return "\(currency == .usDollar ? "$" : "€")\(price)"
    }
}
