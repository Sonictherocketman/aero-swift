//
//  UIImage+PNGExtension.swift
//
//  Created by Brian Schrader on 7/17/17.
//

import Foundation
import UIKit


public extension UIImage {

    public func pngVersion(at size: CGSize) -> Data? {
        guard let resized = self.resizeImage(to: size) else {
            return nil
        }
        return UIImagePNGRepresentation(resized)
    }

    public func resizeImage(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
