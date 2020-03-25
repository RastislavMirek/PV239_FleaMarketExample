//
//  ItemCell.swift
//  FleaMarket
//
//  Created by Rasťo on 11/03/2020.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit

class ItemCell: UICollectionViewCell {
    var itemId: String?
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        itemImageView.image = nil
    }
}
