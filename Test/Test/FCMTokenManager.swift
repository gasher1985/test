//
//  FCMTokenManager.swift
//  Test
//
//  Created by Dustin Franck on 12/29/23.
//

import Foundation

class FCMTokenManager {

    static let shared = FCMTokenManager()

    private enum UserDefaultKey: String {
        case fcmToken
    }

    var currentToken: String? {
        get {
            UserDefaults.standard.string(forKey: UserDefaultKey.fcmToken.rawValue)
        }

        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultKey.fcmToken.rawValue)
        }
    }
}

