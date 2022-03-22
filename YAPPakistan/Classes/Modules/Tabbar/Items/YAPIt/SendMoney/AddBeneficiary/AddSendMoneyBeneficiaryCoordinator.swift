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
   // let root: UINavigationController!
   // var repository: YapItRepositoryType!
    private let sendMoneyType: SendMoneyType!
    private var container: AddBankBeneficiaryContainer //UserSessionContainer
    private let disposeBag = DisposeBag()
   // override var feature: CoordinatorFeature { .addSendMoneyBeneficiary }
    
    private var containerNavigation: UINavigationController!
    private var childContainerNavigation: UINavigationController!
    weak var root: UINavigationController!
    private var containerViewModel: AddSendMoneyBeneficiaryViewModel!
    
    init(root: UINavigationController, container: AddBankBeneficiaryContainer, sendMoneyType: SendMoneyType) {
        self.root = root
       // self.repository = repository
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
           // countrySelection(SendMoneyBeneficiary())
            print("international")
        case .homeCountry(let country, let otherCountries):
         /*   var beneficiary = SendMoneyBeneficiary()
            beneficiary.country = country.isoCode2Digit
            let activeCurrencies = country.currencyList.filter{ $0.isActive }
            let currency = activeCurrencies.filter { $0.isDefault }.first ?? activeCurrencies.first
            beneficiary.countries = otherCountries
            beneficiary.country = country.isoCode2Digit
            beneficiary.type = country.isoCode2Digit == "AE" ? .domestic : (currency?.isRMT ?? false) ? .rmt : .swift
            beneficiary.isRMTCountry = currency?.isRMT ?? false
            beneficiary.currency = currency?.code ?? "AED"
            beneficiary.selectedCountry = country
            beneficiary.selectedResidenceCountry = country
            if country.isoCode2Digit != "AE" {
                beneficiary.countryOfResidence = country.isoCode2Digit
                beneficiary.countryOfResidenceName = country.name
            }
            beneficiaryInfo(beneficiary) */
            print("home country")
        default:
            break
        }
        
        return self.result.do(onNext: { [unowned self] _ in self.root.popToRootViewController(animated: true) })
    }
}

private extension AddSendMoneyBeneficiaryCoordinator {
  /*  func countrySelection(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBCountrySelectionViewModel(beneficiary: SendMoneyBeneficiary(), repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.back.subscribe(onNext: { [unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
        
        let result = viewModel.outputs.result.share()
        
        result.filter { $0.type == nil }.subscribe(onNext: { [unowned self] in
            self.tranferTypeSelection($0)
        }).disposed(by: disposeBag)
        
        result.filter { $0.type == .domestic }.subscribe(onNext: { [unowned self] in
            self.localBankTransfer($0)
        }).disposed(by: disposeBag)
        
        result.filter { $0.type == .rmt || $0.type == .swift }.subscribe(onNext: { [unowned self] in
            self.beneficiaryInfo($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    func tranferTypeSelection(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBTransferTypeSelectionViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.result.filter { $0.type == .cashPayout }.subscribe(onNext: { [unowned self] in
            self.cashPickup($0)
        }).disposed(by: disposeBag)
        
        viewModel.result.filter { $0.type == .domestic }.subscribe(onNext: { [unowned self] in
            self.localBankTransfer($0)
        }).disposed(by: disposeBag)
        
        viewModel.result.filter { $0.type == .rmt || $0.type == .swift }.subscribe(onNext: { [unowned self] in
            self.beneficiaryInfo($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    func cashPickup(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBCashPickupViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.otpRequired.subscribe(onNext: { [weak self] beneficiary in self?.otp(.cashPickupBeneficiary, beneficiary: beneficiary) }).disposed(by: disposeBag)
        otpResult.bind(to: viewModel.inputs.otpResultObserver).disposed(by: disposeBag)
        
        viewModel.outputs.beneficairyAdded.subscribe(onNext: { [unowned self] in
            self.result.onNext(ResultType.success($0))
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    } */
    
