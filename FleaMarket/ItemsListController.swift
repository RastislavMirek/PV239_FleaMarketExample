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
        itemTable.delegate = self
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
        itemTable.insertRows(at: [IndexPath(row: items.count - 1, section: 0)], with: .automatic)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

extension ItemsListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
