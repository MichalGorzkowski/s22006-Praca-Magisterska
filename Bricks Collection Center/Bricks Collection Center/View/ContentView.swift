//
//  ContentView.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 04/01/2024.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var discoverViewModel = DiscoverViewModel()
    @EnvironmentObject var firebaseManager: FirebaseManager
    
    var body: some View {
        Group {
            if firebaseManager.loggedIn {
                TabView {
                    /*
                    MainScreenView()
                        .tabItem {
                            Image(systemName: "house")
                            Text("Dashboard")
                        }
                     */
                    
                    SavedSetsView()
                        .tabItem {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Collection")
                        }
                    
                    SearchView()
                        .tabItem {
                            Image(systemName: "magnifyingglass")
                            Text("Search")
                        }
                    
                    DiscoverView()
                        .environmentObject(discoverViewModel)
                        .tabItem {
                            Image(systemName: "timelapse")
                            Text("Discover")
                        }
                    
                    AccountView()
                        .tabItem {
                            Image(systemName: "person")
                            Text("Account")
                        }
                }
            } else {
                if firebaseManager.isRegistrationViewActive {
                    RegistrationView()
                } else {
                    LoginView()
                }
            }
        }
        .onAppear {
            firebaseManager.loggedIn = firebaseManager.isLoggedIn
        }
    }
}
