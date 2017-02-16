// UIFont+Extension.swift
//
// author: Brian Schrader
//

import Foundation
import UIKit


extension UIFont {
    
    /**
     * Mimics the functionality of `UIFont.preferredFontForTextStyle` but allows for a custom font family.
     */
    static func preferredFont(forTextStyle textStyle: UIFontTextStyle, fontFamily: String) -> UIFont? {
        let font = UIFont.preferredFont(forTextStyle: textStyle)
        return UIFont(name: fontFamily, size: font.pointSize)!
    }
}
