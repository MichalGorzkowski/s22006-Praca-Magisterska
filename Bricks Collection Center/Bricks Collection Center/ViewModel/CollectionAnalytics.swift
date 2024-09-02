//
//  CollectionAnalytics.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 19/05/2024.
//

import Foundation

class CollectionAnalytics {
    let maxParts = 10001
    
    func calculateYearMedian(sets: [LegoSet]) -> Int? {
        var years = [Int]()
        
        for set in sets {
            years.append(set.year)
        }
        
        guard !years.isEmpty else { return nil }  // Sprawdzenie, czy tablica nie jest pusta

        let sortedYears = years.sorted()
        let middleIndex = sortedYears.count / 2

        if sortedYears.count.isMultiple(of: 2) {
            // Dla parzystej liczby elementów zwróć średnią dwóch środkowych wartości
            return (sortedYears[middleIndex - 1] + sortedYears[middleIndex]) / 2
        } else {
            // Dla nieparzystej liczby elementów zwróć środkową wartość
            return sortedYears[middleIndex]
        }
    }
    
    func getThemes(sets: [LegoSet]) -> [Int: Int]? {
        var themesCounts = [Int: Int]()
        
        for set in sets {
            themesCounts[set.themeId, default: 0] += 1
        }
        return themesCounts
    }
    
    func getFavoriteThemes(sets: [LegoSet]) -> [Int] {
        let themesCounts = getThemes(sets: sets) ?? [:]
        let sortedThemes = themesCounts.sorted { $0.value > $1.value }

        let minSetsForTopThree = 10
        let percentageDifferenceForNextTheme = 0.25

        var selectedThemes = [Int]()
        let numberOfSets = sets.count

        for (index, theme) in sortedThemes.enumerated() {
            if numberOfSets < minSetsForTopThree {
                if index < 5 {
                    selectedThemes.append(theme.key)
                }
            } else {
                if index < 3 {
                    selectedThemes.append(theme.key)
                }

                if index > 0 {
                    let previousValue = Double(sortedThemes[index - 1].value)
                    let currentValue = Double(theme.value)
                    let difference = (previousValue - currentValue) / previousValue
                    if difference >= percentageDifferenceForNextTheme && selectedThemes.count > 2 {
                        break
                    }
                }
            }
        }
        
        return selectedThemes
    }
    
    func getYearRanges(sets: [LegoSet]) -> [(RangeType, Int)] {
        let ranges = [
            RangeType(lowerBound: 1932, upperBound: 1950),
            RangeType(lowerBound: 1951, upperBound: 1960),
            RangeType(lowerBound: 1961, upperBound: 1970),
            RangeType(lowerBound: 1971, upperBound: 1980),
            RangeType(lowerBound: 1981, upperBound: 1990),
            RangeType(lowerBound: 1991, upperBound: 2000),
            RangeType(lowerBound: 2001, upperBound: 2010),
            RangeType(lowerBound: 2011, upperBound: 2020),
            RangeType(lowerBound: 2021, upperBound: 2030),
            RangeType(lowerBound: 2031, upperBound: 2040),
            RangeType(lowerBound: 2041, upperBound: 2050),
            RangeType(lowerBound: 2051, upperBound: 2060),
            RangeType(lowerBound: 2061, upperBound: 2070),
            RangeType(lowerBound: 2071, upperBound: 2099)
        ]

        var yearCounts: [(RangeType, Int)] = ranges.map { ($0, 0) }

        for set in sets {
            if let index = yearCounts.firstIndex(where: { $0.0.contains(set.year) }) {
                yearCounts[index].1 += 1
            }
        }

        return yearCounts
    }
    
    func getFavoriteYearRanges(sets: [LegoSet]) -> [(Int, Int)] {
        let yearCounts = getYearRanges(sets: sets)
        let sortedYearCounts = yearCounts.sorted { $0.1 > $1.1 }

        let minSetsForTopFive = 10
        let percentageDifferenceForNextRange = 0.25

        var selectedRanges: [(Int, Int)] = []
        let numberOfSets = sets.count

        for (index, rangeCount) in sortedYearCounts.enumerated() {
            if numberOfSets < minSetsForTopFive {
                if index < 5 {
                    selectedRanges.append((rangeCount.0.lowerBound, rangeCount.0.upperBound))
                }
            } else {
                if index < 3 {
                    selectedRanges.append((rangeCount.0.lowerBound, rangeCount.0.upperBound))
                }

                if index > 0 {
                    let previousValue = Double(sortedYearCounts[index - 1].1)
                    let currentValue = Double(rangeCount.1)
                    let difference = (previousValue - currentValue) / previousValue
                    if difference >= percentageDifferenceForNextRange && selectedRanges.count > 2 {
                        break
                    }
                }
            }
        }
        
        return selectedRanges
    }

    func getPartRanges(sets: [LegoSet]) -> [(RangeType, Int)] {
        let ranges = [
            RangeType(lowerBound: 0, upperBound: 100),
            RangeType(lowerBound: 101, upperBound: 500),
            RangeType(lowerBound: 501, upperBound: 1000),
            RangeType(lowerBound: 1001, upperBound: 2000),
            RangeType(lowerBound: 2001, upperBound: 4000),
            RangeType(lowerBound: 4001, upperBound: 7000),
            RangeType(lowerBound: 7001, upperBound: maxParts)
        ]

        var partCounts: [(RangeType, Int)] = ranges.map { ($0, 0) }

        for set in sets {
            if let index = partCounts.firstIndex(where: { $0.0.contains(set.numParts) }) {
                partCounts[index].1 += 1
            }
        }

        return partCounts
    }
    
    func getFavoritePartRanges(sets: [LegoSet]) -> [(Int, Int)] {
        let partCounts = getPartRanges(sets: sets)
        let sortedPartCounts = partCounts.sorted { $0.1 > $1.1 }

        let minSetsForTopFive = 10
        let percentageDifferenceForNextRange = 0.25

        var selectedRanges: [(Int, Int)] = []
        let numberOfSets = sets.count

        for (index, rangeCount) in sortedPartCounts.enumerated() {
            if numberOfSets < minSetsForTopFive {
                if index < 5 {
                    selectedRanges.append((rangeCount.0.lowerBound, rangeCount.0.upperBound))
                }
            } else {
                if index < 3 {
                    selectedRanges.append((rangeCount.0.lowerBound, rangeCount.0.upperBound))
                }

                if index > 0 {
                    let previousValue = Double(sortedPartCounts[index - 1].1)
                    let currentValue = Double(rangeCount.1)
                    let difference = (previousValue - currentValue) / previousValue
                    if difference >= percentageDifferenceForNextRange && selectedRanges.count > 2 {
                        break
                    }
                }
            }
        }
        
        return selectedRanges
    }
}
