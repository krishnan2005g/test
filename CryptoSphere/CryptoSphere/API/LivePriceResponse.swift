import Foundation

struct CryptoResponse: Decodable {
    let result: CryptoMarket
}

struct CryptoMarket: Codable {
//    let category: String
    let list: [CryptoTicker]
}

struct CryptoTicker: Codable {
    let symbol: String
    let bid1Price: String
    let bid1Size: String
    let ask1Price: String
    let ask1Size: String
    let lastPrice: String //CurrentPrice
    let prevPrice24h: String
    let price24hPcnt: String //Change
    let highPrice24h: String
    let lowPrice24h: String
    let turnover24h: String//
    let volume24h: String//

}

struct BybitPreviousDataResponse: Decodable {
    let retCode: Int
    let retMsg: String
    let result: PreviousResult
    let retExtInfo: [String: String]
    let time : Int
    
    struct PreviousResult: Codable {
//        let category: String
        let list: [[String]]
    }
}

class LivePriceResponse{
    
    func fetchPrice(coinName: String) async throws -> CryptoResponse {
        let endpoint = "https://api.bybit.com/v5/market/tickers"
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            throw CoinError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "category", value: "spot"),
            URLQueryItem(name: "symbol", value: coinName.uppercased())
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
}
