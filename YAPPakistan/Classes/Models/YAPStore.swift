//
//  YAPStore.swift
//  YAPPakistan
//
//  Created by Umair  on 23/04/2022.
//

import Foundation

enum StorePackageType {
    case cardPlans
    case yapYoung
    case yapHousehold
}

extension StorePackageType {
    var localize: String {
        switch self {
        case .cardPlans:
            return "Card Plans"
        case .yapYoung:
            return "YAP Young"
        case .yapHousehold:
            return "YAP Household"
        }
    }
}

struct YAPStore {
    let coverImage: String
    let packageLogo: String
    let heading: String
    let packageDescription: String
    let commingSoonIsHeaden: Bool
    let storePackageType: StorePackageType
}

extension YAPStore {
    static var mock: [YAPStore] {
        [
            /*YAPStore(coverImage: "image_cards_and_plans",
                  packageLogo: "icon_prime_&_metal_card",
                  heading: StorePackageType.cardPlans.localize,
                  packageDescription: "Upgrade your plan to Prime or Metal to supercharge your YAP experience",
                  commingSoonIsHeaden: true, storePackageType: .cardPlans), */
         
         YAPStore(coverImage: "image_store_young",
                  packageLogo:"icon_yap_young",
                  heading: StorePackageType.yapYoung.localize,
                  packageDescription: "Open a bank account for your children and help empower them financially.",
                  commingSoonIsHeaden: true, storePackageType: .yapYoung),
         
         YAPStore(coverImage: "image_store_household",
                  packageLogo: "icon_yap_household",
                  heading: StorePackageType.yapHousehold.localize,
                  packageDescription: "Manage your household salaries digitally.",
                  commingSoonIsHeaden: true, storePackageType: .yapHousehold)]
    }
}

