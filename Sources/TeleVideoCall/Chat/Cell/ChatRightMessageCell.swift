//
//  ChatRightMessageCell.swift
//  VideoCall
//
//  Created by Manpreet Singh on 15/11/24.
//

import UIKit

class ChatRightMessageCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var messageShadowView: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    @IBOutlet weak var userProfileShadowView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var readStatusImageView: UIImageView!
    @IBOutlet weak var messageSentTimeLabel: UILabel!
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = false
        self.configureShadowAndCorners()
        messageTextLabel.font = UIFont(name: "OverusedGrotesk-Medium", size: 16)
        messageSentTimeLabel.font = UIFont(name: "OverusedGrotesk-Medium", size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.configureShadowAndCorners()
    }
    
    func configureMessageReadStatus(with message: ChatMessage) {
        if message.isRead {
            readStatusImageView.image = UIImage(named: "message-read-icon")
        } else {
            readStatusImageView.image = UIImage(named: "message-delivered-icon")
        }
    }
    
    // MARK: - Helper Methods
    private func configureShadowAndCorners() {
        messageShadowView.configureAsSideCell(type: .right)
        userProfileImageView.layer.cornerRadius = 19
        userProfileShadowView.applyShadow(cornerRadii: CGSize(width: 19.5, height: 19.5))
    }
}
