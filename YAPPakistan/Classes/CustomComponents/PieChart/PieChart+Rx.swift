//
//  PieChart+Rx.swift
//  YAPPakistan
//
//  Created by Yasir on 16/05/2022.
//

import Foundation
import RxCocoa
import RxSwift

public extension Reactive where Base: PieChart {
    var selectedIndex: ControlProperty<Int> {
        return base.rx.controlProperty(editingEvents: .valueChanged, getter: { pieChart in
            return pieChart.selectedIndex
        }) { (pieChart, index) in
            pieChart.selectedIndex = index
        }
    }
    
    var components: Binder<[PieChartComponent]> {
        return Binder(self.base) { pieChart, components -> Void in
            pieChart.components = components
        }
    }
    
    var selectionEnabled: Binder<Bool> {
        return Binder(self.base) { pieChart, selection -> Void in
            pieChart.selectionEnabled = selection
        }
    }
}
