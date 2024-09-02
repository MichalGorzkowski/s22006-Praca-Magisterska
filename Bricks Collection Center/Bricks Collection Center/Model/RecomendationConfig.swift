//
//  RecomendationConfig.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 15/08/2024.
//

import Foundation

struct RecommendationConfig {
    static let yearWeight = 0.3
    static let themeWeight = 0.4
    static let partsWeight = 0.3
    static let yearPoints = [30, 20, 10, 0]
    static let themePoints = [40, 30, 10, 0]
    static let partsPoints = [30, 20, 10, 0]
    static let minSetsForTopFive = 10
    static let percentageDifferenceForNextRange = 0.25
}
