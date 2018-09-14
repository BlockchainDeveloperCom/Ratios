//
//  UIColorExtensions.swift
//  Ratios
//
//  Created by Pouria Almassi on 11/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import UIKit

extension UIColor {
    class var primaryColor: UIColor { return UIColor.red }
    class var darkBackgroundColor: UIColor { return UIColor(red: 0.071, green: 0.071, blue: 0.071, alpha: 1.00) }
    class var lightBackgroundColor: UIColor { return UIColor.white }
}

extension UIDevice {
    class var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
}
