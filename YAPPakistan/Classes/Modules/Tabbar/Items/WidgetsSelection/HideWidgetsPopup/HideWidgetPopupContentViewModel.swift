//
//  HideWidgetPopupContentViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 21/04/2022.
//

import Foundation
import RxSwift

class HideWidgetPopupContentViewModel {
    
    //MARK:- Inputs
    var hideWidgetObserver: AnyObserver<Void> { hideWidgetSubject.asObserver() }
    var cancelObserver: AnyObserver<Void> { cancelSubject.asObserver() }
    
    //MARK:- outputs
    var hideWidget: Observable<Void> { hideWidgetSubject }
    var cancel: Observable<Void> { cancelSubject }
    
    //MARK:- Subjects
    private let hideWidgetSubject = PublishSubject<Void>()
    private let cancelSubject = PublishSubject<Void>()
    
    init() {
    }
    
}