    func localBankTransfer(_ beneficiary: SendMoneyBeneficiary) {
        
        let viewModel = AddSendMoneyBeneficiaryViewModel(beneficiary: beneficiary, repository: container.parent.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService) //AddSendMoneyBeneficiaryViewModel(beneficiary: beneficiary, repository: container.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService)
        self.containerViewModel = viewModel
        
        navigateToBankList(beneficiary)
        
        let containerView = container.makeAddBeneficiaryContainerViewController(withViewModel: viewModel, childNavigation: childContainerNavigation) //AddBeneficiaryContainerViewController(themeService: container.themeService, viewModel: viewModel, childNavigation: childContainerNavigation)
        
        containerNavigation = UINavigationController(rootViewController: containerView)
        containerNavigation.navigationBar.isHidden = true
        containerNavigation.interactivePopGestureRecognizer?.isEnabled = false
        childContainerNavigation.interactivePopGestureRecognizer?.isEnabled = false
        
           
        let viewController = container.makeAddSendMoneyBeneficiaryViewController(withViewModel: viewModel, childNavigation: containerNavigation) //AddSendMoneyBeneficiaryViewController(themeService: container.themeService, containerViewModel, childNavigation: containerNavigation)
        
        root.pushViewController(viewController, animated: true)
        
        
        
//        viewModel.outputs.otpRequired.subscribe(onNext: { [weak self] beneficiary in self?.otp(.domesticBeneficiary, beneficiary: beneficiary) }).disposed(by: disposeBag)
//        otpResult.bind(to: viewModel.inputs.otpResultObserver).disposed(by: disposeBag)
        
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
    
  /*  func beneficiaryInfo(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBBeneficiaryInfoViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.result.subscribe(onNext: { [unowned self] in
            if $0.isRMTCountry ?? false {
                self.searchBank($0)
            } else {
                self.manualBankInfo($0)
            }
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    func manualBankInfo(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBBankInfoViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.result.subscribe(onNext: { [unowned self] in
            self.accountInfo($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    } */
    
   /* func searchBank(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBSearchBankViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.result.subscribe(onNext: { [unowned self] in
            self.accountInfo($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    } */
    
  /*  func accountInfo(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBAccountInfoViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
        
        viewModel.outputs.result.subscribe(onNext: { [unowned self] in
            self.overview($0)
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    }
    
    func overview(_ beneficiary: SendMoneyBeneficiary) {
        let viewModel = ASMBBeneficiaryReviewViewModel(beneficiary: beneficiary, repository: repository, sendMoneyType: sendMoneyType)
        let viewController = AddSendMoneyBeneficiaryViewController(viewModel)
        root.pushViewController(viewController, animated: true)
         
        viewModel.outputs.otpRequired.subscribe(onNext: { [weak self] beneficiary in self?.otp(beneficiary.type ?? .swift == .rmt ? .rmtBeneficiary : .nonRmtBeneficiary, beneficiary: beneficiary) }).disposed(by: disposeBag)
        otpResult.bind(to: viewModel.inputs.otpResultObserver).disposed(by: disposeBag)
        
        viewModel.outputs.beneficairyAdded.subscribe(onNext: { [unowned self] in
            self.result.onNext(ResultType.success($0))
            self.result.onCompleted()
        }).disposed(by: disposeBag)
        
        viewModel.outputs.cancel.subscribe(onNext: {[unowned self] in
            self.result.onNext(ResultType.cancel)
            self.result.onCompleted()
        }).disposed(by: disposeBag)
    } */
    
    func otp(_ action: OTPAction, beneficiary: SendMoneyBeneficiary,input: AddBankBeneficiaryRequest) {
        let countryCode = container.accountProvider.currentAccountValue.value?.customer.countryCode ?? "" //""
        let mobileNumber = container.accountProvider.currentAccountValue.value?.customer.mobileNo ?? "" //""
        let formattedPhoneNumber: String = countryCode.replacePrefix("00", with: "+") + " " + mobileNumber
       
       
        let subHeadingText = String(format: "screen_add_beneificiary_otp_display_text_sub_heading".localized, formattedPhoneNumber)
        let viewModel = VerifyMobileOTPViewModel(action: action, heading: "screen_add_beneificiary_otp_display_text_heading".localized, subheading: subHeadingText , repository: container.parent.makeOTPRepository(), mobileNo: formattedPhoneNumber, passcode: "" , backButtonImage: .backEmpty, addBankBeneficiaryInput: input) //VerifyMobileOTPViewModel(action: action, heading: "screen_add_beneificiary_otp_display_text_heading".localized, subheading: "screen_add_beneificiary_otp_display_text_sub_heading".localized , repository: container.makeOTPRepository(), mobileNo: countryCode + mobileNumber, passcode: "" , backButtonImage: .backEmpty)
        let viewController = container.makeVerifyMobileOTPViewController(withViewModel: viewModel) //VerifyMobileOTPViewController(themeService: container.themeService, viewModel: viewModel)
        
//        let nav = UINavigationControllerFactory.createTransparentNavigationBarNavigationController(rootViewController: viewController)
        
//        root.present(nav, animated: true, completion: nil)
        root.pushViewController(viewController, completion: nil)
        
        var otpSubscriptions = [Disposable]()
        
        viewModel.outputs.addBankBeneficiaryResult
            .map{ _ in ResultType<Void>.success(()) }
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)
                self?.containerViewModel.inputs.progressObserver.onNext(.confirmBeneficiaryComplete)
                self?.containerViewModel.inputs.showBeneficiaryAddedObserver.onNext(())
                
                //self?.otpResult.onNext($0)
            }).disposed(by: disposeBag)
        
