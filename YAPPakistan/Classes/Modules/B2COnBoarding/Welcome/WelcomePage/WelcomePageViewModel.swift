//
//  WelcomePageViewModel.swift
//  YAP
//
//  Created by Zain on 19/06/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift


protocol WelcomePageViewModelInput {
    var selectedPageObserver: AnyObserver<Int> { get }
}

protocol WelcomePageViewModelOutput {
    var pageChildViewModels: Observable<[WelcomePageChildViewModelType]> { get }
    var selectedPage: Observable<Int> { get }
}

protocol WelcomePageViewModelType {
    var inputs: WelcomePageViewModelInput { get }
    var outputs: WelcomePageViewModelOutput { get }
}

class WelcomePageViewModel: WelcomePageViewModelInput, WelcomePageViewModelOutput, WelcomePageViewModelType {
    var inputs: WelcomePageViewModelInput { return self }
    var outputs: WelcomePageViewModelOutput { return self }
    
    fileprivate var pageChildViewModelsSubject = BehaviorSubject<[WelcomePageChildViewModelType]>(value: [])
    private var selectedPageSubject = PublishSubject<Int>()
    
    //inputs
    var selectedPageObserver: AnyObserver<Int> { return selectedPageSubject.asObserver() }
    
    //outputs
    var selectedPage: Observable<Int> { return selectedPageSubject.asObservable() }
    var pageChildViewModels: Observable<[WelcomePageChildViewModelType]> { return pageChildViewModelsSubject.asObservable() }
    
    init() {
        generateChildViewModels()
    }
    
    fileprivate func generateChildViewModels() { }
}

class B2CWelcomPageViewModel: WelcomePageViewModel {
    override func generateChildViewModels() {
        var viewModels = [WelcomePageChildViewModelType]()
        
        viewModels.append(WelcomePageChildViewModel(heading: "screen_welcome_b2c_display_text_page1_title".localized, details: "screen_welcome_b2c_display_text_page1_details".localized, image: UIImage(named: "image_welcom_page1", in: .yapPak, compatibleWith: nil)))
        
        viewModels.append(WelcomePageChildViewModel(heading: "screen_welcome_b2c_display_text_page2_title".localized, details: "screen_welcome_b2c_display_text_page2_details".localized, image: UIImage(named: "image_welcom_page2", in: .yapPak, compatibleWith: nil)))
        
        viewModels.append(WelcomePageChildViewModel(heading: "screen_welcome_b2c_display_text_page3_title".localized, details: "screen_welcome_b2c_display_text_page3_details".localized, image: UIImage(named: "image_welcom_page3", in: .yapPak, compatibleWith: nil)))
        
        pageChildViewModelsSubject.onNext(viewModels)
    }
}
