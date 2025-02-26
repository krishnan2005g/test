//
//  CoinDetails.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-24.
//
import Foundation

struct CoinDetails: Decodable, Encodable, Hashable {
    let id: Int
    let coinName: String
    let coinSymbol: String
    let imageUrl: String
}

struct CoinsStruct: Decodable, Hashable {
    let coin: [CoinDetails]
    let total_pages: Int
}


struct UserHolding: Decodable, Hashable, Identifiable {
    let email: String
    let coin: CoinDetails
    let quantity: Double
    
    var id: UUID {
        UUID()
    }
}
