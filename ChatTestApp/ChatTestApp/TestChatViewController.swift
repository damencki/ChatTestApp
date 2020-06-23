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
    
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
         let manager = AttachmentManager()
        manager.isPersistent = true
        manager.showAddAttachmentCell = true
         manager.delegate = self
        manager.dataSource = self
         return manager
     }()
    
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

extension TestChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
  
}

extension TestChatViewController: AttachmentManagerDelegate, AttachmentManagerDataSource {
    func attachmentManager(_ manager: AttachmentManager, cellFor attachment: AttachmentManager.Attachment, at index: Int) -> AttachmentCell {
        return AttachmentCell()
    }
    
    // MARK: - AttachmentManagerDelegate
    
    func attachmentManager(_ manager: AttachmentManager, shouldBecomeVisible: Bool) {
        setAttachmentManager(active: shouldBecomeVisible)
    }
    
    func attachmentManager(_ manager: AttachmentManager, didReloadTo attachments: [AttachmentManager.Attachment]) {
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: AttachmentManager, didInsert attachment: AttachmentManager.Attachment, at index: Int) {
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: AttachmentManager, didRemove attachment: AttachmentManager.Attachment, at index: Int) {
        messageInputBar.sendButton.isEnabled = !manager.attachments.isEmpty
    }
    
    func attachmentManager(_ manager: AttachmentManager, didSelectAddAttachmentAt index: Int) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - AttachmentManagerDelegate Helper
    
    func setAttachmentManager(active: Bool) {
        
        let topStackView = messageInputBar.topStackView
        if active && !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
            topStackView.layoutIfNeeded()
        } else if !active && topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
            topStackView.removeArrangedSubview(attachmentManager.attachmentView)
            topStackView.layoutIfNeeded()
        }
    }
}

extension TestChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        dismiss(animated: true, completion: {
            if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
                let handled = self.attachmentManager.handleInput(of: pickedImage)
                if !handled {
                    // throw error
                }
            }
        })
    }
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
private func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
