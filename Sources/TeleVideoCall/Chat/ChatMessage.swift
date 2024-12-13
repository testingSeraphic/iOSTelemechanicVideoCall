//
//  ChatMessage.swift
//  VideoCall
//
//  Created by Manpreet Singh on 18/11/24.
//

import Foundation
import CometChatSDK

struct ChatMessage {
    let id: Int
    let text: String?
    let mediaURL: URL?
    let senderId: String
    let messageType: CometChatSDK.CometChat.MessageType
    var isRead: Bool = false
    let sentAt: Int
    let receiverId: String
    var attachements: [Attachment]? = []
}
