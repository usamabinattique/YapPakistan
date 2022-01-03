//
//  YAPRangeSliderFactory.swift
//  YAPPakistan
//
//  Created by Umair  on 30/12/2021.
//

import Foundation
import RxTheme
import RxSwift
import RxCocoa

public class YAPRangeSliderFactory: RangeSeekSlider {
    
    public func setupStyle(for theme: ThemeService<AppTheme>) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        handleImage = UIImage(named: "icon_map_pin_purple", in: .yapPakistan)
        minValue = 0.0
        maxValue = 1000
        selectedMinValue = 15.0
        selectedMaxValue = 1000
        minDistance = 1.0
        colorBetweenHandles = UIColor(theme.attrs.primary)
        tintColor = UIColor(theme.attrs.primary).withAlphaComponent(0.16)
        hideLabels = true
    }
}
