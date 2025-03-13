//
//  LoginView.swift
//  DigiQ
//
//  Created by Publio Diaz on 11/03/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingSignUp = false
    @State private var isShowingForgotPassword = false
    @State private var isAuthenticated = false // Track authentication state

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.85, green: 0.93, blue: 0.99)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Bienvenido")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 40)
                    
                    TextField("Correo electrónico", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    
                    SecureField("Contraseña", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    
                    Button(action: {
                        // Simulate a successful login
                        isAuthenticated = true
                    }) {
                        Text("Iniciar Sesión")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.4, green: 0.75, blue: 0.9))
                            .cornerRadius(8)
                            .padding(.horizontal, 20)
                    }
                    
                    Button(action: {
                        isShowingForgotPassword = true
                    }) {
                        Text("¿Olvidaste tu contraseña?")
                            .foregroundColor(Color(red: 0.4, green: 0.75, blue: 0.9))
                            .padding(.top, 10)
                    }
                    .sheet(isPresented: $isShowingForgotPassword) {
                        ForgotPasswordView()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingSignUp = true
                    }) {
                        Text("¿No tienes una cuenta? Regístrate")
                            .foregroundColor(Color(red: 0.4, green: 0.75, blue: 0.9))
                            .padding(.bottom, 40)
                    }
                    .sheet(isPresented: $isShowingSignUp) {
                        SignUpView(onSignUpSuccess: {
                            // Simulate a successful sign-up and login
                            isAuthenticated = true
                        })
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isAuthenticated) {
                ContentView(isAuthenticated: $isAuthenticated) // Navigate to ContentView after authentication
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
}
