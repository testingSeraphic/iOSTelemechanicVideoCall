//
//  TimeExtensionVC.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 13/11/24.
//

import UIKit



class TimeExtensionVC: UIViewController {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurView: CustomLightBlurredView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    
    var userType: UserType?
    
    var onAccept: (() -> Void)?
    var onReject: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 16
        blurView.roundExtensionCorners([.topLeft, .topRight], radius: 28,
                                         borderColor: UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1),
                                         borderWidth: 1)
       // containerView.addInnerShadow(borderWidth: 3, shadowRadius: 10, shadowOpacity: 0.3, shadowColor: .black)
        setupUIComponents()
        let buttons = [acceptButton!, rejectButton!]
        buttons.forEach { button in
            button.applyButtonShadow()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        blurView.roundExtensionCorners([.topLeft, .topRight], radius: 28,
                                         borderColor: UIColor(red: 0.795, green: 0.799, blue: 0.82, alpha: 1),
                                         borderWidth: 1)
    }
    
    func setupUIComponents() {
        if userType == .consumer {
            titleLabel.text = "Appointment Will End Soon"
            subTitleLabel.text = "Do you want to add more time?"
        }
        
        else {
            titleLabel.text = "Client Requested Extension"
            subTitleLabel.text = "Approve adding more time?"
        }
        
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptButtonAction(_ sender: UIButton) {
        onAccept?()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func rejectButtonAction(_ sender: UIButton) {
        onReject?()
        self.dismiss(animated: true, completion: nil)
    }
}
