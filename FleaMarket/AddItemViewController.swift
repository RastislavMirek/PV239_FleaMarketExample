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
    
    @IBOutlet weak var itemPictureView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBAction func nameChanged(_ nameTextField: UITextField) {
        marketItem.name = nameTextField.text ?? "New Item"
    }

    @IBAction func priceChanged(_ priceSlider: UISlider) {
        marketItem.price = Int(round(priceSlider.value))
        updatePriceLabel()
    }
    
    @IBAction func currencyValueChanged(_ sender: UISegmentedControl) {
        marketItem.currency = sender.selectedSegmentIndex == 0 ? .usDollar : .euro
        updatePriceLabel()
    }
    
    @IBAction func selectImagePressed(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func cancelButtonPressed(_: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func sellButtonPressed(_: Any) {
        if marketItem.picture == nil {
            let alert = UIAlertController(title: "Please Add Item Picture", message: "You cannot sell items without picture on FleaMarket", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        itemsListDelegate?.add(item: marketItem)
        dismiss(animated: true)
    }
    
    private func updatePriceLabel() {
        priceLabel.text = marketItem.formatPrice()
    }
}

extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        marketItem.picture = selectedImage
        UIView.transition(with: itemPictureView, duration: 0.5, options: [.transitionCrossDissolve], animations: {
            self.itemPictureView.image = selectedImage
        }, completion: nil)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
