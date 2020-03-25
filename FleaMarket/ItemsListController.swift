//
//  ItemsListController.swift
//  FleaMarket
//
//  Created by Rastislav Mirek on 4/3/20.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseFirestore
import FirebaseStorage
import Firebase
import FirebaseUI
import FirebaseAuth

protocol ItemsListDelegate: class {
    func add(item: MarketItem)
}

private let ADD_ITEM_SEGUE_ID = "addItemSegue"

private let cloudFirestore = Firestore.firestore()
private let itemsCollection = cloudFirestore.collection("items")
private let cloudStorage = Storage.storage()
private let imagesFolder = cloudStorage.reference(withPath: "itemImages")
private let auth = FirebaseAuth.Auth.auth()

class ItemsListController: UIViewController {
    private var items = [MarketItem]()
    @IBOutlet weak var itemsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private(set) var dollarRate: Double? {
        didSet {
            itemsCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ensureAuth()
    
        loadItemsList()
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        requestDollarRate()
    }
    
    private func ensureAuth() {
        if auth.currentUser == nil, let authUI = FUIAuth.defaultAuthUI() {
            authUI.providers = [FUIEmailAuth()]
            authUI.delegate = self
            present(authUI.authViewController(), animated: true)
        }
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
        let itemId = items[indexPath.item].itemId
        itemsCollection.document(itemId).delete()
        imagesFolder.child(itemId).delete()
        items.remove(at: indexPath.item)
        itemsCollectionView.deleteItems(at: [indexPath])
    }
}

extension ItemsListController: ItemsListDelegate {
    func add(item: MarketItem) {
        items.append(item)
        itemsCollectionView.insertItems(at: [IndexPath(item: items.count - 1, section: 0)])
        
        if let imageData = item.picture?.jpegData(compressionQuality: 0.5) {
            imagesFolder.child(item.itemId).putData(imageData)
        }
        
        cloudFirestore.collection("items").document(item.itemId).setData([
            "itemId": item.itemId,
            "name": item.name,
            "price": item.price,
            "currency": item.currency.rawValue,
        ])
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
        cell.itemId = item.itemId
        if let localImage = item.picture {
            cell.itemImageView.image = localImage
        } else {
            imagesFolder.child(item.itemId).getData(maxSize: Int64.max) { (data, error) in
                guard let data = data else {
                    print("Error loading image from remote storage: \(String(describing: error))")
                    return
                }
                let picture = UIImage(data: data)
                self.items[indexPath.item].picture = picture
                if cell.itemId == item.itemId {
                    cell.itemImageView.image = picture
                }
            }
        }
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
    
    private func loadItemsList() {
        activityIndicator.isHidden = false
        itemsCollection.addSnapshotListener { snapshot, err in
            guard let snapshot = snapshot else {
                print(err!)
                return
            }
            
            self.items = snapshot.documents.map { document in
                let data = document.data()
                if
                    let name = data["name"] as? String,
                    let currencyId = data["currency"] as? String,
                    let currency = Currency(rawValue: currencyId),
                    let price = data["price"] as? Int,
                    let itemId = data["itemId"] as? String
                {
                    return MarketItem(itemId: itemId, name: name, price: price, currency: currency)
                }
                print("Item stored in unkown format: \(data)")
                return MarketItem()
            }
            
            self.itemsCollectionView.reloadData()
            self.activityIndicator.isHidden = true
        }
        
    }
}

extension ItemsListController: FUIAuthDelegate {
    // TODO add callbacks
}
