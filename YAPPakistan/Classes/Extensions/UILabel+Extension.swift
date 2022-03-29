//
//  UILabel+Extension.swift
//  YAPPakistan
//
//  Created by Umair  on 29/03/2022.
//

import Foundation

public extension UILabel {
    var textSize: CGSize {
        guard let text = self.text else { return .zero }
        return (text as NSString).size(withAttributes: [.font: font ?? UIFont.systemFont(ofSize: 12)])
    }
    
    func textSize(constrainedToWidth width: CGFloat) -> CGSize {
        guard let text = self.text else { return .zero }
        
        return (text as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font: font ?? UIFont.regular], context: nil).size
    }
    
    func textSize(constrainedToHeight height: CGFloat) -> CGSize {
        guard let text = self.text else { return .zero }
        
        return (text as NSString).boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, attributes: [.font: font ?? UIFont.regular], context: nil).size
    }
}
public extension UILabel {

    // MARK: - spacingValue is spacing that you need
    func addInterlineSpacing(spacingValue: CGFloat = 2) {

        // MARK: - Check if there's any text
        guard let textString = text else { return }

        let attributedString = NSMutableAttributedString(string: textString)

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineSpacing = spacingValue

        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length
        ))
        attributedText = attributedString
    }

}
