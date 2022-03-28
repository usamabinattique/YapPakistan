//
//  ESMBBankTransferViewModel.swift
//  YAPPakistan
//
//  Created by Muhammad Sohaib on 15/03/2022.
//

import Foundation
import RxSwift

class ESMBBankTransferViewModel: EditSendMoneyBeneficiaryViewModel {
    
    override func generateCellViewModels() {
        
        var validations = [Observable<Bool>]()
        
        let userImageAndInfo = YapContactCellViewModel(beneficiary.title ?? "", iban: beneficiary.IBAN ?? "", profilePhoto: beneficiary.profilePhoto)
        profilePictureUpdatedSubject.subscribe(onNext: { imageURL in userImageAndInfo.inputs.updateProfilePicture.onNext((imageURL, nil))}).disposed(by: disposeBag)
        userImageAndInfo.outputs.addProfilePicture.bind(to: addProfilePictureObserver).disposed(by: disposeBag)
        viewModels.append(userImageAndInfo)
        
        let transferType = ASMBTextInputCellViewModelPlainText(.transferType, beneficiary: beneficiary, isReviewing: true, isEnabled: false)
        transferType.inputs.textObserver.onNext(beneficiary.type?.localizeDescription)
        viewModels.append(transferType)
        
        let bankInfo = ASMBBankInfoCellViewModel(beneficiary)
        viewModels.append(bankInfo)
        
        let nickname = ASMBTextInputCellViewModelPlainText(.nickname, isReviewing: true)
        nickname.inputs.textObserver.onNext(beneficiary.nickName)
        nickname.outputs.text.subscribe(onNext: { [unowned self] in self.beneficiary.nickName = $0 }).disposed(by: disposeBag)
        validations.append(nickname.outputs.valid)
        viewModels.append(nickname)
    }
}
