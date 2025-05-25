//
//  ContentView.swift
//  Phmora
//
//  Created by Ahsen on 25.03.2025.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var showLoadingScreen = true
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        ZStack {
            if showLoadingScreen {
                LoadingScreen()
                    .transition(.opacity)
            } else if authService.isLoggedIn {
                MainView()
                    .transition(.opacity)
            } else {
                LoginScreen()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // 4 saniye sonra loading ekranını kapat
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showLoadingScreen = false
                }
            }
            
            // Giriş durumunu kontrol et
            authService.checkLoginStatus()
        }
        .onChange(of: authService.isLoggedIn) { isLoggedIn in
            // Kullanıcı çıkış yaptığında loading ekranını göster
            if !isLoggedIn && !showLoadingScreen {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showLoadingScreen = true
                }
                
                // 2 saniye sonra login ekranına geç
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showLoadingScreen = false
                    }
                }
            }
        }
    }
}

// MARK: - Loading Screen
struct LoadingScreen: View {
    @State private var animationOffset: CGFloat = 0
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var textOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6),
                        Color.cyan.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated Particles
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: CGFloat.random(in: 4...12))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .offset(y: animationOffset)
                        .animation(
                            Animation.linear(duration: Double.random(in: 3...6))
                                .repeatForever(autoreverses: false),
                            value: animationOffset
                        )
                }
                
                // Floating Geometric Shapes
                ForEach(0..<8, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 20, height: 20)
                        .rotationEffect(.degrees(animationOffset * 0.5))
                        .position(
                            x: CGFloat.random(in: 50...geometry.size.width - 50),
                            y: CGFloat.random(in: 100...geometry.size.height - 100)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: true),
                            value: animationOffset
                        )
                }
                
                // Main Content
                VStack(spacing: 30) {
                    // Logo
                    Image("PharmoraLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .shadow(color: .blue.opacity(0.4), radius: 10)
                    
                    // App Name
                    VStack(spacing: 8) {
                        Text("")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(textOpacity)
                        
                        Text("Eczane Stok Yönetim Sistemi")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(textOpacity)
                    }
                    
                    // Loading Indicator
                    VStack(spacing: 15) {
                        // Custom Loading Animation
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(animationOffset > CGFloat(index) * 0.3 ? 1.2 : 0.8)
                                    .animation(
                                        Animation.easeInOut(duration: 0.6)
                                            .repeatForever()
                                            .delay(Double(index) * 0.2),
                                        value: animationOffset
                                    )
                            }
                        }
                        
                        Text("")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .opacity(textOpacity)
                    }
                }
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Logo animation
        withAnimation(.easeOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Text animation
        withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
            textOpacity = 1.0
        }
        
        // Particle animation
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            animationOffset = -500
        }
    }
}

// MARK: - Login Screen
struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var logoScale: CGFloat = 0.8
    @State private var formOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemBackground),
                        Color.blue.opacity(0.05)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Header Section
                        VStack(spacing: 20) {
                            // Logo
                            Image("PharmoraLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 250, height: 250)
                                .scaleEffect(logoScale)
                                .shadow(color: .blue.opacity(0.3), radius: 10)
                            
                         
                        }
                        .padding(.top, 60)
                        
                        // Login Form
                        VStack(spacing: 25) {
                            // Input Fields
                            VStack(spacing: 20) {
                                // Pharmacist ID Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Eczacı Kimlik No")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                    
                                    TextField("Eczane ID Girin", text: $viewModel.pharmacistId)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .autocapitalization(.none)
                                        .keyboardType(.numberPad)
                                        .disabled(viewModel.isLoading)
                                }
                                
                                // Password Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Şifre")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(.secondary)
                                    
                                    SecureField("Şifrenizi girin", text: $viewModel.password)
                                        .textFieldStyle(ModernTextFieldStyle())
                                        .disabled(viewModel.isLoading)
                                }
                            }
                            
                            // Forgot Password
                            HStack {
                                Spacer()
                                Button("") {
                                    // Şifre sıfırlama işlemi
                                }
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                            }
                            
                            // Login Button
                            Button(action: viewModel.login) {
                                HStack(spacing: 12) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: 18))
                                    }
                                    
                                    Text("Giriş Yap")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green, Color.blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(viewModel.isLoading)
                            .scaleEffect(viewModel.isLoading ? 0.98 : 1.0)
                            .animation(.easeInOut(duration: 0.1), value: viewModel.isLoading)
                            
                            // Error Message
                            if !viewModel.errorMessage.isEmpty {
                                HStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    
                                    Text(viewModel.errorMessage)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 30)
                        .opacity(formOpacity)
                        
                        Spacer(minLength: 50)
                    }
                }
            }
        }
        .onAppear {
            startLoginAnimations()
        }
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            MainView()
        }
    }
    
    private func startLoginAnimations() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            logoScale = 1.0
        }
        
        withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
            formOpacity = 1.0
        }
    }
}

// MARK: - Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
                    .stroke(Color(UIColor.systemGray4), lineWidth: 1)
            )
            .font(.system(size: 16, weight: .medium))
    }
}

// MARK: - Login View Model
class LoginViewModel: ObservableObject {
    @Published var pharmacistId = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func login() {
        guard !pharmacistId.isEmpty && !password.isEmpty else {
            withAnimation(.spring()) {
                errorMessage = "Lütfen eczacı kimlik no ve şifrenizi girin"
            }
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        AuthService.shared.login(pharmacistId: pharmacistId, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                self?.isLoading = false
                
                switch completion {
                case .failure(let error):
                    withAnimation(.spring()) {
                        if let apiError = error as? APIError {
                            self?.errorMessage = apiError.errorDescription ?? "Bilinmeyen bir hata oluştu"
                        } else {
                            self?.errorMessage = error.localizedDescription
                        }
                    }
                    self?.isLoggedIn = false
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] (response: LoginResponse) in
                self?.isLoggedIn = true
                self?.errorMessage = ""
                UserDefaults.standard.set(response.user.pharmacistId, forKey: AppConstants.UserDefaultsKeys.pharmacistId)
            })
            .store(in: &cancellables)
    }
}

#Preview {
    ContentView()
}
