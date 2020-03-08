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
    @IBOutlet weak var itemTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        itemTable.dataSource = self
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
        itemTable.reloadData()
    }
}

private let ROW_REUSE_ID = "rowReuseID"
extension ItemsListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowView = tableView.dequeueReusableCell(withIdentifier: ROW_REUSE_ID) else {
            return UITableViewCell() // should not happen, throwing exception is also OK
        }

        let item = items[indexPath.row]
        rowView.textLabel?.text = item.name
        rowView.detailTextLabel?.text = item.formatPrice()
        return rowView
    }
}