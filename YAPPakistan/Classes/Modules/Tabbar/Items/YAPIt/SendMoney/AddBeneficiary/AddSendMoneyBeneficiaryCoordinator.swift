//
//  AddSendMoneyBeneficiaryCoordinator.swift
//  YAPPakistan
//
//  Created by Yasir on 14/03/2022.
//

import Foundation
import YAPCore
import YAPComponents
import RxSwift

class AddSendMoneyBeneficiaryCoordinator: Coordinator<ResultType<SendMoneyBeneficiary?>> {
    
    let result = PublishSubject<ResultType<SendMoneyBeneficiary?>>()
    let otpResult = PublishSubject<ResultType<Void>>()
    private let sendMoneyType: SendMoneyType!
    private var container: AddBankBeneficiaryContainer
    private let disposeBag = DisposeBag()
   
    
    private var containerNavigation: UINavigationController!
    private var childContainerNavigation: UINavigationController!
    weak var root: UINavigationController!
    private var containerViewModel: AddSendMoneyBeneficiaryViewModel!
    
    init(root: UINavigationController, container: AddBankBeneficiaryContainer, sendMoneyType: SendMoneyType) {
        self.root = root
        self.container = container
        self.sendMoneyType = sendMoneyType
    }
    
    deinit {
        print("deinit: AddSendMoneyBeneficiaryCoordinator")
    }
    
    override func start(with option: DeepLinkOptionType?) -> Observable<ResultType<SendMoneyBeneficiary?>> {
        
        switch sendMoneyType {
        case .local:
            var beneficiary = SendMoneyBeneficiary()
            beneficiary.country = "Pakistan"
            beneficiary.currency = "PkR"
            beneficiary.type = .domestic
            localBankTransfer(beneficiary)
        case .international:
            print("international")
        case .homeCountry(let country, let otherCountries):
            print("home country")
        default:
            break
        }
        
        return self.result.do(onNext: { [unowned self] _ in self.root.popToRootViewController(animated: true) })
    }
}

private extension AddSendMoneyBeneficiaryCoordinator {
    
    func localBankTransfer(_ beneficiary: SendMoneyBeneficiary) {
        
        let viewModel = AddSendMoneyBeneficiaryViewModel(beneficiary: beneficiary, repository: container.parent.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService)
        self.containerViewModel = viewModel
        
        navigateToBankList(beneficiary)
        
        let containerView = container.makeAddBeneficiaryContainerViewController(withViewModel: viewModel, childNavigation: childContainerNavigation)
        
        containerNavigation = UINavigationController(rootViewController: containerView)
        containerNavigation.navigationBar.isHidden = true
        containerNavigation.interactivePopGestureRecognizer?.isEnabled = false
        childContainerNavigation.interactivePopGestureRecognizer?.isEnabled = false
        
           
        let viewController = container.makeAddSendMoneyBeneficiaryViewController(withViewModel: viewModel, childNavigation: containerNavigation)
        
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.beneficairyAdded.subscribe(onNext: { [weak self] in
            self?.result.onNext(ResultType.success($0))
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[weak self]  in
            self?.root.popViewController(animated: true, nil)
            self?.result.onNext(ResultType.cancel)
            self?.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.back.withLatestFrom(containerViewModel.outputs.progress).subscribe(onNext: {[weak self] stage in
            switch stage {
            case .bankName:
                self?.root.popViewController(animated: true, nil)
                self?.result.onNext(ResultType.cancel)
                self?.result.onCompleted()
            case .bankNameComplete:
                self?.childContainerNavigation.popViewController(animated: true)?.didPopFromNavigationController()
                self?.containerViewModel.inputs.progressObserver.onNext(.bankName)
            case .confirmBeneficiary:
                self?.childContainerNavigation.popViewController(animated: true)?.didPopFromNavigationController()
                self?.containerViewModel.inputs.progressObserver.onNext(.bankAccountDetailComplete)
            case .bankAccountDetailComplete:
                self?.childContainerNavigation.popViewController(animated: true)?.didPopFromNavigationController()
                self?.containerViewModel.inputs.progressObserver.onNext(.bankName)
            default:
                break
            }
        }).disposed(by: disposeBag)
    }
    
    func otp(_ action: OTPAction, beneficiary: SendMoneyBeneficiary,input: AddBankBeneficiaryRequest) {
        let countryCode = container.accountProvider.currentAccountValue.value?.customer.countryCode ?? "" //""
        let mobileNumber = container.accountProvider.currentAccountValue.value?.customer.mobileNo ?? "" //""
        let formattedPhoneNumber: String = countryCode.replacePrefix("00", with: "+") + " " + mobileNumber
       
       
        let subHeadingText = String(format: "screen_add_beneificiary_otp_display_text_sub_heading".localized, formattedPhoneNumber)
        let viewModel = VerifyMobileOTPViewModel(action: action, heading: "screen_add_beneificiary_otp_display_text_heading".localized, subheading: subHeadingText , otpTime: 30, repository: container.parent.makeOTPRepository(), mobileNo: formattedPhoneNumber, passcode: "" , backButtonImage: .backEmpty, addBankBeneficiaryInput: input)
        let viewController = container.makeVerifyMobileOTPViewController(withViewModel: viewModel)
        root.pushViewController(viewController, completion: nil)
        
        var otpSubscriptions = [Disposable]()
        
        viewModel.outputs.addBankBeneficiaryResult
            .map{ _ in ResultType<Void>.success(()) }
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)
                self?.containerViewModel.inputs.progressObserver.onNext(.confirmBeneficiaryComplete)
                self?.containerViewModel.inputs.showBeneficiaryAddedObserver.onNext(())
            }).disposed(by: disposeBag)
    
