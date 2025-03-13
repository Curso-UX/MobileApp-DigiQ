//
//  ForgotPasswordView.swift
//  DigiQ
//
//  Created by Publio Diaz on 11/03/25.
//
import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 0.99)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Recuperar Contraseña")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 40)
                
                TextField("Correo electrónico", text: $email)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    // Handle forgot password action
                }) {
                    Text("Enviar")
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
    }
}
