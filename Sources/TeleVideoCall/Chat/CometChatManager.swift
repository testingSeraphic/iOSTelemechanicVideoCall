//
//  CometChatManager.swift
//  VideoCall
//
//  Created by Manpreet Singh on 17/11/24.
//

import Foundation
import CometChatSDK
import AVFoundation

class CometChatManager {
    
    static let shared = CometChatManager()
    
    private init() {}
    
//    private let appId = "2625744d5b44a952"
//    private let region = "IN"
//    private let apiKey = "a1089b3c213ae8125c47d2f45dd02442ea76d9de"
//    private let authKey = "b7b95abedd1d919bb511a72aef27809a9f0e17c6"
    private let appId = "267244d0dffebb35"
    private let region = "US"
    private let apiKey = "95a766916d291e05bcdaa229474027f7c368b164"
    private let authKey = "3cb7cdd648fe4b277c18e12d77fb4f23cc3fab4b"
    var messagesRequest: MessagesRequest!
    
    
    var onReceivedMessage: ((ChatMessage)-> Void)?
    
    // MARK: - Initialize CometChat
    func initializeCometChat(completion: @escaping (Bool, String?) -> Void) {
        let appSettings = AppSettings.AppSettingsBuilder()
            .subscribePresenceForAllUsers()
            .setRegion(region: region)
            .build()
        CometChat.init(appId: appId, appSettings: appSettings) { success in
            completion(true, "CometChat initialized successfully.")
        } onError: { error in
            completion(false, error.errorDescription)
        }
    }
    
    // MARK: - Login
    func loginWithUID(uid: String, completion: @escaping (User?, String?) -> Void) {
        CometChat.login(UID: uid, apiKey: apiKey) { user in
            completion(user, nil)
        } onError: { error in
            completion(nil, error.errorDescription)
        }
    }
    
    // MARK: - Send Message
    func sendMessage(to receiverUID: String, messageText: String, completion: @escaping (BaseMessage?, String?) -> Void) {
        let textMessage = TextMessage(
            receiverUid: receiverUID,
            text: messageText,
            receiverType: .user
        )
        
        CometChat.sendTextMessage(message: textMessage) { message in
//            print("sentMessage=", message)
//            debugPrint(message)
//            dump(message)
            completion(message, nil)
        } onError: { error in
            completion(nil, error?.errorCode)
        }
    
    }
    
    func deleteMessage(with messageId: Int, completion: @escaping (Bool, String?) -> Void) {
        // Ensure that the messageId is valid
        guard messageId != 0 else {
            completion(false, "Invalid message ID.")
            return
        }

        CometChat.deleteMessage(messageId) { (deletedMessage) in
            completion(true, nil)
            
        } onError: { (error) in
            completion(false, error.errorDescription)
        }
    }
    
    // MARK: - Real-Time Message Listener
    func addMessageListener(delegate: CometChatMessageDelegate) {
        
        CometChat.addMessageListener("message_listener", delegate)
    }
    
    func updateUnreadMessageCount(uid: String, completion: @escaping (Int, String?) -> Void) {
        
        CometChat.getUnreadMessageCountForUser(uid) { (unread) in
            print("Unread count for users: \(unread)")
            let unreadCount = unread["\(uid)"] as? Int
            completion(unreadCount ?? 0, nil)
        } onError: { (error) in
            print("Error fetching unread message count: \(error?.errorDescription)")
            completion(0, error?.errorDescription)
        }
    }
    
    func removeMessageListener() {
        CometChat.removeMessageListener("message_listener")
    }
    
    func sendAttachment(mediaMessage: MediaMessage, completion: @escaping (MediaMessage?, String?) -> Void) {
        
        // Send the media message
        CometChat.sendMediaMessage(
            message: mediaMessage,
            onSuccess: { response in
                print("Media message sent successfully: \(response)")
                completion(response, nil)
            },
            onError: { error in
                print("Failed to send media message: \(error?.errorDescription ?? "Unknown error")")
                completion(nil, error?.errorDescription)
            }
        )
        
    }
    
