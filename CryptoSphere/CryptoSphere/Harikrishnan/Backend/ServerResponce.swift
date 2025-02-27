//
//  ServerResponce.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-12.
//

import Foundation
import Combine

//let link = "http://10.16.18.191:4060"

let link = "http://172.24.204.231:4060"

class ServerResponce {
    
    static let shared = ServerResponce()
    
    func getUsers() async throws -> [User] {
        guard let url = URL(string: "\(link)/get_users") else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let users = try JSONDecoder().decode([User].self, from: data)
        return users
    }
    
    func addUser(user: User) async {
        guard let url = URL(string: "\(link)/add_user") else {
            return
        }
        print("Added")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
            
            let (data, _) = try await URLSession.shared.data(for: request)
            
            if let decodedResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                print("Response: \(decodedResponse)")
            }
        } catch {
            print("Error: \(error)")
        }
        print(user.username)
    }
    
    func getChatHistory(from: String) async throws -> [Message]{
        guard let url = URL(string: "\(link)/get_chat_history/\(from)") else { return []}
        let (data, _) = try await URLSession.shared.data(from: url)
        let msgs = try JSONDecoder().decode([Message].self, from: data)
        return msgs
    }
    
    
    func fetchuserholdings() async throws -> [UserHolding] {
        let userName = UserSession.shared?.userName ?? preview
        guard let url = URL(string: "\(link)/userholdings/\(userName)") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            return try JSONDecoder().decode([UserHolding].self, from: data)
        } catch {
            print("decode error")
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode UserHoldings"))
        }
    }
    
    func getCoins(searchText: String, page: Int) async throws -> CoinsStruct {
        guard let url = URL(string: "\(link)/get_coins/\(page)/\(searchText)") else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        do {
            return try JSONDecoder().decode(CoinsStruct.self, from: data)
        } catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode CoinDetails"))
        }
    }
    
    func buySellCoin(buySell: String, coinId: Int, quantity: Double, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(link)/\(buySell)_coin?username=\(UserSession.shared?.userName ?? preview)&coin_id=\(coinId)&quantity=\(quantity)") else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    completion(true)
                } else {
                    print("Error: \(httpResponse.statusCode)")
                    completion(false)
                }
            } else {
                completion(false)
            }
        }.resume()
    }
}

func fetchPrice(coinName: String) async throws -> CryptoResponse {
    let endpoint = "https://api.bybit.com/v5/market/tickers"
    
    guard var urlComponents = URLComponents(string: endpoint) else {
        throw CoinError.invalidURL
    }
    urlComponents.queryItems = [
        URLQueryItem(name: "category", value: "spot"),
        URLQueryItem(name: "symbol", value: coinName.uppercased() == "ZOINUSDT" ? "BTCUSDT" : coinName.uppercased())
    ]
    guard let url = urlComponents.url else {
        throw CoinError.invalidURL
    }
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw CoinError.requestFailed
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
        let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
        print("Request failed with status code: \(httpResponse.statusCode), response: \(responseBody)")
        switch httpResponse.statusCode {
        case 400: throw CoinError.invalidSymbol
        case 429: throw CoinError.rateLimitExceeded
        default: throw CoinError.requestFailed
        }
    }
    
    return try JSONDecoder().decode(CryptoResponse.self, from: data)
}
