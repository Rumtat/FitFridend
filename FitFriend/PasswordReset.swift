//
//  PasswordReset.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 6/3/2568 BE.
//

import SwiftUI
import FirebaseAuth

struct PasswordReset: View {
    @State private var email: String = ""
    @State private var message: String = ""

    var body: some View {
        VStack {
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                sendPasswordReset(email: email)
            }) {
                Text("Send Reset Link")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Text(message)
                .foregroundColor(.red)
        }
        .padding()
    }

    func sendPasswordReset(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "Password reset link sent to your email."
            }
        }
    }
}
#Preview {
    PasswordReset()
}
