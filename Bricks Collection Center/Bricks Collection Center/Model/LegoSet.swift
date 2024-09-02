//
//  LegoSet.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import Foundation

struct LegoSet: Identifiable, Decodable {
    let id = UUID()
    let setNum: String
    let name: String
    let year: Int
    let themeId: Int
    let numParts: Int
    let setImgURL: URL?
    let setURL: URL
    let lastModifiedDt: String
    
    enum CodingKeys: String, CodingKey {
        case setNum = "set_num"
        case name
        case year
        case themeId = "theme_id"
        case numParts = "num_parts"
        case setImgURL = "set_img_url"
        case setURL = "set_url"
        case lastModifiedDt = "last_modified_dt"
    }
}

struct LegoSetList: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [LegoSet]
}

struct ScoredLegoSet {
    let legoSet: LegoSet
    var themeScore: Int = 0
    var partsScore: Int = 0
    var yearScore: Int = 0
    var themeAndPartsScore: Int = 0
    var themeAndYearScore: Int = 0
    var partsAndYearScore: Int = 0
    var allCriteriaScore: Int = 0

    var totalScore: Double {
        let totalPoints = yearScore + themeScore + partsScore + themeAndPartsScore + themeAndYearScore + partsAndYearScore + allCriteriaScore
        let maxPoints = 100.0
        return (Double(totalPoints) / maxPoints) * 100
    }
    
    /*

    var totalScore: Double {
        let weightedYearScore = Double(yearScore) * RecommendationConfig.yearWeight
        let weightedThemeScore = Double(themeScore) * RecommendationConfig.themeWeight
        let weightedPartsScore = Double(partsScore) * RecommendationConfig.partsWeight

        return weightedYearScore + weightedThemeScore + weightedPartsScore
    }
    
    private func calculateMaxPoints() -> Int {
        let maxYearPoints = RecommendationConfig.yearPoints.max() ?? 0
        let maxThemePoints = RecommendationConfig.themePoints.max() ?? 0
        let maxPartsPoints = RecommendationConfig.partsPoints.max() ?? 0
        
        // Maksymalne punkty w każdej kategorii
        return maxYearPoints + maxThemePoints + maxPartsPoints
    }
    
    private func calculatePercentageScore(for scoredSet: ScoredLegoSet, maxPoints: Int) -> Double {
        guard maxPoints > 0 else { return 0.0 }
        let totalPoints = scoredSet.yearScore + scoredSet.themeScore + scoredSet.partsScore
        return (Double(totalPoints) / Double(maxPoints)) * 100
    }
     */
}

