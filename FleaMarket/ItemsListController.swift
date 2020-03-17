//
//  ItemsListController.swift
//  FleaMarket
//
//  Created by Rastislav Mirek on 4/3/20.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit
import Alamofire

protocol ItemsListDelegate: class {
    func add(item: MarketItem)
}

private let ADD_ITEM_SEGUE_ID = "addItemSegue"
private let ITEMS_LIST_KEY = "items_list"

class ItemsListController: UIViewController {
    private var items = [MarketItem]()
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    
    private(set) var dollarRate: Double? {
        didSet {
            itemsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItemsList()
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        requestDollarRate()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if
            segue.identifier == ADD_ITEM_SEGUE_ID,
            let addItemController = segue.destination as? AddItemViewController
        {
            addItemController.itemsListDelegate = self
        }
    }
    
    private func imageStorageLocation(for itemId: String) throws -> URL {
        return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(itemId).jpeg")
    }
    
    private func removeItem(at indexPath: IndexPath) {
        items.remove(at: indexPath.item)
        itemsCollectionView.deleteItems(at: [indexPath])
        persistItemsList()
    }
}

extension ItemsListController: ItemsListDelegate {
    func add(item: MarketItem) {
        items.append(item)
        itemsCollectionView.insertItems(at: [IndexPath(item: items.count - 1, section: 0)])
        do {
            try item.picture?.jpegData(compressionQuality: 0.5)?.write(to: try imageStorageLocation(for: item.itemId), options: [.atomicWrite])
        } catch (let error) {
            print("Failed to save image for item \(item.name) with error \(error)")
        }
        persistItemsList()
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
        cell.itemPriceLabel.text = formatWithDollar(for: item)
        cell.itemImageView.image = item.picture
        return cell
    }
}

extension ItemsListController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        let alert = UIAlertController(title: "Do you want to buy \(item.name)?", message: "You will pay \(formatWithDollar(for: item))", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Buy", style: .default) { _ in
            self.removeItem(at: indexPath)
        })
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Currency Exchange Rates Handling

extension ItemsListController {
    private func requestDollarRate() {
        AF.request("https://api.exchangeratesapi.io/latest?symbols=USD").responseJSON { response in
            switch response.result {
            case .success(_):
                if
                    let responseDict = response.value as? [String: Any],
                    let ratesDict = responseDict["rates"] as? [String: Any],
                    let rate = ratesDict["USD"] as? Double
                {
                    self.dollarRate = rate
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func formatWithDollar(for item: MarketItem) -> String {
        return dollarRate == nil || item.currency == .usDollar ? item.formatPrice() : "$\(round(Double(item.price) * dollarRate! * 100) / 100)"
    }
}

// MARK: Items Persistance

extension ItemsListController {
    private func persistItemsList() {
        do {
            let itemsAsJson = try JSONEncoder().encode(items)
            UserDefaults.standard.set(itemsAsJson, forKey: ITEMS_LIST_KEY)
        } catch(let error) {
            print("Error when saving items: \(error)")
        }
    }
    
    private func loadItemsList() {
        guard let jsonData = UserDefaults.standard.data(forKey: ITEMS_LIST_KEY) else {
            return // no items are stored
        }
        do {
            items = try JSONDecoder().decode([MarketItem].self, from: jsonData)
            for i in 0 ..< items.count {
                items[i].picture = try UIImage(contentsOfFile: imageStorageLocation(for: items[i].itemId).path)
            }
        } catch (let error) {
            print("Error when loading items: \(error)")
        }
    }
}
