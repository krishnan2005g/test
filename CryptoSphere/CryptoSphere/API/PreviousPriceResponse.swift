import Foundation

struct PreviousData: Decodable,Identifiable,Equatable {
    let time: Int
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    
    var id: Int {
        return self.time
    }
    
    var formattedTime: Date {
        return Date(timeIntervalSince1970: TimeInterval(time) / 1000)
    }
}

class PreviousPriceResponse{
    func fetchPreviousPrice(coinName: String, from: Int, to: Int, interval: String = "1") async throws -> [PreviousData] {
        let endpoint = "https://api.bybit.com/v5/market/kline"
        
        guard var urlComponents = URLComponents(string: endpoint) else {
            fatalError("Invalid URL")
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "category", value: "spot"),
            URLQueryItem(name: "symbol", value: coinName  == "ZOINUSDT" ? "BTCUSDT" : coinName),
            URLQueryItem(name: "interval", value: interval),
            URLQueryItem(name: "start", value: "\(from)"),
            URLQueryItem(name: "end", value: "\(to)"),
            URLQueryItem(name: "limit", value: "800"),
        ]
        
        guard let url = urlComponents.url else {
            throw CoinError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CoinError.requestFailed
        }
        switch httpResponse.statusCode{
        case 200:
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(BybitPreviousDataResponse.self, from: data)
            
            var result = [PreviousData]()
            
            for klineArray in apiResponse.result.list {
                guard klineArray.count >= 5,
                      let time = Int(klineArray[0]),
                      let open = Double(klineArray[1]),
                      let high = Double(klineArray[2]),
                      let low = Double(klineArray[3]),
                      let close = Double(klineArray[4]) else {
                    continue
                }
                result.append(PreviousData( time: time, open: open, high: high,low: low, close: close))
                // Example instance of PreviousData
//                let data = PreviousData( time: Int(1738733121268.201), open: open, high: high,low: low, close: close)
            }
            return result
            
        case 400:
            throw CoinError.invalidSymbol
        case 429:
            throw CoinError.rateLimitExceeded
        default:
            throw CoinError.requestFailed
        }
        
        
    }
}
