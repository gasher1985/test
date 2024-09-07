import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications



class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()

        // Set messaging delegate
        Messaging.messaging().delegate = self

        // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )

        application.registerForRemoteNotifications()

        return true
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        if let token = fcmToken {
            let dataDict: [String: String] = ["token": token]
            NotificationCenter.default.post(
                name: Notification.Name("FCMToken"),
                object: nil,
                userInfo: dataDict
            )
            
            // Store the token in Firestore
            storeTokenInFirestore(token: token)
        }
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication,
                         didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
            // Handle data of notification
            if let messageID = userInfo[gcmMessageIDKey] {
                print("Message ID: \(messageID)")
            }

            // Check if it's a data message
            if let data = userInfo["data"] as? [String: Any] {
                // Handle the data message
                handleDataMessage(data)
            }

            print(userInfo)
            completionHandler(.newData)
        }
    
    func handleDataMessage(_ data: [String: Any]) {
            // Process the data message
            // This is where you'll implement your custom logic
            print("Received data message: \(data)")
            // TODO: Add your custom handling logic here
        }
    
    func storeTokenInFirestore(token: String) {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("No authenticated user found")
                return
            }
    
            let db = Firestore.firestore()
            db.collection("users").document(userId).setData(["fcmToken": token], merge: true) { error in
                if let error = error {
                    print("Error storing FCM token: \(error)")
                } else {
                    print("FCM token stored successfully")
                }
            }
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 and later devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Uncomment if swizzling is disabled
        // Messaging.messaging().appDidReceiveMessage(userInfo)

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Uncomment if swizzling is disabled
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        print(userInfo)

        completionHandler()
    }
}

extension Notification.Name {
   static let didReceiveDataMessage = Notification.Name("didReceiveDataMessage")
}
@main
struct TestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

