//
//  AeroLabel.swift
//
//  Created by Brian Schrader on 7/21/17.
//
//

import Foundation
import UIKit


public class AeroLabel: UILabel {

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
        textColor = appearanceManager?.label.textColor
        backgroundColor = appearanceManager?.label.backgroundColor
        font = appearanceManager?.label.font

        setNeedsDisplay()
    }
}
