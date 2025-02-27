//
//  User.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-24.
//


struct User: Decodable, Hashable, Encodable {
    let email: String
    let username: String
    let password: String
    let profilePicture: String
}
