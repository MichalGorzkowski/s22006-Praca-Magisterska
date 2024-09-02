//
//  LegoMinifigure.swift
//  Bricks Collection Center
//
//  Created by Michał Gorzkowski on 09/01/2024.
//

import Foundation


struct LegoMinifigure: Codable {
    let id = UUID()
    let setNum: String
    let name: String
    let numParts: Int
    let setImgURL: String
    let setURL: String
    let lastModifiedDt: String
    
    enum CodingKeys: String, CodingKey {
        case setNum = "set_num"
        case name
        case numParts = "num_parts"
        case setImgURL = "set_img_url"
        case setURL = "set_url"
        case lastModifiedDt = "last_modified_dt"
    }
}

struct LegoMinifigureList: Decodable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [LegoMinifigure]
}
