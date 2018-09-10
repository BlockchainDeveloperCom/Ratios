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

    static func ratio(numeratorCoin: Coin, denominatorCoin: Coin) -> String {
        guard denominatorCoin.marketData.currentPrice.usdPrice > 0 else { return String(format: "%.3f", 0.0) }
        return String(format: "%.3f", numeratorCoin.marketData.currentPrice.usdPrice / denominatorCoin.marketData.currentPrice.usdPrice)
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
