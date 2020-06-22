//
//  Channel.swift
//  ChatTestApp
//
//  Created by leanid on 6/18/20.
//  Copyright © 2020 iTechArt. All rights reserved.
//

import FirebaseFirestore

struct Channel {
    let id: String
    let name: String

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let name = data["name"] as? String else {
            return nil
        }

        id = document.documentID
        self.name = name
    }
}

extension Channel: DatabaseRepresentation {
    var representation: [String: Any] {
        var rep = ["name": name]
        rep["id"] = id
        return rep
    }
}

extension Channel: Comparable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Channel, rhs: Channel) -> Bool {
        return lhs.name < rhs.name
    }
}
