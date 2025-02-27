import Foundation

enum CoinError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingError
    case rateLimitExceeded
    case invalidSymbol
    case noData
    case invaildData
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API endpoint"
        case .requestFailed: return "Request failed (status code: ...)"
        case .decodingError: return "Failed to parse response data"
        case .rateLimitExceeded: return "Too many requests - Binance rate limit exceeded"
        case .invalidSymbol: return "Invalid trading pair symbol"
        case .noData: return "No data returned from the server"
        case .invaildData: return "Invalid data returned from the server"
        }
    }
}
