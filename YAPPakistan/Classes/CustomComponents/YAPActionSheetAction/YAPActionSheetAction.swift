//
//  YAPActionSheetAction.swift
//  Adjust
//
//  Created by Awais on 26/04/2022.
//

public class BaseActionSheet {
    public var title: String
    public var subtitle: String?
    init(title: String) {
        self.title = title
    }
}

import Foundation

public typealias YAPAActionSheetActionHandler = ((_ action: YAPActionSheetAction) -> Void)

public class YAPActionSheetAction: BaseActionSheet {
    
    public var image: UIImage?
    
    var handler: YAPAActionSheetActionHandler
    
    public init(title: String, subtitle: String? = nil, image: UIImage? = nil, handler: @escaping YAPAActionSheetActionHandler) {
        self.image = image
        self.handler = handler
        super.init(title: title)
        self.title = title
        self.subtitle = subtitle
    }
    
}

public class YapCardActionSheetAction: BaseActionSheet {
    
    public var value: String?
    public var trailingValue: String?
    public var showButton: Bool?
    public var trailingTitle: String?
    
    var handler: YAPAActionSheetActionHandler
    
    public init(title: String, value: String? = nil,trailingTitle: String? = nil, trailingValue: String? = nil, showButton:Bool, handler: @escaping YAPAActionSheetActionHandler) {
        self.value = value
        self.trailingValue = trailingValue
        self.showButton = showButton
        self.trailingTitle = trailingTitle
        self.handler = handler
        super.init(title: title)
    }
}
