//
//  BmiCal.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 8/3/2568 BE.
//


//
//  BmiCal.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 8/3/2568 BE.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BmiCal: View {
    var weight: Double
    var height: Double
    var age: Int
    @State private var bmi: Double = 0
    @State private var bmiCategory: String = ""
    @State private var navigateToExperience = false
    @State private var saveSuccessful: Bool = false
    @State private var errorMessage: String = ""
    
    let db = Firestore.firestore()

    var body: some View {
        VStack(spacing: 20) {
            Text("ผลลัพธ์ BMI ของคุณ")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            Text(String(format: "BMI: %.2f", bmi))
                .font(.system(size: 36, weight: .bold))
                .padding()
                .foregroundColor(getBMIColor())

            Text("ประเภท: \(bmiCategory)")
                .font(.title)
                .padding()
                .foregroundColor(getBMIColor())
            
            VStack(alignment: .leading, spacing: 15) {
                Text("คำอธิบาย:")
                    .font(.headline)
                
                getBMIDescription()
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
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

            Button("ถัดไป") {
                saveToFirebase()
            }
            .padding()
            .frame(width: 200)
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 3)

            NavigationLink("", destination: Experience(), isActive: $navigateToExperience)
                .hidden()
        }
        .padding()
        .onAppear {
            calculateBMI()
        }
    }

    func calculateBMI() {
        let heightInMeters = height / 100
        bmi = weight / (heightInMeters * heightInMeters)

        if bmi < 18.5 {
            bmiCategory = "น้ำหนักน้อย"
        } else if bmi < 24.9 {
            bmiCategory = "ปกติ"
        } else if bmi < 29.9 {
            bmiCategory = "น้ำหนักเกิน"
        } else {
            bmiCategory = "โรคอ้วน"
        }
    }
    
    func getBMIColor() -> Color {
        if bmi < 18.5 {
            return .blue
        } else if bmi < 24.9 {
            return .green
        } else if bmi < 29.9 {
            return .orange
        } else {
            return .red
        }
    }
    
    func getBMIDescription() -> Text {
        if bmi < 18.5 {
            return Text("คุณมีน้ำหนักน้อยกว่าเกณฑ์ ควรรับประทานอาหารที่มีคุณค่าทางโภชนาการเพิ่มขึ้นและอาจต้องปรึกษาแพทย์")
        } else if bmi < 24.9 {
            return Text("น้ำหนักของคุณอยู่ในเกณฑ์ปกติ พยายามรักษาระดับนี้ด้วยการออกกำลังกายและรับประทานอาหารสุขภาพ")
        } else if bmi < 29.9 {
            return Text("คุณมีน้ำหนักเกินเกณฑ์เล็กน้อย ควรพิจารณาการออกกำลังกายเพิ่มขึ้นและปรับเปลี่ยนอาหารเพื่อลดน้ำหนัก")
        } else {
            return Text("คุณอยู่ในเกณฑ์โรคอ้วน ซึ่งอาจเสี่ยงต่อโรคต่างๆ ควรปรึกษาแพทย์เพื่อวางแผนลดน้ำหนักอย่างเหมาะสม")
        }
    }

    func saveToFirebase() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล"
            return
        }

        let bmiData: [String: Any] = [
            "weight": weight,
            "height": height,
            "age": age,
            "bmi": bmi,
            "bmiCategory": bmiCategory,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        // บันทึกข้อมูลใน document ปัจจุบันของผู้ใช้
        db.collection("users").document(user.uid).setData(bmiData, merge: true) { error in
            if let error = error {
                errorMessage = "เกิดข้อผิดพลาด: \(error.localizedDescription)"
                print("เกิดข้อผิดพลาด: \(error.localizedDescription)")
            } else {
                errorMessage = ""
                saveSuccessful = true
                
                // บันทึกประวัติ BMI ในคอลเลคชัน bmiHistory
                db.collection("users").document(user.uid).collection("bmiHistory").addDocument(data: bmiData) { error in
                    if let error = error {
                        errorMessage = "เกิดข้อผิดพลาดในการบันทึกประวัติ: \(error.localizedDescription)"
                        print("เกิดข้อผิดพลาดในการบันทึกประวัติ: \(error.localizedDescription)")
                    } else {
                        // หน่วงเวลาเล็กน้อยแล้วนำทางไปยังหน้า Experience
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            navigateToExperience = true
                        }
                    }
                }
            }
        }
    }
}

struct BmiCal_Previews: PreviewProvider {
    static var previews: some View {
        BmiCal(weight: 70, height: 170, age: 30)
    }
}
