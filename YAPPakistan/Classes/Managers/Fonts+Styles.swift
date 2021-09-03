//
//  Fonts+Styles.swift
//  YAPPakistan
//
//  Created by Sarmad on 03/09/2021.
//

import SwiftRichString

let normal = Style {
    $0.font = UIFont.appFont(forTextStyle: .regular)
    //Theme.grayLithg
}
        
let bold = Style {
    $0.font = UIFont.appFont(forTextStyle: .regular)
    //Theme.white
}
        
//let italic = normal.byAdding {
//    $0.traitVariants = .italic
//}

//let myGroup = StyleXML(base: normal, ["bold": bold, "italic": italic])
//let str = "Hello <bold>Daniele!</bold>. You're ready to <italic>play with us!</italic>"
//self.label?.attributedText = str.set(style: myGroup)
