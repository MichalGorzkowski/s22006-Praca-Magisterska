//
//  LegoSetDetailViewModel.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 11/05/2024.
//

import Foundation

class LegoSetDetailViewModel: ObservableObject {
    var firebaseManager = FirebaseManager()
    @Published var themeName: String = "Loading..."
    
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
}
