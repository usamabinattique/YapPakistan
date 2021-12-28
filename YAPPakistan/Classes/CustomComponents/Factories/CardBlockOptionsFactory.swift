//
//  CardBlockOptionFactory.swift
//  YAPPakistan
//
//  Created by Umair  on 27/12/2021.
//

import Foundation

public class CardBlockOptionsFactory {
    public class func createCardBlockOptions() -> [OptionPickerItem<PaymentCardBlockOption>] {
        return [
            OptionPickerItem(title:  "screen_report_card_button_damage_card".localized, icon: UIImage(named: "icon_damaged_card", in: .yapPakistan), value: PaymentCardBlockOption.damage),
            OptionPickerItem(title:  "screen_report_card_button_lost_stolen_card".localized, icon: UIImage(named: "icon_lost_stolen_card", in: .yapPakistan), value: PaymentCardBlockOption.lostOrStolen)
            
        ]
    }
}
