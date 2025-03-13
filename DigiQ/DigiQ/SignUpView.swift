//
//  SignUpView.swift
//  DigiQ
//
//  Created by Publio Diaz on 11/03/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    var onSignUpSuccess: () -> Void // Closure to notify success

    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.99)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Regístrate")
                    .font(.title)
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
                
                SecureField("Confirmar Contraseña", text: $confirmPassword)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    // Handle sign up logic
                    // For now, simulate success
                    onSignUpSuccess()
                }) {
                    Text("Registrarse")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.4, green: 0.75, blue: 0.9))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.black)
                },
                trailing: Text("Registrarse")
                    .font(.headline)
                    .foregroundColor(.black)
            )
    }
}
