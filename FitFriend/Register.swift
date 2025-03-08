//
//  Register.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 6/3/2568 BE.
//

//
//  Register.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 6/3/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Register: View {
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var phone: String = ""
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    @State private var navigateToLogin = false
    
    let db = Firestore.firestore()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("สมัครสมาชิก")
                    .font(.largeTitle)
                    .bold()
                    .padding(.vertical)
                
                TextField("ชื่อผู้ใช้", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .autocapitalization(.none)
                
                TextField("อีเมล", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("รหัสผ่าน", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("ยืนยันรหัสผ่าน", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("เบอร์โทรศัพท์", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .keyboardType(.phonePad)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                }
                
                Button(action: {
                    register()
                }) {
                    Text("สมัครสมาชิก")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button("มีบัญชีอยู่แล้ว? เข้าสู่ระบบ") {
                    navigateToLogin = true
                }
                .padding()
                
                NavigationLink("", destination: Login(), isActive: $navigateToLogin)
                    .hidden()
            }
            .padding()
        }
    }
    
    func register() {
        // ตรวจสอบข้อมูลที่กรอก
        if username.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty {
            errorMessage = "กรุณากรอกข้อมูลให้ครบทุกช่อง"
            return
        }
        
        if password != confirmPassword {
            errorMessage = "รหัสผ่านไม่ตรงกัน"
            return
        }
        
        // ตรวจสอบความยาวรหัสผ่าน
        if password.count < 6 {
            errorMessage = "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร"
            return
        }
        
        // สร้างบัญชีด้วย Firebase
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "สมัครสมาชิกไม่สำเร็จ: \(error.localizedDescription)"
            } else {
                // สร้างบัญชีสำเร็จ บันทึกข้อมูลเพิ่มเติมใน Firestore
                guard let uid = authResult?.user.uid else { return }
                
                let userData: [String: Any] = [
                    "username": username,
                    "email": email,
                    "phone": phone,
                    "createdAt": Timestamp(),
                    "uid": uid
                ]
                
                db.collection("users").document(uid).setData(userData) { error in
                    if let error = error {
                        errorMessage = "บันทึกข้อมูลไม่สำเร็จ: \(error.localizedDescription)"
                    } else {
                        errorMessage = ""
                        successMessage = "สมัครสมาชิกเรียบร้อยแล้ว"
                        
                        // หน่วงเวลาก่อนกลับไปหน้า Login
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            navigateToLogin = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Register()
}
