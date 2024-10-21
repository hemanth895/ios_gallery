//
//  FloatingLabelTextField.swift
//  IOS_gallery
//
//  Created by Hemanth on 10/21/24.
//

import UIKit

class FloatingLabelTextField: UIView, UITextFieldDelegate {
    
    // MARK: - Public Properties for Customization
    public var activeBorderColor: UIColor = .blue {
        didSet {
            updateBorderColor()
        }
    }
    public var inactiveBorderColor: UIColor = .lightGray {
        didSet {
            updateBorderColor()
        }
    }
    public var backgroundColorField: UIColor = .white {
        didSet {
            textField.backgroundColor = backgroundColorField
        }
    }
    
    // MARK: - Private UI Elements
    private let floatingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.alpha = 0 // Initially hidden
        return label
    }()
    
    private let textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        return field
    }()
    
    // MARK: - Initializer
    init(placeholder: String) {
        super.init(frame: .zero)
        setupUI()
        self.textField.placeholder = placeholder
        self.floatingLabel.text = placeholder
        self.textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        addSubview(floatingLabel)
        addSubview(textField)
        
        // Add border to the bottom of the text field
        layer.borderWidth = 1
        layer.cornerRadius = 8
        updateBorderColor() // Set the initial border color
        textField.backgroundColor = backgroundColorField
        
        // Set up layout
        floatingLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Constraints for the text field
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            textField.topAnchor.constraint(equalTo: topAnchor, constant: 18),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
        
        // Constraints for the floating label
        NSLayoutConstraint.activate([
            floatingLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            floatingLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -5)
        ])
        
        // Initially, the floating label should not be visible (in case text field is empty)
        floatingLabel.alpha = 0
    }
    
    // MARK: - UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            animateFloatingLabel(up: true)
        }
        // Set active border color when editing begins
        layer.borderColor = activeBorderColor.cgColor
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, text.isEmpty {
            animateFloatingLabel(up: false)
        }
        // Set inactive border color when editing ends
        layer.borderColor = inactiveBorderColor.cgColor
    }
    
    // MARK: - Floating Label Animation
    private func animateFloatingLabel(up: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.floatingLabel.alpha = up ? 1 : 0
            self.floatingLabel.transform = up ? CGAffineTransform(translationX: 0, y: -20) : .identity
        }
    }
    
    // MARK: - Helper Methods
    private func updateBorderColor() {
        layer.borderColor = inactiveBorderColor.cgColor
    }
    
    // Provide a way to access the text from outside the class
    public var text: String? {
        return textField.text
    }
}