        let back = viewModel.outputs.back
            .map{ ResultType<Void>.cancel }
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)
            })
        
        otpSubscriptions.append(result)
        otpSubscriptions.append(back)
        
        
        containerViewModel.outputs.beneficairyAdded.subscribe(onNext: { [weak self] beneficiary in
            if let bene = beneficiary {
                self?.result.onNext(ResultType.success(bene))
            } else {
                self?.result.onNext(ResultType.success(nil))
            }
            self?.result.onCompleted()
        }).disposed(by: disposeBag)

        
        otpResult.subscribe(onNext: { _ in otpSubscriptions.forEach{ $0.dispose() } }).disposed(by: disposeBag)
    }
}

extension AddSendMoneyBeneficiaryCoordinator {
    func navigateToBankList(_ beneficiary: SendMoneyBeneficiary) {
        
        let bankListViewModel = AddBeneficiaryBankListViewModel(beneficiary: beneficiary, repository: container.parent.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService)
        let bankListViewController = container.makeAddBeneficiaryBankListViewController(withViewModel: bankListViewModel)

        
        childContainerNavigation = container.makeAddBeneficiaryBankListContainerNavigationController(rootViewController: bankListViewController)
        childContainerNavigation.navigationBar.isHidden = true

        bankListViewModel.outputs.search.subscribe(onNext: { [unowned self] result in
            self.navigateToSearchBanks(beneficiary,result ?? [])
        }).disposed(by: disposeBag)
        
        bankListViewModel.outputs.bank.subscribe(onNext: { [unowned self] bank in
            self.navigateToBankDetail(beneficiary, bank: bank)
        }).disposed(by: disposeBag)
    }
    
    func navigateToSearchBanks(_ beneficiary: SendMoneyBeneficiary ,_ banks: [BankDetail]) {
        let viewModel = BankListSearchViewModel(banks)
        let viewController = BankListSearchViewController(themeService: container.themeService, viewModel: viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.bank.subscribe(onNext: { [unowned self] bank in
            self.navigateToBankDetail(beneficiary, bank: bank)
        }).disposed(by: disposeBag)
    }
    
    func navigateToBankDetail(_ beneficiary: SendMoneyBeneficiary, bank: BankDetail) {
        
        let bankDetailViewModel = AddBeneficiaryBankDetailViewModel(beneficiary: beneficiary, repository: container.parent.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService, bank: bank)
        let bankDetailViewController = container.makeAddBeneficiaryBankDetailViewController(withViewModel: bankDetailViewModel)

        childContainerNavigation.pushViewController(bankDetailViewController, animated: true)
        
        containerViewModel.inputs.progressObserver.onNext(.bankNameComplete)
        
        bankDetailViewModel.outputs.showError.map { _ -> String? in
           return "screen_add_beneficiary_detail_display_text_bank_account_detail_error".localized
        }.bind(to: containerViewModel.inputs.bankDetailErrorObserver).disposed(by: disposeBag)
        
        bankDetailViewModel.outputs.confirmBeneficiaryData.subscribe(onNext: { [unowned self] _arg1 in
            let (bank, accountTitle) = _arg1
            self.navigateToConfirmBeneficiary(beneficiary, bank: bank, accountTitle: accountTitle)
        }).disposed(by: disposeBag)
    }
    
    func navigateToConfirmBeneficiary(_ beneficiary: SendMoneyBeneficiary, bank: BankDetail, accountTitle: BankAccountDetail) {
        
        let confirmBeneficiaryViewModel = AddBeneficiaryConfirmViewModel(beneficiary: beneficiary, repository: container.parent.makeOTPRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService, bank: bank, accountDetail: accountTitle)
        let confirmBeneficiaryViewController =  container.makeAddBeneficiaryConfirmViewController(withViewModel: confirmBeneficiaryViewModel) 

        childContainerNavigation.pushViewController(confirmBeneficiaryViewController, animated: true)
        
        containerViewModel.inputs.progressObserver.onNext(.confirmBeneficiary)
        
        confirmBeneficiaryViewModel.outputs.otpResult.withUnretained(self).subscribe(onNext: {  `self`,result in
            switch result {
            case .success(let input):
                print(input)
                self.otp(.ibft, beneficiary: beneficiary,  input: input)
            case .cancel:
                break
            }
        }).disposed(by: disposeBag)

    }
}
