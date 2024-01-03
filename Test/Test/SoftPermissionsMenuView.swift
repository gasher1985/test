//
//  SoftPermissionsMenuView.swift
//  Test
//
//  Created by Dustin Franck on 12/29/23.
//

import SwiftUI

struct SoftPermissionsMenuView: View {

    @State var showingSoftPushPermission: Bool = false
    var body: some View {
        List {
            Section("Push Notifications") {
                Group {
                    Button("Show soft push notification view") {
                        UserManager.shared.loginAnonymously()
                        showingSoftPushPermission.toggle()
                    }
                    Button("Trigger push notification") {
                        UserManager.shared.triggerNotification()
                    }
                }
            }
        }
        .sheet(isPresented: $showingSoftPushPermission) {
            SoftPushNotificationView() {
                PushNotificationManager.shared.requestAuthorization {
                    showingSoftPushPermission.toggle()
                }
            } negativeAction: {
                showingSoftPushPermission.toggle()
            }
        }
    }
}
