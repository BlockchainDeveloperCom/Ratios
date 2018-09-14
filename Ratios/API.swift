//
//  API.swift
//  Ratios
//
//  Created by Pouria Almassi on 15/9/18.
//  Copyright © 2018 Blockchain Developer. All rights reserved.
//

import Foundation
import PromiseKit

struct API {
    enum APIError: Error {
        case generic
    }

    static func coins() -> Promise<[Coin]> {
        return Promise { seal in
            guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/list") else {
                seal.reject(APIError.generic)
                return
            }
            URLSession.shared.dataTask(with: url) { data, _, error in
                do {
                    guard let data = data else {
                        seal.reject(APIError.generic)
                        return
                    }
                    let coins = try JSONDecoder().decode([Coin].self, from: data)
                    seal.fulfill(coins)
                } catch {
                    seal.reject(error)
                }
                }.resume()
        }
    }

    static func coin(withSymbol: String) -> Promise<Coin> {
        return Promise { seal in
            guard let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(withSymbol)") else {
                seal.reject(APIError.generic)
                return
            }
            URLSession.shared.dataTask(with: url) { data, _, error in
                do {
                    guard let data = data else {
                        seal.reject(APIError.generic)
                        return
                    }
                    let coin = try JSONDecoder().decode(Coin.self, from: data)
                    seal.fulfill(coin)
                } catch {
                    seal.reject(error)
                }
                }.resume()
        }
    }
}
