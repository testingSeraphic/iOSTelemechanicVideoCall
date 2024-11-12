//
//  VideoVC.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 06/11/24.
//

import UIKit
import AmazonChimeSDK
import ReplayKit

enum UserType {
    case user
    case provider
}

public class VideoVC: UIViewController {
    
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
                    meetingModel?.removePointer()
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
    private let duration = 5
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
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //meeting Model Configuration
        guard let meetingModel = meetingModel else {
            logger.error(msg: "MeetingModel not set")
            dismiss(animated: true, completion: nil)
            return
        }
        
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
        // Enable the microphone for screen broadcasting programmatically
        enableMicrophoneForBroadcasting()
        
    }
    
    func enableMicrophoneForBroadcasting() {
        if RPScreenRecorder.shared().isMicrophoneEnabled == false {
            RPScreenRecorder.shared().isMicrophoneEnabled = true
        }
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // hide views before the transition begins
        self.setViewsHidden(true)
        
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
            
            if self.pointerButtonEnabled {
                self.configurePointer()
            }
        })
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //        if isRecordingEnabled {
        //            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        //                   self.startScreenRecording()
        //               }
        //           }
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
        //        if self.isRecordingEnabled {
        //            self.stopScreenRecording()
        //        }
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
        //        meetingModel.rosterModel.rosterUpdatedHandler = { [weak self] in
        //            //self?.rosterTable.reloadData()
        //        }
        
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
   
        
        meetingModel.meetingTimerIncrementedHandler = {
            self.resetTimer()
        }
        
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
            self.pointerButton.isSelected = true
            self.pointerButtonEnabled = true
            self.configurePointer()
            
        }
        
        meetingModel.pointerRemovedHandler = {
            self.pointerButton.isSelected = false
            self.pointerButtonEnabled = false
            self.removePointer()
        }
        
        meetingModel.isRemotePortrait = { [weak self] isRemotePortrait in
            self?.isRemotePortrait = isRemotePortrait
        }
        
        meetingModel.frontCameraToggle = { [weak self] isFront in
//            self?.updateMirroring(isLocal: false)
            self?.remoteRendererView?.mirror = isFront
            self?.isRemoteFrontEnabled = isFront
            
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
                
                if name == "user" || name == "User" {
                    userType = .user
                    self.isRemoteVideMaximize = false
                }
                else {
                    userType = .provider
                }
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
    
    func bindVideoFeeds() {
        
        guard let meetingModel = meetingModel else { return }
        
        print("meetingModel.videoModel.videoTileCount=", meetingModel.videoModel.videoTileCount)
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
                if userName == "user" {
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
            
            if self.isPortrait &&  self.isRemotePortrait {
                largeView.contentMode = .scaleAspectFill
            } else if self.isPortrait && !self.isRemotePortrait {
                largeView.contentMode = .scaleAspectFit
            } else if !self.isPortrait && !self.isRemotePortrait {
                largeView.contentMode = .scaleAspectFill
            } else if self.isRemotePortrait && !self.isPortrait {
                largeView.contentMode = .scaleAspectFit
            }
            
            smallView.contentMode = self.isPortrait ? .scaleAspectFill : .scaleAspectFit
            
        } else {
            
            if self.isPortrait &&  self.isRemotePortrait {
                smallView.contentMode = .scaleAspectFill
            } else if self.isPortrait && !self.isRemotePortrait {
                smallView.contentMode = .scaleAspectFit
            } else if !self.isPortrait && !self.isRemotePortrait {
                smallView.contentMode = .scaleAspectFit
            } else if self.isRemotePortrait && !self.isPortrait {
                smallView.contentMode = .scaleAspectFill
            }
            
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
                if incrementTimer {
                    self.resetTimer()
                    self.meetingModel?.notifyIncrementTime()
                }
                else {
                    stopTimer()
                    meetingModel?.endMeeting()
                }
                
            } else {
                if userType == .user && timeRemaining == criticalTimeRemaining {
                    showAddMoreTimeAlert()
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
    
    private func showAddMoreTimeAlert() {
        showYesNoAlert(on: self, title: "Do you want to increase the duration of session?", message: "", yesHandler: {
            self.incrementTimer = true
            
        }, noHandler: {
        })
    }
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
        self.isMenuOptionVisible = false
        self.isMinimize = false
        //        self.isRemoteVideMaximize = false
        
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
            self.settingOptionBottomConstraint.constant = 114
            self.settingOptionTrailingConstraint.constant = 10
        } else {
            // landscape constraints
            //
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
            self.settingOptionTrailingConstraint.constant = 114
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
            if isPortrait {
                self.bottomBlurView.roundCorners([.topLeft, .topRight], radius: 28,
                                                 borderColor: UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1),
                                                 borderWidth: 1)
            } else {
                self.bottomBlurView.roundCorners([.bottomLeft, .topLeft], radius: 28,
                                                 borderColor: UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1),
                                                 borderWidth: 1)
            }
        }
    }
    
    private func setOptionButtonOrder() {
        // order of buttons
        var buttons = [showMenuOptionButton!, reverseButton!, microphoneButton!, callButton!, chatButton!, settingButton!, crossButton!]
        
        if !isMenuOptionVisible && !isPortrait {
            buttons =  buttons.reversed()
        }
        
        // remove all current buttons
        for button in buttons {
            menuOptionStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
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
        
        // apply shadow to buttons
        let buttons = [showMenuOptionButton!, reverseButton!, microphoneButton!, callButton!, chatButton!, settingButton!, crossButton!, pointerButton!, highlighterButton!, penButton!, pinButton!, screenshotButton!]
        buttons.forEach { button in
            button.applyShadow()
        }
    }
}

