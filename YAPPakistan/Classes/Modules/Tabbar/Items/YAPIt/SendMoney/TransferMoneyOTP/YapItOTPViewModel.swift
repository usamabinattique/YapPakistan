//
//  YapItOTPViewModel.swift
//  YAP
//
//  Created by Zain on 15/10/2019.
//  Copyright © 2019 YAP. All rights reserved.
//

import Foundation
import RxSwift

public protocol YapItBeneficiary {
    var name: String { get }
    var countryFlag: UIImage? { get }
    var profilePhoto: (photoUrl: String?, initialsImage: UIImage?) { get }
}
