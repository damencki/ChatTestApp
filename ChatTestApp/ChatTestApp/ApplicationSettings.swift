//
//  ApplicationSettings.swift
//  ChatTestApp
//
//  Created by leanid on 6/18/20.
//  Copyright © 2020 iTechArt. All rights reserved.
//

import Foundation

final class ApplicationSettings {
    private enum SettingKey: String {
        case displayName
    }
    
    static var displayName: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingKey.displayName.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: SettingKey.displayName.rawValue)
        }
    }
}
