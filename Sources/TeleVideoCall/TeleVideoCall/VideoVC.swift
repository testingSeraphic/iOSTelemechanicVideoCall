//
//  VideoVC.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 06/11/24.
//

import UIKit
import AmazonChimeSDK
import ReplayKit
import CometChatSDK
import PhotosUI
import Photos
import AVFoundation
import NVActivityIndicatorView
import AVKit

enum UserType {
    case consumer
    case provider
}

class VideoVC: UIViewController {
    
    // MARK: - Outlets
    // main view
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    // bottom menu options
    @IBOutlet weak var bottomBlurView: CustomBlurredView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet weak var bottomViewLeading: NSLayoutConstraint!
    @IBOutlet weak var bottomViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var reverseButton: UIButton!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var chatButtonView: UIView!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var showMenuOptionButton: UIButton!
    // menu option stack view
    @IBOutlet weak var menuOptionStackView: UIStackView!
    @IBOutlet weak var menuOptionTop: NSLayoutConstraint!
    @IBOutlet weak var menuOptionBottom: NSLayoutConstraint!
    @IBOutlet weak var menuOptionLeading: NSLayoutConstraint!
    @IBOutlet weak var menuOptionTrailing: NSLayoutConstraint!
    // hide menu option btn
    @IBOutlet weak var hideMenuOptionButton: UIButton!
    @IBOutlet weak var hideMenuOptionButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hideMenuOptionButtonTrailingConstraint: NSLayoutConstraint!
    // setting option
    @IBOutlet weak var settingOptionView: UIView!
    @IBOutlet weak var settingOptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingOptionTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingOptionStackView: UIStackView!
    @IBOutlet weak var settingOptionStackBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var settingOptionStackTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointerButton: UIButton!
    @IBOutlet weak var highlighterButton: UIButton!
    @IBOutlet weak var penButton: UIButton!
    @IBOutlet weak var pinButton: UIButton!
    @IBOutlet weak var screenshotButton: UIButton!
    @IBOutlet weak var pointerLabel: UILabel!
    @IBOutlet weak var highlighterLabel: UILabel!
    @IBOutlet weak var penLabel: UILabel!
    @IBOutlet weak var pinLabel: UILabel!
    @IBOutlet weak var screenshotLabel: UILabel!
    @IBOutlet weak var pointerStackview: UIStackView!
    @IBOutlet weak var highlighterStackview: UIStackView!
    @IBOutlet weak var penStackview: UIStackView!
    @IBOutlet weak var pinStackview: UIStackView!
    @IBOutlet weak var screenshotStackview: UIStackView!
    // small view
    @IBOutlet weak var smallContainerView: UIView!
    @IBOutlet weak var smallView: DefaultVideoRenderView!
    @IBOutlet weak var smallViewWidth: NSLayoutConstraint!
    @IBOutlet weak var smallViewHeight: NSLayoutConstraint!
    @IBOutlet weak var smallContainerViewTop: NSLayoutConstraint!
    @IBOutlet weak var smallContainerViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var maximizeView: UIView!
    @IBOutlet weak var minimzieView: UIView!
    // show video
    @IBOutlet weak var showVideoView: UIView!
    @IBOutlet weak var showVideoTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var showVideoTopConstraint: NSLayoutConstraint!
    // timer
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerStackView: UIStackView!
    @IBOutlet weak var timerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var timerViewTopConstraint: NSLayoutConstraint!
    // large
    @IBOutlet weak var largeView: DefaultVideoRenderView!
    @IBOutlet weak var largerViewWidth: NSLayoutConstraint!
    @IBOutlet weak var largerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var disablePointerView: UIView!
    @IBOutlet weak var disablePointerButton: UIButton!
    
    
    @IBOutlet weak var chatCloseButton: UIButton!
    // MARK: - Chat Outlets
    @IBOutlet weak var playAttachmentButton: UIButton!
    @IBOutlet weak var chatContainerStackView: UIStackView!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var chatContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var bottomInnerContainerView: UIView!
    @IBOutlet weak var sendButtonShadowView: UIView!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var messageTextfieldShadowView: UIView!
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint?
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var messageTextView: ExpandingTextView!
    
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var notificationCountView: UIView!
    @IBOutlet weak var notificationCountViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationCountViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatBlurView: CustomBlurredView!
    @IBOutlet weak var galleryView: GalleryView!
    @IBOutlet weak var selectedAttachmentView: UIView!
    @IBOutlet weak var chatAttachmentView: UIView!
    @IBOutlet weak var photosBgView: UIView!
    @IBOutlet weak var fileBgView: UIView!
    @IBOutlet weak var chatAttachmentCrossBtnBgView: UIView!
    @IBOutlet weak var selectedAttachmentCrossBtnBgView: UIView!
    @IBOutlet weak var attachmentNameLabel: UILabel!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var selectedAttachmentUserImageView: UIImageView!
    @IBOutlet weak var attachmentUserImageWidth: NSLayoutConstraint!
    @IBOutlet weak var attachmentUserImageHeight: NSLayoutConstraint!
    @IBOutlet weak var chatTextView: DraggableView!
    
    var notificationCount: Int = 0 {
        didSet {
            notificationCountLabel.text = "\(notificationCount)"
            notificationCountView.isHidden = (notificationCount == 0)
        }
    }
    
    //Landscape Name Label
    let landscapeNameLabel = UILabel()
    // @IBOutlet weak var landscapeNameTrailingConstraint: NSLayoutConstraint!
    
    var userRendererView: DefaultVideoRenderView?
    
    var localRendererView: DefaultVideoRenderView?
    var remoteRendererView: DefaultVideoRenderView?
    
    // MARK: - UI Layout Properties
    // height for bottom section
    private var requiredBottomHeight: CGFloat = 108
    
    
    // MARK: - Orientation Properties
    // orientation
    private var isPortrait: Bool {
        return UIScreen.main.bounds.height > UIScreen.main.bounds.width
    }
    
    
    // MARK: - Visibility State Properties
    // menu visibility
    private var isMenuOptionVisible: Bool = false {
        didSet {
            hideShowMenuOption()
            setOptionButtonOrder()
        }
    }
    // setting visibility
    private var isSettingOptionVisible: Bool = false {
        didSet {
            hideShowSettingOption()
        }
    }
    
    // MARK: - Video Control Properties
    // remote video maximized
    private var isRemoteVideMaximize: Bool = true {
        didSet {
            if canSwitchVideo {
                switchVideo()
                setVideoSize()
                setVideoContentMode()
                if pointerButtonEnabled {
                    configurePointer()
                    // meetingModel?.removePointer()
                    meetingModel?.addPointer()
                }
            }
        }
    }
    // minimized state
    private var isMinimize: Bool = false {
        didSet {
            showHideVideo()
        }
    }
    private var canSwitchVideo: Bool = false
    
    //Call
    private let logger = ConsoleLogger(name: "VideoVC")
    var meetingModel: MeetingModel?
    // Track the current video tile IDs for local and remote feeds
    private var userTileId: Int?
    private var providerTileId: Int?
    
    private var isRecordingEnabled = true
    private let screenRecorder = ScreenRecorder()
    
    private var timeRemaining = 0
    private var criticalTimeRemaining = 1*60
    private var timer: Timer?
    private var duration : Int = 0
    private var incrementMode: Bool = false
    
    let cursorSize : CGFloat = 35
    
