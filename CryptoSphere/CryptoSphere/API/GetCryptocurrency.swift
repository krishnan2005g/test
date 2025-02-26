import Foundation
import UIKit

struct Cryptocurrency: Codable {
    let name: String
    let symbol: String
    let price: String
    let logo: String
    let change24hPercent: String
    let change24hValue: String
}

class GetCryptocurrency {
    private var staticDetailsCache: [String: CoinDetails] = [:] // ✅ Use CoinDetails instead of CoinDetailsResponse
    
    func getData(symbol: String) async -> Cryptocurrency {
        print(symbol)
        
        do {
            let staticDetails: CoinDetails
            if let cachedDetails = staticDetailsCache[symbol] {
                staticDetails = cachedDetails // ✅ Use cached static details
            } else {
                staticDetails = try await CoinDetailsResponse().fetchOneCoinDetails(symbol: symbol)
                staticDetailsCache[symbol] = staticDetails // ✅ Cache the fetched data
            }
            
            do {
                let dynamicDetails = try await LivePriceResponse().fetchPrice(coinName: symbol).result.list.filter { $0.symbol == symbol }
                
                guard let firstDynamicDetail = dynamicDetails.first else {
                    throw CoinError.noData
                }

                return Cryptocurrency(
                    name: staticDetails.coinName,
                    symbol: staticDetails.coinSymbol,
                    price: firstDynamicDetail.lastPrice,
                    logo: staticDetails.imageUrl,
                    change24hPercent: firstDynamicDetail.price24hPcnt,
                    change24hValue: {
                        if let lastPrice = Double(firstDynamicDetail.lastPrice),
                           let prevPrice = Double(firstDynamicDetail.prevPrice24h) {
                            let change = lastPrice - prevPrice
                            return String(format: "%.2f", change) // Format to 2 decimal places
                        } else {
                            return "Error!"
                        }
                    }()

                )
            } catch {
                print("Error fetching live price data from LivePriceResponse: \(error.localizedDescription)")
            }
        } catch {
            print("Error fetching coin details from CoinDetailsResponse: \(error.localizedDescription)")
        }

        return Cryptocurrency(
            name: "ERROR!",
            symbol: "ERROR!",
            price: "ERROR!",
            logo: "ERROR!",
            change24hPercent: "Error!",
            change24hValue: "Error!"
        )
    }
}
//
//class GetCryptocurrency {
//    func getData(symbol: String) async -> Cryptocurrency {
//        print(symbol)
//        do {
//            let staticDetails = try await CoinDetailsResponse().fetchOneCoinDetails(symbol: symbol)
//            
//            do {
//                let dynamicDetails = try await LivePriceResponse().fetchPrice(coinName: symbol).result.list.filter { $0.symbol == symbol }
//                
//                guard let firstDynamicDetail = dynamicDetails.first else {
//                    throw CoinError.noData
//                }
//                
////                let change24hValue = (Int(firstDynamicDetail.lastPrice) ?? 0) - (Int(firstDynamicDetail.prevPrice24h) ?? 0)
//
//                return Cryptocurrency(
//                    name: staticDetails.coinName,
//                    symbol: staticDetails.coinSymbol,
//                    price: firstDynamicDetail.lastPrice,
//                    logo: staticDetails.imageUrl,
//                    change24hPercent: firstDynamicDetail.price24hPcnt,
//                    change24hValue: String((Int(firstDynamicDetail.lastPrice) ?? 0) - (Int(firstDynamicDetail.prevPrice24h) ?? 0))
//                )
//            } catch {
//                print("Error fetching live price data from LivePriceResponse: \(error.localizedDescription)")
//            }
//        } catch {
//            print("Error fetching coin details from CoinDetailsResponse: \(error.localizedDescription)")
//        }
//
//        return Cryptocurrency(
//            name: "ERROR!",
//            symbol: "ERROR!",
//            price: "ERROR!",
//            logo: "ERROR!",
//            change24hPercent: "Error!",
//            change24hValue: "Error!"
//        )
//    }
//}
