//
//  UserManager.swift
//  Test
//
//  Created by Dustin Franck on 12/29/23.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager: NSObject {

    private enum CollectionName: String {
        case user
        case trigger
    }

    static let shared = UserManager()
    let db: Firestore

    override init() {
        self.db = Firestore.firestore()
        super.init()
    }

    func loginAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            guard
                let user = authResult?.user.uid,
                let currentToken = FCMTokenManager.shared.currentToken
            else { return }
            self?.updateFCMToken(currentToken, for: user)
        }
    }

    func updateFCMToken(_ token: String, for userId: String) {
        let data: [String: Any] = ["notificationToken": token]
        self.db.collection(CollectionName.user.rawValue)
            .document(userId)
            .setData(data) { error in
                if let error = error {
                    print(error)
                } else {
                    print("Updated FCM Token for anonymous user")
                }
            }
    }

    func triggerNotification() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = ["userId": userId]
        self.db.collection(CollectionName.trigger.rawValue)
            .document()
            .setData(data) { error in
                if let error = error {
                    print(error)
                } else {
                    print("triggered Notification")
                }
            }
    }
}
