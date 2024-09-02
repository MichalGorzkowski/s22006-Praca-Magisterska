//
//  AccountView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var firebaseManager: FirebaseManager
    @ObservedObject var viewModel = AccountViewModel()
    @State var showingPasswordAlert = false
    
    let profileImage = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Name:")
                        .font(.headline)
                    Text("\(firebaseManager.user.firstName)")
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Surname:")
                        .font(.headline)
                    Text("\(firebaseManager.user.lastName)")
                        .font(.body)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("E-mail:")
                        .font(.headline)
                    Text("\(firebaseManager.user.email)")
                        .font(.body)
                }
                
                Spacer()
                
                HStack(alignment: .top, spacing: 8) { // Ustawienie małego odstępu między obrazkiem a tekstem
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sets year median")
                            .font(.headline)
                        if let medianYear = viewModel.analytics.calculateYearMedian(sets: firebaseManager.setsInCollectionList) {
                            Text("\(String(medianYear))")
                                .font(.body)
                        } else {
                            Text("No sets in the collection.")
                                .font(.body)
                        }
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sets in collection")
                            .font(.headline)
                        Text("\(firebaseManager.setsInCollectionList.count)")
                            .font(.body)
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Favorite themes")
                            .font(.headline)
                        Text(viewModel.themeNames.joined(separator: ", "))
                            .font(.body)
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Favorite years")
                            .font(.headline)
                        let favoriteYearRanges = viewModel.analytics.getFavoriteYearRanges(sets: firebaseManager.setsInCollectionList)
                        
                        if !favoriteYearRanges.isEmpty {
                            let favoriteYearRangesString = favoriteYearRanges.map { "\($0.0)-\($0.1)" }.joined(separator: ",   ")
                            Text("\(favoriteYearRangesString)")
                                .font(.body)
                        } else {
                            Text("No favorite set years identified")
                                .font(.body)
                        }
                    }
                }
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Favorite part ranges")
                            .font(.headline)
                        let favoritePartRanges = viewModel.analytics.getFavoritePartRanges(sets: firebaseManager.setsInCollectionList)
                        
                        if !favoritePartRanges.isEmpty {
                            let favoritePartRangesString = favoritePartRanges.map { "\($0.0)-\($0.1)" }.joined(separator: ",   ")
                            Text("\(favoritePartRangesString)")
                                .font(.body)
                        } else {
                            Text("No favorite part ranges identified")
                                .font(.body)
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    let favoriteThemes = viewModel.analytics.getFavoriteThemes(sets: firebaseManager.setsInCollectionList)
                    viewModel.fetchThemeNames(themeIds: favoriteThemes)
                    print("\(viewModel.themeNames)")
                }, label: {
                    Text("Fetch data")
                        .foregroundColor(.blue)
                })
                .padding(.bottom, 10)
                
                Button(action: {
                    firebaseManager.auth.sendPasswordReset(withEmail: firebaseManager.user.email) { error in
                        if let error = error {
                            print("DEBUG: Error while sending password reset: \(error)")
                            return
                        }
                    }
                    showingPasswordAlert = true
                }, label: {
                    Text("Change password")
                        .foregroundColor(.blue)
                })
                .alert("Email with a password reset link has been sent.", isPresented: $showingPasswordAlert) {
                    Button("OK", role: .cancel) { }
                }
                .padding(.bottom, 10)
                
                Button(action: {
                    firebaseManager.signOut()
                }, label: {
                    Text("Sign out")
                        .foregroundColor(.red)
                })
                .padding(.bottom, 10)
            }
            .onAppear {
                firebaseManager.getUserDataFromFirebase()
                firebaseManager.getUserSetCollectionListFromFirebase()
                let favoriteThemes = viewModel.analytics.getFavoriteThemes(sets: firebaseManager.setsInCollectionList)
                viewModel.fetchThemeNames(themeIds: favoriteThemes)
            }
            .navigationTitle("Account")
        }
    }
}
