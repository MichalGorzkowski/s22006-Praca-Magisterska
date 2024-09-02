//
//  DiscoverViewModel.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 15/08/2024.
//

import Foundation

class DiscoverViewModel: ObservableObject {
    var firebaseManager = FirebaseManager()
    @Published var allLegoSets: LegoSetList?
    @Published var filteredLegoSets: [ScoredLegoSet] = []
    @Published var currentPage: Int = 0
    @Published var totalPages: Int = 235 // Zakładamy stałą liczbę stron
    @Published var isLoading: Bool = false // Flaga informująca o ładowaniu

    let analytics = CollectionAnalytics()

    var progressPercentage: Int {
        guard totalPages > 0 else { return 0 }
        return Int((Float(currentPage) / Float(totalPages)) * 100)
    }

    func loadAllLegoSets() {
        if !filteredLegoSets.isEmpty || isLoading {
            return
        }

        isLoading = true
        let rebrickableAPIClient = RebrickableAPIClient()
        loadPage(rebrickableAPIClient: rebrickableAPIClient, page: 1)
    }

    private func loadPage(rebrickableAPIClient: RebrickableAPIClient, page: Int) {
        rebrickableAPIClient.getAllLegoSets(page: page) { result in
            switch result {
            case .success(let legoSetList):
                self.firebaseManager.getUserSetCollectionListFromFirebase()
                DispatchQueue.main.async {
                    if self.allLegoSets == nil {
                        self.allLegoSets = legoSetList
                    } else {
                        var currentResults = self.allLegoSets?.results ?? []
                        currentResults.append(contentsOf: legoSetList.results)
                        self.allLegoSets = LegoSetList(count: self.allLegoSets?.count ?? 0 + legoSetList.count,
                                                       next: legoSetList.next,
                                                       previous: legoSetList.previous,
                                                       results: currentResults)
                    }
                    
                    self.currentPage = page

                    if page < self.totalPages, legoSetList.next != nil {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 1.1) {
                            self.loadPage(rebrickableAPIClient: rebrickableAPIClient, page: page + 1)
                        }
                    } else {
                        self.calculateScores()
                        self.isLoading = false // Ładowanie zakończone
                    }
                }
                
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false // W przypadku błędu zatrzymujemy ładowanie
                }
            }
        }
    }

    func refreshRecommendations() {
        filteredLegoSets.removeAll()
        allLegoSets = nil
        currentPage = 0
        loadAllLegoSets()
    }

    private func calculateScores() {
        guard let allLegoSets = allLegoSets?.results else { return }

        let userSets = firebaseManager.setsInCollectionList
        let userSetYears = Set(userSets.map { $0.year })  // Zestaw lat w kolekcji użytkownika

        let medianYear = analytics.calculateYearMedian(sets: userSets) ?? 0
        let favoriteThemes = analytics.getFavoriteThemes(sets: userSets)
        let favoritePartRanges = analytics.getFavoritePartRanges(sets: userSets)

        var scoredSets: [ScoredLegoSet] = []

        for legoSet in allLegoSets {
            var scoredSet = ScoredLegoSet(legoSet: legoSet)

            // Tematyka zestawu (max 30 punktów)
            if let themeIndex = favoriteThemes.firstIndex(of: legoSet.themeId) {
                if themeIndex <= 4 {
                    let themeScoreStep = 6
                    scoredSet.themeScore = 30 - themeIndex * themeScoreStep
                } else if themeIndex <= 7 {
                    scoredSet.themeScore = 2
                } else {
                    scoredSet.themeScore = 1
                }
            } else {
                scoredSet.themeScore = 0
            }

            // Ilość części (max 20 punktów)
            let setParts = legoSet.numParts
            if let partRangeIndex = favoritePartRanges.firstIndex(where: { $0.0 <= setParts && $0.1 >= setParts }) {
                if partRangeIndex <= 4 {
                    let partsScoreStep = 4
                    scoredSet.partsScore = 20 - partRangeIndex * partsScoreStep
                } else if partRangeIndex <= 7 {
                    scoredSet.partsScore = 2
                } else {
                    scoredSet.partsScore = 1
                }
            } else {
                scoredSet.partsScore = 0
            }

            // Rok wydania (max 10 punktów)
            let yearDifference = abs(legoSet.year - medianYear)
            switch yearDifference {
            case 0:
                scoredSet.yearScore = 10
            case 1:
                scoredSet.yearScore = 9
            case 2:
                scoredSet.yearScore = 8
            case 3:
                scoredSet.yearScore = 7
            case 4...5:
                scoredSet.yearScore = 6
            case 6...7:
                scoredSet.yearScore = 5
            case 8...10:
                scoredSet.yearScore = 4
            case 11...15:
                scoredSet.yearScore = 3
            case 16...20:
                scoredSet.yearScore = 2
            case 21...30:
                scoredSet.yearScore = 1
            default:
                // Sprawdzenie, czy rok zestawu jest w kolekcji użytkownika, ale poza zdefiniowanymi zakresami
                scoredSet.yearScore = userSetYears.contains(legoSet.year) ? 1 : 0
            }

            // Tematyka + Liczba części (max 15 punktów)
            if let themeIndex = favoriteThemes.firstIndex(of: legoSet.themeId), let partRangeIndex = favoritePartRanges.firstIndex(where: { $0.0 <= setParts && $0.1 >= setParts }) {
                switch (themeIndex, partRangeIndex) {
                case (0, 0):
                    scoredSet.themeAndPartsScore = 15
                case (0, 1):
                    scoredSet.themeAndPartsScore = 12
                case (0, 2):
                    scoredSet.themeAndPartsScore = 10
                case (1, 0):
                    scoredSet.themeAndPartsScore = 9
                case (1, 1):
                    scoredSet.themeAndPartsScore = 7
                case (1, 2):
                    scoredSet.themeAndPartsScore = 5
                case (2, 0):
                    scoredSet.themeAndPartsScore = 4
                case (2, 1):
                    scoredSet.themeAndPartsScore = 3
                case (2, 2):
                    scoredSet.themeAndPartsScore = 2
                default:
                    scoredSet.themeAndPartsScore = 0
                }
            } else {
                scoredSet.themeAndPartsScore = 0
            }

            // Tematyka + Rok wydania (max 10 punktów)
            if let themeIndex = favoriteThemes.firstIndex(of: legoSet.themeId) {
                switch (themeIndex, yearDifference) {
                case (0, 0...3):
                    scoredSet.themeAndYearScore = 10
                case (0, 4...7):
                    scoredSet.themeAndYearScore = 8
                case (0, 8...10):
                    scoredSet.themeAndYearScore = 6
                case (1, 0...3):
                    scoredSet.themeAndYearScore = 7
                case (1, 4...7):
                    scoredSet.themeAndYearScore = 5
                case (1, 8...10):
                    scoredSet.themeAndYearScore = 3
                case (2, 0...3):
                    scoredSet.themeAndYearScore = 4
                case (2, 4...7):
                    scoredSet.themeAndYearScore = 3
                case (2, 8...10):
                    scoredSet.themeAndYearScore = 2
                default:
                    scoredSet.themeAndYearScore = 0
                }
            } else {
                scoredSet.themeAndYearScore = 0
            }

            // Liczba części + Rok wydania (max 10 punktów)
            if let partRangeIndex = favoritePartRanges.firstIndex(where: { $0.0 <= setParts && $0.1 >= setParts }) {
                 switch (partRangeIndex, yearDifference) {
                 case (0, 0...3):
                     scoredSet.partsAndYearScore = 10
                 case (0, 4...7):
                     scoredSet.partsAndYearScore = 8
                 case (0, 8...10):
                     scoredSet.partsAndYearScore = 6
                 case (1, 0...3):
                     scoredSet.partsAndYearScore = 7
                 case (1, 4...7):
                     scoredSet.partsAndYearScore = 5
                 case (1, 8...10):
                     scoredSet.partsAndYearScore = 3
                 case (2, 0...3):
                     scoredSet.partsAndYearScore = 4
                 case (2, 4...7):
                     scoredSet.partsAndYearScore = 3
                 case (2, 8...10):
                     scoredSet.partsAndYearScore = 2
                 default:
                     scoredSet.partsAndYearScore = 0
                 }
             } else {
                 scoredSet.partsAndYearScore = 0
             }

            // Wszystkie trzy kryteria (max 5 punktów)
            if let themeIndex = favoriteThemes.firstIndex(of: legoSet.themeId),
               let partRangeIndex = favoritePartRanges.firstIndex(where: { $0.0 <= setParts && $0.1 >= setParts }) {
                if themeIndex == 0 && partRangeIndex == 0 && (0...3).contains(yearDifference) {
                    scoredSet.allCriteriaScore = 5
                } else if (themeIndex == 0 && partRangeIndex == 0 && (4...7).contains(yearDifference)) ||
                          (themeIndex == 1 && partRangeIndex == 0 && (0...3).contains(yearDifference)) {
                    scoredSet.allCriteriaScore = 4
                } else if (themeIndex == 0 && partRangeIndex == 1 && (0...3).contains(yearDifference)) ||
                          (themeIndex == 1 && partRangeIndex == 1 && (0...3).contains(yearDifference)) ||
                          (themeIndex == 2 && partRangeIndex == 0 && (0...3).contains(yearDifference)) {
                    scoredSet.allCriteriaScore = 3
                } else {
                    scoredSet.allCriteriaScore = 0
                }
            }

            scoredSets.append(scoredSet)
        }

        scoredSets.sort { $0.totalScore > $1.totalScore }
        let top100Sets = scoredSets.prefix(100)
        filteredLegoSets = Array(top100Sets)
    }


}