    let cursorImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "cursor"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .red
        return imageView
    }()
    
    var userType: UserType = .provider
    
    var panGesture: UIPanGestureRecognizer!
    var cursorViewOrigin: CGPoint?
    
    var pointerButtonEnabled = false
    
    var incrementTimer = false
    
    var landscapeConstraints: [NSLayoutConstraint] = []
    
    private var broadcastController: RPBroadcastController?
    
    private var isRemotePortrait: Bool = true {
        didSet {
            if isRemotePortrait != oldValue {
                DispatchQueue.main.async {
                    self.setVideoSize()
                    self.setVideoContentMode()
                    if self.pointerButtonEnabled {
                        self.configurePointer()
                    }
                }
            }
        }
    }
    
    private var isRemoteFrontEnabled: Bool = false
    
    var documentInteractionController: UIDocumentInteractionController?
    
    // MARK: - Chat Properties
    var chatMessages: [ChatMessage] = []
    var localUserId: String = ""
    var remoteUserId: String = ""
    
    var isChatVisible: Bool = false{
        didSet {
            if isChatVisible {
                lockOrientationToPortrait()
            } else {
                unlockOrientation()
            }
            self.chatBlurView.isHidden = !isChatVisible
            self.bottomBlurView.isHidden = isChatVisible
            UIViewController.attemptRotationToDeviceOrientation()
            chatButton.isSelected = isChatVisible
            self.updateChatContainerView()
            markAllMessagesRead()
            //updateUnreadMessageCount()
        }
    }
    
    var isChatAttachmentEnable: Bool = false {
        didSet {
            updateChatUI()
        }
    }
    
    var selectedAttachment: MediaMessage? {
        didSet {
            updateChatUI()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fontPath = Bundle.main.path(forResource: "OverusedGrotesk-Medium", ofType: "ttf")
        let fontDataProvider = CGDataProvider(filename: fontPath!)
        let cgFont = CGFont(fontDataProvider!)!
        CTFontManagerRegisterGraphicsFont(cgFont, nil)
        
        //meeting Model Configuration
        guard let meetingModel = meetingModel else {
            logger.error(msg: "MeetingModel not set")
            dismiss(animated: true, completion: nil)
            return
        }
        
        setupMeetingValues()
        
        // set initial load
        initializeViewSettings()
        
        // check user type
        setLocalAttendeeName()
        
        configure(meetingModel: meetingModel)
        meetingModel.startMeeting()
        meetingModel.videoModel.isLocalVideoActive = true
        // updateMirroring()
        
        //Initial Timer Label
        timeRemaining = duration * 60
        timerLabel.text = formatTime(seconds: timeRemaining)
        
        //        if isRecordingEnabled {
        //            self.startScreenRecording()
        //        }
        // startBroadcast()
        
        let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 100, y: 70, width: 50, height: 50))
        
        // Set the preferred extension to the bundle identifier of your Broadcast Upload Extension
        broadcastPicker.preferredExtension = AppConfiguration.broadcastBundleId
        broadcastPicker.showsMicrophoneButton = true
        
        // Add the broadcast picker to the view controller's view
        //        self.view.addSubview(broadcastPicker)
        
        setupLandscapeLabel()
        
        //Chat Setup
        setupChatTableView()
        
        manageAROptionsVisibility()
        
        getGalleryViewImage()
        
        // Enable user interaction for the UIImageView
        selectedAttachmentUserImageView.isUserInteractionEnabled = true
        
        // Create and configure a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(attachmentTapped))
        selectedAttachmentUserImageView.addGestureRecognizer(tapGesture)
        
        chatTextView.onDragDown = { newPosition in
                self.isChatVisible = false
        }
        
        chatCloseButton.addTarget(self, action: #selector(chatCloseButtonTapped(_:)), for: .allEvents)

        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isChatVisible ? .portrait : .all
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // hide views before the transition begins
        self.setViewsHidden(true)
        self.nameLabel.isHidden = true
        self.landscapeNameLabel.isHidden = true
        self.view.endEditing(true)
        
        coordinator.animate(alongsideTransition: { _ in
            // update constraints for the new orientation
            self.updateConstraintsForOrientation(isPortrait: self.isPortrait)
            
            // apply layout changes during rotation
            self.view.layoutIfNeeded()
            
            
        }, completion: { _ in
            // once animation completes, reveal the views
            self.setViewsHidden(false, animated: true)
            self.sendOrientation()
            self.setVideoContentMode()
            self.updateChatContainerView()
            self.setupViewAppearance()
            
            if self.pointerButtonEnabled {
                self.configurePointer()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
        dismissTimeExtensionVC()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    deinit {
        CometChatManager.shared.removeMessageListener()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func lockOrientationToPortrait() {
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
    private func unlockOrientation() {
        UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
    }
    
    func manageAROptionsVisibility() {
        if let deviceModel = UIDevice.modelName.split(separator: " ").last,
           let modelNumber = Int(deviceModel) {
            if modelNumber < 12 {
                // Hide the button
                highlighterStackview.isHidden = true
                penStackview.isHidden = true
                pinStackview.isHidden = true
            } else {
                // Show the button
                highlighterStackview.isHidden = false
                penStackview.isHidden = false
                pinStackview.isHidden = false
            }
        } else {
            // Handle cases where the model doesn't contain a number (e.g., Simulator or SE models)
            highlighterStackview.isHidden = false
            penStackview.isHidden = false
            pinStackview.isHidden = false
        }
    }
    
    func setupMeetingValues() {
        guard let meetingModel = meetingModel else { return }
        localUserId = meetingModel.loginUID
        remoteUserId = meetingModel.remoteUID
        duration = Int(meetingModel.meetingTime) ?? 0
        
        if meetingModel.roleType == "consumer" {
            userType = .consumer
            self.isRemoteVideMaximize = false
        }
        else {
            userType = .provider
        }
    }
    
    func setupLandscapeLabel() {
        landscapeNameLabel.text = ""
        landscapeNameLabel.textAlignment = .center
        landscapeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        landscapeNameLabel.textColor = .white
        landscapeNameLabel.font = UIFont(name: "OverusedGrotesk-SemiBold", size: 23)
        landscapeNameLabel.applyStrokeAndShadow()
        view.addSubview(landscapeNameLabel)
        
        landscapeConstraints = [
            landscapeNameLabel.bottomAnchor.constraint(equalTo: settingOptionView.topAnchor, constant: -5),
            landscapeNameLabel.centerXAnchor.constraint(equalTo: settingOptionView.centerXAnchor)
        ]
    }
    
    func setupChatTableView() {
        
        setupTableView()
        //setupViewAppearance()
        performLogin()
        CometChatManager.shared.addMessageListener(delegate: self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardNotification(notification:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        setTextView()
        addDoneButtonOnKeyboard()
        chatLabel.font = UIFont(name: "OverusedGrotesk-SemiBold", size: 23)
    }
}

extension VideoVC {
    
    private func configure(meetingModel: MeetingModel) {
        
        meetingModel.activeModeDidSetHandler = { activeMode in
            
        }
        meetingModel.notifyHandler = { message in
            //            self?.view?.makeToast(message, duration: 2.0, position: .top)
        }
        meetingModel.isMutedHandler = { [weak self] isMuted in
            self?.microphoneButton.isSelected = isMuted
        }
        meetingModel.isEndedHandler = { [weak meetingModel] in
            if self.isRecordingEnabled {
                //self.stopScreenRecording()
            }
            DispatchQueue.main.async {
                guard let meetingModel = meetingModel else { return }
                MeetingModule.shared().dismissMeeting(meetingModel)
            }
        }
        
        meetingModel.videoModel.videoUpdatedHandler = { [weak self, weak meetingModel] in
            guard let strongSelf = self, let _ = meetingModel else { return }
            strongSelf.bindVideoFeeds()
        }
        
        meetingModel.videoModel.videoSubscriptionUpdatedHandler = { [weak self, weak meetingModel] in
            guard let strongSelf = self, let meetingModel = meetingModel else { return }
            strongSelf.bindVideoFeeds()
        }
        
        meetingModel.videoModel.localVideoUpdatedHandler = { [weak self] in
            self?.bindVideoFeeds()
        }
        
        //        meetingModel.meetingTimerIncrementedHandler = {
        //           // self.resetTimer()
        //        }
        
        meetingModel.pointerDataTransferHandler = { [weak self] data in
            guard let self = self else { return }
            if let result = decodePointerData(jsonString: data) {
                
                if let viewOrigin = result.viewOrigin, let parentSize = result.parentSize {
                    
                    // save cursor points
                    self.cursorViewOrigin = viewOrigin
                    let targetView: UIView = userRendererView ?? UIView()
                    let newFrame = syncViewPosition(
                        firstViewOrigin: viewOrigin,
                        firstParentSize: parentSize,
                        secondParentSize: targetView.frame.size
                    )
                    // clamp the position to keep it within the bounds of targetView
                    let clampedX = min(max(newFrame.x, 0), targetView.frame.size.width - cursorImageView.frame.size.width)
                    let clampedY = min(max(newFrame.y, 0), targetView.frame.size.height - cursorImageView.frame.size.height)
                    
                    // animate the change in frame origin with no delay
                    UIView.animate(withDuration: 0.05, delay: 0, options: [.curveLinear, .allowUserInteraction], animations: {
                        // set the frame’s origin while keeping it within bounds
                        self.cursorImageView.frame.origin = CGPoint(x: clampedX, y: clampedY)
                    })
                    
                    //                    cursorImageView.frame.origin = CGPoint(x: clampedX, y: clampedY)
                }
            }
        }
        
        meetingModel.pointerAddedHandler = {
            if !self.pointerButtonEnabled {
                self.pointerButton.isSelected = true
                self.pointerButtonEnabled = true
                self.disablePointerView.isHidden = false
                if self.largeView != self.userRendererView {
                    self.swapVideoFeeds()
                }
                self.configurePointer()
                self.setPointerUI()
            }
        }
        
        meetingModel.pointerRemovedHandler = {
            self.pointerButton.isSelected = false
            self.pointerButtonEnabled = false
            self.disablePointerView.isHidden = true
            self.removePointer()
            if self.isMinimize {
                self.isMinimize.toggle()
            }
        }
        
        meetingModel.isRemotePortrait = { [weak self] isRemotePortrait in
            self?.isRemotePortrait = isRemotePortrait
        }
        
        meetingModel.frontCameraToggle = { [weak self] isFront in
            //            self?.updateMirroring(isLocal: false)
            self?.remoteRendererView?.mirror = isFront
            self?.isRemoteFrontEnabled = isFront
        }
        
        meetingModel.incrementTimerRequestedHandler = {[weak self] in
            self?.presentTimeExtensionView()
        }
        
        meetingModel.incrementTimerApprovedHandler = {
            self.incrementTimer = true
            self.timeExtensionAPIRequest()
        }
        
    }
    
    func setLocalAttendeeName() {
        
        guard let meetingModel = meetingModel else { return }
        
        let localAttendeeId = meetingModel.meetingSessionConfig.credentials.attendeeId
        
        for i in 0 ..< meetingModel.videoModel.videoTileCount {
            let indexPath = IndexPath(item: i, section: 0)
            if let videoTileState = meetingModel.videoModel.getVideoTileState(for: indexPath),
               videoTileState.attendeeId == localAttendeeId {
                // Get and return the display name for the local attendee
                let name = meetingModel.getVideoTileDisplayName(for: indexPath)
                
                
            }
        }
        
    }
    
    func getRemoteAttendeeName() -> String {
        guard let meetingModel = meetingModel else { return "" }
        
        let localAttendeeId = meetingModel.meetingSessionConfig.credentials.attendeeId
        
        for i in 0 ..< meetingModel.videoModel.videoTileCount {
            let indexPath = IndexPath(item: i, section: 0)
            if let videoTileState = meetingModel.videoModel.getVideoTileState(for: indexPath),
               videoTileState.attendeeId != localAttendeeId {
                // Get and return the display name for the local attendee
                return meetingModel.getVideoTileDisplayName(for: indexPath)
            }
        }
        return ""
    }
    
    func showRemoteName(_ status: Bool) {
        nameLabel.isHidden = !status
        nameLabel.text = getRemoteAttendeeName()
    }
    
    func showLandscapeRemoteName(_ status: Bool) {
        landscapeNameLabel.isHidden = !status
        landscapeNameLabel.text = getRemoteAttendeeName()
    }
    
    func bindVideoFeeds() {
        
        guard let meetingModel = meetingModel else { return }
        // Clear previous tile IDs
        userTileId = nil
        providerTileId = nil
        
        setLocalAttendeeName()
        
        setVideoContentMode()
        
        if meetingModel.videoModel.videoTileCount == 2 {
            startTimer()
        }
        
        // Separate local and remote video tiles
        for i in 0 ..< meetingModel.videoModel.videoTileCount {
            let videoTileState = meetingModel.videoModel.getVideoTileState(for: IndexPath(item: i, section: 0))
            let userName = meetingModel.getVideoTileDisplayName(for: IndexPath(item: i, section: 0))
            
            if let tileState = videoTileState {
                let renderer: DefaultVideoRenderView
                if userType == .consumer {
                    if userName == meetingModel.loginUserName {
                        meetingModel.bind(videoRenderView: largeView, tileId: tileState.tileId)
                        userTileId = tileState.tileId
                        userRendererView = largeView
                        renderer = largeView
                    }
                    else {
                        meetingModel.bind(videoRenderView: smallView, tileId: tileState.tileId)
                        providerTileId = tileState.tileId
                        renderer = smallView
                    }
                }
                
                else {
                    if userName == meetingModel.loginUserName {
                        meetingModel.bind(videoRenderView: smallView, tileId: tileState.tileId)
                        providerTileId = tileState.tileId
                        renderer = smallView
                    }
                    else {
                        meetingModel.bind(videoRenderView: largeView, tileId: tileState.tileId)
                        userTileId = tileState.tileId
                        userRendererView = largeView
                        renderer = largeView
                    }
                }
                
                if tileState.isLocalTile {
                    localRendererView = renderer
                }
                else {
                    remoteRendererView = renderer
                }
                
                updateMirroring()
                
                self.sendOrientation()
            }
        }
    }
    
    
    func swapVideoFeeds() {
        
        guard let meetingModel = meetingModel, let userTileId = userTileId, let providerTileId = providerTileId else {
            logger.error(msg: "Local or Remote Tile ID not available for swapping.")
            return
        }
        
        // bind the video feeds to swap views
        meetingModel.bind(videoRenderView: largeView, tileId: providerTileId)
        meetingModel.bind(videoRenderView: smallView, tileId: userTileId)
        
        // swap tile ids for tracking
        self.userTileId = providerTileId
        self.providerTileId = userTileId
        
        let renderer = localRendererView
        localRendererView = remoteRendererView
        remoteRendererView = renderer
        
        let isFrontCameraActive = meetingModel.videoModel.isFrontCameraActive
        localRendererView?.mirror = isFrontCameraActive
        
        remoteRendererView?.mirror = isRemoteFrontEnabled
        
        userRendererView = userRendererView == smallView ? largeView : smallView
        
        logger.info(msg: "Swapped video feeds: Losrcal Tile ID \(userTileId) <-> Remote Tile ID \(providerTileId)")
    }
    
    private func updateMirroring() {
        if let isFrontCameraActive = meetingModel?.videoModel.isFrontCameraActive {
            localRendererView?.mirror = isFrontCameraActive
            print("cameraTopicToggleCalled=")
            print("isFrontCameraActive=",isFrontCameraActive)
            self.meetingModel?.toggleCamera(isFront: isFrontCameraActive)
        }
    }
    
    
}

//MARK: Orientation and frame
extension VideoVC {
    
    private func setVideoContentMode() {
        if isRemoteVideMaximize {
    //      if self.isPortrait && self.isRemotePortrait {
    //        largeView.contentMode = .scaleAspectFill
    //      } else if self.isPortrait && !self.isRemotePortrait {
    //        largeView.contentMode = .scaleAspectFill
    //      } else if !self.isPortrait && !self.isRemotePortrait {
    //        largeView.contentMode = .scaleAspectFill
    //      } else if self.isRemotePortrait && !self.isPortrait {
    //        largeView.contentMode = .scaleAspectFill
    //      }
          smallView.contentMode = .scaleAspectFill
    //      smallView.contentMode = self.isPortrait ? .scaleAspectFill : .scaleAspectFit
          largeView.contentMode = .scaleAspectFill
        } else {
    //      if self.isPortrait && self.isRemotePortrait {
    //        smallView.contentMode = .scaleAspectFill
    //      } else if self.isPortrait && !self.isRemotePortrait {
    //        smallView.contentMode = .scaleAspectFill
    //      } else if !self.isPortrait && !self.isRemotePortrait {
    //        smallView.contentMode = .scaleAspectFill
    //      } else if self.isRemotePortrait && !self.isPortrait {
    //        smallView.contentMode = .scaleAspectFill
    //      }
          smallView.contentMode = .scaleAspectFill
          largeView.contentMode = .scaleAspectFill
        }
      }
    
    private func setVideoSize() {
        
        if isRemoteVideMaximize {
            
            var width: CGFloat = 0
            var height: CGFloat = 0
            
            if self.isPortrait &&  self.isRemotePortrait {
                width = self.mainView.frame.width
                height = self.mainView.frame.height
            } else if self.isPortrait && !self.isRemotePortrait{
                width = self.mainView.frame.width
                height = width * 9 / 16
            } else if !self.isPortrait && !self.isRemotePortrait {
                width = self.mainView.frame.width
                height = self.mainView.frame.height
            } else if self.isRemotePortrait && !self.isPortrait {
                height = self.mainView.frame.height
                width =  height * 9 / 16
            }
            
            self.largerViewWidth.constant = width
            self.largerViewHeight.constant = height
            
            if self.isPortrait {
                smallViewWidth.constant = self.smallContainerView.frame.width
                smallViewHeight.constant = self.smallContainerView.frame.height
            } else {
                smallViewWidth.constant = self.smallContainerView.frame.width
                smallViewHeight.constant = smallViewWidth.constant * 9 / 16
            }
            
        } else {
            
            var width: CGFloat = 0
            var height: CGFloat = 0
            
            if self.isPortrait &&  self.isRemotePortrait {
                width = self.smallContainerView.frame.width
                height = self.smallContainerView.frame.height
            } else if self.isPortrait && !self.isRemotePortrait {
                width = self.smallContainerView.frame.width
                height = width * 9 / 16
            } else if !self.isPortrait && !self.isRemotePortrait {
                width = self.smallContainerView.frame.width
                height = width * 9 / 16
            } else if self.isRemotePortrait && !self.isPortrait {
                width = self.smallContainerView.frame.width
                height = self.smallContainerView.frame.height
            }
            
            self.smallViewWidth.constant = width
            self.smallViewHeight.constant = height
            
            self.largerViewWidth.constant = self.mainView.frame.width
            self.largerViewHeight.constant = self.mainView.frame.height
        }
        
        self.view.layoutIfNeeded()
    }
    
    private func sendOrientation() {
        meetingModel?.sendOrientation(isPortrait: self.isPortrait)
    }
    
}

//MARK: Screen Recording
extension VideoVC {
    private func startScreenRecording() {
        screenRecorder.startRecording(saveToCameraRoll: true, errorHandler: { error in
            if let error = error {
                debugPrint("Error when starting recording: \(error)")
            } else {
                debugPrint("Screen recording started successfully.")
            }
        })
    }
    
    private func stopScreenRecording() {
        screenRecorder.stopRecording(handler: { error in
            if let error = error {
                debugPrint("Error when stopping recording: \(error)")
            } else {
                debugPrint("Screen recording stopped successfully and saved.")
            }
        })
    }
}

//MARK: Timer
extension VideoVC {
    
    func startTimer() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDecrementTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        print("Timer stopped")
    }
    
    func resetTimer() {
        timeRemaining = 0
        incrementMode = !incrementMode
    }
    
    @objc func updateDecrementTimer() {
        
        if !incrementMode {
            timeRemaining -= 1
            if timeRemaining <= 0 {
                if self.incrementTimer {
                    self.resetTimer()
                    // self.meetingModel?.notifyIncrementTime()
                }
                else {
                    stopTimer()
                    meetingModel?.endMeeting()
                }
                
            } else {
                if userType == .consumer && timeRemaining == criticalTimeRemaining {
                    // showAddMoreTimeAlert()
                    presentTimeExtensionView()
                }
            }
        } else {
            timeRemaining += 1
        }
        
        timerLabel.text = formatTime(seconds: timeRemaining)
        print("Time: \(formatTime(seconds: timeRemaining))")
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    //    private func showAddMoreTimeAlert() {
    //        showYesNoAlert(on: self, title: "Do you want to increase the duration of session?", message: "", yesHandler: {
    //            self.incrementTimer = true
    //
    //        }, noHandler: {
    //        })
}


// helper
extension VideoVC {
    
    func applyHaptic() {
        // haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
}

// set layout
extension VideoVC {
    
    private func initializeViewSettings() {
        
        self.isSettingOptionVisible = false
        self.isMenuOptionVisible = true
        self.isMinimize = false
        self.isChatVisible = false
        
        self.setupView()
        
        // hide views initially to prepare for their first appearance
        self.setViewsHidden(true)
        self.setVideoContentMode()
        
        // show views with optional animation when ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.updateConstraintsForOrientation(isPortrait: self.isPortrait)
            self.setViewsHidden(false, animated: true)
        }
    }
    
    private func setViewsHidden(_ hidden: Bool, animated: Bool = false) {
        let action = {
            self.bottomView.isHidden = hidden
            self.menuOptionStackView.isHidden = hidden
            self.bottomBlurView.isHidden = hidden
            self.hideMenuOptionButton.isHidden = hidden
            self.smallView.isHidden = hidden
            self.timerView.isHidden = hidden
            self.showVideoView.isHidden = hidden
            self.settingOptionView.isHidden = hidden
            // self.nameLabel.isHidden = hidden
            // self.landscapeNameLabel.isHidden = hidden
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: action)
        } else {
            action()
        }
    }
    
    private func updateConstraintsForOrientation(isPortrait: Bool) {
        if isPortrait {
            // portrait constraints
            self.bottomViewBottom.constant = -1
            self.bottomViewLeading.constant = -1
            self.bottomViewTrailing.constant = -1
            self.bottomViewWidth.constant = self.mainView.frame.width + 2
            self.bottomViewHeight.constant = requiredBottomHeight
            
            self.menuOptionStackView.axis = .horizontal
            self.menuOptionTop.constant = 0
            self.menuOptionBottom.constant = 0
            self.menuOptionLeading.constant = 28
            self.menuOptionTrailing.constant = -28
            
            self.hideMenuOptionButtonTopConstraint.constant = -15.53
            self.hideMenuOptionButtonTrailingConstraint.constant = 9
            
            self.smallContainerViewTop.constant = 20
            self.smallContainerViewTrailing.constant = 10
            
            self.showVideoTopConstraint.constant = 20
            self.showVideoTrailingConstraint.constant = 24
            
            self.settingOptionStackView.axis = .vertical
            self.settingOptionBottomConstraint.constant = 90
            self.settingOptionTrailingConstraint.constant = 10
            
            self.settingOptionStackBottomConstraint.constant = 38
            self.settingOptionStackTrailingConstraint.constant = 20
            
            self.notificationCountViewTopConstraint.constant = 24
            self.notificationCountViewTrailingConstraint.constant = -2
            NSLayoutConstraint.deactivate(landscapeConstraints)
            showRemoteName(isMenuOptionVisible)
            
        } else {
            // landscape constraints
            self.bottomViewBottom.constant = -1
            self.bottomViewTrailing.constant = -1
            self.bottomViewLeading.constant = (self.mainView.frame.width + 1) - self.requiredBottomHeight
            self.bottomViewWidth.constant = requiredBottomHeight
            self.bottomViewHeight.constant = self.mainView.frame.height + 2
            
            self.menuOptionStackView.axis = .vertical
            self.menuOptionTop.constant = 28
            self.menuOptionBottom.constant = -28
            self.menuOptionLeading.constant = 0
            self.menuOptionTrailing.constant = 0
            
            self.hideMenuOptionButtonTopConstraint.constant = 9
            self.hideMenuOptionButtonTrailingConstraint.constant = -15.53
            
            self.smallContainerViewTop.constant = 20 + 8 + self.timerView.frame.height
            self.smallContainerViewTrailing.constant = self.mainView.frame.width - (self.smallView.frame.width + 24)
            
            self.showVideoTopConstraint.constant = 20 + 8 + self.timerView.frame.height
            self.showVideoTrailingConstraint.constant = self.mainView.frame.width - (self.showVideoView.frame.width + 24)
            
            self.settingOptionStackView.axis = .horizontal
            self.settingOptionBottomConstraint.constant = 10
            self.settingOptionTrailingConstraint.constant = 90
            self.settingOptionStackBottomConstraint.constant = 20
            self.settingOptionStackTrailingConstraint.constant = 38
            self.notificationCountViewTopConstraint.constant = 0
            self.notificationCountViewTrailingConstraint.constant = 20
            
            NSLayoutConstraint.activate(landscapeConstraints)
            showLandscapeRemoteName(isSettingOptionVisible)
            
            //self.isChatVisible = false
        }
        
        // adjust corner radius for blur view based on orientation
        self.updateBlurViewCorners(isPortrait: isPortrait)
        
        
        DispatchQueue.main.async {
            self.setVideoSize()
        }
        
        // set btn order
        self.setOptionButtonOrder()
    }
    
    private func updateBlurViewCorners(isPortrait: Bool) {
        DispatchQueue.main.async {
            self.bottomBlurView.layer.borderWidth = 1
            self.bottomBlurView.layer.borderColor = UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1).cgColor
        }
    }
    
    private func setOptionButtonOrder() {
        // Define the order of buttons
        var buttons: [UIView] = [showMenuOptionButton!, reverseButton!, microphoneButton!, callButton!, chatButtonView, settingButton!, crossButton!]
        
        // Reverse buttons order if menu option is not visible and orientation is not portrait
        if !isMenuOptionVisible && !isPortrait {
            buttons = buttons.reversed()
        }
        
        // Remove all current views from the stack view
        for button in buttons {
            menuOptionStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        // Add all buttons back in the desired order
        for button in buttons {
            menuOptionStackView.addArrangedSubview(button)
        }
    }
    
    
    private func setupView() {
        
        // main view
        self.mainView.clipsToBounds = true
        self.smallView.clipsToBounds = true
        self.largeView.clipsToBounds = true
        
        // setting option
        //        self.settingOptionView.roundCorners([.topLeft, .topRight], radius: 12, borderColor: UIColor(red: 0.624, green: 0.628, blue: 0.65, alpha: 1), borderWidth: 1)
        self.settingOptionView.layer.cornerRadius = 12
        self.settingOptionView.layer.borderWidth = 1
        self.settingOptionView.clipsToBounds = true
        self.settingOptionView.layer.borderColor = UIColor(red: 0.624, green: 0.628, blue: 0.65, alpha: 1).cgColor
        
        // timer stack
        self.timerView.layer.cornerRadius = self.timerStackView.frame.height / 2
        self.timerView.layer.borderWidth = 1
        self.timerView.clipsToBounds = true
        self.timerView.layer.borderColor = UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1).cgColor
        
        // provider view
        self.smallContainerView.layer.cornerRadius = 18
        self.smallContainerView.layer.borderWidth = 1
        self.smallContainerView.clipsToBounds = true
        self.smallContainerView.layer.borderColor = UIColor(red: 0.929, green: 0.933, blue: 0.949, alpha: 0.8).cgColor
        
        // maximize view
        self.maximizeView.layer.cornerRadius = self.maximizeView.frame.height / 2
        self.maximizeView.layer.borderWidth = 1
        self.maximizeView.clipsToBounds = true
        self.maximizeView.layer.borderColor = UIColor(red: 0.624, green: 0.628, blue: 0.65, alpha: 1).cgColor
        
        // minimize view
        self.minimzieView.layer.cornerRadius = self.maximizeView.frame.height / 2
        self.minimzieView.layer.borderWidth = 1
        self.minimzieView.clipsToBounds = true
        self.minimzieView.layer.borderColor = UIColor(red: 0.624, green: 0.628, blue: 0.65, alpha: 1).cgColor
        
        // show video view
        self.showVideoView.layer.cornerRadius = self.showVideoView.frame.height / 2
        self.showVideoView.layer.borderWidth = 1
        self.showVideoView.clipsToBounds = true
        self.showVideoView.layer.borderColor = UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1).cgColor
        
        self.disablePointerView.layer.cornerRadius = self.disablePointerView.frame.height / 2
        self.disablePointerView.layer.borderWidth = 1
        self.disablePointerView.clipsToBounds = true
        self.disablePointerView.layer.borderColor = UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1).cgColor
        
        
        self.photosBgView.applyShadow(backgroundColor: UIColor(red: 0.93, green: 0.934, blue: 0.95, alpha: 1), cornerRadii: CGSize(width: 7, height: 7), borderWidth: 0, shadowConfigurations: [
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.6), radius: 5, offset: CGSize(width: 2, height: 2)),
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.35), radius: 2, offset: CGSize(width: 1, height: 1)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 5, offset: CGSize(width: -2, height: -2)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 2, offset: CGSize(width: -1, height: -1)),
        ])
        
        self.fileBgView.applyShadow(backgroundColor: UIColor(red: 0.93, green: 0.934, blue: 0.95, alpha: 1), cornerRadii: CGSize(width: 7, height: 7), borderWidth: 0, shadowConfigurations: [
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.6), radius: 5, offset: CGSize(width: 2, height: 2)),
            (color: UIColor(red: 0.518, green: 0.545, blue: 0.62, alpha: 0.35), radius: 2, offset: CGSize(width: 1, height: 1)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 5, offset: CGSize(width: -2, height: -2)),
            (color: UIColor(red: 1, green: 1, blue: 1, alpha: 1), radius: 2, offset: CGSize(width: -1, height: -1)),
        ])
        
        
        self.chatAttachmentCrossBtnBgView.applyShadow(backgroundColor: UIColor.clear, borderColor: UIColor(red: 0.329, green: 0.332, blue: 0.35, alpha: 1) ,borderWidth: 1, shadowConfigurations: [(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), radius: 4, offset: CGSize(width: 2, height: 2))])
        
        self.selectedAttachmentCrossBtnBgView.applyShadow(backgroundColor: UIColor.clear, borderColor: UIColor(red: 0.329, green: 0.332, blue: 0.35, alpha: 1) ,borderWidth: 1, shadowConfigurations: [(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.25), radius: 4, offset: CGSize(width: 2, height: 2))])
        
        self.bottomInnerContainerView.layer.cornerRadius = 16
        self.bottomInnerContainerView.layer.borderWidth = 1.5
        self.bottomInnerContainerView.layer.borderColor = UIColor.white.cgColor
        self.bottomInnerContainerView.clipsToBounds = true
        
        self.playAttachmentButton.applyButtonShadow()
        
        // apply shadow to buttons
        let buttons = [showMenuOptionButton!, reverseButton!, microphoneButton!, callButton!, chatButton!, settingButton!, crossButton!, pointerButton!, highlighterButton!, penButton!, pinButton!, screenshotButton!, disablePointerButton!]
        buttons.forEach { button in
            button.applyButtonShadow()
        }
    }
    
    private func setupTableView() {
        chatTableView.register(UINib(nibName: "ChatLeftMessageCell", bundle: nil), forCellReuseIdentifier: "ChatLeftMessageCell")
        chatTableView.register(UINib(nibName: "ChatRightMessageCell", bundle: nil), forCellReuseIdentifier: "ChatRightMessageCell")
        chatTableView.register(UINib(nibName: "ChatRightDocumentCell", bundle: nil), forCellReuseIdentifier: "ChatRightDocumentCell")
        chatTableView.register(UINib(nibName: "ChatLeftDocumentCell", bundle: nil), forCellReuseIdentifier: "ChatLeftDocumentCell")
        chatTableView.register(UINib(nibName: "ChatLeftImageCell", bundle: nil), forCellReuseIdentifier: "ChatLeftImageCell")
        chatTableView.register(UINib(nibName: "ChatRightImageCell", bundle: nil), forCellReuseIdentifier: "ChatRightImageCell")
        chatTableView.delegate = self
        chatTableView.dataSource = self
        chatTableView.showsVerticalScrollIndicator = false
        chatTableView.showsHorizontalScrollIndicator = false
        chatTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
    }
    
    func setupViewAppearance() {
        DispatchQueue.main.async {
            self.chatContainerView.roundCorners([.topLeft, .topRight], radius: 15, borderColor: .white, borderWidth: 0)
            self.sendButtonShadowView.applyShadow(backgroundColor: UIColor(red: 0, green: 0.404, blue: 0.8, alpha: 1), cornerRadii: CGSize(width: 10, height: 10), borderWidth: 0)
            self.messageTextfieldShadowView.applyInnerShadow(backgroundColor: UIColor(red: 0.93, green: 0.93, blue: 0.95, alpha: 1), cornerRadii: CGSize(width: 10, height: 10), borderWidth: 0)
        }
    }
    
    private func setTextView() {
        // configure the custom text view
        messageTextView.placeholder = "Add message"
        messageTextView.text = ""
        messageTextView.font = UIFont(name: "OverusedGrotesk-Medium", size: 16)
        // height change
        messageTextView.onHeightChange = { [weak self] newHeight in
            guard let self = self else { return }
            self.textViewHeight.constant = newHeight
            self.setupViewAppearance()
            self.view.layoutIfNeeded()
        }
    }
    
    //    private func updateChatContainerView() {
    //
    //        guard let view = self.view else { return }
    //
    //        if !isChatVisible {
    //            messageTextView.resignFirstResponder()
    //        }
    //
    //        self.updateBlurViewCorners(isPortrait: isPortrait)
    //
    //        UIView.animate(
    //            withDuration: 0.4,
    //            delay: 0,
    //            options: [.transitionCrossDissolve],
    //            animations: {
    //                self.chatContainerView.isHidden = !self.isChatVisible
    //                self.hideMenuOptionButton.isHidden = self.isChatVisible
    //                self.view.layoutIfNeeded()
    //            },
    //            completion: { finished in
    //                if finished {
    //                    self.reloadChatTableView()
    //                }
    //            }
    //        )
    //    }
    
    private func updateChatContainerView() {
        guard let view = self.view else { return }
        if !isChatVisible {
          messageTextView.resignFirstResponder()
        }
        self.chatContainerView.isHidden = false
        UIView.animate(
          withDuration: 0.4,
          delay: 0,
          options: [.curveEaseInOut],
          animations: {
            // smooth transition for the chat container visibility
            self.chatContainerView.alpha = self.isChatVisible ? 1.0 : 0.0
            self.hideMenuOptionButton.alpha = self.isMenuOptionVisible ? (self.isChatVisible ? 0.0 : 1.0) : 0.0
            self.view.layoutIfNeeded()
          },
          completion: { finished in
            if finished {
              self.chatContainerView.isHidden = !self.isChatVisible
              self.reloadChatTableView()
            }
          }
        )
      }
    
    func markAllMessagesRead() {
        print("==isChatVisible==",isChatVisible)
        guard isChatVisible else {
            updateUnreadMessageCount()
            return
        }
        
        // filter unread messages that were sent by the logged-in user
        let unreadAndMineMessages = self.chatMessages//.filter({!$0.isRead})
        
        DispatchQueue.main.async {
            
            for message in unreadAndMineMessages {
                CometChat.markAsRead(messageId: message.id, receiverId: message.receiverId, receiverType: .user, messageSender: message.senderId, onSuccess: {
                    self.updateUnreadMessageCount()
                }, onError: {(error) in
                  print("markAsDelivered error message",error?.errorDescription ?? "")
                })
            }
        }
    }

}