// hide show logic
extension VideoVC {
    
    @IBAction func showMenuOptionTapped(_ sender: UIButton) {
        applyHaptic()
        self.isMenuOptionVisible.toggle()
        showRemoteName(true)
    }
    
    @IBAction func hideMenuOptionTapped(_ sender: UIButton) {
        applyHaptic()
        self.isMenuOptionVisible.toggle()
        showRemoteName(false)
    }
    
    @IBAction func showSettingOptionTapped(_ sender: UIButton) {
        applyHaptic()
        self.isSettingOptionVisible.toggle()
    }
    
    @IBAction func hideSettingOptionTapped(_ sender: UIButton) {
        applyHaptic()
        self.isSettingOptionVisible.toggle()
    }
    
    @IBAction func showHiddenVideo(_ sender: UIButton) {
        applyHaptic()
        self.isMinimize.toggle()
    }
    
    @IBAction func minimizeVideo(_ sender: UIButton) {
        applyHaptic()
        self.isMinimize.toggle()
    }
    
    @IBAction func maximizeVideo(_ sender: UIButton) {
        applyHaptic()
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
    
    func hideMaximizeAndMinimizeViews(in view: UIView, hideCount: inout Int) {
        // Base Case
        guard hideCount < 2 else { return }
        
        for subview in view.subviews {
            if subview == maximizeView || subview == minimzieView {
                subview.isHidden = true
                hideCount += 1
                
                if hideCount == 2 { return }
            }
            hideMaximizeAndMinimizeViews(in: subview, hideCount: &hideCount)
        }
    }
    
}

//MARK: Actions
extension VideoVC {
    
    @IBAction func flipCameraView(_: UIButton) {
        print("FlipCameraTapped!")
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
        guard let mainView = self.mainView else { return }
        
        // Specify the two views you want to include in the screenshot
        let viewToShow1 = smallContainerView
        let viewToShow2 = largeView
        
        // Hide all other views except the two specified
        mainView.subviews.forEach { subview in
            if subview != viewToShow1 && subview != viewToShow2 {
                subview.isHidden = true
            }
        }
        
        viewToShow1?.subviews.forEach { subview in
            if subview is UIStackView {
                subview.isHidden = true
            }
        }
        
        // Render the screenshot
        let renderer = UIGraphicsImageRenderer(bounds: mainView.bounds)
        let image = renderer.image { context in
            mainView.layer.render(in: context.cgContext)
        }
        
        // Restore visibility of all views
        mainView.subviews.forEach { subview in
            subview.isHidden = false
        }
        
        viewToShow1?.subviews.forEach { subview in
            if subview is UIStackView {
                subview.isHidden = false
            }
        }
        
       
        
        // Save the image to the photo library (requires permission in Info.plist)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        
        // Show an alert confirming the screenshot was saved
        let alert = UIAlertController(title: "Screenshot Saved", message: "The screenshot has been saved to your photo library.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pointerBtnAction(_ sender: UIButton) {
        guard meetingModel?.videoModel.videoTileCount == 2 else {
           return
        }
        
        pointerButton.isSelected = !pointerButton.isSelected
        pointerButtonEnabled = pointerButton.isSelected
        if pointerButtonEnabled {
            configurePointer()
            meetingModel?.addPointer()
        }
        else {
            removePointer()
            meetingModel?.removePointer()
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
