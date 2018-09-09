//
//  Models.swift
//  Ratios
//
//  Created by Pouria Almassi on 9/5/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import Foundation

struct Container: Codable {
    let coins: [Coin]
}

struct Coin: Codable {
    let id: String
    let name: String
    let symbol: String
    let marketData: MarketData

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case symbol
        case marketData = "market_data"
    }
}

struct MarketData: Codable {
    let currentPrice: CurrentPrice

    enum CodingKeys: String, CodingKey {
        case currentPrice = "current_price"
    }
}

struct CurrentPrice: Codable {
    let usdPrice: Double

    enum CodingKeys: String, CodingKey {
        case usdPrice = "usd"
    }
}

//            "market_data": {
//                "current_price": {
//                    "usd": 6.132701877270238
//                }
//            }
