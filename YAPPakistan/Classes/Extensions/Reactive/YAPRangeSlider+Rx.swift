//
//  YAPRangeSlider+Rx.swift
//  YAPPakistan
//
//  Created by Umair  on 31/12/2021.
//

import Foundation
import RxCocoa
import RxSwift
import YAPComponents

class RangeSeekSliderDelegateProxy :
    DelegateProxy<RangeSeekSlider, RangeSeekSliderDelegate>, DelegateProxyType, RangeSeekSliderDelegate {
    
    override init<Proxy>(parentObject: DelegateProxy<RangeSeekSlider, RangeSeekSliderDelegate>.ParentObject, delegateProxy: Proxy.Type) where RangeSeekSlider == Proxy.ParentObject, RangeSeekSliderDelegate == Proxy.Delegate, Proxy : DelegateProxy<RangeSeekSlider, RangeSeekSliderDelegate>, Proxy : DelegateProxyType {
        super.init(parentObject: parentObject, delegateProxy: delegateProxy)
    }
    
    static func registerKnownImplementations() {
        self.register { RangeSeekSliderDelegateProxy(parentObject: $0, delegateProxy: RangeSeekSliderDelegateProxy.self) }
    }
    
    static func currentDelegate(for object: RangeSeekSlider) -> RangeSeekSliderDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: RangeSeekSliderDelegate?, to object: RangeSeekSlider) {
        object.delegate = delegate
    }
}


//MARK: Reactive

extension Reactive where Base: RangeSeekSlider {
    var delegate: RangeSeekSliderDelegateProxy {
        return RangeSeekSliderDelegateProxy.proxy(for: base)
    }
    
    var didChange: Observable<(minValue: CGFloat, maxValue: CGFloat)> {
        delegate.methodInvoked(#selector(RangeSeekSliderDelegate.rangeSeekSlider(_:didChange:maxValue:)))
            .map { ($0[1] as! CGFloat, $0[2] as! CGFloat) }
    }
}



