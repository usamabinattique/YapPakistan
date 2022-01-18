//
//  AppSearchBarDelegate.swift
//  YAPKit
//
//  Created by Zain on 22/08/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation

public protocol AppSearchBarDelegate: NSObjectProtocol {
    func searchBarShouldBeginEditing(searchBar: AppSearchBar) -> Bool
    func searchBarTextDidBeginEditing(searchBar: AppSearchBar)
    func searchBarShouldEndEditing(searchBar: AppSearchBar) -> Bool
    func searchBarTextDidEndEditing(searchBar: AppSearchBar)
    func searchBar(_ searchBar: AppSearchBar, textDidChange searchText: String)
    func searchBar(_ searchBar: AppSearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    func searchBarCancelButtonClicked(_ searchBar: AppSearchBar)
}

public extension AppSearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: AppSearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: AppSearchBar) {}
    
    func searchBarShouldEndEditing(searchBar: AppSearchBar) -> Bool {
        return true
    }
    
    func searchBarTextDidEndEditing(searchBar: AppSearchBar) {}
    
    func searchBar(_ searchBar: AppSearchBar, textDidChange searchText: String) {}
    
    func searchBar(_ searchBar: AppSearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: AppSearchBar) { }
}
