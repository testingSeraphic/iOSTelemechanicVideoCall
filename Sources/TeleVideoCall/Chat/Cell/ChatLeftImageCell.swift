//
//  ChatLeftImageCell.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 21/11/24.
//

import UIKit
import SDWebImage

class ChatLeftImageCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var messageShadowView: UIView!
    @IBOutlet weak var userProfileShadowView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var messageSentTimeLabel: UILabel!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageImageShadowView: UIView!
    @IBOutlet weak var messageImageContainerView: UIView!
    @IBOutlet weak var downloadButton: UIButton!
    
    var message: ChatMessage?
    
    var downloadImageButtonTapped: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = false
        self.configureShadowAndCorners()
        messageSentTimeLabel.font = UIFont(name: "OverusedGrotesk-Medium", size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.configureShadowAndCorners()
    }
    
    func setup(with data: ChatMessage) {
        self.message = data
        messageSentTimeLabel.text = Helper.formatTimestamp(data.sentAt)
        
        if let attachments = data.attachements, attachments.count > 0, let urlString = attachments.first?.fileUrl, let url = URL(string: urlString) {
            
            self.messageImageView.image = nil
            
            if data.messageType == .image {
                self.playImageView.isHidden = true
                
               // messageImageView.sd_showActivityIndicatorView()
                //messageImageView.sd_setIndicatorStyle(.medium)
               // messageImageView.sd_setShowActivityIndicatorView(true)
                messageImageView.sd_imageIndicator = SDWebImageActivityIndicator.medium
                messageImageView.sd_imageIndicator?.startAnimatingIndicator()
                messageImageView.sd_setImage(with: url, placeholderImage: nil) { [weak self] _, _, _, _ in
                    self?.messageImageView.sd_imageIndicator?.stopAnimatingIndicator()
                }
               // messageImageView.sd_setImage(with: url, placeholderImage: nil)
            } else {
                self.playImageView.isHidden = false
                CometChatManager.shared.generateThumbnail(from: url) {  [weak self] thumbnail in
                    DispatchQueue.main.async {
                        self?.messageImageView.image = thumbnail
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func configureShadowAndCorners() {
        downloadButton.applyButtonShadow()
//        messageShadowView.configureAsSideCell(type: .right)
        userProfileImageView.layer.cornerRadius = 19
        userProfileShadowView.applyShadow(cornerRadii: CGSize(width: 19.5, height: 19.5))
//        messageImageShadowView.applyImageShadow(cornerRadii: CGSize(width: 19.5, height: 19.5), corners: [.topLeft, .topRight, .bottomLeft])
//        messageImageContainerView.layer.cornerRadius = 12
//        messageImageView.roundCorners([.topLeft, .topRight, .bottomLeft], radius: 12)
        
        messageImageContainerView.layer.cornerRadius = 10
        messageImageContainerView.layer.borderWidth = 1
        messageImageContainerView.layer.borderColor = UIColor(red: 0.929, green: 0.933, blue: 0.949, alpha: 0.8).cgColor
        messageImageContainerView.clipsToBounds = true
        self.playImageView.applyButtonShadow()
    }
    
    @IBAction func downloadImageButtonAction(_ sender: UIButton) {
        guard let message = message, let attachments = message.attachements, attachments.count > 0, let url = attachments.first?.fileUrl else { return }
        downloadImageButtonTapped?(url)
    }
    
}
