//
//  Message.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-25.
//
import SwiftData
import Foundation

struct Message: Decodable, Encodable, Identifiable, Equatable {
    var id = UUID()
    
    let from: String
    let to: String
    let message: String
    let timestamp: Int
    
    private enum CodingKeys: String, CodingKey {
        case from, to, message, timestamp
    }
}

@Model
class MessageModel {
    var from: String
    var to: String
    var message: String
    var timestamp: Int

    init(from: String, to: String, message: String, timestamp: Int) {
        self.from = from
        self.to = to
        self.message = message
        self.timestamp = timestamp
    }
}
