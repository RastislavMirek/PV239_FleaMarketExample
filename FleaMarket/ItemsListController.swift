//
//  ItemsListController.swift
//  FleaMarket
//
//  Created by Rastislav Mirek on 4/3/20.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit

protocol ItemsListDelegate: class {
    func add(item: MarketItem)
}

private let ADD_ITEM_SEGUE_ID = "addItemSegue"

class ItemsListController: UIViewController {
    private var items = [MarketItem]()
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == ADD_ITEM_SEGUE_ID,
            let addItemController = segue.destination as? AddItemViewController
        {
            addItemController.itemsListDelegate = self
        }
    }
}

extension ItemsListController: ItemsListDelegate {
    func add(item: MarketItem) {
        items.append(item)
        itemsCollectionView.reloadData()
    }
}

private let CELL_REUSE_ID = "cellReuseID"
extension ItemsListController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CELL_REUSE_ID, for: indexPath) as? ItemCell else {
            return UICollectionViewCell()
        }
        let item = items[indexPath.item]
        cell.itemNameLabel.text = item.name
        cell.itemPriceLabel.text = item.formatPrice()
        cell.itemImageView.image = item.picture
        return cell
    }
}

extension ItemsListController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
