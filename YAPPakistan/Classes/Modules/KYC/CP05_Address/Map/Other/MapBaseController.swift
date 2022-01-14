//
//  MapBaseController.swift
//  OARApp
//
//  Created by Abbas on 06/10/2020.
//  Copyright © 2020 Abbas. All rights reserved.
//
import UIKit
import GoogleMaps
import GooglePlaces

/*

class MapBaseController: MapViewController {
    //@IBOutlet weak var lblJobLocation: APLabel!
    lazy var chatVC:ChatViewController = ChatViewController(target: self)
    var message:PubNubData!
    
    let lblTitle:APLabel = APLabel(fontSize: .font16, color: .darkText, weight: .bold).textAlignment(.center)
    let topView = UIView.getView(.white).shaddow() //.shaddow(radius: 15, color: Theme.Colors.backGround, opacity: 1, offset: CGSize(width: 0, height: 30))
    let btnBack:UIButton = {
        let button = UIButton()
        let attributes = [NSAttributedString.Key.foregroundColor : Theme.Colors.darkText,
                          NSAttributedString.Key.font : UIFont.fontAwesome(ofSize: .font26)]
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setAttributedTitle(NSAttributedString(string: "angle-left", attributes: attributes), for: .normal)
        return button
    }()
    
    
    weak var bottomSheet:JobBottomView?
    var sourceMarker:GMSMarker?
    var destinatinMarker:GMSMarker?
    var currentService = Service()
    var polyline:GMSPolyline?
    var isNotificationTapped = false
    var loadRunningJobs:  Bool  = true {didSet { DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in self?.loadRunningJobs = true }}}
    var isNewMessage = false
    
    var isPubnubListnerAdded = false
    
    //MARK:- PUBNUB SETUP
    var channels:[String] = []
    let listener = SubscriptionListener(queue: .main)
    
    var requestState:RequestState = .unknown {
        didSet {
            switch self.requestState {
            case .unknown: self.markerImage.isHidden = false
            default: self.markerImage.isHidden = true
            }
            self.requestStateDidUpdated()
        }
    }
    
    deinit {
        pubnub.unsubscribeAll()
    }
    
    override func loadView() {
        super.loadView()
        uiLayoutAdjustments()
    }
    
    override func viewDidLoad() {
        //uiLayoutAdjustments()
        super.viewDidLoad()
        self.profileSetup()
        
        //if let vcs = self.navigationController?.viewControllers, let first = vcs.first, let last = vcs.last {
        //    self.navigationController?.viewControllers = [first, last]
        //}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func newMessageCountDidUpdated() {
        bottomSheet?.newMsgView.isHidden = User.newMsgIDDicts.count == 0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        User.msgUserPicUrl = self.currentService.user_detail.profile_picture_url
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //NotificationCenter.default.removeObserver(self)
    }
    
    override func addTopConstraints_to_mapView_txtSearch(_ view:UIView) {
        mapView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        txtSearch.topAnchor.constraint(equalTo: lblTitle.bottomAnchor, constant: Theme.adjustRatio(16) ).isActive = true
    }
    
    override func initialSetup() {
        super.initialSetup()
        
    }
    
    
}

extension MapBaseController {
    //MARK: - APIs
    
    func getServiceDetail(jobId:Int, isModify:Bool = false, completion:((APIResponseStatus, Service?) -> Void)? = nil) {
        //self.requestState = .gettingJobDetails
        
        let endPoint = OarAPI.serviceRequest(.fetchDetail).endPoint
        let parms:[String:Any] = [
            "serviceRequestId":jobId,
            "role":AppDelegate.isForWorker ? 3:2,
            "language":LanguageManager.shared.currentLanguage,
            "isModify":"\(isModify ? 1:0)"
        ]
        
        postRequestJSONAuth(endPoint, parms: parms) { [weak self] (status, json) in
        guard let self = self else { return }
            if status.isSuccess, let json = json {
                let service = Service(json: json)
                if !AppDelegate.isForWorker {
                    runningServices[service.id] = service
                }
                let result = Service.compareServices(newService: service, oldService: self.currentService)
                print("THE DIFFERENCE BETWEEN NEW AND OLD SERVICE DETAILS:\n\(result)")
                
                completion?(status, service)
                //self.requestState = .trackingWorker(service)
            } else {
                completion?(status, nil)
                //self.requestState = .failed(status.message)
            }
        }
    }
    
    func updateServiceStatus(status:ServiceStatus, code:String? = nil, completion:((APIResponseStatus) -> Void)? = nil) {
        let endPoint = OarAPI.serviceRequest(.updateStatus).endPoint
        
        var parms:[String:Any] = [
            "serviceRequestId":self.currentService.id,
            "status":status.value,
            //"startDateTime":self.currentService.start_date_time,
            //"code":self.currentService.service_code,
            "time_zone":"GMT+05:00",
            "language":LanguageManager.shared.currentLanguage,
            "timeSpent":"0"
        ]
        
        if let code = code {
            parms["code"] = code
        }
        
        postRequestJSONAuth(endPoint, parms: parms) { (status, json) in
            if status.isSuccess, let _ = json {
                completion?(status)
                //switch self.requestState {
                //case .markedCompleted:
                //    self.requestState = .completed
                //default:
                //    self.requestState = .canceled(status.message)
                //}
            } else {
                completion?(status)
                //self.requestState = .failed(status.message)
            }
        }
    }
    
    func postRating(rating:Double, comment:String, completion: @escaping (APIResponseStatus)->Void) {
        let endPoint = OarAPI.serviceRequest(.rateUser).endPoint
        let parms:[String:Any] = [
            "serviceRequestId":"\(currentService.id)",
            "ratedTo":"\( currentService.user_detail.id)",
            "rating":"\(round(rating * 100)/100)",
            "language":LanguageManager.shared.currentLanguage,
            "comment":comment
        ]
        
        postRequestJSONAuth(endPoint, parms: parms) { (status, json) in
            completion(status)
        }
    }
}

//MARK: - Map Routes Unility Methods
extension MapBaseController {
    func drawPath(origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        LocationManager.shared.getRoutePoints(origin: origin, destination: destination) {
            [weak self] (isSuccess, message, points) in guard let self = self else { return }
            if isSuccess {
                self.drawPath(from: points)
            } else {
                self.requestState = .failed(message)
            }
        }
    }
    
    func drawPath(from polyStr: String){
        polyline?.map = nil
        let path = GMSPath(fromEncodedPath: polyStr)
        self.polyline = GMSPolyline(path: path)
        polyline?.strokeWidth = 5.0
        polyline?.strokeColor = Theme.Colors.backGroundBlue
        polyline?.map = mapView // Google MapView
    }
}

//MARK:- BUBNUB Setups
extension MapBaseController {
    
    func setupChannels() {
        channels = [currentService.chat_communication_channel + "_chat", currentService.chat_communication_channel]
    }
    
    func sendAck(completion:((APIResponseStatus) -> Void)?) {
        let msgAck = PubNubData()
        msgAck.messageType = .chat_read
        msgAck.id = User.current?.id.intValue ?? 0
        msgAck.message_id = Int(Date().timeIntervalSince1970)
        
        pubnub.publish(channel: channels[0], message:msgAck.getData() , shouldStore: true, storeTTL: 24 * 3, meta: nil, shouldCompress: false, custom: PubNub.RequestConfiguration()) { (result) in
            switch result {
            case .success(_):
                completion?(APIResponseStatus.init(isSuccess: true, code: 1, message: "Success"))
            case let .failure(error):
                completion?(APIResponseStatus.init(isSuccess: false, code: 0, message: error.localizedDescription))
            }
        }
    }
    
    func send(message:JSONCodable, toChannel channel:String, completion:((APIResponseStatus) -> Void)?) {
        let shouldStore = false
        pubnub.publish(channel: channel, message: message, shouldStore: shouldStore, storeTTL: 24 * 3, meta: nil, shouldCompress: false, custom: PubNub.RequestConfiguration()) { (result) in
            switch result {
            case .success(_):
                completion?(APIResponseStatus.init(isSuccess: true, code: 1, message: "Success"))
            case let .failure(error):
                completion?(APIResponseStatus.init(isSuccess: false, code: 0, message: error.localizedDescription))
            }
        }
    }
    
    fileprivate func sendMessage(_ message: PubNubData, sendNotification:Bool, _ completion: ((APIResponseStatus) -> Void)?) {
        let topic = AppDelegate.isForWorker ? "net.suavesolutions.oarcustomerapp":"net.suavesolutions.oarworkerapp"
        
        let msgData = message.getData()
        //var apnsData = msgData
        
        
        let payload = PubNubPushMessage(
            apns: PubNubAPNSPayload (
                aps: APSPayload(
                    alert: .object(
                        .init(
                            title: message.name,
                            body: message.text
                        )
                    ),
                    badge: 1,
                    sound: .string("default"),
                    contentAvailable: 1,
                    mutableContent: 1,
                    apnsExpiration: -1,
                    apnsPriority: 10
                ),
                pubnub: [.init(targets: [.init(topic: topic, environment: .development)])],
                payload: msgData
            ),
            fcm: PubNubFCMPayload (
                payload: msgData,
                target: nil,
                notification: FCMNotificationPayload(title: message.name, body: message.text),
                android: FCMAndroidPayload(notification: FCMAndroidNotification(sound: "default"))
            ),
            additional: msgData
        )
        
        pubnub.publish(
            channel: channels[0],
            message: sendNotification ? payload:msgData,
            shouldStore: true,
            storeTTL: 24 * 3,
            meta: nil,
            shouldCompress: false,
            custom: PubNub.RequestConfiguration()
        ) { (result) in
            switch result {
            case .success(_):
                completion?(APIResponseStatus.success)
            case let .failure(error):
                completion?(APIResponseStatus.failureWith(message: error.localizedDescription, code: 400))
            }
        }
    }
    
    func send(message:PubNubData, completion:((APIResponseStatus) -> Void)?) {
        self.message = message
        pubnub.hereNow(on: [channels[0]]) { [weak self] (result) in guard let self = self else { return }
            switch result {
            case .success(let response):
                if (response.first?.value.occupancy ?? 0) > 1 { // send simple message
                    self.sendMessage(self.message, sendNotification: false, completion)
                } else { // send push notification
                    self.sendMessage(self.message, sendNotification: true, completion)
                }
            case .failure(let error):
                completion?(APIResponseStatus.failureWith(message: error.localizedDescription, code: 400))
            }
        }
        
        
    }
    
    func addPubNubListners() {
        
        guard isPubnubListnerAdded == false else { return }
        isPubnubListnerAdded = true
        listener.didReceiveSubscription = { [weak self] event in guard let self = self else { return }
            switch event {
            case let .messageReceived(message):
                
                print("Message Received: \(message) Publisher: \(message.publisher ?? "defaultUUID")")
                print("Message Received Data: \(String(describing: String(data: message.payload.jsonData ?? Data(), encoding: .utf8))) Publisher: \(message.publisher ?? "defaultUUID")")
                
                if let data = message.payload.jsonData, let json = try? JSON(data:data) {
                    let msgData = PubNubData(json:json)
                    switch msgData.messageType {
                    case .location:
                        self.didReceive(location: msgData, from: message.publisher)
                    case .chat:
                        self.didReceive(message: msgData, from: message.publisher)
                        if msgData.id != User.current?.id.intValue { self.sendAck(completion: nil) }
                    default:
                        self.didReceive(message: msgData, from: message.publisher)
                    }
                }
                
            case let .connectionStatusChanged(status):
                print("Status Received: \(status)")
            case let .presenceChanged(presence):
                print("Presence Received: \(presence)")
            case let .subscribeError(error):
                print("Subscription Error \(error)")
                self.isPubnubListnerAdded = false
            default:
                print("Other Events: \(event)")
                break
            }
        }
        pubnub.add(listener)
    }
    
    func enableSubscription() {
        addPubNubListners()
        addAPNSwithChannel()
        pubnub.subscribe(to: [channels[1]], withPresence: true)
    }
    
    func enableSMSSubscription() {
        User.newMsgIDDicts = [:]
        addPubNubListners()
        addAPNSwithChannel()
        pubnub.subscribe(to: [channels[0]], withPresence: true)
    }
    
    /* func messagesAction() {
     pubnub.addMessageAction(channel: channels[0], type: MessageType.chat_read.rawValue, value: MessageType.chat_read.rawValue, messageTimetoken: Timetoken()) { (result) in
     switch result {
     case .failure(let error):
     print(error.localizedDescription)
     case .success(let response):
     print("acction added success: response \(response)")
     }
     }
     } */
    func ackMessageRecept() {
        
    }
    
    func removeSmsSubscriptions() {
        pubnub.unsubscribe(from: [channels[0]])
    }
    
    func removeAllSubscriptions() {
        pubnub.unsubscribeAll()
    }
    
    func addAPNSwithChannel() {
        
        let topic = AppDelegate.isForWorker ? "net.suavesolutions.oarworkerapp":"net.suavesolutions.oarcustomerapp"
        pubnub.addAPNSDevicesOnChannels([channels.first ?? "a"],
                                        device: User.apnsToken,
                                        on: topic,
                                        environment: PubNub.PushEnvironment.development,
                                        custom: PubNub.RequestConfiguration()) { (result) in
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let response):
                print(response)
            }
        }
        
    }
    
    func fetchHistory (completion:@escaping (APIResponseStatus, [PubNubData], [Int:Int]) -> Void) {
        self.showProgress()
        pubnub.fetchMessageHistory(
            for: [channels[0]],
            includeActions: true,
            includeMeta: true,
            page: PNBoundedPage(start: nil, end: nil, limit: 200),
            custom: PubNub.RequestConfiguration()
        ) { [weak self] (result) in guard let self = self else { return }
            switch result {
            case .success(let response):
                let channel = self.channels[0]
                if let messages = response.messagesByChannel[channel]?.map({ (message) -> PubNubData? in
                    if let data = message.payload.jsonData, let json = try? JSON(data:data) {
                        let msgData = PubNubData(json:json)
                        return msgData
                    }
                    return nil
                }).filter({$0 != nil}).map({$0!}) {
                    var indexesList:[Int:Int] = [:]
                    for idx in 0..<messages.count {
                        indexesList[messages[idx].message_id] = idx
                    }
                    completion(APIResponseStatus.success, messages, indexesList)
                } else {
                    completion(APIResponseStatus.success, [], [:])
                }
            //print("Successful History Fetch Response: \(response)")
            case .failure(let error):
                completion(APIResponseStatus(isSuccess: false, code: 401, message: error.localizedDescription), [], [:])
            //print("Failed History Fetch Response: \(error.localizedDescription)")
            }
            self.dismissProgress()
        }
        
        /*
         pubnub.fetchMessageHistory (
         for: ["ch-1"],
         end: 15343325004275466,
         max: 100
         ) { result in
         switch result {
         case let .success(response):
         print("Successful History Fetch Response: \(response)")
         case let .failure(error):
         print("Failed History Fetch Response: \(error.localizedDescription)")
         }
         } */
    }
    
    class PNBoundedPage:PubNubBoundedPage {
        var start: Timetoken?
        var end: Timetoken?
        var limit: Int?
        
        required init(from other: PubNubBoundedPage) throws {
            self.start = other.start
            self.end = other.end
            self.limit = other.limit
        }
        
        init(start:Timetoken?, end: Timetoken?, limit:Int?) {
            self.start = start
            self.end = end
            self.limit = limit
        }
    }
}

