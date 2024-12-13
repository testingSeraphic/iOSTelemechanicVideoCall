//
//  ExpandingTextView.swift
//  VideoCall
//
//  Created by Manpreet Singh on 17/11/24.
//

import UIKit

public class ExpandingTextView: UITextView {
    
    // placeholder label
    public let placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // minimum height to match single line
    public var minHeight: CGFloat = 0
    
    // maximum height dynamically calculated for 4 lines
    public var maxHeight: CGFloat = 0
    
    // closure for height change
    public var onHeightChange: ((CGFloat) -> Void)?
    
    // placeholder text
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    public override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    // initializer
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        // basic TextView properties
        isScrollEnabled = false
        font = UIFont.systemFont(ofSize: 16)
        textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        backgroundColor = .clear
        autocorrectionType = .no
        spellCheckingType = .no
        textColor = .black
        // add placeholder label
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        
        // constraints for placeholder
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -0),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0)
        ])
        
        // observe text changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        
        // dynamically calculate maxHeight for 4 lines
        if let fontLineHeight = font?.lineHeight {
            maxHeight = (fontLineHeight * 5) + textContainerInset.top + textContainerInset.bottom
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // calculate minimum height (single line height + insets)
        if minHeight == 0 {
            let singleLineHeight = font?.lineHeight ?? 0
            minHeight = singleLineHeight + textContainerInset.top + textContainerInset.bottom
        }
    }
    
    @objc private func textDidChange() {
        // show/hide placeholder
        placeholderLabel.isHidden = !text.isEmpty
        
        // calculate new height
        let size = sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        var newHeight = max(size.height, minHeight)
        
        // restrict to maxHeight and enable scrolling only if content exceeds 4 lines
        if maxHeight > 0, Int(newHeight) > Int(maxHeight) {
            newHeight = maxHeight
            isScrollEnabled = true
        } else {
            isScrollEnabled = false
        }
        
        if frame.height != newHeight {
            // notify height change
            onHeightChange?(newHeight)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
