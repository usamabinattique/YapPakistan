//
//  WelcomeViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 05/04/2022.
//

import Foundation
import RxSwift
import UIKit


public protocol WelcomeViewModelOutputs {
    var icon: Observable<UIImage?> { get }
    var title: Observable<String> {get}
    var desc: Observable<String> {get}
}
public protocol WelcomeViewModelInputs {
    
}

public protocol WelcomeViewModelType {
    var outputs: WelcomeViewModelOutputs { get }
    var inputs: WelcomeViewModelInputs { get }
}

public class WelcomeViewModel: WelcomeViewModelType, WelcomeViewModelInputs, WelcomeViewModelOutputs {
    
    public var inputs: WelcomeViewModelInputs {self}
    public var outputs: WelcomeViewModelOutputs{self}
    
    
    //MARK: subjects
    private let iconSubject = BehaviorSubject<UIImage?>(value: nil)
    private let titleSubject = BehaviorSubject<String>(value: "")
    private let descSubject = BehaviorSubject<String>(value: "")
    
    //MARK: outputs
    public var icon: Observable<UIImage?> { iconSubject.asObservable() }
    public var title: Observable<String> { titleSubject.asObservable() }
    public var desc: Observable<String> { descSubject.asObservable() }
    
  //  private let featureFlagClient = FeatureFlagClient()
    private let disposeBag = DisposeBag()
    init() {
        
        iconSubject.onNext(UIImage.init(named: "icon_coin", in: .yapPakistan))
        titleSubject.onNext("Welcome to YAP")
        descSubject.onNext("Add money to your YAP card to start spending")
    }
    
}
