//
//  Message.swift
//  ChatTestApp
//
//  Created by leanid on 6/19/20.
//  Copyright © 2020 iTechArt. All rights reserved.
//

import FirebaseDatabase
import FirebaseFirestore
import MessageKit

class Message: MessageType {
    var id: String
    var sentDate: Date
    var kind: MessageKind
    var sender: SenderType
    
    var messageId: String {
        return id
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    let content: String
    
    init(messageId: String, messageKind: MessageKind, createdAt: Date, sender: SenderType) {
        self.id = messageId
        self.kind = messageKind
        self.sentDate = createdAt
        self.sender = sender
        
        id = messageId
        
        switch messageKind {
        case .text(let text):
            self.content = text
        default:
            self.content = ""
        }
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["created"] as? Timestamp else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate.dateValue()
        self.sender = Sender(senderId: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            self.content = ""
        } else {
            return nil
        }
        self.kind = MessageKind.text(content)
    }
    
    required init(jsonDict: [String: Any]) {
        fatalError()
    }
}
    
extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "id": id,
            "created": ServerValue.timestamp(),
            "senderID": sender.senderId,
            "senderName": sender.displayName,
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        return rep
    }
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

