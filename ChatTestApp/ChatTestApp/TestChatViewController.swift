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
        static let thread = "thread1"
    }

    var messages: [Message] = []
    let reference = Database.database().reference()
    private let user: User
    private let sender: SenderType
    
    init(user: User) {
        self.user = user
        self.sender = Sender.init(senderId: user.uid, displayName: ApplicationSettings.displayName)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let faceBookInputBar = FacebookInputBar()
        faceBookInputBar.onSelected = { inputItem in
            print("SSS coorinator on selected document")
        }
        messageInputBar = faceBookInputBar
        messageInputBar.delegate = self
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let query = reference.child(Constants.thread)
        query.observe(.value) { [weak self] snaphsot in
            snaphsot.children.forEach { snaphsotChild in
                guard let self = self,
                    let dataSnapshot = snaphsotChild as? DataSnapshot,
                    let message = Message(snapshot: dataSnapshot) else {
                        return
                }
                self.insertNewMessage(message)
            }
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
        reference.child(Constants.thread).child(message.id).setValue(message.representation) { _, _ in
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
