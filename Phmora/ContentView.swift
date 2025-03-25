//
//  ContentView.swift
//  Phmora
//
//  Created by Ahsen on 25.03.2025.
//

import SwiftUI

// Ana görünüm yönetimi için enum
enum AuthScreen {
    case login
    case register
}

struct ContentView: View {
    @State private var currentAuthScreen: AuthScreen = .login
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Logo ve başlık
                VStack(spacing: 20) {
                    Image("PharmoraLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                    
                    
                }
                .padding(.top, 50)
                
                // Segment kontrol
                Picker("Auth Screen", selection: $currentAuthScreen) {
                    Text("Giriş").tag(AuthScreen.login)
                    Text("Kayıt").tag(AuthScreen.register)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // İçerik alanı
                if currentAuthScreen == .login {
                    LoginView()
                        .transition(.opacity)
                } else {
                    RegisterView()
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .background(.background)
        }
    }
}

// Giriş ekranı
struct LoginView: View {
    @State private var kimlikNo = ""
    @State private var password = ""
    @State private var showingAlert = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Giriş formu
            VStack(spacing: 15) {
                TextField("Eczacı Kimlik No", text: $kimlikNo)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                SecureField("Şifre", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Şifremi Unuttum") {
                    // Şifre sıfırlama işlemi
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            
            // Giriş butonu
            Button(action: {
                withAnimation {
                    isLoading = true
                    // Giriş işlemi simülasyonu
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                        showingAlert = true
                    }
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 5)
                    }
                    Text("Giriş Yap")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(isLoading)
            
            Spacer()
        }
        .padding(.top, 30)
        .alert("Başarılı", isPresented: $showingAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Giriş başarılı!")
        }
    }
}

// Kayıt ekranı
struct RegisterView: View {
    @State private var name = ""
    @State private var surname = ""
    @State private var kimlikNo = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Kayıt formu
                VStack(spacing: 15) {
                    TextField("Ad", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Soyad", text: $surname)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Eczacı Kimlik No", text: $kimlikNo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("E-posta", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Telefon", text: $phone)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Şifre", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Şifre Tekrar", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Kayıt butonu
                Button(action: {
                    withAnimation {
                        isLoading = true
                        // Kayıt işlemi simülasyonu
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoading = false
                            showingAlert = true
                        }
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .padding(.trailing, 5)
                        }
                        Text("Kayıt Ol")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(isLoading)
            }
            .padding(.top, 30)
        }
        .alert("Başarılı", isPresented: $showingAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text("Kayıt başarılı!")
        }
    }
}

#Preview {
    ContentView()
}
