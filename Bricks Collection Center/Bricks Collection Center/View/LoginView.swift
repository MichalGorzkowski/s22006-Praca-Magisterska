//
//  LoginView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 04/01/2024.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var email: String = ""
    @State private var password: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Login")
                    .font(.title)
                    .padding()

                TextField("E-mail", text: $email)
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                SecureField("Password", text: $password)
                    .padding()
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    guard !email.isEmpty, !password.isEmpty else {
                        return
                    }
                    firebaseManager.signIn(email: email, password: password)
                }) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
                
                Button(action: {
                    firebaseManager.switchView()
                }) {
                    Text("Don't have an account? Register")
                }
                .padding()
                
            }
            .padding()
        }
        
    }
}

#Preview {
    LoginView()
}
