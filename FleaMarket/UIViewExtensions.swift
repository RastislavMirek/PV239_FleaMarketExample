//
//  UIViewExtensions.swift
//  FleaMarket
//
//  Created by Rasťo on 11/03/2020.
//  Copyright © 2020 FI MU. All rights reserved.
//

import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
