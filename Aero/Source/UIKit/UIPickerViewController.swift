//
//  UIPickerViewController.swift
//
//  Created by Brian Schrader on 6/5/17.
//

import Foundation
import UIKit


/**
 * A ViewController that displays a UIPickerView and done button.
 */
public class UIPickerViewController: UIViewController {
    
    var titleLabel: UILabel! = UILabel()
    var picker: UIPickerView! = UIPickerView()
    var doneButton: UIButton! = UIButton(type: .roundedRect)
    
    /// A handler that is called when the view controller will be dismissed.
    var dismissalHandler: (()->Void)? = nil
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(shouldDismiss), for: .touchUpInside)
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(picker)
        view.addSubview(doneButton)
        view.addSubview(titleLabel)
        constrainViews()
    }
    
    private func constrainViews() {
        NSLayoutConstraint.activate([
            // Picker View
            NSLayoutConstraint(item: picker, attribute: .bottom, relatedBy: .equal, toItem: view,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: picker, attribute: .leading, relatedBy: .equal, toItem: view,
                               attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: picker, attribute: .trailing, relatedBy: .equal, toItem: view,
                               attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: picker, attribute: .top, relatedBy: .equal, toItem: doneButton,
                               attribute: .bottom, multiplier: 1, constant: 0),
            
            // Done Button
            NSLayoutConstraint(item: doneButton, attribute: .top, relatedBy: .equal, toItem: view,
                               attribute: .topMargin, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: doneButton, attribute: .trailing, relatedBy: .equal, toItem: view,
                               attribute: .trailingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: doneButton, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .notAnAttribute, multiplier: 0, constant: 50),
            NSLayoutConstraint(item: doneButton, attribute: .width, relatedBy: .equal, toItem: nil,
                               attribute: .notAnAttribute, multiplier: 0, constant: 50),
            
            // Title Label
            NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view,
                               attribute: .topMargin, multiplier: 1, constant: 5),
            NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view,
                               attribute: .leadingMargin, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: doneButton,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: doneButton,
                               attribute: .height, multiplier: 1, constant: 0),
            
            ])
    }
    
    // MARK: IBAction Methods
    
    func shouldDismiss(sender: Any) {
        if let dismissalHandler = dismissalHandler {
            dismissalHandler()
        }
        dismiss(animated: true, completion: nil)
    }
}
