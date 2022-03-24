//
//  SearchableActionSheetViewModel.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import Foundation
import RxSwift
import RxDataSources

typealias EnumeratedData = (index: Int, data: SearchableDataType)

public protocol SearchableDataType {
    var title: String { get }
    var icon: UIImage? { get }
    var selected: Bool { get }
    var isAttributedTitle: Bool { get }
    var attributedTitle: NSAttributedString? { get }
    var showsIcon: Bool { get }
}

public extension SearchableDataType {
    var selected: Bool { false }
    var isAttributedTitle: Bool { false }
    var attributedTitle: NSAttributedString? { nil }
    var showsIcon: Bool { true }
}

protocol SearchableActionSheetViewModelInput {
    var searchTextObserver: AnyObserver<String?> { get }
    var itemSelectedObserver: AnyObserver<Int> { get }
    var closeObserver: AnyObserver<Void> { get }
}

protocol SearchableActionSheetViewModelOutput {
    var sectionModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { get }
    var title: Observable<String?> { get }
    var searchPlaceholder: Observable<String?> { get }
    var itemSelected: Observable<Int> { get }
}

protocol SearchableActionSheetViewModelType {
    var inputs: SearchableActionSheetViewModelInput { get }
    var outputs: SearchableActionSheetViewModelOutput { get }
}

class SearchableActionSheetViewModel: SearchableActionSheetViewModelInput, SearchableActionSheetViewModelOutput, SearchableActionSheetViewModelType {
    
    var inputs: SearchableActionSheetViewModelInput { self }
    var outputs: SearchableActionSheetViewModelOutput { self }
    
    private let disposeBag = DisposeBag()
    
    private let sectionModelsSubject: BehaviorSubject<[SectionModel<Int, ReusableTableViewCellViewModelType>]>
    private let titleSubject: BehaviorSubject<String?>
    private let searchPlaceholderSubject: BehaviorSubject<String?>
    private let textSubject: BehaviorSubject<String?>
    private let itemSelectedSubject = PublishSubject<Int>()
    private let closeSubject = PublishSubject<Void>()
    
    private let items: [EnumeratedData]
    
    // MARK: - Inputs
    
    var itemSelectedObserver: AnyObserver<Int> { itemSelectedSubject.asObserver() }
    var searchTextObserver: AnyObserver<String?> { textSubject.asObserver() }
    var closeObserver: AnyObserver<Void> { closeSubject.asObserver() }
    
    // MARK: - Ouputs
    
    var sectionModels: Observable<[SectionModel<Int, ReusableTableViewCellViewModelType>]> { sectionModelsSubject.asObservable() }
    var title: Observable<String?> { titleSubject.asObservable() }
    var searchPlaceholder: Observable<String?> { searchPlaceholderSubject.asObservable() }
    var itemSelected: Observable<Int> { itemSelectedSubject.asObservable() }
    
    // MARK: - Initialization
    
    init(_ title: String? = nil, searchPlaceholderText: String = "Search", items: [SearchableDataType]) {
        var data = [EnumeratedData]()
        var index = 0
        for item in items {
            data.append((index: index, data: item))
            index += 1
        }
        self.items = data
        
        titleSubject = BehaviorSubject(value: title)
        searchPlaceholderSubject = BehaviorSubject(value: searchPlaceholderText)
        textSubject = BehaviorSubject(value: nil)
        
        sectionModelsSubject = BehaviorSubject(value: [SectionModel(model: 0, items: self.items.map{ SearchableActionSheetTableViewCellViewModel($0.data, index: $0.index) })])
        search()
        
        closeSubject.subscribe(onNext: { [weak self] in
            self?.itemSelectedSubject.onNext(-1)
            self?.itemSelectedSubject.onCompleted()
        }).disposed(by: disposeBag)
    }
}

// MARK: - Search

private extension SearchableActionSheetViewModel {
    func search() {
        textSubject
            .map{ [unowned self] text -> [EnumeratedData] in
                if (text?.isEmpty ?? true){
                    return self.items
                }  else {
                    return self.items.filter{ $0.data.title.lowercased().contains(text!.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)) }
                } }
            .map{ [SectionModel(model: 0, items: $0.map{ SearchableActionSheetTableViewCellViewModel($0.data, index: $0.index) })] }
            .bind(to: sectionModelsSubject)
            .disposed(by: disposeBag)
    }
}
