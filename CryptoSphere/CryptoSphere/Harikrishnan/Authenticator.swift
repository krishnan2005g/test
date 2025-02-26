//
//  Authenticator.swift
//  CryptoSphere
//
//  Created by Harikrishnan V on 2025-02-21.
//

import SwiftUI
import Foundation

class Authenticator {
    private static let clientID = "1000.UXMV0JKEJX8C4CC7AFHIO04UHCIXJT"
    private static let clientSecret = "fa05a79928c7364edb096446ea71c80bca9af59913"
    private static let baseUrl = "https://accounts.zoho.com/"
    private static let authEndpoint = "oauth/v2/auth"
    private static let tokenEndpoint = "oauth/v2/token"
    private static let revokeEndpoint = "oauth/v2/token/revoke"
    private static let enhanceEndpoint = "oauth/v2/token/scopeenhance"
    private static let host = "172.24.204.231"
    
    private static let authRedirect = "http://\(host):4060/oauthredirect"
    private static let enhanceRedirect = "http://\(host):4060/Account/captureEnhancedScope"
    static let loginRedirect = "http://\(host):4060/Account/login.html"
    static let homeRedirect = "http://\(host):4060/Account/home.html"
    
    enum AuthError: Error {
        case invalidAuthCode
        case invalidRefreshToken
        case requestFailed
    }
    
    struct Scope {
        let oauth: String
        static let profile = Scope(oauth: "profile")
        static let email = Scope(oauth: "email")
    }
    
    static func getAuthURL(scopes: [Scope], consent: Bool = false) -> URL? {
        var components = URLComponents(string: baseUrl + authEndpoint)
        let scopeString = scopes.map { $0.oauth }.joined(separator: ",")
        
        components?.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "scope", value: scopeString),
            URLQueryItem(name: "redirect_uri", value: authRedirect),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: consent ? "consent" : "login")
        ].compactMap { $0 }
        
        return components?.url
    }
    
    static func getTokens(code: String, completion: @escaping (Result<(accessToken: String, refreshToken: String), AuthError>) -> Void) {
        guard let url = URL(string: baseUrl + tokenEndpoint) else {
            completion(.failure(.requestFailed))
            return
        }
        
        let parameters = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "authorization_code",
            "redirect_uri": authRedirect,
            "code": code
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = json["error"] as? String {
                        completion(.failure(error == "invalid_code" ? .invalidAuthCode : .requestFailed))
                        return
                    }
                    
                    guard let accessToken = json["access_token"] as? String,
                          let refreshToken = json["refresh_token"] as? String else {
                        completion(.failure(.requestFailed))
                        return
                    }
                    
                    completion(.success((accessToken, refreshToken)))
                }
            } catch {
                completion(.failure(.requestFailed))
            }
        }.resume()
    }
    
    static func refreshToken(refreshToken: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let url = URL(string: baseUrl + tokenEndpoint) else {
            completion(.failure(.requestFailed))
            return
        }
        
        let parameters = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.requestFailed))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let error = json["error"] as? String {
                        completion(.failure(error == "invalid_code" ? .invalidRefreshToken : .requestFailed))
                        return
                    }
                    
                    guard let accessToken = json["access_token"] as? String else {
                        completion(.failure(.requestFailed))
                        return
                    }
                    
                    completion(.success(accessToken))
                }
            } catch {
                completion(.failure(.requestFailed))
            }
        }.resume()
    }
    
    static func revokeToken(refreshToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: baseUrl + revokeEndpoint) else {
            completion(false)
            return
        }
        
        let parameters = ["token": refreshToken]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = json["status"] as? String {
                completion(status == "success")
            } else {
                completion(false)
            }
        }.resume()
    }
}

struct AuthView: View {
    var body: some View {
        Button("Authenticate") {
            if let authURL = Authenticator.getAuthURL(scopes: [.profile, .email]) {
                print("Open URL: \(authURL)")
                UIApplication.shared.open(authURL)
            }
        }
        .padding()
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}

#Preview {
    AuthView()
}
