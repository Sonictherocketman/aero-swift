//
//  AeroCustomizableUIElement.swift
//
//  Created by Brian Schrader on 7/21/17.
//
//

import Foundation
import UIKit


open class AeroAppearanceManager: NSObject {

    public static var backingStoreName: String? = "DefaultAppearance.plist"
    private static var _shared: AeroAppearanceManager!

    private var _backingStore: NSDictionary?
    private var _theme: String?

    public static var shared: AeroAppearanceManager {
        get {
            if _shared == nil {
                _shared = self.init(theme: backingStoreName)
            }
            return _shared
        }
    }

    required public init(theme: String?) {
        super.init()

        _theme = theme

        label = Label(manager: self)
        button = Button(manager: self)
        borderedButton = BorderedButton(manager: self)
    }

    // MARK: Notifications

    public enum Notifications: String {
        case themeChanged = "Aero.AppearanceManager.Notifications.themeChanged"
    }

    internal func notification(_ about: Notifications) -> Notification.Name {
        return Notification.Name(rawValue: about.rawValue)
    }
    
    // MARK: Theme Change Methods

    public var theme: String? {
        get { return _theme }
        set {
            _theme = newValue

            guard let path = Bundle.main.path(forResource: theme, ofType: "plist") else {
                return
            }

            _backingStore = NSDictionary(contentsOfFile: path)

            let notifications = NotificationCenter.default
            notifications.post(name: notification(.themeChanged), object: self)
        }
    }

    // MARK: Convenience Methods

    subscript(index: String) -> Any? {
        return _backingStore?[index]
    }

    func getHexColor(index: String, placeholder: UIColor) -> UIColor {
        if let hex = self[index] as? Int {
            return UIColor(hex: hex)
        }
        return placeholder
    }

    // MARK: Global Settings

    public let rootViewBackgroundColor: UIColor = .white

    // MARK: Label Settings

    public class Label {
        var manager: AeroAppearanceManager!

        init(manager: AeroAppearanceManager) {
            self.manager = manager
        }

        public var font: UIFont {
            get {
                return manager["Label.font"] as? UIFont ?? UIFont.preferredFont(forTextStyle: .body)
            }
        }

        public var textColor: UIColor {
            get {
               return manager.getHexColor(index: "Label.textColor", placeholder: .black)
            }
        }

        public var backgroundColor: UIColor {
            get {
                return manager.getHexColor(index: "Label.backgroundColor", placeholder: .clear)
            }
        }
    }
    public var label: AeroAppearanceManager.Label!

    // MARK: Button Settings

    public class Button: Label {
        override public var font: UIFont {
            get {
                return manager["Button.font"] as? UIFont ?? super.font
            }
        }

        override public var textColor: UIColor {
            get {
                return manager.getHexColor(index: "Button.textColor", placeholder: super.textColor)
            }
        }

        override  public var backgroundColor: UIColor {
            get {
                return manager.getHexColor(index: "Button.backgroundColor", placeholder: super.backgroundColor)
            }
        }
    }
    public var button: AeroAppearanceManager.Button!

    // MARK: Border Button Settings

    public class BorderedButton: Button {
        public var borderWidth: CGFloat {
            get {
                return CGFloat(manager["BorderedButton.borderWidth"] as? Int ?? 2)
            }
        }
        public var borderColor: UIColor {
            get {
                return manager.getHexColor(index: "BorderedButton.borderColor", placeholder: .black)
            }
        }
    }
    public var borderedButton: AeroAppearanceManager.BorderedButton!
}