//MARK: - Utility Methods
extension MapBaseController {
    @objc func btnBackPressed(_ sender: Any) { self.navigationController?.popViewController(animated: true) }
    @objc func requestStateDidUpdated() { }
    
    @objc func didReceive(location: PubNubData, from publisher:String?) { }
    @objc func startTrackingWorker() { }
    @objc func profileSetup() {}
}

//MARK: - Private Methods
fileprivate extension MapBaseController {
    func uiLayoutAdjustments() {
        view.addSub(view: topView)
            .addSub(view: btnBack)
            .addSub(view: lblTitle)
        
        let constraints = [
            btnBack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.adjustRatio(5)),
            btnBack.leftAnchor.constraint(equalTo: view.leftAnchor),
            btnBack.heightAnchor.constraint(equalToConstant: Theme.adjustRatio(40)),
            btnBack.widthAnchor.constraint(equalTo: btnBack.heightAnchor),
            
            lblTitle.leftAnchor.constraint(equalTo: btnBack.rightAnchor),
            lblTitle.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Theme.adjustRatio(40)),
            //lblTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: Theme.adjustRatio(16)),
            lblTitle.centerYAnchor.constraint(equalToSystemSpacingBelow: btnBack.centerYAnchor, multiplier: 1),
            lblTitle.heightAnchor.constraint(equalTo: btnBack.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        //lblTitle.shaddow(radius: 3, color: Theme.Colors.whiteText, opacity: 1)
        
        topView
            .top(view.safeAreaLayoutGuide.topAnchor, constant: -50)
            .left(view.leftAnchor)
            .right(view.rightAnchor)
            .bottom(lblTitle.bottomAnchor, constant: Theme.adjustRatio(5))
        //.height(80)
        
        btnBack.addTarget(self, action: #selector(btnBackPressed(_:)), for: .touchUpInside)
    }
}

//MARK: - Chatting
extension MapBaseController {
    
    @objc func didReceive(message: PubNubData, from publisher: String?) {
        switch message.messageType {
        case .chat:
            if message.id != User.current?.id.intValue { self.chatVC.msgData.append(message) }
            else {
                if let index = chatVC.msgIDIndex[message.message_id] {
                    chatVC.msgData[index].readStatus = .justSent
                    chatVC.tableView.reloadData()
                }
            }
        case .chat_read:
            if message.id != User.current?.id.intValue {
                
                var idx = (self.chatVC.msgData.count - 1)
                while (idx >= 0 && self.chatVC.msgData[idx].readStatus != .didRead) {
                    self.chatVC.msgData[idx].readStatus = .didRead
                    idx -= 1
                }
                
                self.chatVC.tableView.reloadData()
            }
        case .chat_read_all:
            print("chat read all")
        default: break
        }
    }
    
    @objc func btnShowMessagesViewPressed() {
        //self.showChatViewAlert(data: &self.messages)
        /*
         self.fetchHistory { (status, messages, msgsIdIndex) in
         if status.isSuccess {
         let userId = User.current?.id.intValue ?? 0
         let chatRead = messages.filter({$0.messageType == .chat_read && $0.id != userId})
         if let lastRead = chatRead.last {
         let readIndex = msgsIdIndex[lastRead.message_id] ?? 0
         for id in 0..<readIndex { messages[id].readStatus = .didRead }
         for id in readIndex..<(messages.count) { messages[id].readStatus = .justSent }
         }
         let chatMessages = messages.filter({$0.messageType == .chat})
         
         self.chatVC.msgData = chatMessages
         for idx in 0..<chatMessages.count { self.chatVC.msgIDIndex[chatMessages[idx].message_id] = idx }
         
         if let last = messages.last {
         if last.messageType == .chat && last.id != User.current?.id.intValue {
         self.sendAck(completion: nil)
         }
         } */
        
        self.chatVC.modalPresentationStyle = .overCurrentContext
        self.present(self.chatVC, animated: false, completion: nil)
        /*     } else {
         self.showToast(status.message, type: .error)
         } */
    }
}

*/
