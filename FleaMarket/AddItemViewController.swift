//
//  AddItemViewController.swift
//  FleaMarket
//
//  Created by Rastislav Mirek on 4/3/20.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {
    private var marketItem = MarketItem()
    weak var itemsListDelegate: ItemsListDelegate?
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func nameChanged(_ nameTextField: UITextField) {
        marketItem.name = nameTextField.text ?? "New Item"
    }

    @IBAction func priceChanged(_ priceSlider: UISlider) {
        marketItem.price = Int(round(priceSlider.value))
        priceLabel.text = marketItem.formatPrice()
    }

    @IBAction func sellButtonPressed(_: Any) {
        itemsListDelegate?.add(item: marketItem)
        dismiss(animated: true)
    }
}
