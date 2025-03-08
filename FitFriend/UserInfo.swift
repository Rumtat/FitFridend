//
//  UserInfo.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 8/3/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct UserInfo: View {
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var age: String = ""
    @State private var navigateToNext = false
    @State private var errorMessage: String = ""
    @State private var isLoading = true
    
    let db = Firestore.firestore()

    var body: some View {
        VStack {
            Text("กรอกข้อมูลของคุณ")
                .font(.largeTitle)
                .padding()

            TextField("น้ำหนัก (kg)", text: $weight)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("ส่วนสูง (cm)", text: $height)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextField("อายุ (ปี)", text: $age)
                .keyboardType(.numberPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("คำนวณ BMI") {
                validateAndNavigate()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(weight.isEmpty || height.isEmpty || age.isEmpty)

            NavigationLink("", destination: BmiCal(weight: Double(weight) ?? 0, height: Double(height) ?? 0, age: Int(age) ?? 0), isActive: $navigateToNext)
                .hidden()
        }
        .padding()
        .onAppear {
            loadUserData()
        }
    }
    
    func validateAndNavigate() {
        guard let weightValue = Double(weight), weightValue > 0 else {
            errorMessage = "กรุณากรอกน้ำหนักที่ถูกต้อง"
            return
        }
        
        guard let heightValue = Double(height), heightValue > 0 else {
            errorMessage = "กรุณากรอกส่วนสูงที่ถูกต้อง"
            return
        }
        
        guard let ageValue = Int(age), ageValue > 0 else {
            errorMessage = "กรุณากรอกอายุที่ถูกต้อง"
            return
        }
        
        errorMessage = ""
        navigateToNext = true
    }
    
    func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            isLoading = false
            return
        }
        
        db.collection("users").document(user.uid).getDocument { document, error in
            isLoading = false
            
            if let document = document, document.exists {
                let data = document.data()
                
                if let weightValue = data?["weight"] as? Double {
                    weight = String(weightValue)
                }
                
                if let heightValue = data?["height"] as? Double {
                    height = String(heightValue)
                }
                
                if let ageValue = data?["age"] as? Int {
                    age = String(ageValue)
                }
            }
        }
    }
}

#Preview {
    UserInfo()
}
