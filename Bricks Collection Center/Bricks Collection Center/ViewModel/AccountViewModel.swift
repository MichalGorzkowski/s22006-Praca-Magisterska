//
//  AccountViewModel.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 12/01/2024.
//

import Foundation

class AccountViewModel: ObservableObject {
    var firebaseManager = FirebaseManager()
    let analytics = CollectionAnalytics()
    @Published var themeName: String = "Loading..."
    @Published var themeNames: [String] = [] 
    
    func getData() {
        firebaseManager.getUserDataFromFirebase()
    }
    
    func loadThemeName(themeId: Int) {
        let rebrickableAPIClient = RebrickableAPIClient()
        rebrickableAPIClient.getThemeById(themeId: themeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let theme):
                    self.themeName = theme.title
                case .failure(let error):
                    self.themeName = "Unknown Theme"
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    func loadThemeNames(themeId: Int) {
        let rebrickableAPIClient = RebrickableAPIClient()
        self.themeNames.removeAll()
        rebrickableAPIClient.getThemeById(themeId: themeId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let theme):
                    self.themeNames.append(theme.title)
                case .failure(let error):
                    print("ERROR: \(error)")
                }
            }
        }
    }
    
    func fetchThemeNames(themeIds: [Int]) {
        for themeId in themeIds {
            loadThemeNames(themeId: themeId)
        }
    }
}
