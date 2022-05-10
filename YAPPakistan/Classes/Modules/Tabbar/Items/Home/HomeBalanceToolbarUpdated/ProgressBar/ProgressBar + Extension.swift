//
//  ProgressBar + Extension.swift
//  YAPKit
//
//  Created by Ahmer Hassan on 15/09/2021.
//  Copyright © 2021 YAP. All rights reserved.
//

import Foundation
import UIKit

public protocol ProgressBarDidTapped: AnyObject {
    func progressViewDidTapped(viewForMonth month: String)
}


class StorageProgressSection: ProgressViewSection {
    
    private let rightBorder: UIView = {
        let border = UIView()
        border.backgroundColor = .white
        return border
    }()
    
    func configure() {
        addSubview(rightBorder)
        rightBorder.anchor(top: topAnchor, bottom: bottomAnchor, right: rightAnchor, width: 0)
    }
}

enum StorageType: Int {
  case app, message, media, photo, mail, other
    static var allTypes: [StorageType] = [.app, .message, .media, .photo, .mail, .other]

  var color: UIColor {
    switch self {
    case .app:
      return UIColor.StorageExample.progressRed
    case .message:
      return UIColor.StorageExample.progressGreen
    case .media:
      return UIColor.StorageExample.progressPurple
    case .photo:
      return UIColor.StorageExample.progressYellow
    case .mail:
      return UIColor.StorageExample.progressBlue
    case .other:
      return UIColor(Color(hex: "#A682FF")) //.primarySoft
    }
  }
}

extension UIColor {

  static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
    return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
  }

  enum StorageExample {
    static let progressRed = UIColor.rgb(red: 71, green: 141, blue: 244)
    static let progressGreen = UIColor.rgb(red: 239, green: 106, blue: 144)
    static let progressPurple = UIColor.rgb(red: 255, green: 196, blue: 48)
    static let progressYellow = UIColor.rgb(red: 166, green: 130, blue: 255)
    static let progressBlue = UIColor.rgb(red: 100, green: 213, blue: 207)
    static let backgroundGray = UIColor.rgb(red: 235, green: 235, blue: 242)
    static let borderColor = UIColor.rgb(red: 189, green: 189, blue: 189)
  }
}

extension UIView {

  @discardableResult
  func anchor(top: NSLayoutYAxisAnchor? = nil,
              left: NSLayoutXAxisAnchor? = nil,
              bottom: NSLayoutYAxisAnchor? = nil,
              right: NSLayoutXAxisAnchor? = nil,
              paddingTop: CGFloat = 0,
              paddingLeft: CGFloat = 0,
              paddingBottom: CGFloat = 0,
              paddingRight: CGFloat = 0,
              width: CGFloat = 0,
              height: CGFloat = 0) -> [NSLayoutConstraint] {
    translatesAutoresizingMaskIntoConstraints = false

    var anchors = [NSLayoutConstraint]()

    if let top = top {
      anchors.append(topAnchor.constraint(equalTo: top, constant: paddingTop))
    }
    if let left = left {
      anchors.append(leftAnchor.constraint(equalTo: left, constant: paddingLeft))
    }
    if let bottom = bottom {
      anchors.append(bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom))
    }
    if let right = right {
      anchors.append(rightAnchor.constraint(equalTo: right, constant: -paddingRight))
    }
    if width > 0 {
      anchors.append(widthAnchor.constraint(equalToConstant: width))
    }
    if height > 0 {
      anchors.append(heightAnchor.constraint(equalToConstant: height))
    }

    anchors.forEach({ $0.isActive = true })

    return anchors
  }
}
