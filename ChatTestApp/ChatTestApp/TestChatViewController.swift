//
//  TestChatViewController.swift
//  ChatTestApp
//
//  Created by leanid on 6/22/20.
//  Copyright © 2020 iTechArt. All rights reserved.
//

import UIKit
import MessageKit
import FirebaseDatabase
import FirebaseAuth
import InputBarAccessoryView

class TestChatViewController: MessagesViewController {
    private struct Constants {
        static let thread = "thread"
    }
    
    var messages: [Message] = []
    let reference = Database.database().reference()
    private let user: User
    private let sender = Sender(senderId: UUID().uuidString, displayName: ApplicationSettings.displayName)
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        reference.child(Constants.thread).observe(.childAdded) { [weak self] snapshot in
            guard let self = self, let value = snapshot.value, let dictionary = value as? [String: AnyObject
                ] else {
                return
            }
            let message = Message(document: snapshot)
            
            let message = Message(jsonDict: dictionary)
            self.insertNewMessage(message)
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }
        
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func save(_ message: Message) {
        let representation = message.representation
        reference.child(Constants.thread).childByAutoId().updateChildValues(message.representation) { error, reference in
            self.messagesCollectionView.scrollToBottom()
        }
    }
}

extension TestChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(messageId: UUID().uuidString, messageKind: .text(text), createdAt: Date(), sender: sender)
        save(message)
        inputBar.inputTextView.text = ""
    }
}

extension TestChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension TestChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {}
