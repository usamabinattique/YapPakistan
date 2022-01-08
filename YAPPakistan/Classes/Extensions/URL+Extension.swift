//
//  URL+Extension.swift
//  YAPPakistan
//
//  Created by Umair  on 06/01/2022.
//

import Foundation


public extension URL {
    
    init?(addingPercentEncodingInString string: String) {
        let urlString = string.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        self.init(string: urlString)
    }
}