// hide show logic
extension VideoVC {
    
    @IBAction func showMenuOptionTapped(_ sender: UIButton) {
        //applyHaptic()
        self.isMenuOptionVisible.toggle()
        showRemoteName(true)
    }
    
    @IBAction func hideMenuOptionTapped(_ sender: UIButton) {
        //applyHaptic()
        self.isMenuOptionVisible.toggle()
        showRemoteName(false)
    }
    
    @IBAction func showSettingOptionTapped(_ sender: UIButton) {
        //applyHaptic()
        self.isSettingOptionVisible.toggle()
        if !isPortrait {
            showLandscapeRemoteName(true)
        }
    }
    
    @IBAction func hideSettingOptionTapped(_ sender: UIButton) {
        //applyHaptic()
        self.isSettingOptionVisible.toggle()
        showLandscapeRemoteName(false)
    }
    
    @IBAction func showHiddenVideo(_ sender: UIButton) {
        //applyHaptic()
        self.isMinimize.toggle()
    }
    
    @IBAction func minimizeVideo(_ sender: UIButton) {
        //applyHaptic()
        self.isMinimize.toggle()
    }
    
    @IBAction func maximizeVideo(_ sender: UIButton) {
        //applyHaptic()
        guard meetingModel?.videoModel.videoTileCount == 2 else {
          return
        }
        self.canSwitchVideo = true
        self.isRemoteVideMaximize.toggle()
      }
    
