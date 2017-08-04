//
//  AeroButton.swift
//
//  Created by Brian Schrader on 7/21/17.
//
//

import Foundation
import UIKit


public class AeroButton: UIButton {

    public var appearanceManager: AeroAppearanceManager? {
        didSet {
            updateTheme()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        subscribeToThemeChanges()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        subscribeToThemeChanges()
    }

    private func subscribeToThemeChanges() {
        let notifications = NotificationCenter.default
        notifications.addObserver(self, selector: #selector(self.updateTheme),
                                  name: appearanceManager?.notification(.themeChanged), object: nil)
    }

    func updateTheme() {
        tintColor = appearanceManager?.button.textColor
        backgroundColor = appearanceManager?.button.backgroundColor
        titleLabel?.font = appearanceManager?.button.font

        setNeedsDisplay()
    }
}

public class AeroBorderedButton: AeroButton {

    override public var isHighlighted: Bool {
        didSet {
            let fadedColor = tintColor.withAlphaComponent(0.2).cgColor

            if isHighlighted {
                layer.borderColor = fadedColor
            } else {
                layer.borderColor = tintColor.cgColor

                let animation = CABasicAnimation(keyPath: "borderColor")
                animation.fromValue = fadedColor
                animation.toValue = tintColor.cgColor
                animation.duration = 0.4
                layer.add(animation, forKey: "")
            }
        }
    }

    override func updateTheme() {
        tintColor = appearanceManager?.borderedButton.textColor
        backgroundColor = appearanceManager?.borderedButton.backgroundColor
        titleLabel?.font = appearanceManager?.borderedButton.font

        if let borderWidth = appearanceManager?.borderedButton.borderWidth {
            layer.borderWidth = borderWidth
        }

        if let borderColor = appearanceManager?.borderedButton.borderColor {
            layer.borderColor = borderColor.cgColor
        } else {
            layer.borderColor = tintColor.cgColor
        }

        setNeedsDisplay()
    }
}
