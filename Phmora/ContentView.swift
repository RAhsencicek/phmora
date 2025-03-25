//
//  ContentView.swift
//  Phmora
//
//  Created by Ahsen on 25.03.2025.
//

import SwiftUI

struct ContentView: View {
    // Kullanıcı girişi için state değişkenleri
    @State private var eczaneID = ""
    @State private var kullaniciAdi = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo veya başlık alanı
                Image(systemName: "cross.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 50)
                
                Text("Pharmora")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                // Giriş form alanı
                VStack(spacing: 15) {
                    // Eczane ID giriş alanı
                    TextField("Eczane ID", text: $eczaneID)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Kullanıcı adı giriş alanı
                    TextField("Kullanıcı Adı", text: $kullaniciAdi)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    // Giriş butonu
                    Button(action: {
                        // Giriş işlemleri buraya eklenecek
                        print("Giriş yapılıyor...")
                    }) {
                        Text("Giriş Yap")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 30)
                
                Spacer()
            }
            .toolbar(.hidden)
        }
    }
}

#Preview {
    ContentView()
}