    private func hideShowMenuOption() {
        if isMenuOptionVisible {
            // show menu options with cross-dissolve
            animateMenuOption(shouldShow: true)
        } else {
            // hide menu options with cross-dissolve
            animateMenuOption(shouldShow: false)
        }
    }
    
    private func animateMenuOption(shouldShow: Bool) {
        
        let alphaValue: CGFloat = shouldShow ? 1 : 0
        let isHidden = !shouldShow
        
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            
            // update visibility and interactivity for buttons
            self.bottomBlurView.alpha = alphaValue
            
            self.hideMenuOptionButton.alpha = alphaValue
            self.hideMenuOptionButton.isUserInteractionEnabled = shouldShow
            
            self.microphoneButton.alpha = alphaValue
            self.microphoneButton.isUserInteractionEnabled = shouldShow
            
            self.chatButton.alpha = alphaValue
            self.chatButton.isUserInteractionEnabled = shouldShow
            
            self.chatButtonView.alpha = alphaValue
            self.chatButtonView.isUserInteractionEnabled = shouldShow
            
            self.settingButton.alpha = alphaValue
            self.settingButton.isUserInteractionEnabled = shouldShow
            
            self.crossButton.alpha = alphaValue
            self.crossButton.isUserInteractionEnabled = shouldShow
            
            if self.isSettingOptionVisible {
                self.isSettingOptionVisible = false
            }
            
        }, completion: { _ in    })
        
        self.showMenuOptionButton.isHidden = !isHidden
        self.reverseButton.isHidden = isHidden
    }
    
    private func hideShowSettingOption() {
        // animate the visibility of settingOptionView
        UIView.transition(with: self.view, duration: self.isSettingOptionVisible ? 0.3 : 0, options: .transitionCrossDissolve, animations: {
            self.settingOptionView.alpha = self.isSettingOptionVisible ? 1 : 0
            self.settingOptionView.isUserInteractionEnabled = self.isSettingOptionVisible ? true : false
        }, completion: { _ in
            
        })
        
        // set the visibility of the buttons after the animation finishes
        self.settingButton.isHidden = self.isSettingOptionVisible
        self.crossButton.isHidden = !self.isSettingOptionVisible
        
    }
    
    private func showHideVideo() {
        UIView.animate(withDuration: 0.3) {
            self.smallContainerView.alpha = self.isMinimize ? 0 : 1
            self.smallContainerView.isUserInteractionEnabled = !self.isMinimize
            self.showVideoView.alpha = self.isMinimize ? 1 : 0
            self.showVideoView.isUserInteractionEnabled = self.isMinimize
        }
    }
    
    private func switchVideo() {
        swapVideoFeeds()
    }
    
    private func presentTimeExtensionView() {
        let storyboard = UIStoryboard(name: "TelemechanicVideoMain", bundle: nil)
        guard let timeExtensionVC = storyboard.instantiateViewController(withIdentifier: "TimeExtensionVC") as? TimeExtensionVC else { return }
        timeExtensionVC.modalPresentationStyle = .formSheet
        timeExtensionVC.userType = userType
        
        
        
        timeExtensionVC.onAccept = {
            if self.userType == .consumer {
                self.meetingModel?.sendIncrementRequest()
            }
            else {
                self.incrementTimer = true
                self.meetingModel?.approveIncrementRequest()
            }
            
        }
        
        timeExtensionVC.onReject = {}
        
        let window = UIApplication.shared.keyWindow!
        if let modalVC = window.rootViewController?.presentedViewController {
            modalVC.present(timeExtensionVC, animated: true, completion: nil)
        } else {
            window.rootViewController!.present(timeExtensionVC, animated: true, completion: nil)
        }
        
        // self.present(timeExtensionVC, animated: true, completion: nil)
    }
    
    func dismissTimeExtensionVC() {
        let storyboard = UIStoryboard(name: "TelemechanicVideoMain", bundle: nil)
        guard let timeExtensionVC = storyboard.instantiateViewController(withIdentifier: "TimeExtensionVC") as? TimeExtensionVC else { return }
        timeExtensionVC.dismissView()
    }
    
    @IBAction func showHideChat(_ sender: Any) {
        self.isChatVisible.toggle()
    }
    
    @objc func chatCloseButtonTapped(_ sender: UIButton) {
        // Add the action you want to perform when the button is tapped
        isChatVisible = false
    }
    
}

