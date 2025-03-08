//
//  ContentView.swift
//  FitFriend
//
//  Created by Vituruch Sinthusate on 8/3/2568 BE.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var username: String = "ผู้ใช้"
    @State private var bmi: Double = 0
    @State private var bmiCategory: String = ""
    @State private var isLoggedIn = true
    
    let db = Firestore.firestore()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // หน้าแรก - แสดงข้อมูลสรุป
            VStack {
                Text("ยินดีต้อนรับ, \(username)!")
                    .font(.largeTitle)
                    .padding()
                
                VStack(spacing: 20) {
                    Text("ข้อมูล BMI ล่าสุดของคุณ")
                        .font(.headline)
                    
                    Text(String(format: "BMI: %.2f", bmi))
                        .font(.title)
                        .foregroundColor(getBMIColor())
                    
                    Text("ประเภท: \(bmiCategory)")
                        .font(.title3)
                        .foregroundColor(getBMIColor())
                    
                    Button("คำนวณ BMI ใหม่") {
                        selectedTab = 2
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                .padding()
                
                // ส่วนแสดงคำแนะนำ
                VStack(alignment: .leading) {
                    Text("คำแนะนำสำหรับวันนี้")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    Text(getDailyTip())
                        .font(.body)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                .padding()
                
                Spacer()
                
                Button("ออกจากระบบ") {
                    signOut()
                }
                .foregroundColor(.red)
                .padding()
            }
            .tabItem {
                Label("หน้าแรก", systemImage: "house")
            }
            .tag(0)
            
            // หน้าประวัติ
            Text("ประวัติการติดตาม (จะพัฒนาเพิ่มในอนาคต)")
                .tabItem {
                    Label("ประวัติ", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(1)
            
            // หน้าข้อมูลส่วนตัว
            UserInfo()
                .tabItem {
                    Label("ข้อมูลส่วนตัว", systemImage: "person")
                }
                .tag(2)
        }
        .onAppear {
            loadUserData()
            checkAuthStatus()
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            Login()
        }
    }
    
    func loadUserData() {
        guard let user = Auth.auth().currentUser else {
            isLoggedIn = false
            return
        }
        
        db.collection("users").document(user.uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                
                if let usernameValue = data?["username"] as? String {
                    username = usernameValue
                }
                
                if let bmiValue = data?["bmi"] as? Double {
                    bmi = bmiValue
                }
                
                if let bmiCategoryValue = data?["bmiCategory"] as? String {
                    bmiCategory = bmiCategoryValue
                }
            }
        }
    }
    
    func checkAuthStatus() {
        if Auth.auth().currentUser == nil {
            isLoggedIn = false
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("ไม่สามารถออกจากระบบได้: \(error.localizedDescription)")
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
    
    func getDailyTip() -> String {
        let tips = [
            "การดื่มน้ำอย่างน้อยวันละ 8 แก้วช่วยให้ร่างกายทำงานได้อย่างมีประสิทธิภาพ",
            "การออกกำลังกายแบบคาร์ดิโอ 30 นาทีต่อวัน ช่วยเสริมสร้างสุขภาพหัวใจ",
            "การนอนหลับอย่างน้อย 7-8 ชั่วโมงต่อคืนช่วยให้ร่างกายฟื้นฟูพลังงาน",
            "การรับประทานผักและผลไม้อย่างน้อยวันละ 5 ส่วนช่วยให้ได้รับวิตามินที่เพียงพอ",
            "การยืดเหยียดร่างกายช่วยเพิ่มความยืดหยุ่นและลดอาการบาดเจ็บ",
            "การลดการบริโภคน้ำตาลช่วยควบคุมน้ำหนักและป้องกันโรคเบาหวาน"
        ]
        return tips.randomElement() ?? tips[0]
    }
}

// เพิ่ม extension สำหรับ Boolean not เพื่อความสะดวก
extension Bool {
    var not: Bool {
        return !self
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
