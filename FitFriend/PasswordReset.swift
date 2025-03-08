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
    @State private var messageColor: Color = .red
    @State private var navigateToLogin = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("รีเซ็ตรหัสผ่าน")
                .font(.largeTitle)
                .bold()
                .padding(.vertical)
            
            Text("กรุณากรอกอีเมลที่คุณใช้ลงทะเบียน เราจะส่งลิงก์รีเซ็ตรหัสผ่านไปให้คุณ")
                .multilineTextAlignment(.center)
                .padding()
            
            TextField("อีเมล", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            Button(action: {
                sendPasswordReset(email: email)
            }) {
                Text("ส่งลิงก์รีเซ็ตรหัสผ่าน")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Text(message)
                .foregroundColor(messageColor)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("กลับไปหน้าเข้าสู่ระบบ") {
                navigateToLogin = true
            }
            .padding()
            
            NavigationLink("", destination: Login(), isActive: $navigateToLogin)
                .hidden()
        }
        .padding()
    }

    func sendPasswordReset(email: String) {
        if email.isEmpty {
            message = "กรุณากรอกอีเมล"
            messageColor = .red
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
                messageColor = .red
            } else {
                message = "ส่งลิงก์รีเซ็ตรหัสผ่านไปยังอีเมลของคุณแล้ว"
                messageColor = .green
                
                // หน่วงเวลาก่อนกลับไปหน้า Login
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    navigateToLogin = true
                }
            }
        }
    }
}

#Preview {
    PasswordReset()
}