//MARK: Actions
extension VideoVC {
    
    @IBAction func chatBtnAction(_ sender: UIButton) {
        self.isChatVisible.toggle()
        setupViewAppearance()
    }
    
    @IBAction func flipCameraView(_ sender: UIButton) {
        self.reverseButton.isSelected.toggle()
        self.meetingModel?.videoModel.customSource.switchCamera()
        self.updateMirroring()
    }
    
    @IBAction func endCall(_ sender: UIButton) {
        meetingModel?.endMeeting()
    }
    
    @IBAction func micBtnAction(_ sender: UIButton) {
        meetingModel?.setMute(isMuted: !microphoneButton.isSelected)
    }
    
    @IBAction func screenShotBtnAction(_ sender: UIButton) {
        
        if let screenshot = captureScreenshot(ofViews: [smallContainerView, largeView], inParentView: self.mainView) {
              UIImageWriteToSavedPhotosAlbum(screenshot, nil, nil, nil) // Save to Photos
            }
        
        let alert = UIAlertController(title: "Screenshot Saved", message: "The screenshot has been saved to your photo library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func captureScreenshot(ofViews viewsToShow: [UIView], inParentView parentView: UIView) -> UIImage? {
        // Store the initial visibility states of all subviews
        let initialVisibility = parentView.subviews.map { $0.isHidden }
        // Show only the specified views
        parentView.subviews.forEach { subview in
          subview.isHidden = !viewsToShow.contains(subview)
        }
        // Take the screenshot of the parent view
        let screenshot = parentView.captureScreenshot()
        // Restore the original visibility states
        for (index, subview) in parentView.subviews.enumerated() {
          subview.isHidden = initialVisibility[index]
        }
        return screenshot
      }
    
    @IBAction func removePointerBtnAction(_ sender: UIButton) {
        disablePointerView.isHidden = true
        pointerButton.isSelected = !pointerButton.isSelected
        pointerButtonEnabled = pointerButton.isSelected
        removePointer()
        meetingModel?.removePointer()
        if self.isMinimize {
            self.isMinimize.toggle()
        }
    }
    
    @IBAction func pointerBtnAction(_ sender: UIButton) {
        
        guard meetingModel?.videoModel.videoTileCount == 2 else {
            return
        }
        
        pointerButton.isSelected = !pointerButton.isSelected
        pointerButtonEnabled = pointerButton.isSelected
        
        setPointerUI()
        
        if pointerButtonEnabled {
            configurePointer()
            meetingModel?.addPointer()
            disablePointerView.isHidden = false
        }
        else {
            removePointer()
            meetingModel?.removePointer()
            disablePointerView.isHidden = true
            if self.isMinimize {
                self.isMinimize.toggle()
            }
        }
    }
    
    private func setPointerUI() {
        if pointerButtonEnabled {
            if largeView != userRendererView {
                swapVideoFeeds()
            }
            self.isMenuOptionVisible = false
            self.isMinimize = true
            showRemoteName(false)
            showLandscapeRemoteName(false)
        }
    }
}


// MARK: - Chat
extension VideoVC {
    
