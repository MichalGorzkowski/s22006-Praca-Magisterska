//
//  MLRecommendationEngine.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 26/08/2024.
//

// plik przygotowany do załadowania modelu ML

/*
import Foundation
import CoreML

class MLRecommendationEngine {
    private let firebaseManager = FirebaseManager()
    
    // Przechowuje wyniki rekomendacji
    var recommendedSets: [LegoSet] = []
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        // Tutaj załadujemy model, który zostanie wytrenowany i zapisany w formacie CoreML.
        do {
            let config = MLModelConfiguration()
            //model = try LegoRecommendationModel(configuration: config) // tutaj będzie model
            print("DEBUG: Model loaded successfully")
        } catch {
            print("DEBUG: Error loading model: \(error)")
        }
    }
    
    // Pobiera interakcje użytkownika z Firebase
    func fetchUserInteractions(userId: String, completion: @escaping ([UserInteraction]) -> Void) {
        firebaseManager.getUserInteractions(userId: userId) { interactions in
            completion(interactions)
        }
    }
    
    // Przetwarzanie danych i przygotowanie pod rekomendacje
    func prepareRecommendations(for userId: String, completion: @escaping ([LegoSet]) -> Void) {
        firebaseManager.getUserInteractions(userId: userId) { interactions in
            guard !interactions.isEmpty else {
                print("DEBUG: No user interactions found")
                completion(false)
                return
            }
            
            // Tutaj można przygotować dane dla modelu ML, np. przekształcić interakcje na wektor cech.
            // Można również przeprowadzić preprocessing danych, jeśli jest to wymagane przez model.
            completion(true)
        }
    }
    
    func getRecommendations(for userId: String, completion: @escaping ([LegoSet]) -> Void) {
        prepareRecommendations(for: userId) { recommendedSets in
            // Tutaj można dodać logikę, która przetworzy rekomendacje i przygotuje je do wyświetlenia w interfejsie użytkownika.
            completion(recommendedSets)
        }
    }

}

extension MLRecommendationEngine {
    func getRecommendations(for userId: String, k: Int = 10, completion: @escaping ([LegoSet]) -> Void) {
        // Upewnienie się, że model jest załadowany
        guard let model = model else {
            print("DEBUG: Model not loaded")
            completion([])
            return
        }

        let firebaseManager = FirebaseManager()

        // Pobieranie danych użytkownika
        firebaseManager.getUserInteractions(userId: userId) { interactions in
            guard !interactions.isEmpty else {
                print("DEBUG: No user interactions found")
                completion([])
                return
            }

            // Stworzenie inputu dla modelu ML
            var itemsDict: [Int64: Double] = [:]
            for interaction in interactions {
                let itemId = Int64(interaction.setId) ?? 0
                itemsDict[itemId] = interaction.interactionScore
            }
            
            do {
                // Przygotowanie danych dla modelu
                let input = LegoRecommendationModelInput(items: itemsDict as [NSNumber : Double], k: Int64(k))
                
                // Uzyskanie rekomendacji od modelu
                let output = try model.prediction(input: input)
                
                // Mapowanie wyników na zestawy LEGO
                let recommendedIds = output.recommendations.map { String($0) }
                firebaseManager.getLegoSetsByIds(recommendedIds) { legoSets in
                    completion(legoSets)
                }
            } catch {
                print("DEBUG: Error generating recommendations: \(error)")
                completion([])
            }
        }
    }
}
*/
