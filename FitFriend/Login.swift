//
//  ContentView.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 6/3/2568 BE.
//

import SwiftUI

struct Login: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack {
            TextField("Username or Email", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                // Handle login action
            }) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button("Forgot Password?") {
                // Handle forgot password action
            }
            .padding()
            
            HStack {
                Button("Login with Apple") {
                    // Handle Apple login
                }
                Button("Login with Google") {
                    // Handle Google login
                }
                Button("Login with Facebook") {
                    // Handle Facebook login
                }
            }
            .padding()
        }
        .padding()
        .onAppear {
            // Check Dark Mode or Light Mode
            let currentScheme = UITraitCollection.current.userInterfaceStyle
            if currentScheme == .dark {
                // Adjust UI for Dark Mode
            }
        }
    }
}
#Preview {
    Login()
}
