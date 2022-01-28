//
//  UIToolBar+Extension.swift
//  YAPPakistan
//
//  Created by Yasir on 28/01/2022.
//

import UIKit

extension UIToolbar {
    static func getToolBar(target: Any?, done: Selector?, cancel: Selector?) -> UIToolbar {
        print("getToolBar")
        let toolBar = UIToolbar()
        toolBar.autoresizingMask = .flexibleHeight
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor =  UIColor(Color(hex: "#272262")) //UIColor.appColor(ofType: .primaryDark)
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: target, action: done)
        
        var items: [UIBarButtonItem] = [doneButton]
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        items.insert(spaceButton, at: 0)
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: target, action: cancel)
        items.insert(cancelButton, at: 0)
        
        toolBar.setItems(items, animated: false)
        toolBar.isUserInteractionEnabled = true
        return toolBar
    }

}