    @IBAction func messageSendButtonTapped(_ sender: Any) {
        sendMessage()
    }
    
    @IBAction func attachmentButtonTapped(_ sender: Any) {
        self.galleryView.scrollToFirstItem()
        isChatAttachmentEnable = true
    }
    
    @IBAction func crossAttachmentButtonTapped(_ sender: Any) {
        isChatAttachmentEnable = false
    }
    
    @IBAction func crossSelectedAttachmentButtonTapped(_ sender: Any) {
        self.selectedAttachment = nil
    }
    
    @IBAction func playSelectedAttachmentButtonTapped(_ sender: Any) {
        if let file = selectedAttachment?.files?.first, let data = file.data {
            let documentHandler = DocumentInteractionHandler()
            let fileData: Data = data
            documentHandler.presentDocumentPreview(withData: fileData, name: file.name ?? "")
        }
    }
    
    @IBAction func fileButtonTapped(_ sender: Any) {
        
        let allowedTypes: [UTType] = [
            UTType.pdf,          // PDF files
            UTType.text,         // DOC files (Text documents)
            UTType.audio,        // Audio files (MP3, etc.)
            UTType.video,        // Video files (MP4, MOV, etc.)
            UTType.image    // Image files (JPEG, PNG, etc.)
        ]
        
        // Create the document picker with the allowed content types
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        // Present the document picker
        present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func mediaButtonTapped(_ sender: Any) {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.preferredAssetRepresentationMode = .current
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func performLogin() {
        CometChatManager.shared.loginWithUID(uid: localUserId) { user, errorMessage in
            if let user = user {
                print("User logged in: \(user.name ?? "")")
                CometChatManager.shared.fetchMessageHistory(remoteUID: self.remoteUserId, senderUID: self.localUserId) { [weak self] messages in
                    
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.chatMessages = messages
                        self.reloadChatTableView()
                    }
                }
                
            } else if let error = errorMessage {
                print("Failed to login: \(error)")
            } else {
                print("Unexpected error occurred during login")
            }
        }
    }
    
    func reloadChatTableView() {
        self.chatTableView.reloadData()
        if !self.chatMessages.isEmpty {
            let lastIndex = IndexPath(row: self.chatMessages.count - 1, section: 0)
            self.chatTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
        }
    }
    
    func sendMessage(ignoreAttachment: Bool = false) {
        
        // trim whitespace and check if the message is empty
        let messageText = messageTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if self.isChatAttachmentEnable && selectedAttachment == nil{
            self.showAlert(title: "Alert", message: "Please select attachment")
            return
        }
        
        if let attachment = selectedAttachment, !ignoreAttachment {
            
            DispatchQueue.main.async {
                // start the loader
                ActivityIndicatorHelper.shared.startLoading(on: self.bottomInnerContainerView)
            }
            
            CometChatManager.shared.sendAttachment(mediaMessage: attachment) { (message, error) in
                
                if let error = error {
                    ActivityIndicatorHelper.shared.stopLoading()
                    print("Failed to send message: \(error)")
                } else if let message = message {
                    
                    DispatchQueue.main.async {
                        
                        let chatMessage = ChatMessage(id: message.id, text: "", mediaURL: nil, senderId: self.localUserId, messageType: message.messageType, sentAt: message.sentAt, receiverId: message.receiverUid, attachements: message.attachments)
                        self.chatMessages.append(chatMessage)
                        self.chatTableView.reloadData()
                        let lastIndex = IndexPath(row: self.chatMessages.count - 1, section: 0)
                        self.chatTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
                        
                        guard !messageText.isEmpty else {
                            ActivityIndicatorHelper.shared.stopLoading()
                            self.selectedAttachment = nil
                            self.isChatAttachmentEnable = false
                            return
                        }
                        
                        self.sendMessage(ignoreAttachment: true)
                    }
                }
            }
            
        } else {
            
            guard !messageText.isEmpty else {
                print("Cannot send an empty message.")
                return
            }
            
            CometChatManager.shared.sendMessage(to: remoteUserId, messageText: messageText) { (message, error) in
                
                ActivityIndicatorHelper.shared.stopLoading()
                self.selectedAttachment = nil
                self.isChatAttachmentEnable = false
                
                if let error = error {
                    print("Failed to send message: \(error)")
                    CometChatErrorHandler.shared.handleError(errorCode: error, on: self)
                    
                } else if let message = message {
                    print("Success send message: \(message)")
                    if let textMessage = message as? TextMessage {
                        print("Message content: \(textMessage)")
                    }
                    DispatchQueue.main.async {
                        let chatMessage = ChatMessage(id: message.id, text: messageText, mediaURL: nil, senderId: self.localUserId, messageType: .text, sentAt: message.sentAt, receiverId: message.receiverUid)
                        self.chatMessages.append(chatMessage)
                        self.chatTableView.reloadData()
                        let lastIndex = IndexPath(row: self.chatMessages.count - 1, section: 0)
                        // self.chatTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
                        self.chatTableView.scrollToRow(at: lastIndex, position: .bottom, animated: true) {
                            print("Scrolling animation completed!")
                            
                        }
                        self.messageTextView.text = ""
                    }
                }
            }
        }
        
    }
    
    func deleteMessage(at indexPath: IndexPath) {
        
        let message = chatMessages[indexPath.row]
        
        CometChatManager.shared.deleteMessage(with: message.id) { (success, error) in
            if let error = error {
                print("Failed to delete message: \(error)")
            } else if success {
                print("Message deleted successfully.")
                
                // Update the chatMessages array to remove the deleted message
                DispatchQueue.main.async {
                    self.chatMessages.remove(at: indexPath.row)
                    self.chatTableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func handleButtonTap(message: ChatMessage) {
        
        // Example file URL (replace with your document's actual URL)
        guard let document = message.attachements?.first?.fileUrl else {
            print("Invalid document URL.")
            return
        }
        
        DispatchQueue.main.async {
            // start the loader
            ActivityIndicatorHelper.shared.startLoading(on: self.bottomInnerContainerView)
        }
        
        CometChatManager.shared.downloadFile(from: document) { localURL in
            
            DispatchQueue.main.async {
                
                ActivityIndicatorHelper.shared.stopLoading()
                
                // show doc. preview
                if let localURL = localURL {
                    let documentHandler = DocumentInteractionHandler()
                    documentHandler.presentDocumentPreview(withData: localURL, name: "")
                }
            }
        }
    }
    
    func updateUnreadMessageCount() {
        CometChatManager.shared.updateUnreadMessageCount(uid: remoteUserId) { count, error in
            DispatchQueue.main.async {
                self.notificationCount = count
            }
        }
    }
    
}

extension VideoVC: PHPickerViewControllerDelegate {
    
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        DispatchQueue.main.async {
          if let result = results.first {
            // check if the selected item is a image
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
              result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                if let error = error {
                  print("Error loading image: \(error.localizedDescription)")
                } else if let image = object as? UIImage {
                  DispatchQueue.main.async {
                    // Convert image to Data
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                      print("Image Data Size: \(imageData.count) bytes")
                      print("Image loaded successfully!")
                      // retrieve the file name using PHAsset
                      result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                        if let error = error {
                          print("Error loading file representation: \(error.localizedDescription)")
                        } else if let url = url {
                          // Extract file name from URL
                          let imageName = url.lastPathComponent
                          print("Image Name: \(imageName)")
                          self.selectedAttachment = MediaMessage(receiverUid: self.remoteUserId,
                                              files: [File(name: imageName, data: imageData)],
                                              messageType: .image,
                                              receiverType: .user)
                        }
                      }
                    }
                  }
                }
              }
            }
            // check if the selected item is a video
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                DispatchQueue.main.async {
                    ActivityIndicatorHelper.shared.startLoading(on: self.bottomInnerContainerView)
                }
              result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { url, error in
                  
                  DispatchQueue.main.async {
                      ActivityIndicatorHelper.shared.stopLoading()
                  }
                  
                if let error = error {
                  print("Error loading video: \(error.localizedDescription)")
                } else if let url = url {
                  do {
                    // convert video to Data
                    let videoData = try Data(contentsOf: url)
                    print("Video name: \(url.lastPathComponent)")
                    print("Video Data Size: \(videoData.count) bytes")
                    self.selectedAttachment = MediaMessage(receiverUid: self.remoteUserId,
                                        files: [File(name: url.lastPathComponent, data: videoData)],
                                        messageType: .video,
                                        receiverType: .user)
                    // Example usage: Save or upload the video data
                  } catch {
                    print("Error converting video to data: \(error.localizedDescription)")
                  }
                }
              }
            }
          }
        }
      }
}

