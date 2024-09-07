import Firebase
import FirebaseAuth

class FirebaseAuthManager: ObservableObject {
    @Published var user: User?
    @Published var isSignedIn = false

    init() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.user = user
            self?.isSignedIn = user != nil
        }
    }

    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user))
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

// ContentView.swift
import SwiftUI
import Firebase

struct ContentView: View {
    
    @State private var receivedMessage: String = "No message received yet"
    @StateObject private var authManager = FirebaseAuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var dataToSend = ""
    @State private var recipientId = ""
    @State private var receivedData: String = ""

    var body: some View {
        if authManager.isSignedIn {
            VStack {
                Text("Welcome, \(authManager.user?.email ?? "User")")
                TextField("Recipient ID", text: $recipientId)
                TextField("Data to send", text: $dataToSend)
                Button("Send Data") {
                    sendData()
                }
                Text("Received Data: \(receivedData)")
                Button("Sign Out") {
                    authManager.signOut()
                }
                Spacer()
                VStack {
                            Text("Received Message:")
                            Text(receivedMessage)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                            
                            Button("Simulate Received Message") {
                                simulateReceivedMessage()
                            }
                        }
                Spacer()
            }
            .onReceive(NotificationCenter.default.publisher(for: .didReceiveDataMessage)) { notification in
                print("Notification received in ContentView")
                if let data = notification.userInfo,
                   let message = data["message"] as? String {
                    print("Updating UI with message: \(message)")
                    receivedMessage = message
                } else {
                    print("Failed to extract message from notification userInfo")
                }
            }
        } else {
            VStack {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                SecureField("Password", text: $password)
                Button("Sign In") {
                    authManager.signIn(email: email, password: password) { result in
                        switch result {
                        case .success:
                            print("Signed in successfully")
                        case .failure(let error):
                            print("Error signing in: \(error.localizedDescription)")
                        }
                    }
                }
                Button("Sign Up") {
                    authManager.signUp(email: email, password: password) { result in
                        switch result {
                        case .success:
                            print("Signed up successfully")
                        case .failure(let error):
                            print("Error signing up: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    func simulateReceivedMessage() {
            print("Simulating received message")
            let simulatedData = ["message": "This is a simulated message"]
            NotificationCenter.default.post(name: .didReceiveDataMessage, object: nil, userInfo: simulatedData)
        }

    func sendData() {
        guard let senderId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("dataMessages").addDocument(data: [
            "senderId": senderId,
            "recipientId": recipientId,
            "data": ["message": dataToSend],
            "timestamp": FieldValue.serverTimestamp()
        ]) { error in
            if let error = error {
                print("Error sending data: \(error)")
            } else {
                print("Data sent successfully")
            }
        }
    }
}