    // MARK: - Fetch Message History
    func fetchMessageHistory(remoteUID: String,senderUID:String, lastMessageId: Int? = nil, completion: @escaping ([ChatMessage]) -> Void) {
        let limit = 100
        self.messagesRequest = MessagesRequest.MessageRequestBuilder()
            .set(limit: limit)
            .set(uid: remoteUID)
            .build()

        messagesRequest.fetchPrevious(onSuccess: { messages in
            
            var fetchedMessages: [ChatMessage] = []
            
            for message in messages ?? [] {
                if let receivedMessage = (message as? TextMessage) {
                    let chatMessage = ChatMessage(id: receivedMessage.id, text: receivedMessage.text, mediaURL: nil, senderId: receivedMessage.senderUid, messageType: .text, isRead: receivedMessage.readAt > 0, sentAt: receivedMessage.sentAt, receiverId: receivedMessage.receiverUid)
                    fetchedMessages.append(chatMessage)
                  //  print(receivedMessage.text, receivedMessage.readAt > 0, receivedMessage.readAt)
                    
                }
                
                else if let receivedMessage = (message as? MediaMessage) {
                    
                    let chatMessage = ChatMessage(id: receivedMessage.id, text: "", mediaURL: nil, senderId: receivedMessage.senderUid, messageType: receivedMessage.messageType, isRead: receivedMessage.readAt > 0, sentAt: receivedMessage.sentAt, receiverId: receivedMessage.receiverUid, attachements: receivedMessage.attachments)
                    
                    fetchedMessages.append(chatMessage)
                }
            }
            
            completion(fetchedMessages)
        }) { error in
            print("Message receiving failed with error: \(error?.errorDescription ?? "Unknown error")")
            completion([]) // Return empty array in case of error
        }
    }
    
    // MARK: - Fetch Missed Messages
    func fetchMissedMessages(remoteUID: String, limit: Int = 10,lastMessageId: Int, completion: @escaping ([ChatMessage]) -> Void) {
        let messagesRequest = MessagesRequest.MessageRequestBuilder()
            .set(messageID: lastMessageId)
            .set(limit: limit)
            .set(uid: remoteUID)
            .build()
        
        messagesRequest.fetchNext(onSuccess: { messages in
            
            var fetchedMessages: [ChatMessage] = []
            
            for message in messages ?? [] {
                if let receivedMessage = (message as? TextMessage) {
                    
                    let chatMessage = ChatMessage(id: receivedMessage.id, text: receivedMessage.text, mediaURL: nil, senderId: receivedMessage.senderUid, messageType: .text, isRead: true, sentAt: receivedMessage.sentAt, receiverId: receivedMessage.receiverUid)
                    fetchedMessages.append(chatMessage)
                }
                
                else if let receivedMessage = (message as? MediaMessage) {
                    
                    let chatMessage = ChatMessage(id: receivedMessage.id, text: "", mediaURL: nil, senderId: receivedMessage.senderUid, messageType: receivedMessage.messageType, isRead: true, sentAt: receivedMessage.sentAt, receiverId: receivedMessage.receiverUid, attachements: receivedMessage.attachments)
                    
                    fetchedMessages.append(chatMessage)
                }
            }
            
            completion(fetchedMessages)
        }, onError: { error in
            completion([])
        })
        
    }

    func downloadFile(from urlString: String, completion: @escaping (URL?) -> Void) {
        
        // ensure the url string can be converted to a URL object by encoding spaces and other special characters
        let encodedUrlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString
        
        // ensure the URL string can be converted to a URL object
        guard let url = URL(string: encodedUrlString) else {
            // if the URL is invalid, call the completion handler with nil
            completion(nil)
            return
        }
        
        // create a download task using URLSession
        let task = URLSession.shared.downloadTask(with: url) { localURL, _, error in
            
            // ensure the downloaded file URL is valid and there is no error
            guard let localURL = localURL, error == nil else {
                // if an error occurred or the file URL is invalid, call the completion handler with nil
                completion(nil)
                return
            }
            
            // get the file manager instance
            let fileManager = FileManager.default
            
            // get the URL of the documents directory
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // create a destination URL by appending the last path component of the downloaded file URL
            let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
            
            // remove any existing file at the destination URL
            try? fileManager.removeItem(at: destinationURL)
            
            do {
                // copy the downloaded file to the destination URL
                try fileManager.copyItem(at: localURL, to: destinationURL)
                
                // call the completion handler with the destination URL
                completion(destinationURL)
                
            } catch {
                // if an error occurs during file copying, call the completion handler with nil
                completion(nil)
            }
            
        }
        
        // start the download task
        task.resume()
    }
    
    func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 600) // Generate thumbnail at 1 second
            
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            } catch {
                print("Failed to generate thumbnail: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
}