//        let result = viewModel.outputs.result
//            .map{ _ in ResultType<Void>.success(()) }
//            .subscribe(onNext: { [weak self] in
//                self?.root.popViewController(animated: true)
//                self?.containerViewModel.inputs.progressObserver.onNext(.confirmBeneficiaryComplete)
//                self?.containerViewModel.inputs.showBeneficiaryAddedObserver.onNext(())
//
//                //self?.otpResult.onNext($0)
//            })
        
        let back = viewModel.outputs.back
            .map{ ResultType<Void>.cancel }
            .subscribe(onNext: { [weak self] in
                self?.root.popViewController(animated: true)
               // self?.otpResult.onNext($0)
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

        
        childContainerNavigation = container.makeAddBeneficiaryBankListContainerNavigationController(rootViewController: bankListViewController) //AddBeneficiaryBankListContainerNavigationController(themeService: container.parent.themeService,
//                                                                           rootViewController: bankListViewController)
        childContainerNavigation.navigationBar.isHidden = true

      /*  verificationViewModel.outputs.progress.subscribe(onNext: { [unowned self] progress in
            self.viewModel.inputs.progressObserver.onNext(progress)
        }).disposed(by: disposeBag)

        verificationViewModel.outputs.stage.subscribe(onNext: { [unowned self] stage in
            self.containerViewModel.inputs.activeStageObserver.onNext(stage)
        }).disposed(by: disposeBag)

        verificationViewModel.outputs.valid.subscribe(onNext: { [unowned self] valid in
            self.containerViewModel.inputs.validObserver.onNext(valid)
        }).disposed(by: disposeBag)

        containerViewModel.outputs.send.bind(to: verificationViewModel.inputs.sendObserver).disposed(by: disposeBag)

        verificationViewModel.outputs.result.subscribe(onNext: { [unowned self] result in
            //TODO: uncomment following
            self.navigateToCreatePasscode(user: result)
            
//            //TODO: remove following line
//            var newResult = result
//            newResult.timeTaken = 15
//            self.navigateToWaitingUserCongratulation(user: newResult, session: Session(sessionToken: " abc "))
        }).disposed(by: disposeBag) */
        
        
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

//        viewModel.outputs.invite.subscribe(onNext: { [weak self] in
//            self?.inviteFriend($0.0, self?.name ?? "", appShareUrl: $0.1)
//        }).disposed(by: rx.disposeBag)
//
//        viewModel.outputs.contactSelected.subscribe(onNext: { [weak self] in
//            self?.sendMoney($0)
//        }).disposed(by: rx.disposeBag)
        
        viewModel.outputs.bank.subscribe(onNext: { [unowned self] bank in
            self.navigateToBankDetail(beneficiary, bank: bank)
        }).disposed(by: disposeBag)
    }
    
    func navigateToBankDetail(_ beneficiary: SendMoneyBeneficiary, bank: BankDetail) {
        
        let bankDetailViewModel = AddBeneficiaryBankDetailViewModel(beneficiary: beneficiary, repository: container.parent.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService, bank: bank) //AddBeneficiaryBankDetailViewModel(beneficiary: beneficiary, repository: container.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService, bank: bank)
        let bankDetailViewController = container.makeAddBeneficiaryBankDetailViewController(withViewModel: bankDetailViewModel) //AddBeneficiaryBankDetailViewController(themeService: container.parent.themeService,
//                                                                                viewModel: bankDetailViewModel)

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
        
        let confirmBeneficiaryViewModel = AddBeneficiaryConfirmViewModel(beneficiary: beneficiary, repository: container.parent.makeOTPRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService, bank: bank, accountDetail: accountTitle) //AddBeneficiaryConfirmViewModel(beneficiary: beneficiary, repository: container.makeYapItRepository(), sendMoneyType: sendMoneyType, themeService: container.themeService, bank: bank, accountDetail: accountTitle)
        let confirmBeneficiaryViewController =  container.makeAddBeneficiaryConfirmViewController(withViewModel: confirmBeneficiaryViewModel) //AddBeneficiaryConfirmViewController(themeService: container.parent.themeService,
//                                                                                viewModel: confirmBeneficiaryViewModel)

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