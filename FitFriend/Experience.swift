//
//  Experience.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 8/3/2568 BE.
//

//
//  Experience.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 8/3/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Experience: View {
    @State private var selectedLevel = "Beginner"
    @State private var goalSelection = "ลดน้ำหนัก"
    @State private var errorMessage: String = ""
    @State private var saveSuccessful: Bool = false
    @State private var navigateToHome = false
    
    let levels = ["Beginner", "Intermediate", "Advanced"]
    let goals = ["ลดน้ำหนัก", "เพิ่มน้ำหนัก", "เพิ่มกล้ามเนื้อ", "รักษาสุขภาพ"]
    let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 25) {
            Text("ข้อมูลการออกกำลังกาย")
                .font(.largeTitle)
                .padding()

            VStack(alignment: .leading, spacing: 10) {
                Text("ระดับประสบการณ์")
                    .font(.headline)
                
                Picker("เลือกระดับ", selection: $selectedLevel) {
                    ForEach(levels, id: \.self) { level in
                        Text(level)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text(getExperienceDescription())
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 5)
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("เป้าหมายการออกกำลังกาย")
                    .font(.headline)
                
                Picker("เลือกเป้าหมาย", selection: $goalSelection) {
                    ForEach(goals, id: \.self) { goal in
                        Text(goal)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding()
            
            if saveSuccessful {
                Text("บันทึกข้อมูลเรียบร้อยแล้ว")
                    .foregroundColor(.green)
                    .padding()
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }

            Button("บันทึกข้อมูล") {
                saveExperience()
            }
            .padding()
            .frame(width: 200)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            NavigationLink("", destination: ContentView().navigationBarBackButtonHidden(true), isActive: $navigateToHome)
                .hidden()
        }
        .padding()
    }
    
    func getExperienceDescription() -> String {
        switch selectedLevel {
        case "Beginner":
            return "สำหรับผู้ที่เพิ่งเริ่มออกกำลังกายหรือออกกำลังกายน้อยกว่า 6 เดือน"
        case "Intermediate":
            return "สำหรับผู้ที่ออกกำลังกายมาแล้ว 6 เดือนถึง 2 ปี"
        case "Advanced":
            return "สำหรับผู้ที่ออกกำลังกายมาแล้วมากกว่า 2 ปี"
        default:
            return ""
        }
    }

    func saveExperience() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล"
            return
        }

        db.collection("users").document(user.uid).updateData([
            "experienceLevel": selectedLevel,
            "fitnessGoal": goalSelection
        ]) { error in
            if let error = error {
                errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
                print("เกิดข้อผิดพลาด: \(error.localizedDescription)")
            } else {
                errorMessage = ""
                saveSuccessful = true
                
                // หน่วงเวลาเล็กน้อยแล้วนำทางไปยังหน้าหลัก
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    navigateToHome = true
                }
            }
        }
    }
}

struct Experience_Previews: PreviewProvider {
    static var previews: some View {
        Experience()
    }
}
