//
//  TestApp.swift
//  Test
//
//  Created by Dustin Franck on 12/28/23.
import SwiftUI
import UserNotifications
import Firebase


@main
struct TestApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            SoftPermissionsMenuView()
        }
    }
}



