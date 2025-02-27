import Foundation

class CoinDetailsResponse{
    var baseURL = "https://spyer.pagekite.me/"
    
    func fetchAllCoinDetails() async throws -> [CoinDetails] {
        guard let url = URL(string: "\(baseURL)/coins") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode([CoinDetails].self, from: data)
        } catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode CoinDetails"))
        }
    }
    
    func fetchOneCoinDetails(symbol: String) async throws -> CoinDetails {
        guard let url = URL(string: "\(baseURL)/coins/\(symbol)") else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        do {
            return try JSONDecoder().decode(CoinDetails.self, from: data)
        } catch {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Failed to decode CoinDetails"))
        }
    }
    
    func getGenesisDate(for symbol: String) async -> Int64? {
        guard let coinListURL = URL(string: "\(baseURL)/getCoinName/\(symbol)") else { return nil }

        do {
            // Fetch coin name
            let (data, _) = try await URLSession.shared.data(from: coinListURL)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let coinName = json["coinName"] as? String {

                guard let coinDetailsURL = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinName.lowercased())") else { return nil }

                let (detailsData, _) = try await URLSession.shared.data(from: coinDetailsURL)
                
                if let detailsJson = try JSONSerialization.jsonObject(with: detailsData) as? [String: Any],
                   let genesisDate = detailsJson["genesis_date"] as? String {
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    if let date = formatter.date(from: genesisDate) {
                        return Int64(date.timeIntervalSince1970 * 1000)
                    }
                }
            }
        } catch {
            print("Errorrr: \(error)")
        }
        return nil
    }
}
