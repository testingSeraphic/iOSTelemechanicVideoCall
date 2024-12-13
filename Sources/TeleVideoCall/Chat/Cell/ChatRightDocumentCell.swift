//
//  ChatRightDocumentCell.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 19/11/24.
//

import UIKit

class ChatRightDocumentCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var messageShadowView: UIView!
    @IBOutlet weak var userProfileShadowView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var readStatusImageView: UIImageView!
    @IBOutlet weak var messageSentTimeLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buttonShadowView: UIView!
    @IBOutlet weak var fileTypeImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = false
        self.configureShadowAndCorners()
        nameLabel.font = UIFont(name: "OverusedGrotesk-Medium", size: 16)
        sizeLabel.font = UIFont(name: "OverusedGrotesk-Medium", size: 14)
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
    
    func configureCell(message: ChatMessage) {
        guard let attachments = message.attachements, attachments.count > 0, let attachment = attachments.first else {
            return
        }
        
        // Set the text fields
        messageSentTimeLabel.text = Helper.formatTimestamp(message.sentAt)
        nameLabel.text = message.attachements?.first?.fileName.abbreviated(maxLength: 15)
        sizeLabel.text = Helper.formatSize(bytes: message.attachements?.first?.fileSize)
        configureMessageReadStatus(with: message)
        
        switch message.messageType {
        case .file:
            fileTypeImageView.image = UIImage(named: "chat-file", in: .module, with: nil)
        case .audio:
            fileTypeImageView.image = UIImage(named: "chat-audio", in: .module, with: nil)
        case .video:
            fileTypeImageView.image = UIImage(named: "chat-video", in: .module, with: nil)
            
        default:
            break
            
        }
    }
    
    func configureMessageReadStatus(with message: ChatMessage) {
        if message.isRead {
            readStatusImageView.image = UIImage(named: "message-read-icon", in: .module, with: nil)
        } else {
            readStatusImageView.image = UIImage(named: "message-delivered-icon", in: .module, with: nil)
        }
    }
    
    // MARK: - Helper Methods
    private func configureShadowAndCorners() {
        messageShadowView.configureAsSideCell(type: .right)
       // downloadButton.applyShadow()
        userProfileImageView.layer.cornerRadius = 19
        userProfileShadowView.applyShadow(cornerRadii: CGSize(width: 19.5, height: 19.5))
        buttonShadowView.applyShadow(cornerRadii: CGSize(width: 19.5, height: 19.5))
    }
    
}
