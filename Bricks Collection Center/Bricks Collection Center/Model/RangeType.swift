//
//  RangeType.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 19/05/2024.
//

import Foundation

struct RangeType {
    let lowerBound: Int
    let upperBound: Int

    func contains(_ value: Int) -> Bool {
        return lowerBound <= value && value <= upperBound
    }
}