extension VideoVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            // start accessing the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Could not access security scoped resource for \(url)")
                continue
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                // get the file's type using resourceValues
                let resourceValues = try url.resourceValues(forKeys: [.contentTypeKey])
                
                if let fileType = resourceValues.contentType {
                    // log file name and type for debugging
                    print("File name: \(url.lastPathComponent)")
                    print("File type: \(fileType.identifier)")
                    
                    // determine the type of the file
                    let name = url.lastPathComponent
                    let type: CometChat.MessageType
                    
                    if fileType.conforms(to: .image) {
                        type = .image
                        print("Detected as Image")
                    } else if fileType.conforms(to: .video) {
                        type = .video
                        print("Detected as Video")
                    } else if fileType.conforms(to: .audio) {
                        type = .audio
                        print("Detected as Audio")
                    } else {
                        type = .file
                        print("Detected as File")
                    }
                    
                    // convert the file URL to Data
                    do {
                        let fileData = try Data(contentsOf: url)
                        print("File Data Size: \(fileData.count) bytes")
                        
                        // create the MediaMessage
                        self.selectedAttachment = MediaMessage(
                            receiverUid: self.remoteUserId,
                            files: [File(name: name, data: fileData)],
                            messageType: type,
                            receiverType: .user
                        )
                        
                    } catch {
                        print("Error converting file to data: \(error.localizedDescription)")
                    }
                    
                } else {
                    print("Could not determine the file type for \(url.lastPathComponent).")
                }
            } catch {
                print("Error determining file type: \(error.localizedDescription)")
            }
        }
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("User canceled document picker.")
    }
    
}

extension VideoVC {
    
