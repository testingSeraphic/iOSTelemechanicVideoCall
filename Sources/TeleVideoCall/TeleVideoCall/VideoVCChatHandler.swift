//
//  VideoVCChatHandler.swift
//  TelemechanicVideoCallPluginDemoSPM
//
//  Created by Apple on 18/11/24.
//

import Foundation
import UIKit
import CometChatSDK

// MARK: - CometChatMessageDelegate
extension VideoVC: CometChatMessageDelegate {
    
    func onTextMessageReceived(textMessage: TextMessage) {
        print("TextMessage received: " + textMessage.stringValue())
        let chatMessage = ChatMessage(
            id: textMessage.id,
            text: textMessage.text,
            mediaURL: nil,
            senderId: textMessage.senderUid,
            messageType: .text,
            sentAt: textMessage.sentAt,
            receiverId: textMessage.receiverUid
        )
        chatMessages.append(chatMessage)
        sortChatMessagesByTime()
        chatTableView.reloadData()
        scrollToLastMessage()
        markAllMessagesRead()
    }

    func onMediaMessageReceived(mediaMessage: MediaMessage) {
        print("MediaMessage received: " + mediaMessage.stringValue())
        let chatMessage = ChatMessage(
            id: mediaMessage.id,
            text: nil,
            mediaURL: nil,
            senderId: mediaMessage.senderUid,
            messageType: mediaMessage.messageType,
            sentAt: mediaMessage.sentAt,
            receiverId: mediaMessage.receiverUid,
            attachements: mediaMessage.attachments
        )
        chatMessages.append(chatMessage)
        sortChatMessagesByTime()
        chatTableView.reloadData()
        scrollToLastMessage()
        markAllMessagesRead()
    }

    private func sortChatMessagesByTime() {
        
        // remove duplicates by message ID
        let uniqueMessages = Dictionary(grouping: chatMessages, by: { $0.id })
            .compactMap { $0.value.first }
        
        // assign back the unique messages
        chatMessages = uniqueMessages
        
        // sort messages by sentAt
        chatMessages.sort { $0.sentAt < $1.sentAt }
    }


    private func scrollToLastMessage() {
        if !chatMessages.isEmpty {
            let lastIndex = IndexPath(row: chatMessages.count - 1, section: 0)
            chatTableView.scrollToRow(at: lastIndex, at: .bottom, animated: true)
        }
    }

    func onMessagesRead(receipt: MessageReceipt) {
        print("onMessagesRead \(receipt.stringValue())")
        for index in 0..<chatMessages.count {
            if !chatMessages[index].isRead && chatMessages[index].id == Int(receipt.messageId) {
                chatMessages[index].isRead = true
            }
        }
        chatTableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension VideoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = chatMessages[indexPath.row]
        
        if message.senderId == localUserId {
            // local user message - Right side
    
            if message.messageType == .text {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRightMessageCell", for: indexPath) as! ChatRightMessageCell
                cell.messageTextLabel.text = message.text
                cell.messageSentTimeLabel.text = Helper.formatTimestamp(message.sentAt)
                cell.configureMessageReadStatus(with: message)
                return cell
            }
            
            else if message.messageType == .file ||  message.messageType == .audio {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRightDocumentCell", for: indexPath) as! ChatRightDocumentCell
                cell.selectionStyle = .none
                cell.configureCell(message: message)
                return cell
            }
            else if (message.messageType == .image) || (message.messageType == .video)  {
               
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRightImageCell", for: indexPath) as! ChatRightImageCell
                cell.selectionStyle = .none
                cell.setup(with: message)
                cell.downloadImageButtonTapped = { data in
                    print("Button tapped in row \(indexPath.row) with data: \(data)")
//                    self.downloadFile(with: data, isForGallery: true)
                }
                return cell
            }
            return UITableViewCell()
            // handle media message in future
            
        } else {
            // remote user message - Left side
          
            if message.messageType == .text {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLeftMessageCell", for: indexPath) as! ChatLeftMessageCell
                cell.messageTextLabel.text = message.text
                cell.messageSentTimeLabel.text = Helper.formatTimestamp(message.sentAt)
                return cell
            }
            else if message.messageType == .file ||  message.messageType == .audio {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLeftDocumentCell", for: indexPath) as! ChatLeftDocumentCell
                cell.selectionStyle = .none
                cell.configureCell(message: message)
                return cell
            }
            
            else if message.messageType == .image || message.messageType == .video {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLeftImageCell", for: indexPath) as! ChatLeftImageCell
                cell.selectionStyle = .none
                cell.setup(with: message)
                cell.downloadImageButtonTapped = { data in
                    print("Button tapped in row \(indexPath.row) with data: \(data)")
//                    self.downloadFile(with: data, isForGallery: true)
                }
       
                return cell
            }
            // handle media message in future
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = chatMessages[indexPath.row]
        
        if message.messageType != .text {
            handleButtonTap(message: message)
        }
    }
    
}

// MARK: - Keyboard Handling
extension VideoVC  {
    
    @objc func keyboardNotification(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }

        // get the final frame of the keyboard
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        // get animation duration and curve
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)

        // calculate keyboard height based on its position
        let screenHeight = UIScreen.main.bounds.size.height
        let keyboardHeight = max(screenHeight - (endFrame?.origin.y ?? screenHeight), 0)

        // update the constraint dynamically
        self.keyboardHeightLayoutConstraint?.constant = keyboardHeight == 0 ? 107 : keyboardHeight

        let space = keyboardHeight == 0 ? 20.0 : 0.0
        
        self.chatContainerStackView.layoutMargins = UIEdgeInsets(top: space, left: space, bottom: 0, right: space)
        self.bottomInnerContainerView.layer.cornerRadius = keyboardHeight == 0 ? 16 : 0

        self.setupViewAppearance()
        
        // animate layout updates
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: animationCurve,
            animations: { self.view.layoutIfNeeded() },
            completion: nil
        )
        
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        messageTextView.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        messageTextView.resignFirstResponder()
    }
}
