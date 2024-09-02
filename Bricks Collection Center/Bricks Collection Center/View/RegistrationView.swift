//
//  RegistrationView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 04/01/2024.
//

import SwiftUI
import PhotosUI

struct RegistrationView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    @State private var selectedImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Registration")
                .font(.title)
                .padding()
            
            HStack(spacing: 0) {
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    Image(uiImage: selectedImage ?? UIImage(resource: .minifigure))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(.circle)
                }
                
                VStack(spacing: 0) {
                    TextField("First Name", text: $firstName)
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("Last Name", text: $lastName)
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }

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

            SecureField("Confirm password", text: $confirmPassword)
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button(action: {
                guard !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
                    return
                }
                
                firebaseManager.signUp(firstName: firstName, lastName: lastName, email: email, password: password, image: selectedImage ?? nil)
            }) {
                Text("Register")
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
                Text("Already have an account? Log in")
            }
            .padding()

        }
        .padding()
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem,
                   let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
                
                photosPickerItem = nil
            }
        }
    }
}

#Preview {
    RegistrationView()
}
