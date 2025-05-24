//
//  ContentView.swift
//  Phmora
//
//  Created by Ahsen on 25.03.2025.
//

import SwiftUI
import Combine

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
    @StateObject private var viewModel = LoginViewModel()
    @State private var showMainView = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Giriş formu
            VStack(spacing: 15) {
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disabled(viewModel.isLoading)
                
                SecureField("Şifre", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(viewModel.isLoading)
                
                Button("Şifremi Unuttum") {
                    // Şifre sıfırlama işlemi
                }
                .font(.footnote)
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal)
            
            // Giriş butonu
            Button(action: viewModel.login) {
                HStack {
                    if viewModel.isLoading {
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
            .disabled(viewModel.isLoading)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.red.opacity(0.1))
                    )
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 30)
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            MainView()
        }
    }
}

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Lütfen e-posta ve şifrenizi girin"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading = false
                
                switch completion {
                case .failure(let error):
                    if let apiError = error as? APIError {
                        self?.errorMessage = apiError.errorDescription ?? "Bilinmeyen bir hata oluştu"
                    } else {
                        self?.errorMessage = error.localizedDescription
                    }
                    self?.isLoggedIn = false
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] (response: LoginResponse) in
                self?.isLoggedIn = true
                self?.errorMessage = ""
                UserDefaults.standard.set(response.token, forKey: "userToken")
            })
            .store(in: &cancellables)
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