    func updateChatUI() {
        
        DispatchQueue.main.async {
            
            if let attachment = self.selectedAttachment, let file = attachment.files?.first, let data = file.data {
                
                self.chatTableView.isHidden = true
                self.chatAttachmentView.isHidden = true
                self.selectedAttachmentView.isHidden = false
                self.attachmentButton.isHidden = true
                
                self.playAttachmentButton.isHidden = true
                self.attachmentNameLabel.isHidden = true
                
                switch attachment.messageType {
                    
                case .image:
                    
                    if let image = UIImage(data: data) {
                        
                        self.selectedAttachmentUserImageView.removeShadow()
                        self.selectedAttachmentUserImageView.image = image
                        
                        // calculate the aspect ratio of the image
                        let aspectRatio = image.size.width / image.size.height
                        let viewWidth = self.view.frame.width
                        let viewHeight = self.view.frame.height
                        
                        if aspectRatio > 1 {
                            // landscape
                            let width = viewWidth * 0.7
                            let height = width / aspectRatio
                            self.attachmentUserImageWidth.constant = width
                            self.attachmentUserImageHeight.constant = height
                        } else {
                            // portrait
                            let height = viewHeight * 0.35
                            let width = height * aspectRatio
                            self.attachmentUserImageWidth.constant = width
                            self.attachmentUserImageHeight.constant = height
                        }
                        
                        self.selectedAttachmentUserImageView.layer.borderWidth = 1
                        self.selectedAttachmentUserImageView.layer.borderColor = UIColor(red: 0.929, green: 0.933, blue: 0.949, alpha: 0.8).cgColor
                    }
                    
                case .video:
                    
                    self.playAttachmentButton.isHidden = false
                    
                    // create an AVAsset instance from the video data
                    let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("tempVideo.mp4")
                    do {
                        try data.write(to: tempFileURL)
                        let asset = AVAsset(url: tempFileURL)
                        let imageGenerator = AVAssetImageGenerator(asset: asset)
                        imageGenerator.appliesPreferredTrackTransform = true
                        
                       
                        let time = CMTime(seconds: 1, preferredTimescale: 600)
                        let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                        let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
                        
                        // update the image view
                        self.selectedAttachmentUserImageView.image = thumbnailImage
                        
                        // adjust the aspect ratio as you did for the image case
                        let aspectRatio = thumbnailImage.size.width / thumbnailImage.size.height
                        let viewWidth = self.view.frame.width
                        let viewHeight = self.view.frame.height
                        
                        if aspectRatio > 1 {
                            // landscape
                            let width = viewWidth * 0.7
                            let height = width / aspectRatio
                            self.attachmentUserImageWidth.constant = width
                            self.attachmentUserImageHeight.constant = height
                        } else {
                            // portrait
                            let height = viewHeight * 0.35
                            let width = height * aspectRatio
                            self.attachmentUserImageWidth.constant = width
                            self.attachmentUserImageHeight.constant = height
                        }
                        
                        self.selectedAttachmentUserImageView.layer.borderWidth = 1
                        self.selectedAttachmentUserImageView.layer.borderColor = UIColor(red: 0.929, green: 0.933, blue: 0.949, alpha: 0.8).cgColor
                        
                        // remove the temporary file
                        try FileManager.default.removeItem(at: tempFileURL)
                    } catch {
                        print("Error generating video thumbnail: \(error)")
                    }
                    
                case .file:
                    
                    self.attachmentUserImageWidth.constant = 56.25
                    self.attachmentUserImageHeight.constant = 71.94
                    
                    self.selectedAttachmentUserImageView.image = UIImage(named: "filePreview")
                    self.attachmentNameLabel.isHidden = false
                    self.attachmentNameLabel.text = file.name?.abbreviated(maxLength: 30) ?? ""
                    
                    self.view.layoutIfNeeded()
                    
                    self.selectedAttachmentUserImageView.layer.borderWidth = 0
                    self.selectedAttachmentUserImageView.applyShadow(
                        color: UIColor(red: 0.443, green: 0.463, blue: 0.486, alpha: 0.5),
                        opacity: 1,
                        radius: 8.89,
                        offset: CGSize(width: 4.44, height: 4.44),
                        cornerRadius: 0
                    )
                    
                case .audio:
                    
                    self.selectedAttachmentUserImageView.removeShadow()
                    
                    self.attachmentUserImageWidth.constant = 74
                    self.attachmentUserImageHeight.constant = 74
                    
                    self.selectedAttachmentUserImageView.image = UIImage(named: "audioPreview")
                    self.attachmentNameLabel.isHidden = false
                    self.attachmentNameLabel.text = file.name?.abbreviated(maxLength: 30) ?? ""
                    
                    self.view.layoutIfNeeded()
                    
                    self.selectedAttachmentUserImageView.layer.borderWidth = 0
                    self.selectedAttachmentUserImageView.applyButtonShadow()
                    
                default:
                    break
                }
                
            } else {
                
                self.attachmentButton.isHidden = self.isChatAttachmentEnable
                self.selectedAttachmentView.isHidden = true
                self.chatTableView.isHidden = self.isChatAttachmentEnable
                self.chatAttachmentView.isHidden = !self.isChatAttachmentEnable
                
            }
            
            self.view.layoutIfNeeded()
        }
        
        self.setupViewAppearance()
    }
    
    func getGalleryViewImage() {
        galleryView.onImageTap = { image, name in
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                self.selectedAttachment = MediaMessage(receiverUid: self.remoteUserId,
                                                       files: [File(name: name, data: imageData)],
                                                       messageType: .image,
                                                       receiverType: .user)
            }
        }
    }
    
    @objc func attachmentTapped() {
        if let attachment = self.selectedAttachment, let file = attachment.files?.first, let data = file.data {
            let documentHandler = DocumentInteractionHandler()
            let fileData: Data = data
            documentHandler.presentDocumentPreview(withData: fileData, name: file.name ?? "")
        }
    }
    
}

extension VideoVC {
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func showYesNoAlert(on viewController: UIViewController, title: String, message: String, yesHandler: @escaping () -> Void, noHandler: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            yesHandler()
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            noHandler?()
        }
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension String {
    func abbreviated(maxLength: Int = 50) -> String {
        guard self.count > maxLength else {
            return self
        }
        
        let startIndex = self.index(self.startIndex, offsetBy: 0)
        let endIndex = self.index(self.endIndex, offsetBy: -7)
        
        let start = self[startIndex..<self.index(self.startIndex, offsetBy: maxLength - 7)]
        let end = self[endIndex..<self.endIndex]
        
        return start + "..." + end
    }
}

class DocumentInteractionHandler: NSObject, UIDocumentInteractionControllerDelegate {
    
    private var documentInteractionController: UIDocumentInteractionController?
    
    // Function to set up and present the document preview
    func presentDocumentPreview(withData data: Any, name: String) {
        if let fileURL = data as? URL {
            // If the data is a URL, use it as the document's URL
            self.presentDocumentPreview(withFileURL: fileURL)
        } else if let fileData = data as? Data {
            // If the data is raw data, we need to save it as a temporary file and use its URL
            let tempURL = self.createTemporaryFile(withData: fileData, name: name)
            self.presentDocumentPreview(withFileURL: tempURL)
        }
    }
    
    // Helper method to create a temporary file from raw data
    private func createTemporaryFile(withData data: Data, name: String) -> URL {
        // Get the path to the temporary directory
        let tempDirectory = FileManager.default.temporaryDirectory
        
        // Create a unique file name (e.g., using a UUID)
        let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(name.fileExtension())
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error saving data to temporary file: \(error)")
        }
        
        return fileURL
    }
    
    // Method to present the document interaction controller preview
    private func presentDocumentPreview(withFileURL fileURL: URL) {
        self.documentInteractionController = UIDocumentInteractionController(url: fileURL)
        self.documentInteractionController?.delegate = self
        self.documentInteractionController?.presentPreview(animated: true)
    }
    
    // UIDocumentInteractionControllerDelegate methods (optional)
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        
        let window = UIApplication.shared.keyWindow!
        
        if let modalVC = window.rootViewController?.presentedViewController {
            return modalVC
        } else {
            return window.rootViewController!
        }
        
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        self.documentInteractionController = nil
    }
    
}

extension String {
    
    func fileName() -> String {
        return URL(fileURLWithPath: self).deletingPathExtension().lastPathComponent
    }
    
    func fileExtension() -> String {
        return URL(fileURLWithPath: self).pathExtension
    }
    
}

class DraggableView: UIView {
    // Completion handler for downward drag events
    var onDragDown: ((CGPoint) -> Void)?

    // Add pan gesture programmatically
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPanGesture()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPanGesture()
    }
    
    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let superview = self.superview else { return }
        let translation = sender.translation(in: superview)

        switch sender.state {
        case .changed:
            // Only allow downward drag (positive Y translation)
            if translation.y > 0 {
                // Update the position of the view
                // Trigger the completion handler
                onDragDown?(center)
            }
        default:
            break
        }
    }
}

