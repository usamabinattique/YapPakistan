//
//  ClickableLinkLabel.swift
//  YAPKit
//
//  Created by Zain on 02/04/2020.
//  Copyright © 2020 YAP. All rights reserved.
//

import Foundation
import UIKit

public protocol ClickableLinkLabelDelegate: NSObjectProtocol {
    func clickableLinkLabel(_ clickableLinkLabel: ClickableLinkLabel, didTapLink link: String)
}

open class ClickableLinkLabel: UILabel {
    
    // MARK: Properties
    
    public weak var delegate: ClickableLinkLabelDelegate?
    
    // MARK: Initialization
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
    }
}

// MARK: Private methods

private extension ClickableLinkLabel {
    @objc
    private func tapped(_ tap: UITapGestureRecognizer) {
        guard let attributedString = attributedText else { return }
        let location = tap.location(in: self)
        
        let textRange = NSRange(location: 0, length: attributedString.length)
        
        attributedString.enumerateAttribute(.link, in: textRange, options: .longestEffectiveRangeNotRequired) { [weak self] (value, range, _) in
            if let `value` = value as? String {
                self?.linkFound(at: range, value: value, from: location)
            }
        }
        
        attributedString.enumerateAttribute(.clickableLink, in: textRange, options: .longestEffectiveRangeNotRequired) { [weak self] (value, range, _) in
            if let `value` = value as? String {
                self?.linkFound(at: range, value: value, from:  location)
            }
        }
    }
    
    private func linkFound(at range: NSRange, value: String, from touchLocation: CGPoint) {
        guard boundingRect(forCharacterRange: range).contains(touchLocation) else { return }
        delegate?.clickableLinkLabel(self, didTapLink: value)
    }
    
    private func boundingRect(forCharacterRange range: NSRange) -> CGRect {
        
        guard let attributedText = attributedText else { return .zero }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        
        layoutManager.addTextContainer(textContainer)
        
        var glyphRange = NSRange()
        
        layoutManager.characterRange(forGlyphRange: range, actualGlyphRange: &glyphRange)
        
        return layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
    }
}
