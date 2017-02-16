//
//  UIFont+Extension.swift
//  MyGeneRank
//
//  Created by Brian Schrader on 2/2/17.
//  Copyright © 2017 Apple, Inc. All rights reserved.
//

import Foundation
import UIKit


extension UIFont {
    
    /**
     * Mimics the functionality of `UIFont.preferredFontForTextStyle` but allows for a custom font family.
     */
    static func preferredFont(forTextStyle textStyle: UIFontTextStyle, fontFamily: String) -> UIFont? {
        return UIFont(name: fontFamily, size: font.pointSize)!
    }
}
